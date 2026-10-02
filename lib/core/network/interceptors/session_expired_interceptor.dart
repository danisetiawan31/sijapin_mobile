import 'package:dio/dio.dart';

/// Interceptor untuk mendeteksi sesi server CodeIgniter 3 yang kedaluwarsa (> 30 menit)
/// Memungkinkan aplikasi menangani timeout secara anggun (graceful timeout)
/// tanpa menghilangkan draft isian formulir pasien.
class SessionExpiredInterceptor extends Interceptor {
  final void Function()? onSessionExpired;

  SessionExpiredInterceptor({this.onSessionExpired});

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (_isSessionExpiredResponse(response)) {
      onSessionExpired?.call();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onSessionExpired?.call();
    }
    handler.next(err);
  }

  bool _isSessionExpiredResponse(Response<dynamic> response) {
    // 1. Cek Redirect HTTP 301, 302, 303, 307, 308 ke halaman Login CI3
    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 300 && statusCode < 400) {
      final location = response.headers.value('location') ?? '';
      if (location.toLowerCase().contains('login')) {
        return true;
      }
    }

    // 2. Cek Payload JSON respons CI3 (misal: {"login": 0})
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['login'] == 0) {
        return true;
      }
      final msg = data['msg']?.toString().toLowerCase() ?? '';
      if (msg.contains('sesi telah habis') ||
          msg.contains('session expired') ||
          msg.contains('silahkan login') ||
          msg.contains('login terlebih dahulu')) {
        return true;
      }
    }

    return false;
  }
}
