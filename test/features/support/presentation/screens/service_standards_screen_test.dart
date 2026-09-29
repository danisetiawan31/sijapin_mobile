import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/service_standards_screen.dart';

void main() {
  group('ServiceStandardsScreen Widget Tests (Epic 08)', () {
    testWidgets(
      'renders service standards screen with maklumat, schedule, and patient rights',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const ServiceStandardsScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Memeriksa judul AppBar
        expect(find.text('Standar Pelayanan Publik'), findsOneWidget);

        // Memeriksa Maklumat Pelayanan
        expect(find.text('Maklumat Pelayanan'), findsOneWidget);
        expect(find.text('— Direksi RSUP Dr. Sitanala'), findsOneWidget);

        // Memeriksa Jam Operasional Pelayanan
        expect(find.text('Jam Operasional Pelayanan'), findsOneWidget);
        expect(find.text('Instalasi Gawat Darurat (IGD)'), findsOneWidget);
        expect(find.textContaining('24 Jam Non-Stop'), findsOneWidget);

        // Memeriksa Hak dan Kewajiban Pasien
        expect(find.text('Hak & Kewajiban Pasien'), findsOneWidget);
        expect(find.text('Ringkasan Hak Pasien'), findsOneWidget);
        expect(find.text('Ringkasan Kewajiban Pasien'), findsOneWidget);
      },
    );
  });
}
