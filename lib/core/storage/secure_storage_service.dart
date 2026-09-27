import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kontrak abstraksi penyimpanan data sensitif terenkripsi hardware (UU PDP)
abstract class ISecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
}

/// Implementasi penyimpanan aman menggunakan Android Keystore (AES-256)
/// dan iOS Keychain Services (kSecAttrAccessibleAfterFirstUnlock)
class SecureStorageService implements ISecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorageService([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key: key);
  }
}

/// Provider Riverpod untuk SecureStorageService
final secureStorageServiceProvider = Provider<ISecureStorage>((ref) {
  return SecureStorageService();
});
