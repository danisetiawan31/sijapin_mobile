import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<AuthResult> call({
    required String fullName,
    required String phone,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) {
    return _repository.register(
      fullName: fullName,
      phone: phone,
      email: email,
      birthDate: birthDate,
      gender: gender,
      password: password,
    );
  }
}
