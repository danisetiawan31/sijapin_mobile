import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/storage/local_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/features/auth/data/repositories/fake_auth_repository.dart';
import 'package:sijapin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/family_member_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';

/// Local storage palsu yang mendata request clearBox per box.
class RecordingLocalStorage implements ILocalStorage {
  final List<String> clearedBoxes = <String>[];

  @override
  Future<void> init() async {}

  @override
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {}

  @override
  T? get<T>({required String boxName, required String key, T? defaultValue}) =>
      defaultValue;

  @override
  Future<void> delete({required String boxName, required String key}) async {}

  @override
  Future<void> clearBox({required String boxName}) async {
    clearedBoxes.add(boxName);
  }

  @override
  bool containsKey({required String boxName, required String key}) => false;

  @override
  List<T> getAll<T>({required String boxName}) => <T>[];
}

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

    test(
      'menghapus data user perangkat, penanda ekspel tetap disimpan',
      () async {
        final RecordingLocalStorage storage = RecordingLocalStorage();
        final ProviderContainer container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              const FakeAuthRepository(),
            ),
            localStorageServiceProvider.overrideWithValue(storage),
            familyMemberRepositoryProvider.overrideWith(
              (ref) => FamilyMemberRepositoryImpl(remoteDataSource: null),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Notifier + repo berbasis sesi sudah dibangun dan memegang instance.
        container.read(familyMembersProvider);
        final repoBefore = container.read(familyMemberRepositoryProvider);

        await container.read(authControllerProvider.notifier).logout();

        // Semua box data user dikosongkan.
        expect(
          storage.clearedBoxes,
          containsAll(<String>[
            StorageConstants.ticketsBox,
            StorageConstants.masterCacheBox,
            StorageConstants.familyMembersBox,
          ]),
        );
        // Penanda ekspel (satunya isi preferences box) dipertahankan.
        expect(
          storage.clearedBoxes,
          isNot(contains(StorageConstants.preferencesBox)),
        );

        // Provider per-user selesai di-reset: repo di-instansiasi ulang
        // (tak mewarisi cache memori akun sebelumnya) dan daftar kosong.
        final repoAfter = container.read(familyMemberRepositoryProvider);
        expect(identical(repoBefore, repoAfter), isFalse);
        expect(container.read(familyMembersProvider), isEmpty);
      },
    );
  });
}
