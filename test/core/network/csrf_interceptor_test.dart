import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/interceptors/csrf_interceptor.dart';

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late CsrfInterceptor interceptor;

  setUp(() {
    interceptor = CsrfInterceptor();
  });

  group('CsrfInterceptor Test Suite (US-CORE-02)', () {
    test(
      'Scenario 1: should extract token from response JSON property "token"',
      () {
        final response = Response<dynamic>(
          requestOptions: RequestOptions(path: '/Login/cek_login'),
          statusCode: 200,
          data: <String, dynamic>{
            'ret': 'success',
            'token': 'hash_csrf_pertama_123',
          },
        );

        final handler = MockResponseInterceptorHandler();
        interceptor.onResponse(response, handler);

        expect(interceptor.currentToken, 'hash_csrf_pertama_123');
        verify(() => handler.next(response)).called(1);
      },
    );

    test(
      'Scenario 2: should inject ci_csrf_token into Map data on POST request',
      () {
        interceptor.updateToken('active_token_abc');

        final options = RequestOptions(
          path: '/Login/cek_login',
          method: 'POST',
          data: <String, dynamic>{
            'nomor_telepon': '081234567890',
            'kunci': 'secret123',
          },
        );

        final handler = MockRequestInterceptorHandler();
        interceptor.onRequest(options, handler);

        final data = options.data as Map<String, dynamic>;
        expect(data[ApiConstants.csrfTokenKey], 'active_token_abc');
        expect(data['nomor_telepon'], '081234567890');
        verify(() => handler.next(options)).called(1);
      },
    );

    test('Scenario 3: should inject ci_csrf_token into FormData fields on POST request', () {
      interceptor.updateToken('active_token_formdata_456');

      final formData = FormData.fromMap(<String, dynamic>{
        'nama': 'Pasien Uji',
      });

      final options = RequestOptions(
        path: '/Registrasi/simpan',
        method: 'POST',
        data: formData,
      );

      final handler = MockRequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      final resultData = options.data as FormData;
      final csrfField = resultData.fields.firstWhere(
        (entry) => entry.key == ApiConstants.csrfTokenKey,
      );
      expect(csrfField.value, 'active_token_formdata_456');
      verify(() => handler.next(options)).called(1);
    });

    test('Scenario 4: should NOT inject token on GET requests', () {
      interceptor.updateToken('active_token_get');

      final options = RequestOptions(path: '/Ket_Kamar', method: 'GET');

      final handler = MockRequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      expect(options.data, isNull);
      verify(() => handler.next(options)).called(1);
    });

    test(
      'Scenario 5: should handle token rotation between consecutive calls',
      () {
        // 1. Panggilan pertama server memberikan token A
        final responseA = Response<dynamic>(
          requestOptions: RequestOptions(path: '/api_a'),
          statusCode: 200,
          data: <String, dynamic>{'token': 'token_alpha'},
        );
        interceptor.onResponse(responseA, MockResponseInterceptorHandler());
        expect(interceptor.currentToken, 'token_alpha');

        // 2. Request berikutnya menggunakan token A
        final requestOptionsA = RequestOptions(
          path: '/submit_a',
          method: 'POST',
          data: <String, dynamic>{'field': '1'},
        );
        interceptor.onRequest(requestOptionsA, MockRequestInterceptorHandler());
        expect(
          (requestOptionsA.data
              as Map<String, dynamic>)[ApiConstants.csrfTokenKey],
          'token_alpha',
        );

        // 3. Server merespons dengan token rotasi baru B
        final responseB = Response<dynamic>(
          requestOptions: RequestOptions(path: '/submit_a'),
          statusCode: 200,
          data: <String, dynamic>{'token': 'token_beta'},
        );
        interceptor.onResponse(responseB, MockResponseInterceptorHandler());
        expect(interceptor.currentToken, 'token_beta');

        // 4. Request selanjutnya wajib menggunakan token B yang baru
        final requestOptionsB = RequestOptions(
          path: '/submit_b',
          method: 'POST',
          data: <String, dynamic>{'field': '2'},
        );
        interceptor.onRequest(requestOptionsB, MockRequestInterceptorHandler());
        expect(
          (requestOptionsB.data
              as Map<String, dynamic>)[ApiConstants.csrfTokenKey],
          'token_beta',
        );
      },
    );

    test('Scenario 6: clearToken should remove active token from memory', () {
      interceptor.updateToken('token_to_clear');
      expect(interceptor.currentToken, 'token_to_clear');

      interceptor.clearToken();
      expect(interceptor.currentToken, isNull);
    });
  });
}
