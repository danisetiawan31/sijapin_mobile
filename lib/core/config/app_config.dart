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

  /// Batas jam dan menit pembatalan tiket mandiri H-1 (23:59 WIB)
  static const int cancellationDeadlineHour = 23;
  static const int cancellationDeadlineMinute = 59;
  static const String cancellationDeadlineTime = '23:59';

  /// Batas jam penutupan pendaftaran online H-1 (23:59 WIB)
  static const String registrationCutoffTime = '23:59';
  static const int bpjsRegistrationCutoffHour = 23;

  /// Jam buka operasional mesin APM / layanan pendaftaran
  static const String admissionServiceOpenTime = '06.30';
}
