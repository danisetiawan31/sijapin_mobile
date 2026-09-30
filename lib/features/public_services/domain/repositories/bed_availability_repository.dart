import '../entities/bed_availability.dart';

/// Kontrak repository ketersediaan kamar rawat inap.
///
/// Siap diganti dengan implementasi backend `Ket_Kamar` (HTML view)
/// tanpa mengubah lapisan domain/presentation.
abstract interface class BedAvailabilityRepository {
  /// Mengambil ringkasan ketersediaan bed seluruh RS.
  ///
  /// [classFilter] opsional untuk memfilter ruangan berdasarkan kelas
  /// (misal: `Kelas 1`, `Kelas 2`, `Kelas 3`, `VIP / VVIP`, `ICU`).
  /// Nilai `Semua Kelas` (atau null) menampilkan semua ruangan.
  Future<BedAvailabilitySummary> getBedAvailability({String? classFilter});

  /// Mengambil detail satu ruangan berdasarkan ID.
  Future<WardAvailability?> getWardById(String id);
}
