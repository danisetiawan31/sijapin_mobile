import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sijapin_mobile/core/network/interceptors/session_expired_interceptor.dart';

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  group('SessionExpiredInterceptor Test Suite', () {
    test('should trigger onSessionExpired when response is 302 redirecting to Login', () {
      var isExpiredTriggered = false;
      final interceptor = SessionExpiredInterceptor(
        onSessionExpired: () => isExpiredTriggered = true,
      );

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/daftar_log'),
        statusCode: 302,
        headers: Headers.fromMap({
          'location': ['https://rsup-drsitanala.net/siijapin-v2/Login'],
        }),
      );

      final handler = MockResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(isExpiredTriggered, isTrue);
      verify(() => handler.next(response)).called(1);
    });

    test(
      'should trigger onSessionExpired when response JSON contains login: 0',
      () {
        var isExpiredTriggered = false;
        final interceptor = SessionExpiredInterceptor(
          onSessionExpired: () => isExpiredTriggered = true,
        );

        final response = Response<dynamic>(
          requestOptions: RequestOptions(
            path: '/Daftar_Kunj_Raja/insert_daftar_rajal',
          ),
          statusCode: 200,
          data: {
            'ret': 'failed',
            'login': 0,
            'msg': 'Sesi telah habis, silahkan login kembali',
          },
        );

        final handler = MockResponseInterceptorHandler();
        interceptor.onResponse(response, handler);

        expect(isExpiredTriggered, isTrue);
        verify(() => handler.next(response)).called(1);
      },
    );

    test(
      'should trigger onSessionExpired when response status code is 401',
      () {
        var isExpiredTriggered = false;
        final interceptor = SessionExpiredInterceptor(
          onSessionExpired: () => isExpiredTriggered = true,
        );

        final err = DioException(
          requestOptions: RequestOptions(path: '/daftar_log'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/daftar_log'),
            statusCode: 401,
          ),
        );

        final handler = MockErrorInterceptorHandler();
        interceptor.onError(err, handler);

        expect(isExpiredTriggered, isTrue);
        verify(() => handler.next(err)).called(1);
      },
    );

    test('should NOT trigger onSessionExpired on normal 200 response with active session', () {
      var isExpiredTriggered = false;
      final interceptor = SessionExpiredInterceptor(
        onSessionExpired: () => isExpiredTriggered = true,
      );

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/daftar_log'),
        statusCode: 200,
        data: {'ret': 'success', 'login': 1, 'data': <dynamic>[]},
      );

      final handler = MockResponseInterceptorHandler();
      interceptor.onResponse(response, handler);

      expect(isExpiredTriggered, isFalse);
      verify(() => handler.next(response)).called(1);
    });
  });
}
