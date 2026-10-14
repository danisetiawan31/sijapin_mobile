import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/domain/entities/auth_result.dart';
import 'package:sijapin_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sijapin_mobile/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('AuthController.honestOfflineUser (tanpa data karangan)', () {
    test('login email: telepon kosong, email terisi', () {
      final user = AuthController.honestOfflineUser('pasien@domain.com');
      expect(user.fullName, isEmpty);
      expect(user.phone, isEmpty);
      expect(user.email, equals('pasien@domain.com'));
      expect(user.birthDate, isNull);
    });

    test('login nomor HP: email kosong, telepon terisi', () {
      final user = AuthController.honestOfflineUser('081234567890');
      expect(user.fullName, isEmpty);
      expect(user.phone, equals('081234567890'));
      expect(user.email, isEmpty);
    });

    test('tidak pernah bernama samaran', () {
      expect(
        AuthController.honestOfflineUser('081234567890').fullName,
        isNot('Pasien Terdaftar'),
      );
    });
  });

  group('AuthController.login contextual error message', () {
    test('email login salah menampilkan pesan kontekstual email', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            const _StubAuthRepository(
              failureMessage: 'Nomor telepon atau kata sandi Anda salah.',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .login(identifier: 'pasien@sitanala.com', password: 'salah');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthSubmissionStatus.error);
      expect(state.message, 'E-mail atau password yang anda gunakan salah');
    });

    test(
      'phone login salah menampilkan pesan kontekstual nomor handphone',
      () async {
        final ProviderContainer container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              const _StubAuthRepository(
                failureMessage: 'Nomor telepon atau kata sandi Anda salah.',
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authControllerProvider.notifier)
            .login(identifier: '081234567890', password: 'salah');

        final state = container.read(authControllerProvider);
        expect(state.status, AuthSubmissionStatus.error);
        expect(
          state.message,
          'Nomor Handphone atau password yang anda masukkan salah',
        );
      },
    );

    test('network failure mempertahankan pesan koneksi internet verbatim', () async {
      const netMsg =
          'Gagal terhubung ke server SIMRS. Silakan periksa koneksi internet Anda.';
      final ProviderContainer container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            const _StubAuthRepository(failureMessage: netMsg),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .login(identifier: 'pasien@sitanala.com', password: 'salah');

      final state = container.read(authControllerProvider);
      expect(state.status, AuthSubmissionStatus.error);
      expect(state.message, netMsg);
    });
  });
}

class _StubAuthRepository implements AuthRepository {
  final String failureMessage;
  const _StubAuthRepository({required this.failureMessage});

  @override
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    return AuthResult(success: false, message: failureMessage);
  }

  @override
  Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) async => const AuthResult(success: false, message: 'fail');

  @override
  Future<void> logout() async {}
}
