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

/// Provider daftar jadwal dokter dengan filter & pencarian
@riverpod
class DoctorScheduleList extends _$DoctorScheduleList {
  @override
  Future<List<DoctorSchedule>> build() async {
    final repo = ref.watch(doctorScheduleRepositoryProvider);
    return repo.getDoctorSchedules();
  }

  /// Mencari jadwal dokter berdasarkan query
  Future<void> search(String query) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules(searchQuery: query);
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Memfilter jadwal dokter berdasarkan spesialisasi
  Future<void> filterBySpecialty(String specialty) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules(
        specialtyFilter: specialty,
        searchQuery: _currentSearchQuery,
      );
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Menggabungkan pencarian dan filter
  Future<void> searchAndFilter({String? query, String? specialty}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules(
        specialtyFilter: specialty,
        searchQuery: query,
      );
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Query pencarian saat ini (disimpan untuk digabung dengan filter)
  String _currentSearchQuery = '';

  /// Memperbarui query pencarian internal
  void setSearchQuery(String query) {
    _currentSearchQuery = query;
  }

  /// Reset ke data awal (semua dokter)
  Future<void> reset() async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(doctorScheduleRepositoryProvider);
      final result = await repo.getDoctorSchedules();
      _currentSearchQuery = '';
      state = AsyncData(result);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
