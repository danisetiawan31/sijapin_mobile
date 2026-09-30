import '../entities/doctor_schedule.dart';

/// Kontrak repository jadwal dokter.
///
/// Dapat diganti dengan implementasi backend CI3 (`Jadwal_Dokter` endpoint)
/// tanpa mengubah lapisan domain/presentation.
abstract interface class DoctorScheduleRepository {
  /// Mengambil daftar jadwal dokter aktif.
  ///
  /// [specialtyFilter] opsional untuk memfilter berdasarkan spesialisasi
  /// (misal: `Penyakit Dalam`, `Mata`, `Anak`).
  /// [searchQuery] opsional untuk pencarian nama dokter atau spesialisasi.
  /// [dayFilter] opsional untuk memfilter hari kerja operasional (misal: `Senin`, `Selasa`, dll).
  Future<List<DoctorSchedule>> getDoctorSchedules({
    String? specialtyFilter,
    String? searchQuery,
    String? dayFilter,
  });

  /// Mengambil detail jadwal dokter berdasarkan ID.
  Future<DoctorSchedule?> getDoctorScheduleById(String id);
}
