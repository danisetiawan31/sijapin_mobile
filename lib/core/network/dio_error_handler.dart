import 'dart:io';

import 'package:dio/dio.dart';

import '../errors/failures.dart';

/// Handler terpusat untuk memetakan error jaringan Dio ke domain Failure
class DioErrorHandler {
  const DioErrorHandler._();

  /// Mengonversi exception/error menjadi objek domain Failure
  static Failure handle(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
        case DioExceptionType.connectionError:
          return const NetworkFailure();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401 || statusCode == 302) {
            return const SessionExpiredFailure();
          }
          if (statusCode == 403) {
            return const CsrfMismatchFailure();
          }
          if (statusCode != null && statusCode >= 500) {
            return const ServerMaintenanceFailure();
          }

          // Periksa pesan spesifik dari backend CI3 jika ada
          final data = error.response?.data;
          if (data is Map<String, dynamic>) {
            final msg = data['pesan'] ?? data['message'] ?? data['error'];
            if (msg != null && msg.toString().trim().isNotEmpty) {
              return ValidationFailure(msg.toString().trim());
            }
          }
          return ValidationFailure(
            'Permintaan gagal diproses (${statusCode ?? "Error"}). Silakan coba lagi.',
          );

        case DioExceptionType.cancel:
          return const ValidationFailure('Permintaan dibatalkan.');

        case DioExceptionType.badCertificate:
          return const NetworkFailure(
            'Sertifikat keamanan server tidak valid.',
          );

        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return const NetworkFailure();
          }
          return ValidationFailure(
            error.message ?? 'Terjadi kesalahan tidak terduga.',
          );
      }
    }

    if (error is Failure) {
      return error;
    }

    return ValidationFailure(error.toString());
  }
}
