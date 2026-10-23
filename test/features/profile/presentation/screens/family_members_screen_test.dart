import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/repositories/family_member_repository.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/screens/family_members_screen.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_card.dart';

import '../../../../fixtures/mock_family_members.dart';

const testUser = UserProfile(
  customerId: '4',
  fullName: 'Rina Puspita Sari',
  email: 'rina.puspita@warga.go.id',
  phone: '081234567890',
  nik: '3671044508940002',
  gender: 'P',
  bloodType: 'O',
  address: 'Jl. Cileduk Raya No. 24, Tangerang',
);

Future<void> _pumpFamilyMembersScreen(
  WidgetTester tester, {
  bool signedIn = true,
  List<FamilyMember>? initialMembers,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final testRepo = FamilyMemberRepositoryImpl(
    remoteDataSource: null,
    initialMembers: initialMembers ?? kMockFamilyMembers,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWithValue(
          signedIn ? testUser : null,
        ),
        familyMemberRepositoryProvider.overrideWithValue(testRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const FamilyMembersScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('FamilyMembersScreen Widget Tests', () {
    testWidgets(
      'menampilkan ringkasan, filter bar, dan kartu anggota keluarga',
      (tester) async {
        await _pumpFamilyMembersScreen(tester);

        expect(find.text('Anggota Keluarga'), findsOneWidget);
        expect(find.text('5 anggota keluarga'), findsOneWidget);
        expect(find.text('Semua'), findsOneWidget);
        expect(find.text('Pasangan'), findsOneWidget);
        expect(find.text('Anak'), findsOneWidget);
        expect(find.text('Ahmad Fauzi Rahman'), findsOneWidget);
        expect(find.text('Nadira Aulia Putri'), findsOneWidget);
        expect(find.text('Tambah Anggota Keluarga'), findsOneWidget);
      },
    );

    testWidgets('filter kategori menyaring daftar anggota', (tester) async {
      await _pumpFamilyMembersScreen(tester);

      // Awalnya ada 5 kartu anggota
      expect(find.byType(FamilyMemberCard), findsNWidgets(5));

      // Tap filter Pasangan
      await tester.tap(find.text('Pasangan'));
      await tester.pumpAndSettle();

      // Hanya tampil 1 kartu pasangan
      expect(find.byType(FamilyMemberCard), findsOneWidget);
      expect(find.text('Ahmad Fauzi Rahman'), findsOneWidget);
      expect(find.text('Nadira Aulia Putri'), findsNothing);
    });

    testWidgets('menampilkan pesan belum masuk saat tidak ada sesi login', (
      tester,
    ) async {
      await _pumpFamilyMembersScreen(tester, signedIn: false);

      expect(find.text('Belum Masuk'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
      expect(find.byType(FamilyMemberCard), findsNothing);
    });

    testWidgets('memuat ulang data DB saat layar dibuka, cache basi dibuang', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // Cache memori masih berisi sisa akun sebelumnya; sinkronisasi DB
      // saat layar dibuka harus menggantinya dengan data akun aktif.
      final staleRepository = StaleThenFreshRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProfileProvider.overrideWithValue(testUser),
            familyMemberRepositoryProvider.overrideWith(
              (ref) => staleRepository,
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FamilyMembersScreen(),
          ),
        ),
      );

      // Tampilan pertama masih data cache basi (belum ada sinkronisasi).
      expect(find.text('Pengguna Akun Lama'), findsOneWidget);

      // Setelah sinkronisasi masuk: data milik akun aktif menggantikan cache.
      await tester.pumpAndSettle();
      expect(find.text('Pengguna Akun Lama'), findsNothing);
      expect(find.text('Ahmad Fauzi Rahman'), findsOneWidget);
      expect(find.byType(FamilyMemberCard), findsNWidgets(5));
    });

    testWidgets(
      'daftar kosong menyajikan tombol Tambahkan Diri Sendiri dengan form terisi profil',
      (tester) async {
        await _pumpFamilyMembersScreen(tester, initialMembers: const []);

        expect(find.text('Belum Ada Anggota'), findsOneWidget);
        expect(find.text('Tambahkan Diri Sendiri'), findsOneWidget);

        // Sheet terbuka dengan data profil sesi terisi dari awal (prefill).
        await tester.tap(find.text('Tambahkan Diri Sendiri'));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(TextFormField, 'Rina Puspita Sari'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tombol tambah anggota membuka sheet dan dapat menyimpan data',
      (tester) async {
        await _pumpFamilyMembersScreen(tester);

        await tester.tap(find.text('Tambah Anggota Keluarga'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Pilih jenis pasien untuk menyesuaikan formulir data medis.',
          ),
          findsOneWidget,
        );
        expect(find.text('Tautkan Pasien Lama'), findsOneWidget);

        // Isi No. RM dan Nama Pasien
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Contoh: 012345 atau 039450'),
          '039450',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama sesuai kartu berobat'),
          'Dewi Sartika',
        );

        // Buka pemilih tanggal lahir dan pilih
        await tester.tap(find.text('Pilih tanggal lahir'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pilih'));
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.text('Tautkan Pasien Lama'));
        await tester.pumpAndSettle();

        // Verifikasi snackbar dan penambahan kartu di list
        expect(
          find.text('Anggota keluarga "Dewi Sartika" berhasil ditambahkan.'),
          findsOneWidget,
        );
        expect(find.text('Dewi Sartika'), findsOneWidget);
      },
    );
  });

  group('AddFamilyMemberSheet.prefillSelfFromProfile', () {
    test(
      'mengisi relasi Diri Sendiri dan hanya field yang tersedia di profil',
      () {
        final FamilyMember? draft = AddFamilyMemberSheet.prefillSelfFromProfile(
          testUser,
        );
        expect(draft, isNotNull);
        expect(draft!.relation, FamilyRelation.self);
        expect(draft.relation.label, 'Diri Sendiri');
        expect(draft.relation.icon, Icons.person_outline_rounded);
        expect(draft.fullName, 'Rina Puspita Sari');
        expect(draft.phone, '081234567890');
        expect(draft.gender, 'P');
        // Field yang tidak ada di profil akun tidak dikarang.
        expect(draft.motherName, '');
        expect(draft.medicalRecordNumber, isNull);
      },
    );

    test('profil tanpa nama menghasilkan null tanpa data karangan', () {
      const UserProfile emptyUser = UserProfile(
        fullName: '',
        email: 'x@example.com',
        phone: '0812000000',
      );
      expect(AddFamilyMemberSheet.prefillSelfFromProfile(emptyUser), isNull);
    });
  });
}

/// Repositori palsu untuk kasus sisa akun: cache memori masih memuat data
/// akun lama, sedangkan sinkronisasi DB (saat layar dibuka) mengembalikan
/// data akun aktif, sehingga cache basi harus tergeser.
class StaleThenFreshRepository implements FamilyMemberRepository {
  static const FamilyMember _staleMember = FamilyMember(
    id: 'lamalama-99',
    fullName: 'Pengguna Akun Lama',
    relation: FamilyRelation.sibling,
    gender: 'L',
    nik: '3671040000000001',
    insurance: FamilyInsurance.umum,
  );

  @override
  List<FamilyMember> getCachedFamilyMembers() =>
      List<FamilyMember>.unmodifiable(<FamilyMember>[_staleMember]);

  @override
  Future<List<FamilyMember>> getFamilyMembers() async => kMockFamilyMembers;

  @override
  Future<FamilyMember> addFamilyMember(FamilyMember member) async => member;

  @override
  Future<FamilyMember> updateFamilyMember(FamilyMember member) async => member;

  @override
  Future<bool> deleteFamilyMember(String id) async => true;
}
