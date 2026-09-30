/// Hubungan anggota keluarga dengan pemilik akun pasien.
enum FamilyRelation { spouse, child, parent, sibling }

/// Jaminan kesehatan yang dipakai anggota keluarga saat berobat.
enum FamilyInsurance { bpjs, umum, selfPay }

/// Satu anggota keluarga yang didaftarkan atas nama pemilik akun.
///
/// Data ini sengaja dibuat ringkas agar mudah diganti pembacaan API tanpa
/// menyentuh layar maupun widget presentasi.
class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.fullName,
    required this.relation,
    required this.gender,
    required this.nik,
    required this.insurance,
    this.birthDate,
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
}
