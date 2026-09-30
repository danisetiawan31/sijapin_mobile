import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';

/// Hubungan anggota keluarga dengan pemilik akun pasien.
enum FamilyRelation { spouse, child, parent, sibling }

/// Jaminan kesehatan yang dipakai anggota keluarga saat berobat.
enum FamilyInsurance { bpjs, umum, selfPay }

/// Ekstensi label teks untuk [FamilyRelation] dalam bahasa Indonesia.
extension FamilyRelationLabel on FamilyRelation {
  String get label {
    switch (this) {
      case FamilyRelation.spouse:
        return 'Suami / Istri';
      case FamilyRelation.child:
        return 'Anak';
      case FamilyRelation.parent:
        return 'Orang Tua';
      case FamilyRelation.sibling:
        return 'Saudara';
    }
  }
}

/// Ekstensi label teks untuk [FamilyInsurance].
extension FamilyInsuranceLabel on FamilyInsurance {
  String get label {
    switch (this) {
      case FamilyInsurance.bpjs:
        return 'BPJS';
      case FamilyInsurance.umum:
        return 'Umum';
      case FamilyInsurance.selfPay:
        return 'Biaya Sendiri';
    }
  }
}

/// Satu anggota keluarga yang didaftarkan atas nama pemilik akun.
///
/// Mengacu pada tabel `m_customer_member` SIMRS RSUP Dr. Sitanala.
class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.fullName,
    required this.relation,
    required this.gender,
    required this.nik,
    required this.insurance,
    this.birthDate,
    this.medicalRecordNumber,
    this.bloodType = '',
    this.phone = '',
    this.insuranceNumber,
    this.lastServiceDate,
    this.healthNote,
    this.isPrimary = false,
  });

  /// Pengenal anggota agar unik pada daftar.
  final String id;

  /// Nama lengkap sesuai identitas resmi.
  final String fullName;

  /// Hubungan dengan pemilik akun.
  final FamilyRelation relation;

  /// Kode jenis kelamin: `L` (Laki-laki) atau `P` (Perempuan).
  final String gender;

  /// Nomor induk kependudukan 16 digit.
  final String nik;

  /// Jaminan kesehatan yang dipakai.
  final FamilyInsurance insurance;

  /// Tanggal lahir; `null` bila belum dilengkapi anggota keluarga.
  final DateTime? birthDate;

  /// Nomor Rekam Medis jika pasien lama (misal: `012345`). Null bila pasien baru.
  final String? medicalRecordNumber;

  /// Golongan darah, misal `O`, `A`, `B`, `AB`.
  final String bloodType;

  /// Nomor HP untuk pemberitahuan hasil pemeriksaan.
  final String phone;

  /// Nomor kartu BPJS, hanya terisi untuk [FamilyInsurance.bpjs].
  final String? insuranceNumber;

  /// Tanggal layanan terakhir di RSUP Dr. Sitanala.
  final DateTime? lastServiceDate;

  /// Catatan kesehatan ringkas, misal riwayat alergi atau penyakit kronis.
  final String? healthNote;

  /// Penanda anggota utama yang mewakili pemilik akun saat memesan janji temu.
  final bool isPrimary;

  /// Apakah pasien baru (belum memiliki No. Rekam Medis RSUP Dr. Sitanala)
  bool get isNewPatient =>
      medicalRecordNumber == null || medicalRecordNumber!.trim().isEmpty;

  /// No. RM tersamar (contoh: `0123**` atau `Pasien Baru`)
  String get maskedMedicalRecord {
    final rm = medicalRecordNumber;
    if (rm == null || rm.trim().isEmpty) return 'Pasien Baru';
    if (rm.length <= 3) return '$rm***';
    return '${rm.substring(0, rm.length - 2)}**';
  }

  /// NIK dan tanggal lahir adalah data minimum untuk expedite layanan.
  bool get hasProfileComplete {
    return nik.trim().isNotEmpty && birthDate != null;
  }

  /// Inisial nama untuk avatar, misal `Bagas Nugroho` menjadi `BN`.
  String get initials {
    final List<String> parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  /// Mengonversi entitas [FamilyMember] menjadi [PatientMember] untuk pendaftaran di Wizard Booking.
  PatientMember toPatientMember() {
    final int parsedId =
        int.tryParse(id.replaceAll(RegExp(r'[^0-9]'), '')) ??
        (id.hashCode.abs() % 100000);
    return PatientMember(
      id: parsedId,
      fullName: fullName,
      nik: nik,
      medicalRecordNumber: medicalRecordNumber,
      relation: relation.label,
      gender: gender,
      birthDate: birthDate ?? AppDateTime.now(),
      bpjsCardNumber: insurance == FamilyInsurance.bpjs
          ? insuranceNumber
          : null,
      phone: phone.isNotEmpty ? phone : null,
    );
  }

  FamilyMember copyWith({
    String? id,
    String? fullName,
    FamilyRelation? relation,
    String? gender,
    String? nik,
    FamilyInsurance? insurance,
    DateTime? birthDate,
    String? medicalRecordNumber,
    String? bloodType,
    String? phone,
    String? insuranceNumber,
    DateTime? lastServiceDate,
    String? healthNote,
    bool? isPrimary,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      relation: relation ?? this.relation,
      gender: gender ?? this.gender,
      nik: nik ?? this.nik,
      insurance: insurance ?? this.insurance,
      birthDate: birthDate ?? this.birthDate,
      medicalRecordNumber: medicalRecordNumber ?? this.medicalRecordNumber,
      bloodType: bloodType ?? this.bloodType,
      phone: phone ?? this.phone,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      healthNote: healthNote ?? this.healthNote,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyMember &&
        other.id == id &&
        other.fullName == fullName &&
        other.relation == relation &&
        other.gender == gender &&
        other.nik == nik &&
        other.insurance == insurance &&
        other.birthDate == birthDate &&
        other.medicalRecordNumber == medicalRecordNumber &&
        other.bloodType == bloodType &&
        other.phone == phone &&
        other.insuranceNumber == insuranceNumber &&
        other.lastServiceDate == lastServiceDate &&
        other.healthNote == healthNote &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      fullName,
      relation,
      gender,
      nik,
      insurance,
      birthDate,
      medicalRecordNumber,
      bloodType,
      phone,
      insuranceNumber,
      lastServiceDate,
      healthNote,
      isPrimary,
    );
  }
}
