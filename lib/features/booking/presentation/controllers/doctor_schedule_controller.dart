import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/doctor_schedule_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/doctor_schedule_repository.dart';

part 'doctor_schedule_controller.g.dart';

/// Provider repository jadwal dokter
@riverpod
DoctorScheduleRepository doctorScheduleRepository(Ref ref) {
  return const DoctorScheduleRepositoryImpl();
}

/// State class untuk DoctorScheduleList
class DoctorScheduleState {
  const DoctorScheduleState({
    required this.schedules,
    this.selectedSpecialty = 'Semua Poli',
    this.searchQuery = '',
    this.isFetching = false,
  });

  final AsyncValue<List<DoctorSchedule>> schedules;
  final String selectedSpecialty;
  final String searchQuery;
  final bool isFetching;

  DoctorScheduleState copyWith({
    AsyncValue<List<DoctorSchedule>>? schedules,
    String? selectedSpecialty,
    String? searchQuery,
    bool? isFetching,
  }) {
    return DoctorScheduleState(
      schedules: schedules ?? this.schedules,
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
      searchQuery: searchQuery ?? this.searchQuery,
      isFetching: isFetching ?? this.isFetching,
    );
  }
}

/// Provider daftar jadwal dokter dengan filter & pencarian
@riverpod
class DoctorScheduleList extends _$DoctorScheduleList {
  int _requestId = 0;

  @override
  DoctorScheduleState build() {
    // Trigger initial load after the provider is created
    Future.microtask(() => loadInitial());

    return const DoctorScheduleState(
      schedules: AsyncLoading(),
      selectedSpecialty: 'Semua Poli',
      searchQuery: '',
      isFetching: false,
    );
  }

  /// Load initial data
  Future<void> loadInitial() async {
    final repo = ref.read(doctorScheduleRepositoryProvider);
    try {
      final result = await repo.getDoctorSchedules();
      state = state.copyWith(schedules: AsyncData(result), isFetching: false);
    } catch (e, st) {
      state = state.copyWith(schedules: AsyncError(e, st), isFetching: false);
    }
  }

  /// Mencari jadwal dokter berdasarkan query
  Future<void> search(String query) async {
    final id = ++_requestId;
    state = state.copyWith(searchQuery: query, isFetching: true);
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules(
        specialtyFilter: state.selectedSpecialty == 'Semua Poli'
            ? null
            : state.selectedSpecialty,
        searchQuery: query,
      );
      if (id != _requestId) return; // stale request
      state = state.copyWith(schedules: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (id != _requestId) return;
      state = state.copyWith(schedules: AsyncError(e, st), isFetching: false);
    }
  }

  /// Memfilter jadwal dokter berdasarkan spesialisasi
  Future<void> filterBySpecialty(String specialty) async {
    final id = ++_requestId;
    state = state.copyWith(selectedSpecialty: specialty, isFetching: true);
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules(
        specialtyFilter: specialty == 'Semua Poli' ? null : specialty,
        searchQuery: state.searchQuery,
      );
      if (id != _requestId) return; // stale request
      state = state.copyWith(schedules: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (id != _requestId) return;
      state = state.copyWith(schedules: AsyncError(e, st), isFetching: false);
    }
  }

  /// Menggabungkan pencarian dan filter
  Future<void> searchAndFilter({String? query, String? specialty}) async {
    final id = ++_requestId;
    state = state.copyWith(
      searchQuery: query ?? state.searchQuery,
      selectedSpecialty: specialty ?? state.selectedSpecialty,
      isFetching: true,
    );
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules(
        specialtyFilter: (specialty ?? state.selectedSpecialty) == 'Semua Poli'
            ? null
            : (specialty ?? state.selectedSpecialty),
        searchQuery: query ?? state.searchQuery,
      );
      if (id != _requestId) return; // stale request
      state = state.copyWith(schedules: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (id != _requestId) return;
      state = state.copyWith(schedules: AsyncError(e, st), isFetching: false);
    }
  }

  /// Reset ke data awal (semua dokter)
  Future<void> reset() async {
    final id = ++_requestId;
    state = state.copyWith(
      selectedSpecialty: 'Semua Poli',
      searchQuery: '',
      isFetching: true,
    );
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules();
      if (id != _requestId) return;
      state = state.copyWith(schedules: AsyncData(result), isFetching: false);
    } catch (e, st) {
      if (id != _requestId) return;
      state = state.copyWith(schedules: AsyncError(e, st), isFetching: false);
    }
  }
}
