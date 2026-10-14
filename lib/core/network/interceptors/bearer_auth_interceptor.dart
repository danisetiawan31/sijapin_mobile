import 'package:dio/dio.dart';

import '../../storage/secure_storage_service.dart';
import '../../storage/storage_constants.dart';

/// Interceptor autentikasi Bearer untuk REST API v2 SIIJAPIN
/// (SSOT: `.artifacts/PANDUAN_ENDPOINT_FLUTTER.md` aturan emas 3).
/// Melampirkan `Authorization: Bearer <token>` dari Secure Storage pada
/// setiap request; 401 hanya memberi sinyal (tanpa menghapus token —
/// penghapusan milik alur logout).
class BearerAuthInterceptor extends Interceptor {
  static const String hadBearerKey = 'sijapin_had_bearer';

  final ISecureStorage secureStorage;
  final void Function()? onSessionExpired;

  BearerAuthInterceptor({required this.secureStorage, this.onSessionExpired});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final String? token = await secureStorage.read(
        key: StorageConstants.keyBearerToken,
      );
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        options.extra[hadBearerKey] = true;
      }
    } catch (_) {
      // Tanpa token lanjut sebagai tamu; endpoint publik tetap terjangkau.
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final bool hadBearer =
        err.requestOptions.extra[hadBearerKey] == true ||
        ((err.requestOptions.headers['Authorization'] as String?)?.startsWith(
              'Bearer ',
            ) ??
            false);
    if (err.response?.statusCode == 401 && hadBearer) {
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}
