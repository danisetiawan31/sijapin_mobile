import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/cookie_manager_service.dart';

void main() {
  late CookieJar inMemoryJar;
  late CookieManagerService cookieService;
  final testUri = Uri.parse('https://rsup-drsitanala.net/siijapin-v2/');

  setUp(() {
    inMemoryJar = CookieJar();
    cookieService = CookieManagerService(inMemoryJar);
  });

  group('CookieManagerService Test Suite', () {
    test(
      'saveFromResponse and loadForRequest should store and retrieve cookies',
      () async {
        final cookies = [
          Cookie(ApiConstants.sessionCookieName, 'test_ci_session_value_123')
            ..path = '/'
            ..domain = 'rsup-drsitanala.net',
        ];

        await cookieService.saveFromResponse(testUri, cookies);
        final loadedCookies = await cookieService.loadForRequest(testUri);

        expect(loadedCookies.length, 1);
        expect(loadedCookies.first.name, ApiConstants.sessionCookieName);
        expect(loadedCookies.first.value, 'test_ci_session_value_123');
      },
    );

    test(
      'getCiSessionToken should return ci_session value when exists',
      () async {
        final cookies = [
          Cookie(ApiConstants.sessionCookieName, 'session_abc_999')
            ..path = '/'
            ..domain = 'rsup-drsitanala.net',
        ];
        await cookieService.saveFromResponse(testUri, cookies);

        final token = await cookieService.getCiSessionToken(testUri);
        expect(token, 'session_abc_999');
      },
    );

    test(
      'getCiSessionToken should return null when ci_session does not exist',
      () async {
        final cookies = [
          Cookie('other_cookie', 'some_value')
            ..path = '/'
            ..domain = 'rsup-drsitanala.net',
        ];
        await cookieService.saveFromResponse(testUri, cookies);

        final token = await cookieService.getCiSessionToken(testUri);
        expect(token, isNull);
      },
    );

    test('clearCookies should delete all stored cookies', () async {
      final cookies = [
        Cookie(ApiConstants.sessionCookieName, 'to_be_deleted')
          ..path = '/'
          ..domain = 'rsup-drsitanala.net',
      ];
      await cookieService.saveFromResponse(testUri, cookies);

      await cookieService.clearCookies();
      final loadedCookies = await cookieService.loadForRequest(testUri);

      expect(loadedCookies, isEmpty);
    });
  });
}
