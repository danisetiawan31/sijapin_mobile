import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';
import 'package:sijapin_mobile/core/network/interceptors/api_envelope_interceptor.dart';

/// Dio hermetik dengan [ApiEnvelopeInterceptor] + stub transport.
Dio _envelopeDio({Object? stubData, DioException? stubError}) {
  final Dio dio = Dio();
  dio.interceptors.add(ApiEnvelopeInterceptor());
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
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

DioException _httpError({required int statusCode, required Object? data}) {
  final RequestOptions options = RequestOptions(path: '/api/v1/auth/login');
  return DioException(
    requestOptions: options,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  group('ApiEnvelopeInterceptor', () {
    test('passes through success envelope untouched', () async {
      final Dio dio = _envelopeDio(
        stubData: <String, dynamic>{
          'status': 200,
          'success': true,
          'message': 'OK',
          'data': <String, dynamic>{'token': 't'},
          'errors': null,
          'meta': <String, dynamic>{'version': '2.0'},
        },
      );

      final Response<dynamic> response = await dio.get<dynamic>('/x');

      final Object? body = response.data;
      expect(body, isA<Map<String, dynamic>>());
      expect((body as Map<String, dynamic>)['data'], <String, dynamic>{
        'token': 't',
      });
    });

    test(
      'rejects success:false on HTTP 200 as ApiException verbatim',
      () async {
        final Dio dio = _envelopeDio(
          stubData: <String, dynamic>{
            'status': 200,
            'success': false,
            'message': 'Nomor telepon atau kata sandi salah.',
            'data': null,
            'errors': null,
            'meta': null,
          },
        );

        await expectLater(
          dio.get<dynamic>('/x'),
          throwsA(
            isA<DioException>().having(
              (DioException e) => e.error,
              'error',
              isA<ApiException>().having(
                (ApiException e) => e.message,
                'message',
                'Nomor telepon atau kata sandi salah.',
              ),
            ),
          ),
        );
      },
    );

    test(
      'converts error-status envelope to ApiException (definitive)',
      () async {
        final Dio dio = _envelopeDio(
          stubError: _httpError(
            statusCode: 422,
            data: <String, dynamic>{
              'status': 422,
              'success': false,
              'message': 'Validasi gagal',
              'data': null,
              'errors': <String, dynamic>{'kunci': 'wajib diisi'},
              'meta': null,
            },
          ),
        );

        await expectLater(
          dio.get<dynamic>('/x'),
          throwsA(
            isA<DioException>().having(
              (DioException e) => e.error,
              'error',
              isA<ApiException>()
                  .having(
                    (ApiException e) => e.message,
                    'message',
                    'Validasi gagal',
                  )
                  .having(
                    (ApiException e) => e.errors,
                    'errors',
                    <String, String>{'kunci': 'wajib diisi'},
                  ),
            ),
          ),
        );
      },
    );

    test('passes through transport errors without envelope', () async {
      final Dio dio = _envelopeDio(
        stubError: DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
        ),
      );

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having(
            (DioException e) => e.error,
            'error',
            isNull,
          ),
        ),
      );
    });

    test('rejects non-Map body as ApiException', () async {
      final Dio dio = _envelopeDio(stubData: '<html>bukan json</html>');

      await expectLater(
        dio.get<dynamic>('/x'),
        throwsA(
          isA<DioException>().having(
            (DioException e) => e.error,
            'error',
            isA<ApiException>(),
          ),
        ),
      );
    });
  });
}
