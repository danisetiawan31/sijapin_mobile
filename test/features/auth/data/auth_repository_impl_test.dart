import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/cookie_manager_service.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sijapin_mobile/features/auth/data/repositories/auth_repository_impl.dart';

class _FakeSecureStorage implements ISecureStorage {
  final Map<String, String> _store = {};

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

class _FakeCookieManagerService implements ICookieManagerService {
  @override
  CookieJar get cookieJar => CookieJar();

  @override
  CookieManager? get cookieManager => null;

  @override
  Future<void> clearCookies() async {}

  @override
  Future<String?> getCiSessionToken(Uri baseUri) async =>
      'mock-ci-session-12345';

  @override
  Future<List<Cookie>> loadForRequest(Uri uri) async => [];

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {}
}

class _MockAuthRemoteDataSource implements IAuthRemoteDataSource {
  Map<String, dynamic> loginResponse = {
    'ret': 'success',
    'login': 1,
    'token': 'csrf-123',
  };
  Map<String, dynamic> registerResponse = {
    'ret': 'success',
    'msg': 'Pendaftaran berhasil',
  };
  bool shouldThrow = false;

  @override
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    return loginResponse;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) async {
    if (shouldThrow) throw Exception('Network error');
    return registerResponse;
  }

  @override
  Future<void> logout() async {}
}

void main() {
  group('AuthRepositoryImpl Unit Tests', () {
    late _MockAuthRemoteDataSource remoteDataSource;
    late _FakeSecureStorage secureStorage;
    late _FakeCookieManagerService cookieManager;
    late AuthRepositoryImpl repository;

    setUp(() {
      remoteDataSource = _MockAuthRemoteDataSource();
      secureStorage = _FakeSecureStorage();
      cookieManager = _FakeCookieManagerService();
      repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        secureStorage: secureStorage,
        cookieManagerService: cookieManager,
      );
    });

    test('login berhasil menyimpan session token dan nomor telepon', () async {
      final result = await repository.login(
        identifier: '081234567890',
        password: 'password123',
        rememberMe: true,
      );

      expect(result.success, isTrue);
      expect(result.message, 'Berhasil masuk ke layanan SIIJAPIN.');
      expect(
        await secureStorage.read(key: StorageConstants.keyCustomerPhoneNumber),
        '081234567890',
      );
      expect(
        await secureStorage.read(key: StorageConstants.keyCustomerSession),
        'mock-ci-session-12345',
      );
    });

    test(
      'login gagal kredensial salah mengembalikan pesan informatif',
      () async {
        remoteDataSource.loginResponse = {'ret': 'success', 'login': 2};

        final result = await repository.login(
          identifier: '081234567890',
          password: 'wrong-password',
          rememberMe: false,
        );

        expect(result.success, isFalse);
        expect(result.message, 'Nomor telepon atau kata sandi Anda salah.');
      },
    );

    test('login saat jaringan error ditangani secara graceful', () async {
      remoteDataSource.shouldThrow = true;

      final result = await repository.login(
        identifier: '081234567890',
        password: 'password123',
        rememberMe: false,
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Gagal terhubung ke server SIMRS'));
    });

    test('register sukses mengembalikan status true', () async {
      final result = await repository.register(
        fullName: 'Budi Santoso',
        phone: '081298765432',
        email: 'budi@example.com',
        birthDate: DateTime(1990, 5, 20),
        gender: 'L',
        password: 'secretPassword',
      );

      expect(result.success, isTrue);
      expect(result.message, contains('Pendaftaran berhasil'));
    });
  });
}
