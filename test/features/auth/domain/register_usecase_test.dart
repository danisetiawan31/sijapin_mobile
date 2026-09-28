import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:sijapin_mobile/features/auth/domain/usecases/register_usecase.dart';

void main() {
  test('register use case returns dummy success without network access', () async {
    const repository = FakeAuthRepository();
    const useCase = RegisterUseCase(repository);

    final result = await useCase(
      fullName: 'Pasien Uji',
      phone: '081234567890',
      email: 'test@example.com',
      birthDate: DateTime(2000, 1, 1),
      gender: 'Laki-laki',
      password: 'dummy-password',
    );

    expect(result.success, isTrue);
    expect(result.message, contains('dummy'));
  });
}
