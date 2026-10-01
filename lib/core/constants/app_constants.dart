/// Konstanta nilai statis dan identitas resmi RSUP Dr. Sitanala Tangerang.
///
/// Bertindak sebagai Single Source of Truth (SSOT) untuk konfigurasi global,
/// kontak hotline rumah sakit, dan nilai default beranda.
class AppConstants {
  const AppConstants._();

  // 1. Identitas Resmi Rumah Sakit
  static const String hospitalName = 'RSUP Dr. Sitanala';
  static const String hospitalFullName = 'RSUP Dr. Sitanala Tangerang';
  static const String hospitalTagline = 'Selamat Datang di SIIJAPIN';
  static const String hospitalAddress =
      'Jl. Dr. Sitanala No.99, Karangsari, Kec. Neglasari, Kota Tangerang, Banten 15121';
  static const String hospitalOperatingHours =
      'Buka 24 jam untuk layanan IGD & Ambulans.';

  // Tautan universal Google Maps menuju RSUP Dr. Sitanala Tangerang.
  // Dipakai tombol "Lokasi RS" di Beranda agar user langsung mendapat
  // halaman navigasi/arah jalan tanpa harus mengetik alamat secara manual.
  static const String hospitalMapsUrl =
      'https://www.google.com/maps/dir//RSUP+Dr.+Sitanala+Tangerang,+Jl.+DR.+'
      'Sitanala+No.99,+RT.002%2FRW.003,+Karang+Sari,+Kec.+Neglasari,+Kota+'
      'Tangerang,+Banten+15121/data=!4m6!4m5!1m1!4e2!1m2!1m1!1s'
      '0x2e69f8ca0d055a17:0x743efba65114c9ca?sa=X&ved=1t:57443&ictx=111';

  // 2. Kontak Tunggal & Hotline Resmi RSUP Dr. Sitanala (Single Source of Truth)
  // Menyatukan seluruh nomor panggilan IGD, Ambulans, Admisi, dan Call Center
  static const String hospitalPhoneNumber = '(021) 552-3059';
  static const String hospitalPhoneDial = '0215523059';
  static const String callActionText = 'Panggil';

  // Pointer semantik untuk backward compatibility (menjamin nol breaking change)
  static const String emergencyPhoneNumber = hospitalPhoneNumber;
  static const String emergencyPhoneDial = hospitalPhoneDial;
  static const String emergencyCallAction = callActionText;
  static const String admissionPhoneNumber = hospitalPhoneNumber;
  static const String admissionPhoneDial = hospitalPhoneDial;
  static const String admissionCallAction = callActionText;

  // 3. Metrik Kapasitas Rawat Inap & Nilai Default Beranda
  static const int hospitalTotalBeds = 142;
  static const int defaultAvailableBeds = 18;
  static const int defaultActiveDoctors = 52;

  // Kesegaran Data Ketersediaan Kamar (Keputusan Q5)
  // Selisih pembaruan di bawah ambang ini dilabeli "Real-time".
  static const int bedDataFreshnessMinutes = 5;

  // 4. Beranda Dinamis & Sapaan
  static const String welcomeGreeting = 'Halo, 👋';
  static const String welcomeTitle = 'Selamat Datang di $hospitalName';
  static const String welcomeSubtitle =
      'Kami siap membantu Anda mendapatkan layanan kesehatan terbaik.';
  static const String quickActionsTitle = 'Bantuan & Informasi Cepat';
  static const String quickActionsSubtitle =
      'Akses mudah untuk segala kebutuhan Anda';
  static const String searchHint = 'Cari dokter, poliklinik, atau layanan...';

  // 5. Judul Banner Layanan
  static const String emergencyBannerTitle = 'IGD & Ambulans 24 Jam';
  static const String admissionBannerTitle =
      'Butuh info rujukan rawat inap mendesak?';
}
