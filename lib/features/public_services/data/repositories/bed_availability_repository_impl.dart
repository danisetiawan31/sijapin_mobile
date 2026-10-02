import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/features/public_services/data/datasources/bed_availability_remote_data_source.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/domain/repositories/bed_availability_repository.dart';

/// Implementasi repository ketersediaan kamar rawat inap RSUP Dr. Sitanala
/// yang terhubung langsung ke backend CI3 SIMRS dengan network-first caching.
class BedAvailabilityRepositoryImpl implements BedAvailabilityRepository {
  BedAvailabilityRepositoryImpl({
    this.remoteDataSource,
    BedAvailabilitySummary? initialSummary,
  }) : _cachedSummary = initialSummary;

  final IBedAvailabilityRemoteDataSource? remoteDataSource;
  BedAvailabilitySummary? _cachedSummary;

  @override
  Future<BedAvailabilitySummary> getBedAvailability({
    String? classFilter,
  }) async {
    if (remoteDataSource != null) {
      try {
        final remoteSummary = await remoteDataSource!.fetchBedAvailability();
        if (remoteSummary != null) {
          _cachedSummary = remoteSummary;
        }
      } catch (_) {
        // Fallback to cache if network fails
      }
    }

    final summary =
        _cachedSummary ??
        const BedAvailabilitySummary(
          totalBeds: AppConstants.hospitalTotalBeds,
          availableBeds: AppConstants.defaultAvailableBeds,
          wards: <WardAvailability>[],
        );

    if (classFilter == null || classFilter == BedClass.all) {
      return summary;
    }

    List<WardAvailability> filtered = summary.wards;
    if (classFilter == BedClass.icu) {
      filtered = filtered
          .where(
            (w) =>
                w.category == BedClass.icu ||
                w.name.toUpperCase().contains('ICU') ||
                w.name.toUpperCase().contains('INTENSIF'),
          )
          .toList();
    } else {
      filtered = filtered
          .where(
            (w) => w.classBreakdown.any(
              (c) =>
                  c.className.toLowerCase().contains(
                    classFilter.toLowerCase(),
                  ) &&
                  c.availableBeds > 0,
            ),
          )
          .toList();
    }

    return summary.copyWith(wards: filtered);
  }

  @override
  Future<WardAvailability?> getWardById(String id) async {
    final summary = await getBedAvailability();
    try {
      return summary.wards.firstWhere((w) => w.id == id);
    } on StateError {
      return null;
    }
  }
}
