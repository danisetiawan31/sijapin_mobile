import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/family_member_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_detail_sheet.dart';

void main() {
  group('FamilyMemberDetailSheet Widget Tests', () {
    final testMember = FamilyMember(
      id: 'keluarga-1',
      fullName: 'Ahmad Fauzi Rahman',
      relation: FamilyRelation.spouse,
      gender: 'L',
      nik: '3671041205860005',
      medicalRecordNumber: '012345',
      birthDate: DateTime(1986, 5, 12),
      bloodType: 'A',
      phone: '081298765432',
      insurance: FamilyInsurance.bpjs,
      insuranceNumber: '0001122334455',
      lastServiceDate: DateTime(2026, 8, 19),
      healthNote: 'Hipertensi ringan, rutin kontrol setiap 3 bulan.',
      isPrimary: true,
    );

    Future<void> pumpDetailSheet(
      WidgetTester tester, {
      required ProviderContainer container,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          GoRoute(
            path: '/test',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () =>
                        FamilyMemberDetailSheet.show(context, testMember),
                    child: const Text('Buka Detail'),
                  );
                },
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.bookingWizardPath,
            builder: (context, state) =>
                const Scaffold(body: Text('Layar Booking Wizard')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buka Detail'));
      await tester.pumpAndSettle();
    }

    testWidgets('menampilkan rincian data kesehatan dan identitas tersamar', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpDetailSheet(tester, container: container);

      expect(find.text('Ahmad Fauzi Rahman'), findsOneWidget);
      expect(find.text('AF'), findsOneWidget);
      expect(find.text('Suami / Istri'), findsOneWidget);
      expect(find.text('BPJS'), findsOneWidget);

      // Masked data
      expect(find.text('367104******0005'), findsOneWidget);
      expect(find.text('0123**'), findsOneWidget);
      expect(find.text('Laki-laki'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('0812****5432'), findsOneWidget);
      expect(find.text('000112****455'), findsOneWidget);
      expect(
        find.text('Hipertensi ringan, rutin kontrol setiap 3 bulan.'),
        findsOneWidget,
      );

      // Action buttons
      expect(find.text('Buat Janji Temu'), findsOneWidget);
      expect(find.text('Hapus Anggota'), findsOneWidget);
    });

    testWidgets(
      'menekan Buat Janji Temu mengisi draft pasien pada booking wizard',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await pumpDetailSheet(tester, container: container);

        // Tap Buat Janji Temu
        await tester.tap(find.text('Buat Janji Temu'));
        await tester.pumpAndSettle();

        // Verifikasi bahwa navigasi ke wizard dan state wizard memiliki pasien yang dipilih
        expect(find.text('Layar Booking Wizard'), findsOneWidget);
        final wizardState = container.read(bookingWizardControllerProvider);
        expect(wizardState.draft.patient, isNotNull);
        expect(wizardState.draft.patient!.fullName, 'Ahmad Fauzi Rahman');
        expect(wizardState.draft.patient!.nik, '3671041205860005');
        expect(wizardState.draft.patient!.medicalRecordNumber, '012345');
      },
    );

    testWidgets('menekan Hapus Anggota memunculkan dialog konfirmasi', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await pumpDetailSheet(tester, container: container);

      // Tap Hapus Anggota
      await tester.tap(find.text('Hapus Anggota'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus Anggota Keluarga?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Konfirmasi Hapus
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      // Verifikasi anggota terhapus dari state
      final members = container.read(familyMembersProvider);
      expect(members.any((m) => m.id == testMember.id), isFalse);
    });
  });
}
