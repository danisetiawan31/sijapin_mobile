import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementasi sementara untuk slicing UI dan pengujian.
/// Tidak melakukan request ke server CI3 dan tidak menyimpan kredensial.
class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository();

  @override
  Future<AuthResult> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const AuthResult(success: true, message: 'Login dummy berhasil.');
  }

  @override
  Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const AuthResult(
      success: true,
      message: 'Pendaftaran dummy berhasil.',
    );
  }
}
