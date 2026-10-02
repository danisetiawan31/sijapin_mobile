import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/family_member_controller.dart';
import '../../../../fixtures/mock_family_members.dart';

void main() {
  group('FamilyMembersNotifier Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      final repository = FamilyMemberRepositoryImpl(
        remoteDataSource: null,
        initialMembers: kMockFamilyMembers,
      );
      container = ProviderContainer(
        overrides: [
          familyMemberRepositoryProvider.overrideWithValue(repository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state tanpa data cached menghasilkan daftar kosong', () {
      final emptyContainer = ProviderContainer();
      final members = emptyContainer.read(familyMembersProvider);
      expect(members.isEmpty, isTrue);
      emptyContainer.dispose();
    });

    test('initial state dengan test fixture memuat 5 anggota keluarga', () {
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
