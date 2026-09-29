import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/mcu_catalog_screen.dart';

void main() {
  group('McuCatalogScreen Widget Tests (Epic 08 US-SUP-01)', () {
    testWidgets(
      'renders MCU catalog screen with packages and fasting guide banner',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const McuCatalogScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Memeriksa judul AppBar
        expect(find.text('Katalog Paket MCU'), findsOneWidget);

        // Memeriksa Banner Panduan Puasa (US-SUP-01)
        expect(find.text('Panduan Persiapan Puasa'), findsOneWidget);
        expect(find.textContaining('Wajib berpuasa 10–12 jam'), findsOneWidget);

        // Memeriksa judul seksi paket
        expect(
          find.text('Pilihan Paket Pemeriksaan MCU Sitanala'),
          findsOneWidget,
        );

        // Memeriksa keberadaan nama-nama paket MCU riil Sitanala
        expect(find.text('Paket MCU Standar'), findsOneWidget);
        expect(find.text('Paket Bebas Narkoba & MMPI'), findsOneWidget);
        expect(find.text('Paket MCU Komprehensif'), findsOneWidget);
        expect(find.text('Paket Psikologi & Konseling'), findsOneWidget);

        // Memeriksa tombol aksi pemilihan paket
        expect(find.text('Pilih Paket'), findsWidgets);
      },
    );

    testWidgets('tapping Pilih Paket triggers snackbar selection message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const McuCatalogScreen()),
      );
      await tester.pumpAndSettle();

      final firstSelectButton = find.text('Pilih Paket').first;
      await tester.tap(firstSelectButton);
      await tester.pump();

      expect(
        find.textContaining('Paket MCU Standar (Kode: 120050) dipilih'),
        findsOneWidget,
      );
    });
  });
}
