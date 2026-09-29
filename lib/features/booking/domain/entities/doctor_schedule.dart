import 'package:sijapin_mobile/core/config/app_config.dart';

/// Entitas jadwal praktik dokter spesialis & poliklinik.
class DoctorSchedule {
  const DoctorSchedule({
    required this.id,
    required this.name,
    required this.specialization,
    this.gender = 'L',
    this.poli = '',
    this.photoUrl,
    required this.schedules,
    required this.status,
  });

  /// ID unik dokter (digunakan untuk routing/detail)
  final String id;

  /// Nama lengkap dokter dengan gelar, contoh: `dr. Era Medina, Sp.PD`
  final String name;

  /// Spesialisasi dokter, contoh: `Spesialis Penyakit Dalam`
  final String specialization;

  /// Poliklinik/poli tempat dokter praktik, contoh: `Penyakit Dalam`, `Mata`, `Kebidanan & Obgyn`
  final String poli;

  /// Jenis kelamin dokter: `'L'` (Laki-laki) atau `'P'` (Perempuan)
  final String gender;

  /// URL foto dokter (opsional, gunakan inisial/avatar gender jika null)
  final String? photoUrl;

  /// Daftar jadwal praktik per hari
  final List<DoctorScheduleEntry> schedules;

  /// Status praktik: praktik reguler, libur, cuti, dll.
  final DoctorPracticeStatus status;

  /// Apakah dokter berjenis kelamin pria
  bool get isMale => gender.toUpperCase() == 'L';

  /// Apakah dokter berjenis kelamin wanita
  bool get isFemale => gender.toUpperCase() == 'P';
}

/// Entri jadwal praktik per hari.
class DoctorScheduleEntry {
  const DoctorScheduleEntry({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  /// Nama hari, contoh: `Selasa`, `Rabu`
  final String day;

  /// Jam mulai praktik (24h format), contoh: `07:30`
  final String startTime;

  /// Jam selesai praktik (24h format), contoh: `12:00`
  final String endTime;

  /// Format tampilan jam praktik, contoh: `07.30 – 12.00 WIB`
  String get displayTime => '$startTime – $endTime ${AppConfig.timeZoneAbbr}';
}

/// Status praktik dokter.
enum DoctorPracticeStatus { reguler, libur, cuti, penuh }
