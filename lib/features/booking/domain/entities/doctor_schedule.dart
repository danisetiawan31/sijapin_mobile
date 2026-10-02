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
    this.status = DoctorPracticeStatus.reguler,
    this.doctorId,
    this.unitId,
  });

  /// ID unik dokter (string untuk routing/detail, atau ID string angka)
  final String id;

  /// ID pegawai dokter di database SIMRS (`PEGAWAI_ID` di `m_pegawai`)
  final int? doctorId;

  /// ID poliklinik tujuan di database SIMRS (`UNIT_ID` di `m_unit`)
  final int? unitId;

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

  /// Status praktik umum dokter
  final DoctorPracticeStatus status;

  /// Apakah dokter berjenis kelamin pria
  bool get isMale => gender.toUpperCase() == 'L';

  /// Apakah dokter berjenis kelamin wanita
  bool get isFemale => gender.toUpperCase() == 'P';

  /// Mengecek apakah dokter aktif berpraktik pada hari tertentu
  bool isPracticingOnDay(String dayName) {
    final lower = dayName.toLowerCase().trim();
    if (lower == 'semua hari') {
      return schedules.any((e) => e.isAvailable);
    }
    return schedules.any(
      (e) => e.day.toLowerCase().trim() == lower && e.isAvailable,
    );
  }

  /// Menghitung status praktik dokter dinamis pada hari tertentu
  DoctorPracticeStatus statusForDay(String dayName) {
    if (status == DoctorPracticeStatus.cuti) return DoctorPracticeStatus.cuti;
    if (status == DoctorPracticeStatus.libur) return DoctorPracticeStatus.libur;
    final lower = dayName.toLowerCase().trim();
    if (lower == 'semua hari') {
      return schedules.any((e) => e.isAvailable)
          ? DoctorPracticeStatus.reguler
          : DoctorPracticeStatus.libur;
    }
    final match = schedules.where((e) => e.day.toLowerCase().trim() == lower);
    if (match.isEmpty) return DoctorPracticeStatus.libur;
    return match.any((e) => e.isAvailable)
        ? DoctorPracticeStatus.reguler
        : DoctorPracticeStatus.libur;
  }
}

/// Entri jadwal praktik per hari.
class DoctorScheduleEntry {
  const DoctorScheduleEntry({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.hariId,
    this.isLibur = false,
    this.quota,
  });

  /// Nama hari, contoh: `Selasa`, `Rabu`
  final String day;

  /// Jam mulai praktik (24h format), contoh: `07:30`
  final String startTime;

  /// Jam selesai praktik (24h format), contoh: `12:00`
  final String endTime;

  /// ID hari operasional (1 = Senin, 2 = Selasa, ..., 5 = Jumat)
  final int? hariId;

  /// Penanda apakah pada hari ini dokter libur/tidak berpraktik
  final bool isLibur;

  /// Kuota antrean dokter untuk hari ini (jika ada)
  final int? quota;

  /// Apakah dokter aktif membuka pelayanan pada entri hari ini
  bool get isAvailable =>
      !isLibur &&
      startTime.isNotEmpty &&
      !startTime.toLowerCase().contains('libur');

  /// Format tampilan jam praktik, contoh: `07.30 – 12.00 WIB` atau `Sedang Libur`
  String get displayTime {
    if (!isAvailable) {
      return 'Sedang Libur';
    }
    if (endTime.isEmpty || endTime == startTime) {
      return '$startTime ${AppConfig.timeZoneAbbr}';
    }
    return '$startTime – $endTime ${AppConfig.timeZoneAbbr}';
  }
}

/// Status praktik dokter.
enum DoctorPracticeStatus { reguler, libur, cuti, penuh }
