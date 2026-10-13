import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/interceptors/bearer_auth_interceptor.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';

class _FakeSecureStorage implements ISecureStorage {
  final Map<String, String> _store = <String, String>{};

  void seed(String token) => _store[StorageConstants.keyBearerToken] = token;

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

/// Dio hermetik: interceptor subjek + stub transport paling akhir.
Dio _stubDio(
  Interceptor subject, {
  Map<String, String?>? capturedHeaders,
  Object? stubData,
  DioException? stubError,
}) {
  final Dio dio = Dio();
  dio.interceptors.add(subject);
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        capturedHeaders?.addAll(
          options.headers.map(
            (String key, dynamic value) =>
                MapEntry<String, String?>(key, value?.toString()),
          ),
        );
        final DioException? error = stubError;
        if (error != null) {
          handler.reject(error, true);
          return;
        }
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: stubData,
          ),
          true,
        );
      },
    ),
  );
  return dio;
}

void main() {
  group('BearerAuthInterceptor', () {
    test('attaches Bearer token from secure storage', () async {
      final _FakeSecureStorage storage = _FakeSecureStorage();
      storage.seed('tok-abc-123');
      final Map<String, String?> captured = <String, String?>{};
      final Dio dio = _stubDio(
        BearerAuthInterceptor(secureStorage: storage),
        capturedHeaders: captured,
      );

      await dio.get<dynamic>('/api/v1/profile');

      expect(captured['Authorization'], 'Bearer tok-abc-123');
    });

    test('sends no Authorization header without stored token', () async {
      final _FakeSecureStorage storage = _FakeSecureStorage();
      final Map<String, String?> captured = <String, String?>{};
      final Dio dio = _stubDio(
        BearerAuthInterceptor(secureStorage: storage),
        capturedHeaders: captured,
      );

      await dio.get<dynamic>('/Ket_Kamar');

      expect(captured.containsKey('Authorization'), isFalse);
    });

    test('notifies session-expired callback on 401', () async {
      final _FakeSecureStorage storage = _FakeSecureStorage();
      bool notified = false;
      final Dio dio = _stubDio(
        BearerAuthInterceptor(
          secureStorage: storage,
          onSessionExpired: () => notified = true,
        ),
        stubError: DioException(
          requestOptions: RequestOptions(path: '/api/v1/profile'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/api/v1/profile'),
            statusCode: 401,
            data: <String, dynamic>{'message': 'Unauthenticated.'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      await expectLater(
        dio.get<dynamic>('/api/v1/profile'),
        throwsA(isA<DioException>()),
      );
      expect(notified, isTrue);
    });

    test('does not notify on non-401 transport errors', () async {
      final _FakeSecureStorage storage = _FakeSecureStorage();
      bool notified = false;
      final Dio dio = _stubDio(
        BearerAuthInterceptor(
          secureStorage: storage,
          onSessionExpired: () => notified = true,
        ),
        stubError: DioException(
          requestOptions: RequestOptions(path: '/Ket_Kamar'),
          type: DioExceptionType.connectionError,
        ),
      );

      await expectLater(
        dio.get<dynamic>('/Ket_Kamar'),
        throwsA(isA<DioException>()),
      );
      expect(notified, isFalse);
    });
  });
}
