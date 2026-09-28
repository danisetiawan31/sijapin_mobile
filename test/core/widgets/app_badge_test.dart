import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';

void main() {
  group('AppBadge Widget Tests', () {
    testWidgets('renders success badge with label and check icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppBadge.success(label: '5 Bed Kosong')),
        ),
      );

      expect(find.text('5 Bed Kosong'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('renders warning badge with label and warning icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppBadge.warning(label: '1 Bed Tersisa')),
        ),
      );

      expect(find.text('1 Bed Tersisa'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders danger badge with label and cancel icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppBadge.danger(label: 'Penuh')),
        ),
      );

      expect(find.text('Penuh'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('renders neutral badge with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppBadge.neutral(label: 'BPJS Kesehatan')),
        ),
      );

      expect(find.text('BPJS Kesehatan'), findsOneWidget);
    });
  });
}
