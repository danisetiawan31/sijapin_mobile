import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/app_text_field.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/complaint_screen.dart';

void main() {
  group('ComplaintScreen Widget Tests (Epic 08 US-SUP-02)', () {
    testWidgets(
      'renders complaint screen with form inputs and Kemenkes help info',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ComplaintScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Memeriksa judul AppBar
        expect(find.text('Form Pengaduan Layanan'), findsOneWidget);

        // Memeriksa kanal bantuan resmi Kemenkes (US-SUP-02 Scenario 2)
        expect(find.text('Kanal Bantuan Resmi Kemenkes RI'), findsOneWidget);
        expect(find.textContaining('Halo Kemenkes 1500-567'), findsOneWidget);

        // Memeriksa keberadaan 6 komponen input AppTextField beserta hint text
        expect(find.byType(AppTextField), findsNWidgets(6));
        expect(find.text('Masukkan nama pengirim'), findsOneWidget);
        expect(find.text('Contoh: 081234567890'), findsOneWidget);
        expect(find.text('Contoh: pasien@email.com'), findsOneWidget);
        expect(find.text('Masukkan alamat domisili pengirim'), findsOneWidget);
        expect(
          find.text('Contoh: Keluhan Waktu Tunggu Farmasi'),
          findsOneWidget,
        );

        // Memeriksa tombol submit
        expect(find.text('Kirim Pengaduan'), findsOneWidget);
      },
    );

    testWidgets('submitting empty form triggers validation error messages', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const ComplaintScreen()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kirim Pengaduan'));
      await tester.pumpAndSettle();

      expect(find.text('Nama pengirim wajib diisi'), findsOneWidget);
      expect(find.text('Nomor HP wajib diisi'), findsOneWidget);
      expect(find.text('Perihal pengaduan wajib diisi'), findsOneWidget);
      expect(find.text('Deskripsi pengaduan wajib diisi'), findsOneWidget);
    });
  });
}
