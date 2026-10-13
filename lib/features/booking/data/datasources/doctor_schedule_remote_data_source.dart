import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/network/json_first.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';

abstract interface class IDoctorScheduleRemoteDataSource {
  Future<List<Polyclinic>> fetchPolyclinics();
  Future<List<DoctorSchedule>> fetchDoctorSchedules({int? unitId});
}

/// Label hari operasional koleksi JSON (kunci uppercase dari backend).
const List<String> _dayOrder = <String>[
  'SENIN',
  'SELASA',
  'RABU',
  'KAMIS',
  'JUMAT',
  'SABTU',
  'MINGGU',
];

const Map<String, String> _dayLabels = <String, String>{
  'SENIN': 'Senin',
  'SELASA': 'Selasa',
  'RABU': 'Rabu',
  'KAMIS': 'Kamis',
  'JUMAT': 'Jumat',
  'SABTU': 'Sabtu',
  'MINGGU': 'Minggu',
};

class DoctorScheduleRemoteDataSource
    implements IDoctorScheduleRemoteDataSource {
  const DoctorScheduleRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<Polyclinic>> fetchPolyclinics() async {
    // JSON murni (nol HTML): `GET /Jadwal_Dokter` → envelope data
    // `[{UNIT_ID, NAMA_UNIT}]` (`M_jadwal::get_unit_rows`).
    final response = await dioClient.get<dynamic>(
      ApiConstants.doctorSchedule,
      queryParameters: {'_t': AppDateTime.now().millisecondsSinceEpoch},
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return const [];
    final Object? payload = isEnvelopeMap(map)
        ? unwrapEnvelopeData(map)
        : map['data'] ?? map;
    if (payload is List) return _clinicsFromJson(payload);
    return const [];
  }

  List<Polyclinic> _clinicsFromJson(List<Object?> raw) {
    final List<Polyclinic> clinics = <Polyclinic>[];
    final Set<int> seenIds = <int>{};
    for (final Object? item in raw) {
      if (item is! Map) continue;
      final int id =
          int.tryParse(item['UNIT_ID']?.toString() ?? '') ??
          int.tryParse(item['id_unit']?.toString() ?? '') ??
          0;
      final String name = (item['NAMA_UNIT'] ?? item['nama_unit'] ?? '')
          .toString()
          .trim();
      if (id <= 0 || name.isEmpty || seenIds.contains(id)) continue;
      seenIds.add(id);
      clinics.add(
        Polyclinic(
          id: id,
          name: name,
          code: _mapCode(name),
          bpjsCode: _mapBpjsCode(name, id),
          floor: _mapFloor(id),
          description: 'Pelayanan poli spesialis $name',
        ),
      );
    }
    return clinics;
  }

  @override
  Future<List<DoctorSchedule>> fetchDoctorSchedules({int? unitId}) async {
    // JSON murni (nol HTML): per-unit `GET /Jadwal_Dokter/cari/{id}` →
    // envelope data `[{NAMA_DOKTER, SENIN..MINGGU}]` (`jadwal_normalize_rows`).
    final List<Polyclinic> clinics = unitId != null
        ? <Polyclinic>[Polyclinic(id: unitId, name: '')]
        : await fetchPolyclinics();
    final List<DoctorSchedule> allDoctors = <DoctorSchedule>[];
    final Set<String> seenDoctorUnit = <String>{};
    for (final Polyclinic clinic in clinics) {
      final doctors = await _fetchDoctorsJson(
        unitId: clinic.id,
        clinicName: clinic.name,
        seen: seenDoctorUnit,
      );
      allDoctors.addAll(doctors);
    }
    return allDoctors;
  }

  Future<List<DoctorSchedule>> _fetchDoctorsJson({
    required int unitId,
    required String clinicName,
    required Set<String> seen,
  }) async {
    final String suffix = clinicName.isEmpty
        ? ''
        : '/${Uri.encodeComponent(clinicName)}';
    final response = await dioClient.get<dynamic>(
      '${ApiConstants.doctorSchedule}/cari/$unitId$suffix',
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return const [];
    final Object? payload = isEnvelopeMap(map)
        ? unwrapEnvelopeData(map)
        : map['data'] ?? map;
    if (payload is! List) return const [];
    final List<DoctorSchedule> doctors = <DoctorSchedule>[];
    for (final Object? item in payload) {
      if (item is! Map) continue;
      final String docName = (item['NAMA_DOKTER'] ?? item['nama_dokter'] ?? '')
          .toString()
          .trim();
      if (docName.isEmpty) continue;
      final String key = '${unitId}_$docName';
      if (seen.contains(key)) continue;
      seen.add(key);
      final List<DoctorScheduleEntry> entries = <DoctorScheduleEntry>[];
      for (var i = 0; i < _dayOrder.length; i++) {
        final String dayKey = _dayOrder[i];
        final String raw = (item[dayKey] ?? item[dayKey.toLowerCase()] ?? '')
            .toString()
            .trim();
        final bool isLibur =
            raw.isEmpty || raw == '-' || raw.toLowerCase().contains('libur');
        final String start = isLibur
            ? ''
            : (RegExp(r'(\d{2}:\d{2})').firstMatch(raw)?.group(1) ?? raw);
        entries.add(
          DoctorScheduleEntry(
            day: _dayLabels[dayKey]!,
            hariId: i + 1,
            startTime: start,
            endTime: isLibur ? '' : '12:00',
            isLibur: isLibur,
          ),
        );
      }
      doctors.add(
        DoctorSchedule(
          id: 'doc_${unitId}_${seen.length}',
          name: docName,
          specialization: clinicName.isEmpty
              ? 'Spesialis'
              : 'Spesialis $clinicName',
          poli: clinicName,
          unitId: unitId,
          gender: _guessGender(docName),
          schedules: entries,
          status: entries.any((e) => e.isAvailable)
              ? DoctorPracticeStatus.reguler
              : DoctorPracticeStatus.libur,
        ),
      );
    }
    return doctors;
  }

  String _guessGender(String docName) {
    final lower = docName.toLowerCase();
    if (lower.contains('maria') ||
        lower.contains(' era') ||
        lower.contains(' eka') ||
        lower.contains(' siti') ||
        lower.contains(' prima') ||
        lower.contains(' dewi') ||
        lower.contains(' rina')) {
      return 'P';
    }
    return 'L';
  }

  static String _mapCode(String unitName) {
    final lower = unitName.toLowerCase();
    if (lower.contains('dalam')) return 'PDI';
    if (lower.contains('kandungan') || lower.contains('kebidanan')) {
      return 'OBG';
    }
    if (lower.contains('anak')) return 'ANA';
    if (lower.contains('bedah')) return 'BED';
    if (lower.contains('gigi')) return 'GIG';
    if (lower.contains('mata')) return 'MAT';
    if (lower.contains('paru')) return 'PAR';
    if (lower.contains('saraf')) return 'SAR';
    if (lower.contains('kulit') || lower.contains('kusta')) return 'KLT';
    if (lower.contains('jiwa')) return 'JIW';
    if (lower.contains('jantung')) return 'JAN';
    if (lower.contains('tht')) return 'THT';
    return 'UMU';
  }

  static String _mapBpjsCode(String unitName, int id) {
    final lower = unitName.toLowerCase();
    if (lower.contains('dalam')) return 'INT';
    if (lower.contains('kandungan') || lower.contains('kebidanan')) {
      return 'OBG';
    }
    if (lower.contains('anak')) return 'ANA';
    if (lower.contains('bedah')) return 'BED';
    if (lower.contains('gigi')) return 'GND';
    if (lower.contains('mata')) return 'MAT';
    if (lower.contains('paru')) return 'PAR';
    if (lower.contains('saraf')) return 'SAR';
    if (lower.contains('kulit') || lower.contains('kusta')) return 'KLT';
    if (lower.contains('jiwa')) return 'JIW';
    if (lower.contains('jantung')) return 'JAN';
    if (lower.contains('tht')) return 'THT';
    return 'POL-$id';
  }

  static String _mapFloor(int id) {
    if (id <= 5) return 'Lantai 1';
    if (id <= 30) return 'Lantai 2';
    return 'Lantai 3';
  }
}
