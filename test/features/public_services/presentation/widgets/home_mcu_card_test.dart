import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_mcu_card.dart';

void main() {
  group('HomeMcuCard Widget Tests', () {
    testWidgets('renders all labels, badges, and triggers onMcuTap on tap', (
      tester,
    ) async {
      var mcuTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeMcuCard(
              onMcuTap: () {
                mcuTapped = true;
              },
            ),
          ),
        ),
      );

      // Verifikasi judul dan subjudul
      expect(find.text('Skrining Preventif'), findsOneWidget);
      expect(find.text('Paket Medical Check Up (MCU)'), findsOneWidget);
      expect(
        find.textContaining('Pemeriksaan kesehatan menyeluruh'),
        findsOneWidget,
      );

      // Verifikasi elemen visual utama (Badge Plus)
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Verifikasi tombol Lihat Paket
      expect(find.text('Lihat Paket'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);

      // Verifikasi tap pada tombol
      await tester.tap(find.text('Lihat Paket'));
      await tester.pumpAndSettle();
      expect(mcuTapped, isTrue);
    });
  });
}
