import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/network/json_first.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

abstract interface class IBedAvailabilityRemoteDataSource {
  Future<BedAvailabilitySummary?> fetchBedAvailability();

  /// Rincian kelas per jenis perawatan (`GET /Ket_Kamar/cari/{tipe}`).
  Future<List<WardClassAvailability>> fetchWardClassDetail(String jnsPerawatan);
}

class BedAvailabilityRemoteDataSource
    implements IBedAvailabilityRemoteDataSource {
  const BedAvailabilityRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<BedAvailabilitySummary?> fetchBedAvailability() async {
    // JSON murni (nol HTML): backend menjawab envelope
    // `{ruangan, kelas: [{ruangan, kelas, total, terisi, tersedia, ...}]}`.
    final response = await dioClient.get<dynamic>(
      ApiConstants.bedAvailability,
      queryParameters: {'_t': AppDateTime.now().millisecondsSinceEpoch},
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return null;
    final Object? payload = isEnvelopeMap(map) ? unwrapEnvelopeData(map) : map;
    return _summaryFromJson(payload);
  }

  BedAvailabilitySummary? _summaryFromJson(Object? payload) {
    if (payload is! Map<String, dynamic>) return null;
    final Object? rawKelas = payload['kelas'];
    if (rawKelas is! List) return null;
    final Map<String, List<WardClassAvailability>> grouped =
        <String, List<WardClassAvailability>>{};
    for (final Object? item in rawKelas) {
      if (item is! Map<String, dynamic>) continue;
      final String ruangan = (item['ruangan'] ?? payload['ruangan'] ?? '')
          .toString()
          .trim();
      if (ruangan.isEmpty || ruangan == 'SEMUA') continue;
      final String kelasLabel = item['kelas']?.toString().trim() ?? '';
      final int total = int.tryParse(item['total']?.toString() ?? '') ?? 0;
      final int occupied = int.tryParse(item['terisi']?.toString() ?? '') ?? 0;
      final int available =
          int.tryParse(item['tersedia']?.toString() ?? '') ??
          (total - occupied).clamp(0, total);
      grouped
          .putIfAbsent(ruangan, () => <WardClassAvailability>[])
          .add(
            WardClassAvailability(
              className: kelasLabel.isEmpty
                  ? 'Kelas Standar'
                  : 'Kelas $kelasLabel',
              availableBeds: available,
              totalBeds: total,
              occupiedBeds: occupied,
            ),
          );
    }
    if (grouped.isEmpty) return null;
    final List<WardAvailability> wards = <WardAvailability>[];
    for (final MapEntry<String, List<WardClassAvailability>> entry
        in grouped.entries) {
      final String rawType = entry.key;
      final bool isIcu =
          rawType.toUpperCase().contains('INTENSIF') ||
          rawType.toUpperCase().contains('ICU');
      wards.add(
        WardAvailability(
          id: rawType.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
          name: rawType,
          category: isIcu ? BedClass.icu : 'Umum',
          specialty: _mapSpecialty(rawType),
          floorBuilding: _mapBuilding(rawType),
          classBreakdown: entry.value,
          updatedAt: AppDateTime.now(),
          isRealtime: true,
        ),
      );
    }
    final int totalBeds = wards.fold(0, (sum, w) => sum + w.totalBeds);
    final int availableBeds = wards.fold(0, (sum, w) => sum + w.availableBeds);
    return BedAvailabilitySummary(
      totalBeds: totalBeds > 0 ? totalBeds : 142,
      availableBeds: availableBeds,
      wards: wards,
    );
  }

  /// Rincian kelas kamar per jenis perawatan (`GET /Ket_Kamar/cari/{tipe}`,
  /// JSON murni). Gagal/acak → daftar kosong (UI menampilkan status kosong).
  @override
  Future<List<WardClassAvailability>> fetchWardClassDetail(
    String jnsPerawatan,
  ) async {
    final encoded = Uri.encodeComponent(jnsPerawatan);
    final response = await dioClient.get<dynamic>(
      '${ApiConstants.bedAvailability}/cari/$encoded',
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return const [];
    final Object? payload = isEnvelopeMap(map) ? unwrapEnvelopeData(map) : map;
    if (payload is Map<String, dynamic>) {
      final Object? rawKelas = payload['kelas'];
      if (rawKelas is List) {
        return rawKelas
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> m) => WardClassAvailability(
                className: 'Kelas ${m['kelas']?.toString() ?? ''}'.trim(),
                availableBeds:
                    int.tryParse(m['tersedia']?.toString() ?? '') ?? 0,
                totalBeds: int.tryParse(m['total']?.toString() ?? ''),
                occupiedBeds: int.tryParse(m['terisi']?.toString() ?? ''),
              ),
            )
            .toList();
      }
    }
    return const [];
  }

  String _mapSpecialty(String rawType) {
    final upper = rawType.toUpperCase();
    if (upper.contains('ANAK') || upper.contains('BAYI')) return 'Pediatri';
    if (upper.contains('KEBIDANAN')) return 'Obstetri & Ginekologi';
    if (upper.contains('BEDAH')) return 'Bedah';
    if (upper.contains('KUSTA')) return 'Dermatologi Kusta';
    if (upper.contains('PARU')) return 'Pulmonologi';
    if (upper.contains('NEURO')) return 'Neurologi';
    if (upper.contains('INTENSIF') || upper.contains('ICU')) {
      return 'Perawatan Intensif';
    }
    return 'Penyakit Dalam & Umum';
  }

  String _mapBuilding(String rawType) {
    final upper = rawType.toUpperCase();
    if (upper.contains('INTENSIF') || upper.contains('ICU')) {
      return 'Gedung ICU Sentral';
    }
    if (upper.contains('KEBIDANAN')) return 'Gedung Srikandi';
    if (upper.contains('ANAK')) return 'Gedung Arjuna';
    return 'Gedung Rawat Inap Terpadu';
  }
}
