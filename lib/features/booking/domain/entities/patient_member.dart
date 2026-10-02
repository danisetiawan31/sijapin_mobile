import 'package:sijapin_mobile/core/utils/app_date_time.dart';

/// Entitas anggota keluarga / pasien untuk pendaftaran janji temu rawat jalan.
///
/// Mengacu pada tabel `m_customer_member` SIMRS RSUP Dr. Sitanala.
class PatientMember {
  const PatientMember({
    required this.id,
    required this.fullName,
    required this.nik,
    this.medicalRecordNumber,
    required this.relation,
    required this.gender,
    required this.birthDate,
    this.bpjsCardNumber,
    this.phone,
    this.birthPlace = '',
    this.motherName = '',
    this.address = '',
  });

  /// ID anggota di tabel `m_customer_member`
  final int id;

  /// Nama lengkap pasien
  final String fullName;

  /// Nomor Induk Kependudukan (16 digit)
  final String nik;

  /// Nomor Rekam Medis jika pasien lama (misal: `012345`). Null jika pasien baru.
  final String? medicalRecordNumber;

  /// Hubungan keluarga: `'Diri Sendiri'`, `'Istri'`, `'Suami'`, `'Anak'`, `'Orang Tua'`, dll.
  final String relation;

  /// Kode jenis kelamin: `'L'` (Laki-laki) atau `'P'` (Perempuan)
  final String gender;

  /// Tanggal lahir pasien
  final DateTime birthDate;

  /// Nomor kartu BPJS Kesehatan (13 digit) jika ada
  final String? bpjsCardNumber;

  /// Nomor kontak telepon pasien (NO_CONTACT)
  final String? phone;

  /// Tempat lahir pasien (TMP_LAHIR)
  final String birthPlace;

  /// Nama ibu kandung pasien (NAMA_IBU, wajib jika pasien baru)
  final String motherName;

  /// Alamat domisili pasien (ALAMAT)
  final String address;

  /// Apakah pasien berjenis kelamin pria
  bool get isMale => gender.toUpperCase() == 'L';

  /// Apakah pasien baru (belum memiliki nomor rekam medis RSUP Dr. Sitanala)
  bool get isNewPatient =>
      medicalRecordNumber == null || medicalRecordNumber!.trim().isEmpty;

  /// Apakah memiliki nomor kartu BPJS terdaftar
  bool get hasBpjs =>
      bpjsCardNumber != null && bpjsCardNumber!.trim().isNotEmpty;

  /// NIK tersamar untuk kepatuhan UU PDP (contoh: `367104******0002`)
  String get maskedNik {
    if (nik.length < 12) return nik;
    return '${nik.substring(0, 6)}******${nik.substring(nik.length - 4)}';
  }

  /// No. RM tersamar (contoh: `0123**`)
  String get maskedMedicalRecord {
    final rm = medicalRecordNumber;
    if (rm == null || rm.isEmpty) return 'Pasien Baru (Belum ada RM)';
    if (rm.length <= 3) return '$rm***';
    return '${rm.substring(0, rm.length - 2)}**';
  }

  /// Usia pasien dalam tahun berdasarkan tanggal lahir
  int get age {
    final now = AppDateTime.now();
    int calculatedAge = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  /// Inisial nama untuk avatar
  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  PatientMember copyWith({
    int? id,
    String? fullName,
    String? nik,
    String? medicalRecordNumber,
    String? relation,
    String? gender,
    DateTime? birthDate,
    String? bpjsCardNumber,
    String? phone,
    String? birthPlace,
    String? motherName,
    String? address,
  }) {
    return PatientMember(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nik: nik ?? this.nik,
      medicalRecordNumber: medicalRecordNumber ?? this.medicalRecordNumber,
      relation: relation ?? this.relation,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      bpjsCardNumber: bpjsCardNumber ?? this.bpjsCardNumber,
      phone: phone ?? this.phone,
      birthPlace: birthPlace ?? this.birthPlace,
      motherName: motherName ?? this.motherName,
      address: address ?? this.address,
    );
  }
}
