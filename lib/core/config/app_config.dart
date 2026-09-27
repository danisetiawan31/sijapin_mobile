/// Konfigurasi global aplikasi SIIJAPIN Mobile
class AppConfig {
  const AppConfig._();

  static const String appName = 'SIIJAPIN Mobile';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://rsup-drsitanala.net/siijapin-v2/';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
