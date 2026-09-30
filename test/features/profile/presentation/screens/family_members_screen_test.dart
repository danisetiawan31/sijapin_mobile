import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/screens/family_members_screen.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_card.dart';

Future<void> _pumpFamilyMembersScreen(
  WidgetTester tester, {
  bool signedIn = true,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (!signedIn) currentUserProfileProvider.overrideWithValue(null),
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

    testWidgets(
      'tombol tambah anggota membuka sheet dan dapat menyimpan data',
      (tester) async {
        await _pumpFamilyMembersScreen(tester);

        await tester.tap(find.text('Tambah Anggota Keluarga'));
        await tester.pumpAndSettle();

        expect(
          find.text('Masukkan data sesuai KTP atau Kartu Keluarga resmi.'),
          findsOneWidget,
        );
        expect(find.text('Simpan Anggota'), findsOneWidget);

        // Isi Nama dan NIK
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Contoh: Ahmad Fauzi'),
          'Dewi Sartika',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, '367104xxxxxxxxxx'),
          '3671049909990001',
        );
        await tester.pumpAndSettle();

        // Submit
        await tester.tap(find.text('Simpan Anggota'));
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
}
