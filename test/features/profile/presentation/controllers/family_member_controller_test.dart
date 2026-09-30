import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/family_member_controller.dart';

void main() {
  group('FamilyMembersNotifier Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state memuat daftar 5 anggota keluarga mock', () {
      final members = container.read(familyMembersProvider);
      expect(members.length, 5);
      expect(members.first.fullName, 'Ahmad Fauzi Rahman');
      expect(members.first.isPrimary, isTrue);
    });

    test('addMember menambahkan anggota keluarga baru ke state', () {
      const newMember = FamilyMember(
        id: 'keluarga-99',
        fullName: 'Budi Santoso',
        relation: FamilyRelation.sibling,
        gender: 'L',
        nik: '3671041111110001',
        insurance: FamilyInsurance.umum,
      );

      container.read(familyMembersProvider.notifier).addMember(newMember);

      final members = container.read(familyMembersProvider);
      expect(members.length, 6);
      expect(members.last.id, 'keluarga-99');
      expect(members.last.fullName, 'Budi Santoso');
    });

    test('removeMember menghapus anggota keluarga berdasarkan ID', () {
      expect(container.read(familyMembersProvider).length, 5);

      container.read(familyMembersProvider.notifier).removeMember('keluarga-1');

      final members = container.read(familyMembersProvider);
      expect(members.length, 4);
      expect(members.any((m) => m.id == 'keluarga-1'), isFalse);
    });

    test('updateMember memperbarui data anggota keluarga yang ada', () {
      final existing = container.read(familyMembersProvider).first;
      final updated = existing.copyWith(fullName: 'Ahmad Fauzi Rahman, S.T.');

      container.read(familyMembersProvider.notifier).updateMember(updated);

      final members = container.read(familyMembersProvider);
      expect(members.first.fullName, 'Ahmad Fauzi Rahman, S.T.');
    });
  });
}
