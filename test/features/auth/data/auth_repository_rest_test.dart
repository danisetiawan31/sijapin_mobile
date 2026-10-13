import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/api_client.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';
import 'package:sijapin_mobile/core/network/cookie_manager_service.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:sijapin_mobile/features/auth/data/datasources/auth_rest_data_source.dart';
import 'package:sijapin_mobile/features/auth/data/repositories/auth_repository_impl.dart';

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
  Future<List<Cookie>> loadForRequest(Uri uri) async => <Cookie>[];

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) async {}
}

class _MockCi3DataSource implements IAuthRemoteDataSource {
  int loginCalls = 0;
  bool loginShouldThrow = false;
  Map<String, dynamic> loginResponse = <String, dynamic>{
    'ret': 'success',
    'login': 1,
  };

  @override
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    loginCalls++;
    if (loginShouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: 'Login/cek_login'),
      );
    }
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
    return <String, dynamic>{'ret': 'success'};
  }

  @override
  Future<void> logout() async {}
}

class _DummyApiClient implements ApiClient {
  @override
  Dio get dio => throw UnimplementedError();

  @override
  ISecureStorage get secureStorage => throw UnimplementedError();

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    throw UnimplementedError();
  }
}

class _FakeRestDataSource extends AuthRestDataSource {
  _FakeRestDataSource() : super(apiClient: _DummyApiClient());

  Map<String, dynamic>? loginPayload;
  Map<String, dynamic>? profilePayload;
  bool profileShouldThrow = false;
  ApiException? definitiveError;
  DioException? transportError;
  int logoutCalls = 0;

  @override
  Future<Map<String, dynamic>> loginRest({
    required String phoneNumber,
    required String password,
  }) async {
    final ApiException? definitive = definitiveError;
    if (definitive != null) {
      throw definitive;
    }
    final DioException? transport = transportError;
    if (transport != null) {
      throw transport;
    }
    return loginPayload ?? <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> fetchRestProfile() async {
    if (profileShouldThrow) {
      throw const ApiException('Sesi berakhir atau tidak valid.');
    }
    return profilePayload ?? <String, dynamic>{};
  }

  @override
  Future<void> logoutRest() async {
    logoutCalls++;
  }
}

Map<String, dynamic> _restPayload() {
  return <String, dynamic>{
    'token': 'rest-bearer-token',
    'token_type': 'Bearer',
    'expires_at': '2026-11-11T00:00:00+07:00',
  };
}

Map<String, dynamic> _restProfile() {
  return <String, dynamic>{
    'id_customer': 163958,
    'nama': 'Ahmad Dani',
    'nomor_telepon': '0812000000',
    'email': 'ahmad@example.com',
    'tanggal_lahir': '1990-05-20',
    'jenis_kelamin': 'L',
    'alamat': 'Tangerang',
  };
}

void main() {
  group('AuthRepositoryImpl REST primary + CI3 fallback', () {
    late _MockCi3DataSource ci3;
    late _FakeRestDataSource rest;
    late _FakeSecureStorage secureStorage;
    late _FakeCookieManagerService cookieManager;
    late AuthRepositoryImpl repository;

    setUp(() {
      ci3 = _MockCi3DataSource();
      rest = _FakeRestDataSource();
      secureStorage = _FakeSecureStorage();
      cookieManager = _FakeCookieManagerService();
      repository = AuthRepositoryImpl(
        remoteDataSource: ci3,
        secureStorage: secureStorage,
        cookieManagerService: cookieManager,
        restDataSource: rest,
      );
    });

    test('REST-ok persists bearer token and plants CI3 cookie', () async {
      rest.loginPayload = _restPayload();
      rest.profilePayload = _restProfile();

      final result = await repository.login(
        identifier: '0812000000',
        password: 'rahasia',
        rememberMe: true,
      );

      expect(result.success, isTrue);
      // Cookie CI3 ditanam best-effort untuk endpoint tulis legacy.
      expect(ci3.loginCalls, 1);
      expect(
        await secureStorage.read(key: StorageConstants.keyBearerToken),
        'rest-bearer-token',
      );
      expect(
        await secureStorage.read(key: StorageConstants.keyBearerExpiresAt),
        '2026-11-11T00:00:00+07:00',
      );
      expect(
        await secureStorage.read(key: StorageConstants.keyCustomerPhoneNumber),
        '0812000000',
      );
      expect(result.profile, _restProfile());
    });

    test(
      'profile fetch failure still succeeds login with null profile',
      () async {
        rest.loginPayload = _restPayload();
        rest.profileShouldThrow = true;

        final result = await repository.login(
          identifier: '0812000000',
          password: 'rahasia',
          rememberMe: true,
        );

        expect(result.success, isTrue);
        expect(result.profile, isNull);
        expect(ci3.loginCalls, 1);
      },
    );

    test(
      'definitive ApiException surfaces verbatim without fallback',
      () async {
        rest.definitiveError = const ApiException(
          'Nomor telepon atau kata sandi salah.',
        );

        final result = await repository.login(
          identifier: '0812000000',
          password: 'salah',
          rememberMe: false,
        );

        expect(result.success, isFalse);
        expect(result.message, 'Nomor telepon atau kata sandi salah.');
        expect(ci3.loginCalls, 0);
      },
    );

    test('kegagalan tanam cookie tidak menggagalkan login REST', () async {
      rest.loginPayload = _restPayload();
      rest.profilePayload = _restProfile();
      ci3.loginShouldThrow = true;

      final result = await repository.login(
        identifier: '0812000000',
        password: 'rahasia',
        rememberMe: true,
      );

      expect(result.success, isTrue);
      expect(ci3.loginCalls, 1);
      expect(
        await secureStorage.read(key: StorageConstants.keyBearerToken),
        'rest-bearer-token',
      );
    });

    test('connection error falls back to CI3', () async {
      rest.transportError = DioException(
        requestOptions: RequestOptions(path: 'api/v1/auth/login'),
        type: DioExceptionType.connectionError,
      );

      final result = await repository.login(
        identifier: '0812000000',
        password: 'rahasia',
        rememberMe: true,
      );

      expect(result.success, isTrue);
      expect(ci3.loginCalls, 1);
      expect(
        await secureStorage.read(key: StorageConstants.keyCustomerSession),
        'mock-ci-session-12345',
      );
    });

    test('HTTP 503 falls back to CI3', () async {
      final RequestOptions options = RequestOptions(path: 'api/v1/auth/login');
      rest.transportError = DioException(
        requestOptions: options,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 503,
          data: '<html>maintenance</html>',
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.login(
        identifier: '0812000000',
        password: 'rahasia',
        rememberMe: false,
      );

      expect(result.success, isTrue);
      expect(ci3.loginCalls, 1);
    });

    test('logout revokes REST token and clears bearer key', () async {
      await secureStorage.write(
        key: StorageConstants.keyBearerToken,
        value: 'rest-bearer-token',
      );
      await secureStorage.write(
        key: StorageConstants.keyCustomerPhoneNumber,
        value: '0812000000',
      );

      await repository.logout();

      expect(rest.logoutCalls, 1);
      expect(
        await secureStorage.containsKey(key: StorageConstants.keyBearerToken),
        isFalse,
      );
      expect(
        await secureStorage.containsKey(
          key: StorageConstants.keyCustomerPhoneNumber,
        ),
        isFalse,
      );
    });
  });
}
