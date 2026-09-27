/// Konfigurasi global aplikasi SIIJAPIN Mobile
class AppConfig {
  const AppConfig._();

  static const String appName = 'SIIJAPIN Mobile';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://rsup-drsitanala.net/siijapin-v2/';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Sentry DSN untuk monitoring crash & error pelaporan
  static const String sentryDsn =
      'https://ac448d0abedd43ac92e03d425f46eade@o4512159208964096.ingest.us.sentry.io/4512159237668864';
}
