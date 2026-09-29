/// Entitas jadwal praktik dokter spesialis & poliklinik.
class DoctorSchedule {
  const DoctorSchedule({
    required this.id,
    required this.name,
    required this.specialization,
    required this.poli,
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
  /// Digunakan untuk filter chip yang cocok dengan label UI.
  final String poli;

  /// URL foto dokter (opsional, gunakan inisial jika null)
  final String? photoUrl;

  /// Daftar jadwal praktik per hari
  final List<DoctorScheduleEntry> schedules;

  /// Status praktik: praktik reguler, libur, cuti, dll.
  final DoctorPracticeStatus status;
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
  String get displayTime => '$startTime – $endTime WIB';
}

/// Status praktik dokter.
enum DoctorPracticeStatus { reguler, libur, cuti, penuh }
