import '../entities/ticket.dart';

/// Kontrak repositori domain untuk manajemen tiket antrean dan integrasi Kiosk APM
/// Bebas dari ketergantungan framework I/O (Clean Architecture)
abstract class TicketRepository {
  /// Menyimpan atau memperbarui data tiket ke basis data lokal (Hive)
  Future<void> saveTicket(Ticket ticket);

  /// Mengambil tiket antrean aktif terkini yang belum selesai diperiksa
  Future<Ticket?> getActiveTicket();

  /// Mengambil seluruh daftar tiket (aktif dan riwayat lampau)
  Future<List<Ticket>> getAllTickets();

  /// Membatalkan reservasi janji temu (maksimal H-1 23:59 WIB)
  /// Menyinkronkan ke endpoint CI3 POST /Daftar_Log/daftar_batal dan memperbarui status lokal
  Future<bool> cancelTicket({
    required String bookingCode,
    required String reason,
    int? memberId,
    DateTime? scheduledDate,
  });

  /// Memperbarui status tiket lokal setelah konfirmasi kehadiran di Kiosk APM (Task 2)
  Future<void> checkInTicket(String bookingCode);

  /// Menyinkronkan aksi tertunda (seperti pembatalan offline) ke backend CI3 saat koneksi pulih.
  /// Mengembalikan jumlah aksi yang berhasil disinkronkan.
  Future<int> syncPendingOfflineActions();
}
