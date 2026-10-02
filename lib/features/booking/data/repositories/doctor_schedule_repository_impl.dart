import 'dart:async';

import 'package:sijapin_mobile/features/booking/data/datasources/doctor_schedule_remote_data_source.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/doctor_schedule_repository.dart';

/// Implementasi repository jadwal dokter yang terhubung ke backend SIMRS
/// dengan fallback in-memory cache dan filter terpadu.
class DoctorScheduleRepositoryImpl implements DoctorScheduleRepository {
  DoctorScheduleRepositoryImpl({
    this.remoteDataSource,
    List<DoctorSchedule>? initialSchedules,
  }) : _cachedSchedules = initialSchedules;

  final IDoctorScheduleRemoteDataSource? remoteDataSource;
  List<DoctorSchedule>? _cachedSchedules;

  @override
  Future<List<DoctorSchedule>> getDoctorSchedules({
    String? specialtyFilter,
    String? searchQuery,
    String? dayFilter,
  }) async {
    if (remoteDataSource != null) {
      try {
        final remote = await remoteDataSource!.fetchDoctorSchedules();
        if (remote.isNotEmpty) {
          _cachedSchedules = remote;
        }
      } catch (_) {
        // Fallback to cache if network call fails
      }
    }

    final allSchedules = _cachedSchedules ?? const <DoctorSchedule>[];

    // Filter berdasarkan poli (poliklinik) & spesialisasi
    var filtered = allSchedules;
    if (specialtyFilter != null && specialtyFilter != 'Semua Poli') {
      final filterLower = specialtyFilter.toLowerCase().trim();
      filtered = filtered.where((d) {
        if (d.poli.isNotEmpty && d.poli.toLowerCase() == filterLower) {
          return true;
        }
        final specLower = d.specialization.toLowerCase();
        if (filterLower.contains('obgyn') ||
            filterLower.contains('kebidanan') ||
            filterLower.contains('kandungan')) {
          return specLower.contains('obstetri') ||
              specLower.contains('ginekologi') ||
              specLower.contains('obgyn') ||
              specLower.contains('kebidanan') ||
              specLower.contains('kandungan');
        }
        return specLower.contains(filterLower) || filterLower.contains(specLower);
      }).toList();
    }

    // Filter berdasarkan hari operasional (Senin – Jumat)
    if (dayFilter != null && dayFilter != 'Semua Hari') {
      final dayLower = dayFilter.toLowerCase().trim();
      filtered = filtered.where((d) {
        return d.isPracticingOnDay(dayLower);
      }).toList();
    }

    // Filter berdasarkan pencarian nama dokter atau spesialisasi
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      filtered = filtered.where((d) {
        return d.name.toLowerCase().contains(query) ||
            d.specialization.toLowerCase().contains(query) ||
            d.poli.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Future<DoctorSchedule?> getDoctorScheduleById(String id) async {
    final allSchedules = await getDoctorSchedules();
    try {
      return allSchedules.firstWhere((d) => d.id == id);
    } on StateError {
      return null;
    }
  }
}
