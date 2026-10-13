import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:sijapin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';

void main() {
  group('AuthController.logout', () {
    test('clears session user via repository logout path', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(const FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(activeSessionUserProvider.notifier)
          .setUser(
            const UserProfile(
              fullName: 'Ahmad Dani',
              email: 'ahmad@example.com',
              phone: '0812000000',
            ),
          );
      expect(container.read(activeSessionUserProvider), isNotNull);

      await container.read(authControllerProvider.notifier).logout();

      expect(container.read(activeSessionUserProvider), isNull);
    });
  });
}
