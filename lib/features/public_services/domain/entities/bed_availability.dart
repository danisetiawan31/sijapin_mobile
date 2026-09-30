/// Ringkasan ketersediaan kamar rawat inap RSUP Dr. Sitanala.
///
/// Mencerminkan data referensi `stitch_design/Ketersedian-Kamar/screen.png`:
/// 18 bed tersedia dari total 142 (BOR 87.3%).
class BedAvailabilitySummary {
  const BedAvailabilitySummary({
    required this.totalBeds,
    required this.availableBeds,
    required this.wards,
  });

  /// Total kapasitas tempat tidur (contoh: 142).
  final int totalBeds;

  /// Bed siap huni (contoh: 18).
  final int availableBeds;

  /// Daftar ruangan yang dipantau.
  final List<WardAvailability> wards;

  /// Bed terisi = total - tersedia (contoh: 124).
  int get occupiedBeds => totalBeds - availableBeds;

  /// Tingkat keterisian / BOR dalam persen (contoh: 87.3).
  double get borPercent => totalBeds == 0 ? 0 : occupiedBeds / totalBeds * 100;

  /// Jumlah unit yang dipantau (contoh: 3).
  int get monitoredUnits => wards.length;
}

/// Ketersediaan bed per ruangan/bangsal.
class WardAvailability {
  const WardAvailability({
    required this.id,
    required this.name,
    required this.category,
    required this.specialty,
    required this.floorBuilding,
    required this.classBreakdown,
    required this.updatedAt,
    this.isRealtime = false,
  });

  /// ID unik ruangan (contoh: `melati`).
  final String id;

  /// Nama ruangan (contoh: `Ruang Melati (Dewasa)`).
  final String name;

  /// Kategori ruangan untuk filter chip ICU (contoh: `Umum`, `ICU`).
  final String category;

  /// Spesialisasi/layanan (contoh: `Penyakit Dalam`).
  final String specialty;

  /// Lokasi fisik (contoh: `Lantai 3 Gedung B`).
  final String floorBuilding;

  /// Rincian bed tersedia per kelas (contoh: Kelas 1: 2, Kelas 2: 1, Kelas 3: 3).
  final List<WardClassAvailability> classBreakdown;

  /// Waktu pembaruan data terakhir.
  final DateTime updatedAt;

  /// True bila pembaruan bersifat real-time (label "Real-time",
  /// bukan relatif "N mnt lalu").
  final bool isRealtime;

  /// Total bed tersedia di ruangan ini.
  int get availableBeds =>
      classBreakdown.fold(0, (sum, c) => sum + c.availableBeds);

  /// True bila tidak ada bed kosong.
  bool get isFull => availableBeds == 0;

  /// Status turunan untuk styling badge/kartu.
  WardStatus get status => isFull ? WardStatus.full : WardStatus.available;

  /// Nama kelas dengan ketersediaan terbanyak (disorot mint di kartu).
  /// Null bila semua kelas kosong.
  String? get highlightedClass {
    WardClassAvailability? best;
    for (final c in classBreakdown) {
      if (c.availableBeds <= 0) continue;
      if (best == null || c.availableBeds > best.availableBeds) best = c;
    }
    return best?.className;
  }
}

/// Bed tersedia untuk satu kelas perawatan dalam sebuah ruangan.
class WardClassAvailability {
  const WardClassAvailability({
    required this.className,
    required this.availableBeds,
  });

  /// Nama kelas (contoh: `Kelas 1`, `Kelas 2`, `Kelas 3`, `VIP / VVIP`, `ICU`).
  final String className;

  /// Jumlah bed kosong di kelas ini.
  final int availableBeds;
}

/// Status keterisian ruangan untuk styling badge/kartu.
enum WardStatus { available, full }
