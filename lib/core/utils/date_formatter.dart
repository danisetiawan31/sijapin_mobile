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
    return '${date.day} ${_bulan[date.month - 1]} ${date.year}';
  }

  /// Contoh: `14 Agu 1998`
  static String tanggalPendek(DateTime date) {
    final String namaBulan = _bulan[date.month - 1];
    return '${date.day} ${namaBulan.substring(0, 3)} ${date.year}';
  }

  /// Contoh: `Senin, 14 Agustus 1998`
  static String hariTanggalPanjang(DateTime date) {
    return '${_hari[date.weekday - 1]}, ${tanggalPanjang(date)}';
  }

  /// Jam dan menit dua digit, contoh: `08:30`.
  static String jamMenit(DateTime date) {
    final String jam = date.hour.toString().padLeft(2, '0');
    final String menit = date.minute.toString().padLeft(2, '0');
    return '$jam:$menit';
  }

  /// Label hari relatif untuk tanggal kunjungan: `Hari ini`, `Besok`, atau nama
  /// hari dalam seminggu bila lebih dari satu hari ke depan.
  static String hariRelatif(DateTime date, {DateTime? reference}) {
    final DateTime now = reference ?? DateTime.now();
    final DateTime target = DateTime(date.year, date.month, date.day);
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int selisih = target.difference(today).inDays;
    if (selisih == 0) return 'Hari ini';
    if (selisih == 1) return 'Besok';
    if (selisih == -1) return 'Kemarin';
    return _hari[target.weekday - 1];
  }

  /// Umur pasien dalam tahun pada [reference], atau `null` bila tanggal lahir belum diisi.
  static int? umur({required DateTime? birthDate, DateTime? reference}) {
    if (birthDate == null) return null;
    final DateTime now = reference ?? DateTime.now();
    int tahun = now.year - birthDate.year;
    final bool belumUlangTahun =
        now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day);
    if (belumUlangTahun) tahun -= 1;
    return tahun < 0 ? null : tahun;
  }
}
