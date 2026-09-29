import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/bpjs_flow_screen.dart';

void main() {
  group('BpjsFlowScreen Widget Tests (Epic 08)', () {
    testWidgets('renders BPJS flow screen with guide banner and 5 steps', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const BpjsFlowScreen()),
      );
      await tester.pumpAndSettle();

      // Memeriksa judul AppBar
      expect(find.text('Alur Pasien BPJS Kesehatan'), findsOneWidget);

      // Memeriksa Banner Edukasi
      expect(
        find.textContaining('Pastikan status kepesertaan BPJS Kesehatan Anda'),
        findsOneWidget,
      );

      // Memeriksa judul alur
      expect(find.text('5 Langkah Berobat dengan BPJS'), findsOneWidget);

      // Memeriksa langkah-langkah alur berobat sesuai Task 1-7 BPJS Sitanala
      expect(
        find.text('Pemeriksaan di Faskes Tingkat 1 (FKTP)'),
        findsOneWidget,
      );
      expect(
        find.text('Pendaftaran Online via Aplikasi (Task 1)'),
        findsOneWidget,
      );
      expect(
        find.text('Hadir di RS & Check-In Mesin APM Fisik (Task 2)'),
        findsOneWidget,
      );
      expect(
        find.text('Pelayanan Medis di Poliklinik Spesialis (Task 5 & 6)'),
        findsOneWidget,
      );
      expect(
        find.text('Pengambilan Resep Obat di Farmasi RS (Task 7)'),
        findsOneWidget,
      );
    });
  });
}
