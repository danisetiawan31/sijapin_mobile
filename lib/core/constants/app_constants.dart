/// Konstanta nilai statis dan identitas resmi RSUP Dr. Sitanala Tangerang.
class AppConstants {
  const AppConstants._();

  // Identitas Resmi Rumah Sakit
  static const String hospitalName = 'RSUP Dr. Sitanala';
  static const String hospitalFullName = 'RSUP Dr. Sitanala Tangerang';
  static const String hospitalTagline = 'Selamat Datang di SIIJAPIN';
  static const String hospitalAddress =
      'Jl. Dr. Sitanala No.99, Karangsari, Kec. Neglasari, Kota Tangerang, Banten 15121';
  static const String hospitalOperatingHours =
      'Buka 24 jam untuk layanan IGD & Ambulans.';

  // Kontak Darurat & Bantuan
  static const String emergencyPhoneNumber = '(021) 552-3059';
  static const String emergencyPhoneDial = '0215523059';
  static const String emergencyBannerTitle = 'IGD & Ambulans 24 Jam';
  static const String emergencyCallAction = 'Panggil';

  // Kontak Admisi Rawat Inap
  static const String admissionPhoneNumber = '(021) 552-3059';
  static const String admissionPhoneDial = '0215523059';
  static const String admissionBannerTitle =
      'Butuh info rujukan rawat inap mendesak?';
  static const String admissionCallAction = 'Panggil';

  // Metrik Kapasitas Rawat Inap & Beranda
  static const int hospitalTotalBeds = 142;
  static const int defaultAvailableBeds = 18;
  static const int defaultActiveDoctors = 52;

  // Filter & Kategori Kelas Rawat Inap
  static const String bedClassAll = 'Semua Kelas';
  static const String bedClass3 = 'Kelas 3';
  static const String bedClass2 = 'Kelas 2';
  static const String bedClass1 = 'Kelas 1';
  static const String bedClassVip = 'VIP / VVIP';
  static const String bedClassIcu = 'ICU';

  static const List<String> bedClassFilters = <String>[
    bedClassAll,
    bedClass3,
    bedClass2,
    bedClass1,
    bedClassVip,
    bedClassIcu,
  ];

  // Kesegaran Data Ketersediaan Kamar (Keputusan Q5)
  // Selisih pembaruan di bawah ambang ini dilabeli "Real-time".
  static const int bedDataFreshnessMinutes = 5;

  // Beranda Dinamis & Sapaan
  static const String welcomeGreeting = 'Halo, 👋';
  static const String welcomeTitle = 'Selamat Datang di RSUP Dr. Sitanala';
  static const String welcomeSubtitle =
      'Kami siap membantu Anda mendapatkan layanan kesehatan terbaik.';
  static const String quickActionsTitle = 'Bantuan & Informasi Cepat';
  static const String quickActionsSubtitle =
      'Akses mudah untuk segala kebutuhan Anda';
  static const String searchHint = 'Cari dokter, poliklinik, atau layanan...';
  static const String greetingMorning = 'Selamat Pagi';
  static const String greetingAfternoon = 'Selamat Siang';
  static const String greetingEvening = 'Selamat Sore';
  static const String greetingNight = 'Selamat Malam';
  static const String greetingSuffix = 'Ada yang bisa kami bantu?';
}
