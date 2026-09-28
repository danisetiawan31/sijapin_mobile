import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/app_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

void main() {
  group('AppTextField Widget Tests', () {
    testWidgets('renders label text correctly via RichText', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(label: 'Nomor Handphone')),
      );
      // AppTextField label menggunakan RichText (untuk mendukung asterisk suffix)
      final richTextFinder = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          return widget.text.toPlainText().contains('Nomor Handphone');
        }
        return false;
      });
      expect(richTextFinder, findsOneWidget);
    });

    testWidgets('renders mandatory asterisk (*) when isRequired is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(label: 'Email', isRequired: true)),
      );
      // The RichText widget contains the label + ' *'
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final rootSpan = richText.text as TextSpan;
      // Main text should contain label
      expect(rootSpan.text, equals('Email'));
      // Children should contain ' *'
      expect(rootSpan.children, isNotNull);
      expect((rootSpan.children!.first as TextSpan).text, equals(' *'));
    });

    testWidgets('does not show asterisk when isRequired is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(label: 'Nama Lengkap', isRequired: false)),
      );
      final richText = tester.widget<RichText>(find.byType(RichText).first);
      final rootSpan = richText.text as TextSpan;
      expect(rootSpan.children, isNull);
    });

    testWidgets('toggles password visibility when eye icon is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppTextField(label: 'Kata Sandi', obscureText: true)),
      );

      // Initial state: eye-off icon shown (field is obscured)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      final editableBefore = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableBefore.obscureText, isTrue);

      // Tap the toggle icon
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      // After tap: eye icon shown (field is visible)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      final editableAfter = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableAfter.obscureText, isFalse);
    });

    testWidgets('renders prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AppTextField(
            label: 'Nomor HP',
            prefixIcon: Icons.phone_outlined,
          ),
        ),
      );
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });

    testWidgets('triggers onChanged when text is entered', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(AppTextField(label: 'Input', onChanged: (val) => changed = val)),
      );
      await tester.enterText(find.byType(TextFormField), 'test123');
      expect(changed, equals('test123'));
    });
  });
}
