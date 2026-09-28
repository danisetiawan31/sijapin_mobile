import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:sijapin_mobile/features/auth/domain/usecases/login_usecase.dart';

void main() {
  test('login use case returns dummy success without network access', () async {
    const repository = FakeAuthRepository();
    const useCase = LoginUseCase(repository);

    final result = await useCase(
      identifier: 'test@example.com',
      password: 'dummy-password',
      rememberMe: false,
    );

    expect(result.success, isTrue);
    expect(result.message, contains('dummy'));
  });
}
