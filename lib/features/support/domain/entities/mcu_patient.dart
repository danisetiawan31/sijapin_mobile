import '../../../../core/utils/data_masker.dart';

/// Anggota pasien yang dapat didaftarkan Medical Check-Up (MCU).
///
/// Mengacu pada endpoint `GET /pendaftaran` (Uniform Envelope
/// `data: [{id_member, nomr, nama, nik}]`).
class McuPatient {
  const McuPatient({
    required this.idMember,
    required this.nama,
    this.nomr = '',
    this.nik = '',
  });

  factory McuPatient.fromRow(Map<String, dynamic> row) {
    return McuPatient(
      idMember: _asText(row['id_member']),
      nama: _asText(row['nama']),
      nomr: _asText(row['nomr']),
      nik: _asText(row['nik']),
    );
  }

  /// Pengenal anggota pada tabel `m_customer_member` (`id_member`).
  final String idMember;

  /// Nama lengkap pasien.
  final String nama;

  /// Nomor Rekam Medis SIMRS; kosong bila pasien baru.
  final String nomr;

  /// Nomor Induk Kependudukan (16 digit).
  final String nik;

  /// Apakah pasien baru (belum memiliki No. Rekam Medis RSUP Dr. Sitanala).
  bool get isNewPatient => nomr.trim().isEmpty;

  /// NIK tersamar untuk kepatuhan UU PDP No. 27/2022.
  String get maskedNik => DataMasker.maskNik(nik);

  /// No. RM tersamar (contoh: `001234**`).
  String get maskedNomr {
    final String rm = nomr.trim();
    if (rm.isEmpty) return 'Belum ada No. RM';
    if (rm.length <= 3) return '$rm***';
    return '${rm.substring(0, rm.length - 2)}**';
  }

  /// Inisial nama untuk avatar, misal `Bambang Sutrisno` menjadi `BS`.
  String get initials {
    final List<String> parts = nama
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  static String _asText(Object? value) => value?.toString().trim() ?? '';
}
