import 'app_date_time.dart';

/// Format tanggal dalam bahasa Indonesia tanpa dependensi locale tambahan.
///
/// Menghindari `intl` + `initializeDateFormatting` yang menambah inisialisasi
/// saat splash, cukup untuk kebutuhan tampilan profil pasien.
class DateFormatter {
  const DateFormatter._();

  static const List<String> _bulan = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _hari = <String>[
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  /// Contoh: `14 Agustus 1998`
  static String tanggalPanjang(DateTime date) {
    final wib = AppDateTime.toWib(date);
    return '${wib.day} ${_bulan[wib.month - 1]} ${wib.year}';
  }

  /// Contoh: `14 Agu 1998`
  static String tanggalPendek(DateTime date) {
    final wib = AppDateTime.toWib(date);
    final String namaBulan = _bulan[wib.month - 1];
    return '${wib.day} ${namaBulan.substring(0, 3)} ${wib.year}';
  }

  /// Contoh: `Senin, 14 Agustus 1998`
  static String hariTanggalPanjang(DateTime date) {
    final wib = AppDateTime.toWib(date);
    return '${_hari[wib.weekday - 1]}, ${tanggalPanjang(wib)}';
  }

  /// Jam dan menit dua digit, contoh: `08:30`.
  static String jamMenit(DateTime date) {
    final wib = AppDateTime.toWib(date);
    final String jam = wib.hour.toString().padLeft(2, '0');
    final String menit = wib.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  /// Jam, menit dan zona waktu resmi, contoh: `08:30 WIB`.
  static String jamMenitWib(DateTime date) {
    return '${jamMenit(date)} ${AppDateTime.timeZoneAbbr}';
  }

  /// Label hari relatif untuk tanggal kunjungan: `Hari ini`, `Besok`, atau nama
  /// hari dalam seminggu bila lebih dari satu hari ke depan (berbasis zona WIB).
  static String hariRelatif(DateTime date, {DateTime? reference}) {
    final DateTime nowWib = AppDateTime.toWib(reference ?? AppDateTime.now());
    final DateTime targetWib = AppDateTime.toWib(date);
    final DateTime target = DateTime(
      targetWib.year,
      targetWib.month,
      targetWib.day,
    );
    final DateTime today = DateTime(nowWib.year, nowWib.month, nowWib.day);
    final int selisih = target.difference(today).inDays;
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Besok';
    if (selisih == -1) return 'Kemarin';
    return _hari[target.weekday - 1];
  }

  /// Label relatif ringkas untuk pembaruan data: `Baru saja`, `N mnt lalu`,
  /// `N jam lalu`, atau label hari dari [hariRelatif] untuk selisih ≥ 1 hari.
  static String waktuRelatif(DateTime date, {DateTime? reference}) {
    final DateTime now = reference ?? DateTime.now();
    final Duration diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return hariRelatif(date, reference: reference);
  }

  /// Umur pasien dalam tahun pada [reference], atau `null` bila tanggal lahir belum diisi.
  static int? umur({required DateTime? birthDate, DateTime? reference}) {
    if (birthDate == null) return null;
    final DateTime nowWib = AppDateTime.toWib(reference ?? AppDateTime.now());
    final DateTime birthWib = AppDateTime.toWib(birthDate);
    int tahun = nowWib.year - birthWib.year;
    final bool belumUlangTahun =
        nowWib.month < birthWib.month ||
        (nowWib.month == birthWib.month && nowWib.day < birthWib.day);
    if (belumUlangTahun) tahun -= 1;
    return tahun < 0 ? null : tahun;
  }
}
