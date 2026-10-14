import '../entities/auth_result.dart';

/// Kontrak autentikasi yang dapat diganti dengan adapter API CI3.
abstract interface class AuthRepository {
  Future<AuthResult> login({
    required String identifier,
    required String password,
  });

  Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  });

  /// Mencabut sesi di server dan membersihkan seluruh jejak lokal
  /// (token, cookie, secure keys, in-memory user milik controller).
  Future<void> logout();
}
