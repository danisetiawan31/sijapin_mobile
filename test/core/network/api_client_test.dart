import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/network/api_client.dart';
import 'package:sijapin_mobile/core/network/interceptors/api_envelope_interceptor.dart';
import 'package:sijapin_mobile/core/network/interceptors/bearer_auth_interceptor.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';

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
  group('ApiClient', () {
    test('initializes JSON BaseOptions from AppConfig', () {
      final ApiClient client = ApiClient(secureStorage: _FakeSecureStorage());

      final BaseOptions options = client.dio.options;
      expect(options.baseUrl, AppConfig.baseUrl);
      expect(options.connectTimeout, AppConfig.connectTimeout);
      expect(options.receiveTimeout, AppConfig.receiveTimeout);
      expect(options.headers['Accept'], 'application/json');
      expect(options.headers['Content-Type'], 'application/json');
    });

    test('registers Bearer + envelope interceptors in order', () {
      final ApiClient client = ApiClient(secureStorage: _FakeSecureStorage());

      final List<Interceptor> interceptors = client.dio.interceptors;
      final int bearerIndex = interceptors.indexWhere(
        (Interceptor i) => i is BearerAuthInterceptor,
      );
      final int envelopeIndex = interceptors.indexWhere(
        (Interceptor i) => i is ApiEnvelopeInterceptor,
      );
      expect(bearerIndex, greaterThanOrEqualTo(0));
      expect(envelopeIndex, greaterThan(bearerIndex));
    });

    test('accepts injected Dio without adding duplicate interceptors', () {
      final Dio dio = Dio();
      final int before = dio.interceptors.length;
      final ApiClient client = ApiClient(
        secureStorage: _FakeSecureStorage(),
        dio: dio,
      );

      expect(client.dio, same(dio));
      expect(dio.interceptors.length, before + 2);
    });
  });
}
