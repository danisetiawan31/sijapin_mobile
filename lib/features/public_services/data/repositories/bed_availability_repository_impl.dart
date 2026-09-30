import 'package:sijapin_mobile/features/public_services/data/datasources/bed_availability_mock_data.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/domain/repositories/bed_availability_repository.dart';

/// Implementasi repository ketersediaan kamar rawat inap RSUP Dr. Sitanala.
class BedAvailabilityRepositoryImpl implements BedAvailabilityRepository {
  const BedAvailabilityRepositoryImpl();

  @override
  Future<BedAvailabilitySummary> getBedAvailability({
    String? classFilter,
  }) async {
    // Simulasi latensi jaringan
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final allWards = getSampleWards();

    // Filter berdasarkan kelas
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
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final allWards = getSampleWards();
    try {
      return allWards.firstWhere((w) => w.id == id);
    } on StateError {
      return null;
    }
  }
}
