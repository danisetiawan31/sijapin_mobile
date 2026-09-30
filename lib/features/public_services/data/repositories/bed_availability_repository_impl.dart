import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/features/public_services/data/datasources/bed_availability_mock_data.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/domain/repositories/bed_availability_repository.dart';

/// Implementasi repository ketersediaan kamar rawat inap RSUP Dr. Sitanala.
///
/// Seluruh parameter numerik default merujuk pada [AppConstants], sedangkan kelas perawatan
/// merujuk pada domain entity [BedClass] untuk memfasilitasi migrasi seamless ke endpoint SIMRS / Database.
class BedAvailabilityRepositoryImpl implements BedAvailabilityRepository {
  const BedAvailabilityRepositoryImpl();

  @override
  Future<BedAvailabilitySummary> getBedAvailability({
    String? classFilter,
  }) async {
    // Simulasi latensi jaringan (pada fase migrasi backend, blok ini digantikan HTTP/REST client)
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final allWards = BedAvailabilityMockData.getSampleWards();

    // Filter berdasarkan kelas perawatan
    var filtered = allWards;
    if (classFilter != null && classFilter != BedClass.all) {
      if (classFilter == BedClass.icu) {
        filtered = filtered.where((w) => w.category == BedClass.icu).toList();
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
      totalBeds: AppConstants.hospitalTotalBeds,
      availableBeds: AppConstants.defaultAvailableBeds,
      wards: filtered,
    );
  }

  @override
  Future<WardAvailability?> getWardById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final allWards = BedAvailabilityMockData.getSampleWards();
    try {
      return allWards.firstWhere((w) => w.id == id);
    } on StateError {
      return null;
    }
  }
}
