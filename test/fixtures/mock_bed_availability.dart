import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

/// Test fixture mock ketersediaan tempat tidur rawat inap RSUP Dr. Sitanala
/// khusus untuk pengujian terisolasi (test only).
class MockBedAvailabilityFixture {
  const MockBedAvailabilityFixture._();

  static List<WardAvailability> getSampleWards() {
    final now = DateTime.now();
    return <WardAvailability>[
      WardAvailability(
        id: 'melati',
        name: 'Ruang Melati (Dewasa)',
        category: 'Umum',
        specialty: 'Penyakit Dalam',
        floorBuilding: 'Lantai 3 Gedung B',
        updatedAt: now.subtract(const Duration(minutes: 15)),
        classBreakdown: const <WardClassAvailability>[
          WardClassAvailability(
            className: BedClass.class1,
            availableBeds: 2,
            totalBeds: 10,
            occupiedBeds: 8,
          ),
          WardClassAvailability(
            className: BedClass.class2,
            availableBeds: 1,
            totalBeds: 10,
            occupiedBeds: 9,
          ),
          WardClassAvailability(
            className: BedClass.class3,
            availableBeds: 3,
            totalBeds: 15,
            occupiedBeds: 12,
          ),
        ],
      ),
      WardAvailability(
        id: 'dahlia',
        name: 'Ruang Dahlia (Anak)',
        category: 'Umum',
        specialty: 'Pediatri',
        floorBuilding: 'Lantai 2 Gedung B',
        updatedAt: now.subtract(const Duration(minutes: 20)),
        classBreakdown: const <WardClassAvailability>[
          WardClassAvailability(
            className: BedClass.class2,
            availableBeds: 2,
            totalBeds: 8,
            occupiedBeds: 6,
          ),
          WardClassAvailability(
            className: BedClass.class3,
            availableBeds: 3,
            totalBeds: 12,
            occupiedBeds: 9,
          ),
        ],
      ),
      WardAvailability(
        id: 'icu-sentral',
        name: 'ICU Sentral',
        category: BedClass.icu,
        specialty: 'Intensif & Ventilator',
        floorBuilding: 'Lantai 1 Gedung A',
        updatedAt: now,
        isRealtime: true,
        classBreakdown: const <WardClassAvailability>[
          WardClassAvailability(
            className: BedClass.icu,
            availableBeds: 0,
            totalBeds: 6,
            occupiedBeds: 6,
          ),
        ],
      ),
    ];
  }

  static BedAvailabilitySummary getSampleSummary() {
    final wards = getSampleWards();
    return BedAvailabilitySummary(
      totalBeds: AppConstants.hospitalTotalBeds,
      availableBeds: AppConstants.defaultAvailableBeds,
      wards: wards,
    );
  }
}
