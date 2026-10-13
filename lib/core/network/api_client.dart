import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'interceptors/api_envelope_interceptor.dart';
import 'interceptors/bearer_auth_interceptor.dart';
import 'session_expiry_controller.dart';

/// Client HTTP JSON untuk REST API v2 SIIJAPIN
/// (SSOT: `.artifacts/PANDUAN_ENDPOINT_FLUTTER.md` aturan emas 1–4).
/// Terpisah dari [DioClient] CI3 karena interceptor CSRF-nya menyuntik token
/// ke body POST — tidak valid untuk payload JSON. Base URL sama-sama dari
/// [AppConfig.baseUrl] (compile-time `--dart-define=API_BASE_URL`).
class ApiClient {
  final Dio _dio;
  final ISecureStorage secureStorage;

  ApiClient({
    required this.secureStorage,
    Dio? dio,
    void Function()? onSessionExpired,
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: AppConfig.baseUrl,
               connectTimeout: AppConfig.connectTimeout,
               receiveTimeout: AppConfig.receiveTimeout,
               headers: const <String, dynamic>{
                 'Accept': 'application/json',
                 'Content-Type': 'application/json',
               },
               validateStatus: (int? status) {
                 return status != null && status >= 200 && status < 400;
               },
             ),
           ) {
    _dio.interceptors.add(
      BearerAuthInterceptor(
        secureStorage: secureStorage,
        onSessionExpired: onSessionExpired,
      ),
    );
    _dio.interceptors.add(ApiEnvelopeInterceptor());
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Provider Riverpod untuk ApiClient REST JSON.
/// 401 terpusat: [BearerAuthInterceptor] memanggil balik ke sini → token
/// dihapus + sinyal sesi-kedaluwarsa dikibarkan → router ke layar login.
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiClient(
    secureStorage: secureStorage,
    onSessionExpired: () {
      // Interceptor sync: biarkan penghapusan berjalan tanpa menunggu.
      unawaited(handleSessionExpired(ref));
    },
  );
});
