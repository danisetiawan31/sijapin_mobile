import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/presentation/screens/login_view.dart';

void main() {
  group('LoginView Widget Tests (Epic 02 Authentication)', () {
    testWidgets('login view renders required authentication controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginView())),
      );

      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Nomor Telepon / Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Masuk ke Akun'), findsOneWidget);
      expect(find.text('Daftar di sini'), findsOneWidget);
    });

    testWidgets(
      'submitting empty form displays phone/email and password validation errors',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: LoginView())),
        );

        await tester.tap(find.text('Masuk ke Akun'));
        await tester.pumpAndSettle();

        expect(
          find.text('Masukkan nomor telepon atau email terdaftar.'),
          findsOneWidget,
        );
        expect(find.text('Masukkan kata sandi.'), findsOneWidget);
      },
    );

    testWidgets(
      'entering invalid phone number with fewer than 10 digits shows length error',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: LoginView())),
        );

        final phoneFinder = find.widgetWithText(TextField, '');
        await tester.enterText(phoneFinder.first, '08123');
        await tester.tap(find.text('Masuk ke Akun'));
        await tester.pumpAndSettle();

        expect(
          find.text('Nomor telepon harus 10–15 digit angka.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('entering invalid email format shows email format error', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginView())),
      );

      final inputFinder = find.widgetWithText(TextField, '');
      await tester.enterText(inputFinder.first, 'invalid@email');
      await tester.tap(find.text('Masuk ke Akun'));
      await tester.pumpAndSettle();

      expect(find.text('Format email belum benar.'), findsOneWidget);
    });
  });
}
