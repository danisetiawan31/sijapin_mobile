import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/errors/failures.dart';
import 'package:sijapin_mobile/core/network/dio_error_handler.dart';

void main() {
  group('DioErrorHandler Tests', () {
    final testRequestOptions = RequestOptions(path: '/test');

    test('maps connection timeout to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final result = DioErrorHandler.handle(dioError);
      expect(result, isA<NetworkFailure>());
    });

    test('maps connectionError to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
      );

      final result = DioErrorHandler.handle(dioError);
      expect(result, isA<NetworkFailure>());
    });

    test('maps 401 or 302 badResponse to SessionExpiredFailure', () {
      final error401 = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: testRequestOptions, statusCode: 401),
      );

      expect(DioErrorHandler.handle(error401), isA<SessionExpiredFailure>());

      final error302 = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: testRequestOptions, statusCode: 302),
      );

      expect(DioErrorHandler.handle(error302), isA<SessionExpiredFailure>());
    });

    test('maps 403 badResponse to CsrfMismatchFailure', () {
      final error403 = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: testRequestOptions, statusCode: 403),
      );

      expect(DioErrorHandler.handle(error403), isA<CsrfMismatchFailure>());
    });

    test('maps 500+ badResponse to ServerMaintenanceFailure', () {
      final error500 = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: testRequestOptions, statusCode: 500),
      );

      expect(DioErrorHandler.handle(error500), isA<ServerMaintenanceFailure>());

      final error503 = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: testRequestOptions, statusCode: 503),
      );

      expect(DioErrorHandler.handle(error503), isA<ServerMaintenanceFailure>());
    });

    test('extracts custom error message from JSON response', () {
      final error400 = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 400,
          data: <String, dynamic>{'pesan': 'Nomor RM tidak terdaftar'},
        ),
      );

      final failure = DioErrorHandler.handle(error400);
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, equals('Nomor RM tidak terdaftar'));
    });

    test('maps unknown error with SocketException to NetworkFailure', () {
      final errorUnknown = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.unknown,
        error: const SocketException('Failed host lookup'),
      );

      expect(DioErrorHandler.handle(errorUnknown), isA<NetworkFailure>());
    });

    test('returns existing Failure directly', () {
      const existing = NetworkFailure('Custom network error');
      expect(DioErrorHandler.handle(existing), equals(existing));
    });
  });
}
