import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/features/public_services/data/repositories/bed_availability_repository_impl.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/domain/repositories/bed_availability_repository.dart';

/// Provider repository ketersediaan kamar rawat inap
final bedAvailabilityRepositoryProvider = Provider<BedAvailabilityRepository>((
  ref,
) {
  return const BedAvailabilityRepositoryImpl();
});

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

/// Notifier pengelola ketersediaan kamar dan filter kelas perawatan.
class BedAvailabilityListNotifier extends Notifier<BedAvailabilityState> {
  int _requestId = 0;

  @override
  BedAvailabilityState build() {
    // Inisialisasi pengambilan data awal secara aman
    Future.microtask(loadInitial);
    return const BedAvailabilityState(summary: AsyncLoading());
  }

  /// Memuat data ringkasan ketersediaan kamar dari repository.
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

  /// Memfilter ruangan berdasarkan kelas perawatan (misal: 'Kelas 1', 'ICU', 'Semua Kelas').
  Future<void> filterByClass(String className) async {
    final id = ++_requestId;
    state = state.copyWith(selectedClass: className, isFetching: true);
    try {
      final repo = ref.read(bedAvailabilityRepositoryProvider);
      final result = await repo.getBedAvailability(classFilter: className);
      if (id != _requestId || !ref.mounted) return;
      state = state.copyWith(summary: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (id != _requestId || !ref.mounted) return;
      state = state.copyWith(summary: AsyncError(e, st), isFetching: false);
    }
  }

  /// Reset ke data awal (seluruh kelas).
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

/// Provider ringkasan ketersediaan kamar dengan filter kelas
final bedAvailabilityListProvider =
    NotifierProvider<BedAvailabilityListNotifier, BedAvailabilityState>(
      BedAvailabilityListNotifier.new,
    );
