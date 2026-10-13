import 'package:dio/dio.dart';

import '../api_response.dart';

/// Interceptor validasi envelope seragam REST API v2 SIIJAPIN.
/// `success:false` (HTTP 200 maupun status galat) diubah menjadi
/// [ApiException] definitif; selain itu error diteruskan apa adanya agar
/// pemanggil dapat memutuskan fallback transport.
class ApiEnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final Object? body = response.data;
    if (body is! Map<String, dynamic>) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: const ApiException('Format respons server tidak valid.'),
        ),
      );
      return;
    }
    final ApiEnvelope envelope = ApiEnvelope.fromJson(body);
    if (!envelope.success) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: ApiException(
            envelope.message.isEmpty
                ? 'Permintaan gagal diproses.'
                : envelope.message,
            status: envelope.status,
            errors: envelope.errors,
          ),
        ),
      );
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final Object? body = err.response?.data;
    if (body is Map<String, dynamic>) {
      final ApiEnvelope envelope = ApiEnvelope.fromJson(body);
      if (!envelope.success) {
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: ApiException(
              envelope.message.isEmpty
                  ? 'Permintaan gagal diproses.'
                  : envelope.message,
              status: envelope.status,
              errors: envelope.errors,
            ),
          ),
        );
        return;
      }
    }
    handler.next(err);
  }
}
