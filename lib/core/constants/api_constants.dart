/// Konstanta endpoint API backend SIMRS RSUP Dr. Sitanala Tangerang
class ApiConstants {
  const ApiConstants._();

  // 1. Autentikasi, Sesi & Akun (m_customer)
  static const String login = 'Login/cek_login';
  static const String logout = 'Login/logout';
  static const String register = 'Registrasi/simpan';
  static const String updateProfile = 'Profile/update_profile';

  // 2. Proteksi Anti-CSRF & Cookie Sesi CI3
  static const String csrfTokenKey = 'ci_csrf_token';
  static const String sessionCookieName = 'ci_session';

  // 3. Wizard Pendaftaran Rawat Jalan (Controller Daftar_Kunj_Raja)
  // Step 1: Tetapkan Identitas Pasien (m_customer_member) ke Sesi
  static const String bookingInputPasien = 'Daftar_Kunj_Raja/input_pasien';
  // Step 2: Tetapkan Unit Poli & Tanggal Rencana Kunjungan ke Sesi
  static const String bookingInputKunjungan =
      'Daftar_Kunj_Raja/input_kunjungan';
  // Step 3 & 4: Final Submit Transaksi & Terbitkan Tiket APM (t_daftar_rj)
  static const String bookingInsertRajal =
      'Daftar_Kunj_Raja/insert_daftar_rajal';
  // Pembatalan Mandiri (Maksimal H-1 pukul 21:00 WIB)
  static const String bookingBatalAntrian = 'Daftar_Kunj_Raja/batal_antrian';
  // Riwayat Antrean Pasien
  static const String bookingHistory = 'daftar_log';

  // 4. Layanan Publik (Tanpa Login)
  // Ketersediaan Kamar Rawat Inap (View HTML Scraping)
  static const String bedAvailability = 'Ket_Kamar';
  // Jadwal Praktik Dokter
  static const String doctorSchedule = 'Jadwal_Dokter';

  // 5. Aspirasi & Saran Pengaduan
  static const String submitFeedback = 'Saran_Pengaduan/input_saran_pengaduan';
}
