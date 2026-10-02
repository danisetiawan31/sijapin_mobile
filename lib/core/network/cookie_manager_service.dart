import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/api_constants.dart';

/// Kontrak interface untuk Cookie Manager Service
abstract class ICookieManagerService {
  /// Instance CookieJar (Memory atau Persist)
  CookieJar get cookieJar;

  /// Interceptor Dio CookieManager (null jika berjalan di platform Web)
  CookieManager? get cookieManager;

  /// Mengambil daftar cookie untuk URI tertentu
  Future<List<Cookie>> loadForRequest(Uri uri);

  /// Menyimpan cookie untuk URI tertentu
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies);

  /// Menghapus seluruh cookie sesi (saat logout)
  Future<void> clearCookies();

  /// Mengambil nilai session ID 'ci_session' aktif jika ada
  Future<String?> getCiSessionToken(Uri baseUri);
}

/// Implementasi Cookie Manager dengan dukungan penyimpanan persisten disk lokal
class CookieManagerService implements ICookieManagerService {
  final CookieJar _cookieJar;
  late final CookieManager? _cookieManager;

  CookieManagerService(this._cookieJar) {
    _cookieManager = kIsWeb ? null : CookieManager(_cookieJar);
  }

  @override
  CookieManager? get cookieManager => _cookieManager;

  /// Factory untuk inisialisasi persisten di direktori aman aplikasi mobile
  static Future<CookieManagerService> createPersistent([
    String? customPath,
  ]) async {
    if (kIsWeb) {
      return CookieManagerService(CookieJar());
    }

    final String storagePath;
    if (customPath != null) {
      storagePath = customPath;
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      storagePath = p.join(appDir.path, '.cookies');
    }

    final persistJar = PersistCookieJar(
      storage: FileStorage(storagePath),
      persistSession: true,
      ignoreExpires: true,
    );

    return CookieManagerService(persistJar);
  }

  /// Factory untuk testing menggunakan in-memory CookieJar
  factory CookieManagerService.inMemory() {
    return CookieManagerService(CookieJar());
  }

  @override
  CookieJar get cookieJar => _cookieJar;

  @override
  Future<List<Cookie>> loadForRequest(Uri uri) {
    return _cookieJar.loadForRequest(uri);
  }

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) {
    return _cookieJar.saveFromResponse(uri, cookies);
  }

  @override
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  @override
  Future<String?> getCiSessionToken(Uri baseUri) async {
    final cookies = await _cookieJar.loadForRequest(baseUri);
    for (final cookie in cookies) {
      if (cookie.name == ApiConstants.sessionCookieName ||
          cookie.name == 'cisession' ||
          cookie.name == 'ci_session') {
        return cookie.value;
      }
    }
    return null;
  }
}
