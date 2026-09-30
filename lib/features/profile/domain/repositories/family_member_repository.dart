import '../entities/family_member.dart';

/// Kontrak repositori manajemen data anggota keluarga pasien RSUP Dr. Sitanala.
///
/// Mengacu pada tabel `m_customer_member` SIMRS dan alur pendaftaran rawat jalan:
/// - POST /Pasien/input_pasien (pendaftaran pasien keluarga)
/// - POST /Profile/simpan_akun_pr (pembaruan data profil)
abstract interface class FamilyMemberRepository {
  /// Mengambil daftar anggota keluarga yang tersimpan di memori/cache lokal secara sinkron.
  List<FamilyMember> getCachedFamilyMembers();

  /// Mengambil daftar anggota keluarga yang terdaftar pada akun pasien.
  Future<List<FamilyMember>> getFamilyMembers();

  /// Menambahkan anggota keluarga baru.
  Future<FamilyMember> addFamilyMember(FamilyMember member);

  /// Memperbarui data anggota keluarga yang sudah ada.
  Future<FamilyMember> updateFamilyMember(FamilyMember member);

  /// Menghapus anggota keluarga berdasarkan ID.
  Future<bool> deleteFamilyMember(String id);
}
