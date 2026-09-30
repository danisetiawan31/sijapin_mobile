import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/passcode/passcode_controller.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';

class _FakeSecureStorage implements ISecureStorage {
  final Map<String, String> _store = <String, String>{};

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
  late _FakeSecureStorage storage;
  late PasscodeController controller;

  setUp(() {
    storage = _FakeSecureStorage();
    final container = ProviderContainer(
      overrides: [secureStorageServiceProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);
    controller = container.read(passcodeControllerProvider.notifier);
  });

  group('PasscodeController', () {
    test('awalnya belum ada kode kunci', () async {
      expect(await controller.hasPasscode(), isFalse);
    });

    test('setPasscode menyimpan hash dan salt untuk PIN 4-6 digit', () async {
      expect(await controller.setPasscode('123456'), isTrue);
      expect(await controller.hasPasscode(), isTrue);

      final String? salt = await storage.read(
        key: StorageConstants.keyPasscodeSalt,
      );
      final String? hash = await storage.read(
        key: StorageConstants.keyPasscodeHash,
      );
      expect(salt, isNotNull);
      expect(salt, isNotEmpty);
      expect(hash, isNotNull);
      expect(hash, hasLength(64));
    });

    test('setPasscode menolak PIN non-angka / di luar panjang', () async {
      expect(await controller.setPasscode('12'), isFalse);
      expect(await controller.setPasscode('123'), isFalse);
      expect(await controller.setPasscode('1234567'), isFalse);
      expect(await controller.setPasscode('12ab'), isFalse);
      expect(await controller.hasPasscode(), isFalse);
    });

    test('verifyPasscode cocok hanya dengan PIN yang benar', () async {
      await controller.setPasscode('2468');

      expect(await controller.verifyPasscode('2468'), isTrue);
      expect(await controller.verifyPasscode('1357'), isFalse);
    });

    test('setPasscode kedua mengubah kode kunci lama', () async {
      await controller.setPasscode('1111');
      await controller.setPasscode('2222');

      expect(await controller.verifyPasscode('2222'), isTrue);
      expect(await controller.verifyPasscode('1111'), isFalse);
    });

    test('disablePasscode menghapus kode kunci', () async {
      await controller.setPasscode('1234');

      expect(await controller.disablePasscode(), isTrue);
      expect(await controller.hasPasscode(), isFalse);
      expect(await controller.verifyPasscode('1234'), isFalse);
    });
  });
}
