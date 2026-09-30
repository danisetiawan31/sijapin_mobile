import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

/// Data fixture mock ketersediaan tempat tidur rawat inap RSUP Dr. Sitanala.
///
/// Merujuk pada struktur data SIRANAP Kemenkes & SIMRS Rawat Inap RSUP Dr. Sitanala:
/// - Kapasitas Total RS: 142 tempat tidur
/// - Bed Siap Huni Total RS: 18 tempat tidur (BOR 87.3%)
/// - Data bangsal di bawah ini merepresentasikan unit sampel yang dipantau.
List<WardAvailability> getSampleWards() {
  final now = DateTime.now();
  return <WardAvailability>[
    // Ruang 1: Melati (Dewasa) — 6 bed kosong
    WardAvailability(
      id: 'melati',
      name: 'Ruang Melati (Dewasa)',
      category: 'Umum',
      specialty: 'Penyakit Dalam',
      floorBuilding: 'Lantai 3 Gedung B',
      updatedAt: now.subtract(const Duration(minutes: 15)),
      classBreakdown: const <WardClassAvailability>[
        WardClassAvailability(className: 'Kelas 1', availableBeds: 2),
        WardClassAvailability(className: 'Kelas 2', availableBeds: 1),
        WardClassAvailability(className: 'Kelas 3', availableBeds: 3),
      ],
    ),

    // Ruang 2: Dahlia (Anak) — 5 bed kosong
    WardAvailability(
      id: 'dahlia',
      name: 'Ruang Dahlia (Anak)',
      category: 'Umum',
      specialty: 'Pediatri',
      floorBuilding: 'Lantai 2 Gedung B',
      updatedAt: now.subtract(const Duration(minutes: 20)),
      classBreakdown: const <WardClassAvailability>[
        WardClassAvailability(className: 'Kelas 2', availableBeds: 2),
        WardClassAvailability(className: 'Kelas 3', availableBeds: 3),
      ],
    ),

    // Ruang 3: ICU Sentral — penuh (0 bed)
    WardAvailability(
      id: 'icu-sentral',
      name: 'ICU Sentral',
      category: 'ICU',
      specialty: 'Intensif & Ventilator',
      floorBuilding: 'Lantai 1 Gedung A',
      updatedAt: now,
      isRealtime: true,
      classBreakdown: const <WardClassAvailability>[
        WardClassAvailability(className: 'ICU', availableBeds: 0),
      ],
    ),
  ];
}
