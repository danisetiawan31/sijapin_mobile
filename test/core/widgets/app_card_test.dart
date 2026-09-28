import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';

void main() {
  group('AppCard Widget Tests', () {
    testWidgets('renders child widget correctly in elevated variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppCard.elevated(child: Text('Konten Kartu'))),
        ),
      );

      expect(find.text('Konten Kartu'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when card is tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard.elevated(
              onTap: () => tapped = true,
              child: const Text('Klik Saya'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Klik Saya'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('renders highlighted variant with gold border', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard.highlighted(child: Text('Tiket Aktif Hari Ini')),
          ),
        ),
      );

      expect(find.text('Tiket Aktif Hari Ini'), findsOneWidget);
    });
  });
}
