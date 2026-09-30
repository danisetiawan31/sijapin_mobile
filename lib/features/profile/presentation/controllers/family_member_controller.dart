import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/features/profile/data/datasources/family_members_mock_data.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

/// Notifier pengelola daftar anggota keluarga pasien terdaftar.
class FamilyMembersNotifier extends Notifier<List<FamilyMember>> {
  @override
  List<FamilyMember> build() {
    return kMockFamilyMembers;
  }

  /// Menambahkan anggota keluarga baru ke dalam daftar.
  void addMember(FamilyMember member) {
    state = [...state, member];
  }

  /// Menghapus anggota keluarga berdasarkan ID.
  void removeMember(String id) {
    state = state.where((FamilyMember m) => m.id != id).toList();
  }

  /// Memperbarui data anggota keluarga.
  void updateMember(FamilyMember updated) {
    state = state
        .map((FamilyMember m) => m.id == updated.id ? updated : m)
        .toList();
  }
}

/// Provider daftar anggota keluarga yang terdaftar atas nama pasien aktif.
final familyMembersProvider =
    NotifierProvider<FamilyMembersNotifier, List<FamilyMember>>(
      FamilyMembersNotifier.new,
    );
