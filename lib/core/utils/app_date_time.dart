import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Utility terpusat untuk tanggal dan zona waktu resmi RSUP Dr. Sitanala (WIB - Asia/Jakarta).
///
/// Menghindari ketergantungan jam perangkat lokal yang berpotensi keliru / melompat hari
/// saat pasien memesan tiket atau melihat jadwal dokter.
class AppDateTime {
  const AppDateTime._();

  /// Nama zona waktu resmi RSUP Dr. Sitanala (Asia/Jakarta)
  static const String timeZoneName = AppConfig.timeZoneName;

  /// Singkatan zona waktu resmi RSUP Dr. Sitanala (WIB)
  static const String timeZoneAbbr = AppConfig.timeZoneAbbr;

  static bool _initialized = false;

  /// Inisialisasi basis data zona waktu global aplikasi
  static void initialize() {
    if (_initialized) return;
    tz.initializeTimeZones();
    final location = tz.getLocation(timeZoneName);
    tz.setLocalLocation(location);
    _initialized = true;
  }

  /// Membuat objek [DateTime] secara eksplisit dalam zona waktu resmi WIB
  static DateTime wibDateTime(
    int year, [
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
  ]) {
    if (!_initialized) initialize();
    final location = tz.getLocation(timeZoneName);
    return tz.TZDateTime(
      location,
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
    );
  }

  /// Mengambil waktu saat ini dalam zona waktu Asia/Jakarta (WIB)
  static DateTime now() {
    if (!_initialized) initialize();
    final location = tz.getLocation(timeZoneName);
    return tz.TZDateTime.now(location);
  }

  /// Mengonversi [DateTime] apapun menjadi zona waktu Asia/Jakarta (WIB)
  static DateTime toWib(DateTime dateTime) {
    if (!_initialized) initialize();
    final location = tz.getLocation(timeZoneName);
    return tz.TZDateTime.from(dateTime, location);
  }

  /// Mengembalikan nama hari dalam Bahasa Indonesia untuk [dateTime] di zona WIB
  static String namaHariWib(DateTime dateTime) {
    const listHari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final wib = toWib(dateTime);
    return listHari[wib.weekday - 1];
  }
}
