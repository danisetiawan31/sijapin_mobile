/// Hasil autentikasi yang sengaja tidak memuat kredensial sensitif.
class AuthResult {
  final bool success;
  final String message;

  /// Peta profil REST (`GET /api/v1/profile`) bila login via REST berhasil;
  /// `null` untuk jalur CI3 atau bila pemuatan profil gagal (login tetap sah).
  final Map<String, dynamic>? profile;

  const AuthResult({
    required this.success,
    required this.message,
    this.profile,
  });
}
