import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'cookie_manager_service.dart';
import 'interceptors/csrf_interceptor.dart';
import 'interceptors/session_expired_interceptor.dart';

/// Client HTTP terpusat untuk komunikasi dengan backend CodeIgniter 3 RSUP Dr. Sitanala
class DioClient {
  final Dio _dio;
  final ICookieManagerService cookieManagerService;
  final CsrfInterceptor csrfInterceptor;

  DioClient({
    required this.cookieManagerService,
    CsrfInterceptor? csrfInterceptor,
    Dio? dio,
    void Function()? onSessionExpired,
    List<Interceptor>? additionalInterceptors,
  }) : csrfInterceptor = csrfInterceptor ?? CsrfInterceptor(),
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: AppConfig.baseUrl,
               connectTimeout: AppConfig.connectTimeout,
               receiveTimeout: AppConfig.receiveTimeout,
               headers: const {
                 'Accept': 'application/json, text/html, */*',
                 'Content-Type': 'application/x-www-form-urlencoded',
                 'User-Agent': 'SIIJAPIN-Mobile/1.0.0 (Android/iOS)',
               },
               followRedirects: false,
               validateStatus: (status) {
                 // Izinkan status 200 s/d 399 agar redirect 302 dapat diinspeksi oleh interceptor
                 return status != null && status >= 200 && status < 400;
               },
             ),
           ) {
    _dio.interceptors.add(this.csrfInterceptor);
    _dio.interceptors.add(cookieManagerService.cookieManager);
    _dio.interceptors.add(
      SessionExpiredInterceptor(onSessionExpired: onSessionExpired),
    );
    if (additionalInterceptors != null) {
      _dio.interceptors.addAll(additionalInterceptors);
    }
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
    dynamic data,
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
