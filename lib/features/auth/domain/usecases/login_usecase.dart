import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<AuthResult> call({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) {
    return _repository.login(
      identifier: identifier,
      password: password,
      rememberMe: rememberMe,
    );
  }
}
