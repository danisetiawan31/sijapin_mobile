import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

void main() {
  group('BedAvailabilitySummary Entity Tests', () {
    test('kalkulasi occupiedBeds dan borPercent akurat', () {
      const summary = BedAvailabilitySummary(
        totalBeds: 100,
        availableBeds: 20,
        wards: [],
      );

      expect(summary.occupiedBeds, 80);
      expect(summary.borPercent, 80.0);
      expect(summary.monitoredUnits, 0);
      expect(summary.visibleAvailableBeds, 0);
    });

    test('borPercent aman dari pembagian dengan nol saat totalBeds = 0', () {
      const summary = BedAvailabilitySummary(
        totalBeds: 0,
        availableBeds: 0,
        wards: [],
      );

      expect(summary.occupiedBeds, 0);
      expect(summary.borPercent, 0.0);
    });

    test('visibleAvailableBeds menjumlahkan seluruh bed kosong pada daftar bangsal', () {
      final now = DateTime.now();
      final ward1 = WardAvailability(
        id: 'w1',
        name: 'Ruang 1',
        category: 'Umum',
        specialty: 'Umum',
        floorBuilding: 'Lantai 1',
        updatedAt: now,
        classBreakdown: const [
          WardClassAvailability(className: 'Kelas 1', availableBeds: 3),
          WardClassAvailability(className: 'Kelas 2', availableBeds: 4),
        ],
      );
      final ward2 = WardAvailability(
        id: 'w2',
        name: 'Ruang 2',
        category: 'Umum',
        specialty: 'Umum',
        floorBuilding: 'Lantai 2',
        updatedAt: now,
        classBreakdown: const [
          WardClassAvailability(className: 'Kelas 3', availableBeds: 5),
        ],
      );

      final summary = BedAvailabilitySummary(
        totalBeds: 142,
        availableBeds: 18,
        wards: [ward1, ward2],
      );

      expect(summary.monitoredUnits, 2);
      expect(summary.visibleAvailableBeds, 12);
    });

    test('copyWith, operator ==, dan hashCode bekerja dengan benar', () {
      const s1 = BedAvailabilitySummary(
        totalBeds: 100,
        availableBeds: 20,
        wards: [],
      );
      final s2 = s1.copyWith(availableBeds: 25);
      const s3 = BedAvailabilitySummary(
        totalBeds: 100,
        availableBeds: 20,
        wards: [],
      );

      expect(s2.availableBeds, 25);
      expect(s1 == s3, isTrue);
      expect(s1.hashCode, equals(s3.hashCode));
      expect(s1 == s2, isFalse);
    });
  });

  group('WardAvailability Entity Tests', () {
    test('availableBeds, isFull, dan status terhitung akurat', () {
      final now = DateTime.now();
      final availableWard = WardAvailability(
        id: 'w1',
        name: 'Ruang Melati',
        category: 'Umum',
        specialty: 'Penyakit Dalam',
        floorBuilding: 'Lantai 3',
        updatedAt: now,
        classBreakdown: const [
          WardClassAvailability(className: 'Kelas 1', availableBeds: 2),
          WardClassAvailability(className: 'Kelas 2', availableBeds: 1),
        ],
      );

      expect(availableWard.availableBeds, 3);
      expect(availableWard.isFull, isFalse);
      expect(availableWard.status, WardStatus.available);

      final fullWard = WardAvailability(
        id: 'icu',
        name: 'ICU',
        category: 'ICU',
        specialty: 'Intensif',
        floorBuilding: 'Lantai 1',
        updatedAt: now,
        classBreakdown: const [
          WardClassAvailability(className: 'ICU', availableBeds: 0),
        ],
      );

      expect(fullWard.availableBeds, 0);
      expect(fullWard.isFull, isTrue);
      expect(fullWard.status, WardStatus.full);
    });

    test('highlightedClass memilih kelas dengan ketersediaan terbanyak', () {
      final now = DateTime.now();
      final ward = WardAvailability(
        id: 'w1',
        name: 'Ruang Melati',
        category: 'Umum',
        specialty: 'Penyakit Dalam',
        floorBuilding: 'Lantai 3',
        updatedAt: now,
        classBreakdown: const [
          WardClassAvailability(className: 'Kelas 1', availableBeds: 2),
          WardClassAvailability(className: 'Kelas 2', availableBeds: 5),
          WardClassAvailability(className: 'Kelas 3', availableBeds: 1),
        ],
      );

      expect(ward.highlightedClass, 'Kelas 2');

      final emptyWard = WardAvailability(
        id: 'w2',
        name: 'Ruang Kosong',
        category: 'Umum',
        specialty: 'Penyakit Dalam',
        floorBuilding: 'Lantai 1',
        updatedAt: now,
        classBreakdown: const [
          WardClassAvailability(className: 'Kelas 1', availableBeds: 0),
        ],
      );

      expect(emptyWard.highlightedClass, isNull);
    });
  });
}
