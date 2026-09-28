import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/network/cookie_manager_service.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';

void main() {
  group('DioClient Test Suite', () {
    test('should initialize with correct BaseOptions and default headers', () {
      final cookieService = CookieManagerService(CookieJar());
      final client = DioClient(cookieManagerService: cookieService);

      final options = client.dio.options;
      expect(options.baseUrl, AppConfig.baseUrl);
      expect(options.connectTimeout, AppConfig.connectTimeout);
      expect(options.receiveTimeout, AppConfig.receiveTimeout);
      expect(options.headers['Accept'], 'application/json, text/html, */*');
      expect(
        options.headers['Content-Type'],
        'application/x-www-form-urlencoded',
      );
      expect(
        options.headers['User-Agent'],
        'SIIJAPIN-Mobile/1.0.0 (Android/iOS)',
      );
    });

    test('should register CookieManager in interceptors', () {
      final cookieService = CookieManagerService(CookieJar());
      final client = DioClient(cookieManagerService: cookieService);

      final hasCookieManager = client.dio.interceptors.any(
        (i) => i == cookieService.cookieManager,
      );
      expect(hasCookieManager, isTrue);
    });

    test('should register CsrfInterceptor in interceptors', () {
      final cookieService = CookieManagerService(CookieJar());
      final client = DioClient(cookieManagerService: cookieService);

      final hasCsrfInterceptor = client.dio.interceptors.any(
        (i) => i == client.csrfInterceptor,
      );
      expect(hasCsrfInterceptor, isTrue);
    });
  });
}
