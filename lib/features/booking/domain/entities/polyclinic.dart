/// Entitas master data Poliklinik Rawat Jalan RSUP Dr. Sitanala Tangerang.
///
/// Mengacu pada tabel `m_unit` SIMRS Sitanala.
class Polyclinic {
  const Polyclinic({
    required this.id,
    required this.name,
    this.code = '',
    this.floor = '',
    this.description = '',
    this.iconName,
    this.bpjsCode,
    this.bpjsName,
    this.kuotaJkn,
    this.kuotaNonJkn,
    this.isExecutive = false,
    this.irja = 'umum',
  });

  /// ID unik unit di tabel `m_unit` (UNIT_ID)
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

  /// Kode poli BPJS (KODE_POLI_BPJS), contoh: `'INT'`, `'MAT'`, `'OBG'`
  final String? bpjsCode;

  /// Nama poli BPJS (NAMA_POLI_BPJS)
  final String? bpjsName;

  /// Kuota antrean JKN harian (KUOTA_JKN)
  final int? kuotaJkn;

  /// Kuota antrean Non-JKN / Umum harian (KUOTA_NONJKN)
  final int? kuotaNonJkn;

  /// Apakah poliklinik eksekutif (Alamanda)
  final bool isExecutive;

  /// Jenis IRJA ('umum' atau 'kusta')
  final String irja;

  /// Helper untuk mengambil kode efektif (bpjsCode atau code fallback)
  String get effectiveCode =>
      (bpjsCode != null && bpjsCode!.isNotEmpty) ? bpjsCode! : code;
}
