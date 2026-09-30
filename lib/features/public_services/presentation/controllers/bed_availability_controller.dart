import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sijapin_mobile/features/public_services/data/repositories/bed_availability_repository_impl.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/domain/repositories/bed_availability_repository.dart';

part 'bed_availability_controller.g.dart';

/// Provider repository ketersediaan kamar
@riverpod
BedAvailabilityRepository bedAvailabilityRepository(Ref ref) {
  return const BedAvailabilityRepositoryImpl();
}

/// State untuk BedAvailabilityList
class BedAvailabilityState {
  const BedAvailabilityState({
    required this.summary,
    this.selectedClass = 'Semua Kelas',
    this.isFetching = false,
  });

  final AsyncValue<BedAvailabilitySummary> summary;
  final String selectedClass;
  final bool isFetching;

  BedAvailabilityState copyWith({
    AsyncValue<BedAvailabilitySummary>? summary,
    String? selectedClass,
    bool? isFetching,
  }) {
    return BedAvailabilityState(
      summary: summary ?? this.summary,
      selectedClass: selectedClass ?? this.selectedClass,
      isFetching: isFetching ?? this.isFetching,
    );
  }
}

/// Provider ringkasan ketersediaan kamar dengan filter kelas
@riverpod
class BedAvailabilityList extends _$BedAvailabilityList {
  int _requestId = 0;

  @override
  BedAvailabilityState build() {
    // Trigger initial load after the provider is created
    Future.microtask(() => loadInitial());

    return const BedAvailabilityState(summary: AsyncLoading());
  }

  /// Load initial data
  Future<void> loadInitial() async {
    final repo = ref.read(bedAvailabilityRepositoryProvider);
    try {
      final result = await repo.getBedAvailability();
      if (!ref.mounted) return;
      state = state.copyWith(summary: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = state.copyWith(summary: AsyncError(e, st), isFetching: false);
    }
  }

  /// Memfilter ruangan berdasarkan kelas perawatan
  Future<void> filterByClass(String className) async {
    final id = ++_requestId;
    state = state.copyWith(selectedClass: className, isFetching: true);
    try {
      final repo = ref.read(bedAvailabilityRepositoryProvider);
      final result = await repo.getBedAvailability(classFilter: className);
      if (id != _requestId || !ref.mounted) return; // stale request
      state = state.copyWith(summary: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (id != _requestId || !ref.mounted) return;
      state = state.copyWith(summary: AsyncError(e, st), isFetching: false);
    }
  }

  /// Reset ke data awal (semua kelas)
  Future<void> reset() async {
    final id = ++_requestId;
    state = state.copyWith(selectedClass: 'Semua Kelas', isFetching: true);
    try {
      final repo = ref.read(bedAvailabilityRepositoryProvider);
      final result = await repo.getBedAvailability();
      if (id != _requestId || !ref.mounted) return;
      state = state.copyWith(summary: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (id != _requestId || !ref.mounted) return;
      state = state.copyWith(summary: AsyncError(e, st), isFetching: false);
    }
  }
}
