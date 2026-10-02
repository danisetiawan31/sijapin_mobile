/// Konstanta endpoint API backend SIMRS RSUP Dr. Sitanala Tangerang
class ApiConstants {
  const ApiConstants._();

  // 1. Autentikasi, Sesi & Akun (m_customer)
  static const String login = 'Login/cek_login';
  static const String logout = 'Login/logout';
  static const String register = 'Login/simpan_akun_pr';
  static const String updateProfile = 'Profile/simpan_akun_pr';

  // 2. Manajemen Anggota Keluarga (m_customer_member via Controller Pasien)
  static const String inputPasien = 'Pasien/input_pasien';
  static const String listPasien = 'pasien';
  static const String formPasien = 'pasien/form_data';

  // 2. Proteksi Anti-CSRF & Cookie Sesi CI3
  static const String csrfTokenKey = 'ci_csrf_token';
  static const String sessionCookieName = 'ci_session';

  // 3. Wizard Pendaftaran Rawat Jalan (Controller Daftar_Kunj_Raja & Daftar_Log)
  // Step 1: Tetapkan Identitas Pasien (m_customer_member) ke Sesi
  static const String bookingInputPasien = 'Daftar_Kunj_Raja/input_pasien';
  // Step 2: Tetapkan Unit Poli & Tanggal Rencana Kunjungan ke Sesi
  static const String bookingInputKunjungan =
      'Daftar_Kunj_Raja/input_kunjungan';
  // Step 3: Tetapkan Metode Pembayaran ke Sesi
  static const String bookingInputPembayaran =
      'Daftar_Kunj_Raja/input_pembayaran';
  // Helper AJAX Wizard: Daftar Dokter Jaga per Unit
  static const String bookingListDokter = 'Daftar_Kunj_Raja/list_dokter_jaga';
  // Helper AJAX Wizard: Jadwal Praktik Dokter
  static const String bookingListJadwal = 'Daftar_Kunj_Raja/list_jadwal';
  // Helper AJAX Wizard: Jam Pelayanan Dokter
  static const String bookingJamPelayanan =
      'Daftar_Kunj_Raja/get_jam_pelayanan';
  // Step 3 & 4: Final Submit Transaksi & Terbitkan Tiket APM (t_daftar_rj)
  static const String bookingInsertRajal =
      'Daftar_Kunj_Raja/insert_daftar_rajal';
  // Step 5: Pembersihan Variabel Sesi Wizard CI3 (finish_daftar)
  static const String bookingFinishDaftar = 'Daftar_Kunj_Raja/finish_daftar';
  // Pembatalan Mandiri (Controller Daftar_Log, Maksimal H-1 pukul 23:59 WIB)
  static const String bookingBatalAntrian = 'Daftar_Log/daftar_batal';
  // Riwayat Antrean Pasien
  static const String bookingHistory = 'daftar_log';

  // 4. Layanan Publik (Tanpa Login)
  // Ketersediaan Kamar Rawat Inap (View HTML Scraping)
  static const String bedAvailability = 'Ket_Kamar';
  // Jadwal Praktik Dokter
  static const String doctorSchedule = 'Jadwal_Dokter';

  // 5. Aspirasi & Saran Pengaduan
  static const String submitFeedback = 'Saran_Pengaduan/input_saran_pengaduan';

  // 6. Check-In Kiosk APM & Status QR (Controller Daftar_Log)
  static const String checkInUpdateStatus = 'Daftar_Log/update_qrcode_status';
  static const String checkInCekStatus = 'Daftar_Log/cek_status_qrcode';
}
