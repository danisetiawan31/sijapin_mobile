import 'package:html/parser.dart' as html_parser;
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

abstract interface class IBedAvailabilityRemoteDataSource {
  Future<BedAvailabilitySummary?> fetchBedAvailability();
}

class BedAvailabilityRemoteDataSource
    implements IBedAvailabilityRemoteDataSource {
  const BedAvailabilityRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<BedAvailabilitySummary?> fetchBedAvailability() async {
    try {
      final response = await dioClient.get<String>(
        '/ket_kamar',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );

      final html = response.data;
      if (html == null || html.isEmpty) return null;

      final document = html_parser.parse(html);
      final cards = document.querySelectorAll(
        '.ketersediaan-kamar-cards, .card',
      );

      final List<WardAvailability> wards = [];
      final Set<String> seenTypes = {};

      for (final card in cards) {
        final titleEl = card.querySelector('.ket-kamar-title') ??
            card.querySelector('.card-title') ??
            card.querySelector('h5');
        final rawType = titleEl?.text.trim() ?? '';
        if (rawType.isEmpty || seenTypes.contains(rawType)) continue;
        seenTypes.add(rawType);

        final imgEl = card.querySelector('img');
        final logoUrl = imgEl?.attributes['src'];

        // Ambil rincian kelas kamar untuk jenis perawatan ini
        final classes = await _fetchWardClassDetail(rawType);

        final isIcu = rawType.toUpperCase().contains('INTENSIF') ||
            rawType.toUpperCase().contains('ICU');

        wards.add(
          WardAvailability(
            id: rawType.toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
            name: rawType,
            category: isIcu ? BedClass.icu : 'Umum',
            specialty: _mapSpecialty(rawType),
            floorBuilding: _mapBuilding(rawType),
            classBreakdown: classes,
            updatedAt: DateTime.now(),
            isRealtime: true,
            logoUrl: (logoUrl != null && logoUrl.isNotEmpty) ? logoUrl : null,
          ),
        );
      }

      if (wards.isEmpty) return null;

      final totalBeds = wards.fold(0, (sum, w) => sum + w.totalBeds);
      final availableBeds = wards.fold(0, (sum, w) => sum + w.availableBeds);

      return BedAvailabilitySummary(
        totalBeds: totalBeds > 0 ? totalBeds : 142,
        availableBeds: availableBeds,
        wards: wards,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<WardClassAvailability>> _fetchWardClassDetail(
    String jnsPerawatan,
  ) async {
    try {
      final encoded = Uri.encodeComponent(jnsPerawatan);
      final response = await dioClient.get<String>(
        '/Ket_Kamar/cari/$encoded',
      );

      final html = response.data;
      if (html == null || html.isEmpty) return const [];

      final document = html_parser.parse(html);
      final List<WardClassAvailability> classList = [];

      final tables = document.querySelectorAll('table');
      final headers = document.querySelectorAll('h2');

      for (var i = 0; i < tables.length; i++) {
        final table = tables[i];
        String className = 'Kelas Standar';
        if (i < headers.length) {
          final h2Text = headers[i].text.replaceAll('Kelas', '').trim();
          if (h2Text.isNotEmpty) className = 'Kelas $h2Text';
        }

        final cells = table.querySelectorAll('tbody tr td');
        if (cells.length >= 3) {
          final totalStr = RegExp(r'\d+').firstMatch(cells[0].text)?.group(0);
          final occupiedStr =
              RegExp(r'\d+').firstMatch(cells[1].text)?.group(0);
          final availableStr =
              RegExp(r'\d+').firstMatch(cells[2].text)?.group(0);

          final total = int.tryParse(totalStr ?? '0') ?? 0;
          final occupied = int.tryParse(occupiedStr ?? '0') ?? 0;
          final available = int.tryParse(availableStr ?? '0') ?? 0;

          classList.add(
            WardClassAvailability(
              className: className,
              availableBeds: available,
              totalBeds: total,
              occupiedBeds: occupied,
            ),
          );
        }
      }

      return classList;
    } catch (_) {
      return const [];
    }
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
