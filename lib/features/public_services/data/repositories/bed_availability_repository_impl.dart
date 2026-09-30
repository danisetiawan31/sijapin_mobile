import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/domain/repositories/bed_availability_repository.dart';

/// Implementasi repository ketersediaan kamar dengan data lokal/sampel.
///
/// Mengikuti pola `DoctorScheduleRepositoryImpl` — data dummy sesuai
/// referensi visual `stitch_design/Ketersedian-Kamar/screen.png`.
/// Siap diganti dengan implementasi backend `Ket_Kamar` endpoint CI3.
class BedAvailabilityRepositoryImpl implements BedAvailabilityRepository {
  const BedAvailabilityRepositoryImpl();

  @override
  Future<BedAvailabilitySummary> getBedAvailability({
    String? classFilter,
  }) async {
    // Simulasi delay jaringan
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final allWards = _getSampleWards();

    // Filter berdasarkan kelas (presence-based, Keputusan Q2)
    var filtered = allWards;
    if (classFilter != null && classFilter != 'Semua Kelas') {
      if (classFilter == 'ICU') {
        filtered = filtered.where((w) => w.category == 'ICU').toList();
      } else {
        filtered = filtered
            .where(
              (w) => w.classBreakdown.any(
                (c) => c.className == classFilter && c.availableBeds > 0,
              ),
            )
            .toList();
      }
    }

    return BedAvailabilitySummary(
      totalBeds: 142,
      availableBeds: 18,
      wards: filtered,
    );
  }

  @override
  Future<WardAvailability?> getWardById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final allWards = _getSampleWards();
    try {
      return allWards.firstWhere((w) => w.id == id);
    } on StateError {
      return null;
    }
  }

  /// Data sampel — sesuai referensi visual (screenshot + code.html).
  List<WardAvailability> _getSampleWards() {
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
}
