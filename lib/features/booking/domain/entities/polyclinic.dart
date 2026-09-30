/// Entitas master data Poliklinik Rawat Jalan RSUP Dr. Sitanala Tangerang.
///
/// Mengacu pada tabel `m_unit` SIMRS Sitanala.
class Polyclinic {
  const Polyclinic({
    required this.id,
    required this.name,
    required this.code,
    required this.floor,
    this.description = '',
    this.iconName,
  });

  /// ID unik unit di tabel `m_unit`
  final int id;

  /// Nama poliklinik, contoh: `'Poli Penyakit Dalam'`, `'Poli Mata'`
  final String name;

  /// Kode poliklinik 3 huruf untuk prefix nomor antrean (contoh: `'PDI'`, `'MAT'`, `'THT'`)
  final String code;

  /// Lokasi lantai gedung rawat jalan (contoh: `'Lantai 1'`, `'Lantai 2'`)
  final String floor;

  /// Deskripsi singkat poliklinik
  final String description;

  /// Nama ikon representasi
  final String? iconName;
}
