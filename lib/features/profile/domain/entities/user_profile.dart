/// Entitas domain profil pasien yang sedang login.
class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nik,
    required this.birthDate,
    required this.gender,
    required this.bloodType,
    required this.address,
    required this.memberSince,
  });

  final String fullName;
  final String email;
  final String phone;
  final String nik;

  /// Tanggal lahir; `null` bila pasien belum melengkapinya.
  final DateTime? birthDate;

  /// Kode jenis kelamin: `L` (Laki-laki) atau `P` (Perempuan).
  final String gender;

  /// Golongan darah, misal `O`, `A`, `B`, `AB`. Kosong bila belum diisi.
  final String bloodType;
  final String address;

  /// Tanggal pasien pertama kali terdaftar sebagai anggota.
  final DateTime memberSince;

  /// NIK dan tanggal lahir adalah data minimum untuk expedite layanan (DESIGN.md §2).
  bool get hasProfileComplete {
    return nik.trim().isNotEmpty && birthDate != null;
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
    String? fullName,
    String? email,
    String? phone,
    String? nik,
    DateTime? birthDate,
    String? gender,
    String? bloodType,
    String? address,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nik: nik ?? this.nik,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      address: address ?? this.address,
      memberSince: memberSince,
    );
  }
}
