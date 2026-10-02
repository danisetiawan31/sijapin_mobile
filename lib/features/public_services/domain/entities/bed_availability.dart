/// Ringkasan ketersediaan kamar rawat inap RSUP Dr. Sitanala.
///
/// Mencerminkan metrik rumah sakit dari SIMRS dan referensi visual:
/// Kapasitas tempat tidur dan BOR dihitung dinamis dari data bangsal aktif.
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

  /// Jumlah unit yang dipantau.
  int get monitoredUnits => wards.length;

  /// Total bed kosong yang terakumulasi khusus dari daftar bangsal yang sedang tampil.
  int get visibleAvailableBeds =>
      wards.fold(0, (sum, w) => sum + w.availableBeds);

  /// Total kapasitas tempat tidur dari bangsal yang sedang tampil.
  int get visibleTotalBeds =>
      wards.fold(0, (sum, w) => sum + w.totalBeds);

  /// Total bed terisi dari bangsal yang sedang tampil.
  int get visibleOccupiedBeds =>
      wards.fold(0, (sum, w) => sum + w.occupiedBeds);

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
    this.logoUrl,
  });

  /// ID unik ruangan (contoh: `ANAK`, `BEDAH`).
  final String id;

  /// Nama ruangan / jenis perawatan (contoh: `ANAK`, `BEDAH NON INTENSIF`).
  final String name;

  /// Kategori ruangan untuk filter chip (contoh: `Umum`, `ICU`, `Khusus`).
  final String category;

  /// Spesialisasi / rincian layanan (contoh: `Pediatri`, `Penyakit Dalam`).
  final String specialty;

  /// Lokasi fisik / nama gedung (contoh: `Gedung Rawat Inap`, `Lantai 2`).
  final String floorBuilding;

  /// Rincian bed tersedia per kelas (contoh: Kelas 1, Kelas 2, Kelas 3, VIP, ICU).
  final List<WardClassAvailability> classBreakdown;

  /// Waktu pembaruan data terakhir.
  final DateTime updatedAt;

  /// True bila pembaruan bersifat real-time.
  final bool isRealtime;

  /// URL icon / logo ruangan dari SIMRS (LOGO_RUANGAN).
  final String? logoUrl;

  /// Total bed tersedia di ruangan ini (akumulasi sisa kosong per kelas).
  int get availableBeds =>
      classBreakdown.fold(0, (sum, c) => sum + c.availableBeds);

  /// Total kapasitas terdaftar di ruangan ini.
  int get totalBeds =>
      classBreakdown.fold(0, (sum, c) => sum + (c.totalBeds ?? c.availableBeds));

  /// Total bed terisi pasien di ruangan ini.
  int get occupiedBeds =>
      classBreakdown.fold(0, (sum, c) => sum + (c.occupiedBeds ?? 0));

  /// True bila tidak ada bed kosong sama sekali.
  bool get isFull => availableBeds <= 0;

  /// Status 3-tier ketersediaan sesuai SSOT:
  /// - [WardStatus.full]: 0 bed (Merah)
  /// - [WardStatus.limited]: 1-2 bed (Kuning/Amber)
  /// - [WardStatus.available]: > 2 bed (Hijau)
  WardStatus get status {
    if (availableBeds <= 0) return WardStatus.full;
    if (availableBeds <= 2) return WardStatus.limited;
    return WardStatus.available;
  }

  /// Nama kelas dengan ketersediaan terbanyak (disorot di kartu).
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
    String? logoUrl,
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
      logoUrl: logoUrl ?? this.logoUrl,
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
          logoUrl == other.logoUrl &&
          _classEquals(classBreakdown, other.classBreakdown);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    specialty,
    floorBuilding,
    isRealtime,
    logoUrl,
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

/// Bed untuk satu kelas perawatan dalam sebuah ruangan.
class WardClassAvailability {
  const WardClassAvailability({
    required this.className,
    required this.availableBeds,
    this.totalBeds,
    this.occupiedBeds,
  });

  /// Nama kelas (contoh: `Kelas 1`, `Kelas 2`, `Kelas 3`, `VIP / VVIP`, `ICU`).
  final String className;

  /// Jumlah bed kosong di kelas ini (JML_TMP_TIDUR - ISI).
  final int availableBeds;

  /// Total kapasitas terdaftar (JML_TMP_TIDUR).
  final int? totalBeds;

  /// Jumlah tempat tidur terisi pasien aktif (ISI).
  final int? occupiedBeds;

  /// Status 3-tier ketersediaan kelas perawatan
  WardStatus get status {
    if (availableBeds <= 0) return WardStatus.full;
    if (availableBeds <= 2) return WardStatus.limited;
    return WardStatus.available;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardClassAvailability &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          availableBeds == other.availableBeds &&
          totalBeds == other.totalBeds &&
          occupiedBeds == other.occupiedBeds;

  @override
  int get hashCode =>
      Object.hash(className, availableBeds, totalBeds, occupiedBeds);
}

/// Status 3-tier keterisian ruangan/kelas (SSOT PRD & Backlog US-PUB-01 Scenario 2).
enum WardStatus {
  available, // > 2 bed kosong (Hijau)
  limited,   // 1 - 2 bed kosong (Kuning / Amber)
  full,      // 0 bed kosong (Merah)
}

/// Definisi kelas perawatan kamar rawat inap RSUP Dr. Sitanala
abstract final class BedClass {
  static const String all = 'Semua Kelas';
  static const String class3 = 'Kelas 3';
  static const String class2 = 'Kelas 2';
  static const String class1 = 'Kelas 1';
  static const String vip = 'VIP / VVIP';
  static const String icu = 'ICU';

  /// Daftar seluruh opsi filter kelas rawat inap yang didukung sistem
  static const List<String> filters = <String>[
    all,
    class3,
    class2,
    class1,
    vip,
    icu,
  ];
}
