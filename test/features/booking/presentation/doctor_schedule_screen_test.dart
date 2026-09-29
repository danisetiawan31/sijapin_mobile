import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/app_loading_state.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/app_text_field.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/doctor_schedule_screen.dart';

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const DoctorScheduleScreen(),
    ),
  );
}

void main() {
  group('DoctorScheduleScreen (Jadwal Dokter)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('renders header with title, subtitle, and badge', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      expect(find.text('Jadwal Dokter'), findsOneWidget);
      expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);
      expect(find.text('52 Dokter Aktif'), findsOneWidget);
    });

    testWidgets('renders search field with correct placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AppTextField, 'Cari nama dokter atau spesialis...'),
        findsOneWidget,
      );
    });

    testWidgets('renders 6 filter chips with Semua Poli active by default', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      // Check first 5 chips exist (they should be in viewport)
      expect(find.text('Semua Poli'), findsOneWidget);
      expect(find.text('Penyakit Dalam'), findsAtLeastNWidgets(1));
      expect(find.text('Mata'), findsAtLeastNWidgets(1));
      expect(find.text('Anak'), findsAtLeastNWidgets(1));
      expect(find.text('Kebidanan & Obgyn'), findsOneWidget);

      // Semua Poli should be active (caramel background)
      final semuaPoliChip = find.ancestor(
        of: find.text('Semua Poli'),
        matching: find.byType(AnimatedContainer),
      );
      final animatedContainer = tester.widget<AnimatedContainer>(semuaPoliChip);
      expect(animatedContainer.decoration, isA<BoxDecoration>());
      final decoration = animatedContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.brandGoldenCaramel);
    });

    testWidgets('tapping Mata chip makes it active and filters list', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      // Tap Mata chip
      await tester.tap(find.text('Mata'));
      await tester.pumpAndSettle();

      // Mata chip should be active (caramel)
      final mataChip = find.ancestor(
        of: find.text('Mata'),
        matching: find.byType(AnimatedContainer),
      );
      final mataDecoration =
          tester.widget<AnimatedContainer>(mataChip).decoration
              as BoxDecoration;
      expect(mataDecoration.color, AppColors.brandGoldenCaramel);

      // Semua Poli should be inactive (white)
      final semuaPoliChip = find.ancestor(
        of: find.text('Semua Poli'),
        matching: find.byType(AnimatedContainer),
      );
      final semuaPoliDecoration =
          tester.widget<AnimatedContainer>(semuaPoliChip).decoration
              as BoxDecoration;
      expect(semuaPoliDecoration.color, AppColors.surfaceCard);

      // List should show Mata doctors
      expect(find.text('dr. Hendra, Sp.M'), findsOneWidget);
      expect(find.text('dr. Anita Kusuma, Sp.M'), findsOneWidget);
    });

    testWidgets(
      'tapping Kebidanan & Obgyn chip shows 2 Obgyn doctors (BUG-4 regression)',
      (tester) async {
        await tester.pumpWidget(_buildApp(container));
        await tester.pumpAndSettle();

        // Tap Kebidanan & Obgyn chip
        await tester.tap(find.text('Kebidanan & Obgyn'));
        await tester.pumpAndSettle();

        // Should show the 2 Obgyn doctors
        expect(find.text('dr. Damas Hendriansyah, Sp.OG'), findsOneWidget);
        expect(find.text('dr. Eko Wibowo, Sp.OG'), findsOneWidget);

        // Should NOT show empty state
        expect(find.text('Tidak Ada Jadwal Dokter'), findsNothing);
      },
    );

    testWidgets('search filters list correctly', (tester) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      // Focus the search field and enter text
      await tester.tap(find.byType(AppTextField));
      await tester.enterText(find.byType(AppTextField), 'Hendra');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show only Hendra
      expect(find.text('dr. Hendra, Sp.M'), findsOneWidget);
      // Era Medina should not be visible
      expect(find.text('dr. Era Medina, Sp.PD'), findsNothing);
    });

    testWidgets('search + filter intersection works (BUG-5 regression)', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      // First search for Hendra
      await tester.tap(find.byType(AppTextField));
      await tester.enterText(find.byType(AppTextField), 'Hendra');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Then filter by Mata (Hendra is a Mata doctor)
      await tester.tap(find.text('Mata'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should still show Hendra (intersection)
      expect(find.text('dr. Hendra, Sp.M'), findsOneWidget);

      // Now filter by Anak (Hendra is NOT an Anak doctor)
      await tester.tap(find.text('Anak'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should show empty state (no intersection)
      expect(find.text('Tidak Ada Jadwal Dokter'), findsOneWidget);
      expect(find.text('dr. Hendra, Sp.M'), findsNothing);
    });

    testWidgets('doctor card renders with all required elements', (
      tester,
    ) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      // Check first doctor card elements
      expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);
      expect(find.text('Spesialis Penyakit Dalam'), findsOneWidget);
      // Penyakit Dalam appears in both chip and badge - at least one
      expect(find.text('Penyakit Dalam'), findsAtLeastNWidgets(1));
      expect(find.text('Selasa'), findsOneWidget);
      expect(find.text('Rabu'), findsOneWidget);
      expect(find.text('07.30 – 12.00 WIB'), findsAtLeastNWidgets(2));
      // Praktik Reguler appears for multiple doctors
      expect(find.text('Praktik Reguler'), findsAtLeastNWidgets(1));
      expect(
        find.widgetWithText(AppPrimaryButton, 'Daftar Janji Temu'),
        findsAtLeastNWidgets(1),
      );
    });

    testWidgets('filter with no matches shows empty state', (tester) async {
      await tester.pumpWidget(_buildApp(container));
      await tester.pumpAndSettle();

      // Search for something that doesn't exist
      await tester.tap(find.byType(AppTextField));
      await tester.enterText(find.byType(AppTextField), 'NonExistentDoctor123');
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Tidak Ada Jadwal Dokter'), findsOneWidget);
      expect(
        find.text('Jadwal praktik untuk filter ini belum tersedia.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'filter change does not show shimmer skeleton (BUG-3 regression)',
      (tester) async {
        await tester.pumpWidget(_buildApp(container));
        await tester.pumpAndSettle();

        // Verify initial list is shown (not shimmer)
        expect(find.byType(AppLoadingState), findsNothing);
        expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);

        // Tap a filter chip
        await tester.tap(find.text('Mata'));
        await tester.pump(); // pump once during the fetch

        // Should NOT show shimmer skeleton during filter change
        expect(find.byType(AppLoadingState), findsNothing);

        // Old list should still be visible during fetch
        expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);

        // Wait for fetch to complete
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // New list should be shown
        expect(find.text('dr. Hendra, Sp.M'), findsOneWidget);
      },
    );
  });
}
