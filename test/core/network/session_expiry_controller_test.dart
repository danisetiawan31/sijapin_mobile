import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/session_expiry_controller.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';

class _FakeSecureStorage implements ISecureStorage {
  _FakeSecureStorage(this._store);

  final Map<String, String> _store;

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _store.containsKey(key);
}

void main() {
  final refGrabber = Provider<Ref>((ref) => ref);

  group('Central 401 (aturan global §1)', () {
    test('handleSessionExpired menghapus token + mengibarkan sinyal', () async {
      final store = <String, String>{
        StorageConstants.keyBearerToken: 'mati',
        StorageConstants.keyBearerExpiresAt: '2099-01-01 00:00:00',
      };
      final container = ProviderContainer(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(
            _FakeSecureStorage(store),
          ),
        ],
      );
      addTearDown(container.dispose);

      await handleSessionExpired(container.read(refGrabber));
      expect(store.containsKey(StorageConstants.keyBearerToken), isFalse);
      expect(store.containsKey(StorageConstants.keyBearerExpiresAt), isFalse);
      expect(container.read(sessionExpiryNotifierProvider).value, isTrue);

      clearSessionExpired(container.read(refGrabber));
      expect(container.read(sessionExpiryNotifierProvider).value, isFalse);
    });
  });
}
