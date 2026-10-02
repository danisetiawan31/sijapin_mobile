import 'package:html/parser.dart' as html_parser;
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';

abstract interface class IDoctorScheduleRemoteDataSource {
  Future<List<Polyclinic>> fetchPolyclinics();
  Future<List<DoctorSchedule>> fetchDoctorSchedules({int? unitId});
}

class DoctorScheduleRemoteDataSource
    implements IDoctorScheduleRemoteDataSource {
  const DoctorScheduleRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<Polyclinic>> fetchPolyclinics() async {
    try {
      final response = await dioClient.get<String>(
        '/jadwal_dokter',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );

      final html = response.data;
      if (html == null || html.isEmpty) return _defaultPolyclinics;

      final document = html_parser.parse(html);
      final cards = document.querySelectorAll('.ruangan-card, .keterangan-cards');
      final List<Polyclinic> clinics = [];
      final Set<int> seenIds = {};

      for (final card in cards) {
        final titleEl = card.querySelector('.card-title') ?? card.querySelector('h5');
        final anchorEl = card.querySelector('a');
        final rawTitle = titleEl?.text.trim() ?? '';
        final href = anchorEl?.attributes['href'] ?? '';

        final idMatch = RegExp(r'Jadwal_Dokter/cari/(\d+)').firstMatch(href);
        if (idMatch != null) {
          final id = int.tryParse(idMatch.group(1) ?? '') ?? 0;
          if (id > 0 && !seenIds.contains(id)) {
            seenIds.add(id);
            clinics.add(
              Polyclinic(
                id: id,
                name: rawTitle,
                code: _mapCode(rawTitle),
                bpjsCode: _mapBpjsCode(rawTitle, id),
                floor: _mapFloor(id),
                description: 'Pelayanan poli spesialis $rawTitle',
              ),
            );
          }
        }
      }

      return clinics.isNotEmpty ? clinics : _defaultPolyclinics;
    } catch (_) {
      return _defaultPolyclinics;
    }
  }

  @override
  Future<List<DoctorSchedule>> fetchDoctorSchedules({int? unitId}) async {
    try {
      final clinics = unitId != null
          ? [Polyclinic(id: unitId, name: 'Poli Spesialis')]
          : await fetchPolyclinics();

      final List<DoctorSchedule> allDoctors = [];
      final Set<String> seenDoctorUnit = {};

      for (final clinic in clinics) {
        final encodedName = Uri.encodeComponent(clinic.name);
        final response = await dioClient.get<String>(
          '/Jadwal_Dokter/cari/${clinic.id}/$encodedName',
        );

        final html = response.data;
        if (html == null || html.isEmpty) continue;

        final document = html_parser.parse(html);
        final doctorTitles = document.querySelectorAll('h1.card-title, .card h1');
        final tables = document.querySelectorAll('table');

        final count = doctorTitles.length < tables.length
            ? doctorTitles.length
            : tables.length;

        for (var i = 0; i < count; i++) {
          final docName = doctorTitles[i].text.trim();
          if (docName.isEmpty) continue;

          final uniqueKey = '${clinic.id}_$docName';
          if (seenDoctorUnit.contains(uniqueKey)) continue;
          seenDoctorUnit.add(uniqueKey);

          final table = tables[i];
          final cells = table.querySelectorAll('tbody tr td');

          final List<DoctorScheduleEntry> entries = [];
          final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

          for (var dayIdx = 0; dayIdx < days.length && dayIdx < cells.length; dayIdx++) {
            final cellText = cells[dayIdx].text.trim();
            final isLibur = cellText.toLowerCase().contains('libur') ||
                cellText.isEmpty ||
                cellText == '-';

            String startTime = '';
            if (!isLibur) {
              final timeMatch =
                  RegExp(r'(\d{2}:\d{2})').firstMatch(cellText);
              startTime = timeMatch?.group(1) ?? '08:00';
            }

            entries.add(
              DoctorScheduleEntry(
                day: days[dayIdx],
                hariId: dayIdx + 1,
                startTime: isLibur ? '' : startTime,
                endTime: isLibur ? '' : '12:00',
                isLibur: isLibur,
              ),
            );
          }

          final isFemale = docName.toLowerCase().contains('dr. maria') ||
              docName.toLowerCase().contains('dr. era') ||
              docName.toLowerCase().contains('dr. eka') ||
              docName.toLowerCase().contains('dr. siti') ||
              docName.toLowerCase().contains('dr. prima');

          allDoctors.add(
            DoctorSchedule(
              id: 'doc_${clinic.id}_${i + 1}',
              name: docName,
              specialization: 'Spesialis ${clinic.name}',
              poli: clinic.name,
              unitId: clinic.id,
              gender: isFemale ? 'P' : 'L',
              schedules: entries,
              status: entries.any((e) => e.isAvailable)
                  ? DoctorPracticeStatus.reguler
                  : DoctorPracticeStatus.libur,
            ),
          );
        }
      }

      return allDoctors;
    } catch (_) {
      return const [];
    }
  }

  static String _mapCode(String unitName) {
    final lower = unitName.toLowerCase();
    if (lower.contains('dalam')) return 'PDI';
    if (lower.contains('kandungan') || lower.contains('kebidanan')) return 'OBG';
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
    if (lower.contains('kandungan') || lower.contains('kebidanan')) return 'OBG';
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

  static const List<Polyclinic> _defaultPolyclinics = [
    Polyclinic(
      id: 1,
      name: 'Penyakit Dalam',
      code: 'PDI',
      bpjsCode: 'INT',
      floor: 'Lantai 1',
      description: 'Layanan spesialis penyakit dalam & organ tubuh',
    ),
    Polyclinic(
      id: 2,
      name: 'Kebidanan & Kandungan',
      code: 'OBG',
      bpjsCode: 'OBG',
      floor: 'Lantai 2',
      description: 'Antenatal care (ANC), USG, ginekologi, & KB',
    ),
    Polyclinic(
      id: 3,
      name: 'Anak',
      code: 'ANA',
      bpjsCode: 'ANA',
      floor: 'Lantai 1',
      description: 'Tumbuh kembang anak, imunisasi dasar, & pediatri',
    ),
    Polyclinic(
      id: 4,
      name: 'Bedah Umum',
      code: 'BED',
      bpjsCode: 'BED',
      floor: 'Lantai 2',
      description: 'Konsultasi & tindakan bedah umum',
    ),
    Polyclinic(
      id: 5,
      name: 'Gigi',
      code: 'GIG',
      bpjsCode: 'GND',
      floor: 'Lantai 1',
      description: 'Konservasi gigi, bedah mulut, & periodonsia',
    ),
    Polyclinic(
      id: 29,
      name: 'Mata',
      code: 'MAT',
      bpjsCode: 'MAT',
      floor: 'Lantai 2',
      description: 'Pemeriksaan refraksi, katarak, glaukoma, & retina',
    ),
    Polyclinic(
      id: 30,
      name: 'Paru',
      code: 'PAR',
      bpjsCode: 'PAR',
      floor: 'Lantai 2',
      description: 'Pemeriksaan paru, asma, & penyakit pernapasan',
    ),
    Polyclinic(
      id: 43,
      name: 'Saraf',
      code: 'SAR',
      bpjsCode: 'SAR',
      floor: 'Lantai 2',
      description: 'Pemeriksaan saraf, stroke, vertigo, & neurologi',
    ),
  ];
}
