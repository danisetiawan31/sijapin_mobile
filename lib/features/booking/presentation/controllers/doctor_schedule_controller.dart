import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/doctor_schedule_remote_data_source.dart';
import '../../data/repositories/doctor_schedule_repository_impl.dart';
import '../../domain/entities/doctor_schedule.dart';
import '../../domain/entities/polyclinic.dart';
import '../../domain/repositories/doctor_schedule_repository.dart';

part 'doctor_schedule_controller.g.dart';

/// Provider repository jadwal dokter
@riverpod
DoctorScheduleRepository doctorScheduleRepository(Ref ref) {
  final dioClient = ref.watch(dioClientProvider);
  return DoctorScheduleRepositoryImpl(
    remoteDataSource: DoctorScheduleRemoteDataSource(dioClient: dioClient),
  );
}

/// Provider daftar poliklinik aktif untuk filter chips dan form pendaftaran
final activePolyclinicsProvider = FutureProvider<List<Polyclinic>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  final remote = DoctorScheduleRemoteDataSource(dioClient: dioClient);
  return remote.fetchPolyclinics();
});

/// Provider spesialisasi/poli yang sedang dipilih
@riverpod
class SelectedDoctorSpecialty extends _$SelectedDoctorSpecialty {
  @override
  String build() => 'Semua Poli';

  void setSpecialty(String specialty) {
    state = specialty;
  }
}

/// Provider teks pencarian jadwal dokter
@riverpod
class DoctorSearchQuery extends _$DoctorSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }
}

/// Provider hari operasional yang sedang dipilih (Senin – Jumat / Semua Hari)
class SelectedDoctorDayNotifier extends Notifier<String> {
  @override
  String build() => 'Semua Hari';

  void setDay(String day) {
    state = day;
  }
}

final selectedDoctorDayProvider =
    NotifierProvider<SelectedDoctorDayNotifier, String>(
      SelectedDoctorDayNotifier.new,
    );

/// Provider daftar jadwal dokter dengan filter & pencarian terpadu
@riverpod
class DoctorScheduleList extends _$DoctorScheduleList {
  @override
  Future<List<DoctorSchedule>> build() async {
    final repo = ref.watch(doctorScheduleRepositoryProvider);
    final specialty = ref.watch(selectedDoctorSpecialtyProvider);
    final query = ref.watch(doctorSearchQueryProvider);
    final day = ref.watch(selectedDoctorDayProvider);

    return repo.getDoctorSchedules(
      specialtyFilter: specialty == 'Semua Poli' ? null : specialty,
      searchQuery: query.trim().isEmpty ? null : query.trim(),
      dayFilter: day == 'Semua Hari' ? null : day,
    );
  }

  /// Helper untuk mencari jadwal dokter (kompatibilitas & kemudahan akses)
  void search(String query) {
    ref.read(doctorSearchQueryProvider.notifier).setQuery(query);
  }

  /// Helper untuk memfilter spesialisasi (kompatibilitas & kemudahan akses)
  void filterBySpecialty(String specialty) {
    ref.read(selectedDoctorSpecialtyProvider.notifier).setSpecialty(specialty);
  }

  /// Helper untuk memfilter hari operasional (kompatibilitas & kemudahan akses)
  void filterByDay(String day) {
    ref.read(selectedDoctorDayProvider.notifier).setDay(day);
  }

  /// Reset ke data awal (semua poli, semua hari & pencarian kosong)
  void reset() {
    ref.read(doctorSearchQueryProvider.notifier).setQuery('');
    ref
        .read(selectedDoctorSpecialtyProvider.notifier)
        .setSpecialty('Semua Poli');
    ref.read(selectedDoctorDayProvider.notifier).setDay('Semua Hari');
  }
}
