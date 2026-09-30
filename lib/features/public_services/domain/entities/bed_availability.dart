/// Ringkasan ketersediaan kamar rawat inap RSUP Dr. Sitanala.
///
/// Mencerminkan metrik rumah sakit dari SIMRS dan referensi visual:
/// 18 bed tersedia dari total 142 kapasitas tempat tidur (BOR 87.3%).
class BedAvailabilitySummary {
  const BedAvailabilitySummary({
    required this.totalBeds,
    required this.availableBeds,
    required this.wards,
  });

  /// Total kapasitas tempat tidur seluruh rumah sakit (contoh: 142).
  final int totalBeds;

  /// Bed siap huni seluruh rumah sakit (contoh: 18).
  final int availableBeds;

  /// Daftar ruangan yang dipantau.
  final List<WardAvailability> wards;

  /// Bed terisi seluruh RS = total - tersedia (contoh: 124).
  int get occupiedBeds => (totalBeds - availableBeds).clamp(0, totalBeds);

  /// Tingkat keterisian / BOR dalam persen (contoh: 87.3).
  double get borPercent =>
      totalBeds == 0 ? 0.0 : (occupiedBeds / totalBeds * 100);

  /// Jumlah unit yang dipantau (contoh: 3).
  int get monitoredUnits => wards.length;

  /// Total bed kosong yang terakumulasi khusus dari daftar bangsal yang sedang tampil.
  int get visibleAvailableBeds =>
      wards.fold(0, (sum, w) => sum + w.availableBeds);

  BedAvailabilitySummary copyWith({
    int? totalBeds,
    int? availableBeds,
    List<WardAvailability>? wards,
  }) {
    return BedAvailabilitySummary(
      totalBeds: totalBeds ?? this.totalBeds,
      availableBeds: availableBeds ?? this.availableBeds,
      wards: wards ?? this.wards,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BedAvailabilitySummary &&
          runtimeType == other.runtimeType &&
          totalBeds == other.totalBeds &&
          availableBeds == other.availableBeds &&
          _listEquals(wards, other.wards);

  @override
  int get hashCode =>
      Object.hash(totalBeds, availableBeds, Object.hashAll(wards));

  static bool _listEquals(List<WardAvailability> a, List<WardAvailability> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
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

  WardAvailability copyWith({
    String? id,
    String? name,
    String? category,
    String? specialty,
    String? floorBuilding,
    List<WardClassAvailability>? classBreakdown,
    DateTime? updatedAt,
    bool? isRealtime,
  }) {
    return WardAvailability(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      specialty: specialty ?? this.specialty,
      floorBuilding: floorBuilding ?? this.floorBuilding,
      classBreakdown: classBreakdown ?? this.classBreakdown,
      updatedAt: updatedAt ?? this.updatedAt,
      isRealtime: isRealtime ?? this.isRealtime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardAvailability &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          specialty == other.specialty &&
          floorBuilding == other.floorBuilding &&
          isRealtime == other.isRealtime &&
          _classEquals(classBreakdown, other.classBreakdown);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    specialty,
    floorBuilding,
    isRealtime,
    Object.hashAll(classBreakdown),
  );

  static bool _classEquals(
    List<WardClassAvailability> a,
    List<WardClassAvailability> b,
  ) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardClassAvailability &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          availableBeds == other.availableBeds;

  @override
  int get hashCode => Object.hash(className, availableBeds);
}

/// Status keterisian ruangan untuk styling badge/kartu.
enum WardStatus { available, full }
