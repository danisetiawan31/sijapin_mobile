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

  /// Zona waktu resmi RSUP Dr. Sitanala (Tangerang, Banten)
  static const String timeZoneName = 'Asia/Jakarta';
  static const String timeZoneAbbr = 'WIB';

  /// Batas jam pembatalan tiket mandiri H-1 (21:00 WIB)
  static const int cancellationDeadlineHour = 21;

  /// Batas jam penutupan pendaftaran BPJS online H-1 (14:00 WIB)
  static const int bpjsRegistrationCutoffHour = 14;

  /// Jam buka operasional mesin APM / layanan pendaftaran
  static const String admissionServiceOpenTime = '06.30';
}
