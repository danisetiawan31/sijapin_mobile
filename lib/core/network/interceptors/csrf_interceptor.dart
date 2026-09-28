import 'package:dio/dio.dart';

import '../../constants/api_constants.dart';

/// Interceptor untuk mengekstrak token anti-CSRF CodeIgniter 3 secara otomatis dari respons server
/// dan menyuntikkannya ke setiap payload mutasi bertipe POST/PUT/DELETE.
class CsrfInterceptor extends Interceptor {
  String? _currentToken;
  final String csrfKey;

  CsrfInterceptor({
    String? initialToken,
    this.csrfKey = ApiConstants.csrfTokenKey,
  }) : _currentToken = initialToken;

  /// Token CSRF aktif terkini di memori
  String? get currentToken => _currentToken;

  /// Memperbarui token secara manual jika diperlukan
  void updateToken(String token) {
    if (token.isNotEmpty) {
      _currentToken = token;
    }
  }

  /// Menghapus token (misal saat logout)
  void clearToken() {
    _currentToken = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final method = options.method.toUpperCase();

    // Hanya injeksikan token pada request mutasi (POST, PUT, DELETE, PATCH)
    if (_currentToken != null &&
        (method == 'POST' ||
            method == 'PUT' ||
            method == 'DELETE' ||
            method == 'PATCH')) {
      final dynamic data = options.data;

      if (data is FormData) {
        // Hapus entri lama jika sudah ada, lalu tambahkan token terbaru
        data.fields.removeWhere((entry) => entry.key == csrfKey);
        data.fields.add(MapEntry(csrfKey, _currentToken!));
      } else if (data is Map<String, dynamic>) {
        data[csrfKey] = _currentToken!;
      } else if (data == null) {
        options.data = <String, dynamic>{csrfKey: _currentToken!};
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _extractAndSaveToken(response.data);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _extractAndSaveToken(err.response!.data);
    }
    handler.next(err);
  }

  void _extractAndSaveToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Backend CI3 biasanya mengirimkan token dalam properti "token" atau "ci_csrf_token"
      final dynamic token =
          data['token'] ?? data[csrfKey] ?? data['csrf_token'];
      if (token is String && token.isNotEmpty) {
        _currentToken = token;
      }
    }
  }
}
