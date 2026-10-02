/// Entitas domain profil akun pengguna / customer yang sedang login (m_customer).
class UserProfile {
  const UserProfile({
    this.customerId = '',
    required this.fullName,
    required this.email,
    required this.phone,
    this.nik = '',
    this.birthDate,
    this.gender = 'L',
    this.bloodType = '',
    this.address = '',
    this.memberSince,
  });

  /// ID Customer di database SIMRS (CUSTOMER_ID pada tabel m_customer).
  final String customerId;

  /// Nama lengkap pemilik akun (NAMA_CUSTOMER).
  final String fullName;

  /// Alamat email terdaftar (EMAIL).
  final String email;

  /// Nomor telepon seluler terdaftar (NO_TELEPON).
  final String phone;

  /// NIK opsional (NIK utama dicatat pada entitas pasien/m_customer_member).
  final String nik;

  /// Tanggal lahir (TANGGAL_LAHIR); `null` bila belum dilengkapi.
  final DateTime? birthDate;

  /// Kode jenis kelamin (JENIS_KELAMIN): `L` (Laki-laki) atau `P` (Perempuan).
  final String gender;

  /// Golongan darah opsional, misal `O`, `A`, `B`, `AB`.
  final String bloodType;

  /// Alamat domisili pemilik akun (ALAMAT).
  final String address;

  /// Tanggal akun pertama kali terdaftar.
  final DateTime? memberSince;

  /// Data minimum akun customer untuk kelayakan pendaftaran: nama, email, nomor HP, dan tanggal lahir.
  bool get hasProfileComplete {
    return fullName.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        phone.trim().isNotEmpty &&
        birthDate != null;
  }

  /// Inisial nama untuk avatar, misal `Rina Puspita Sari` menjadi `RS`.
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

  UserProfile copyWith({
    String? customerId,
    String? fullName,
    String? email,
    String? phone,
    String? nik,
    DateTime? birthDate,
    String? gender,
    String? bloodType,
    String? address,
    DateTime? memberSince,
  }) {
    return UserProfile(
      customerId: customerId ?? this.customerId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nik: nik ?? this.nik,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      address: address ?? this.address,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
