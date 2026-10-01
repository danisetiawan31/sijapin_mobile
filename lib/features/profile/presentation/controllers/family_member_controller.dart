import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/domain/repositories/family_member_repository.dart';

/// Notifier pengelola daftar anggota keluarga pasien terdaftar.
class FamilyMembersNotifier extends Notifier<List<FamilyMember>> {
  FamilyMemberRepository get _repository =>
      ref.read(familyMemberRepositoryProvider);

  @override
  List<FamilyMember> build() {
    return ref.watch(familyMemberRepositoryProvider).getCachedFamilyMembers();
  }

  /// Menambahkan anggota keluarga baru ke dalam daftar dan repositori.
  Future<void> addMember(FamilyMember member) async {
    state = [...state, member];
    final reconciled = await _repository.addFamilyMember(member);
    if (reconciled.id != member.id) {
      state = state
          .map((FamilyMember m) => m.id == member.id ? reconciled : m)
          .toList();
    }
  }

  /// Menghapus anggota keluarga berdasarkan ID dari state dan repositori.
  void removeMember(String id) {
    state = state.where((FamilyMember m) => m.id != id).toList();
    _repository.deleteFamilyMember(id);
  }

  /// Memperbarui data anggota keluarga di state dan repositori.
  void updateMember(FamilyMember updated) {
    state = state
        .map((FamilyMember m) => m.id == updated.id ? updated : m)
        .toList();
    _repository.updateFamilyMember(updated);
  }
}

/// Provider daftar anggota keluarga yang terdaftar atas nama pasien aktif.
final familyMembersProvider =
    NotifierProvider<FamilyMembersNotifier, List<FamilyMember>>(
      FamilyMembersNotifier.new,
    );
