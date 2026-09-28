/// Hasil autentikasi dummy yang sengaja tidak memuat kredensial sensitif.
class AuthResult {
  final bool success;
  final String message;

  const AuthResult({required this.success, required this.message});
}
