import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/presentation/screens/register_view.dart';

void main() {
  group('RegisterView Widget Tests (Epic 02 Registration)', () {
    testWidgets('register view renders required registration controls', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterView())),
      );

      expect(find.text('Buat Akun Pasien'), findsOneWidget);
      expect(find.text('Nama Lengkap Pasien *'), findsOneWidget);
      expect(find.text('Nomor Telepon *'), findsOneWidget);
      expect(find.text('Email Pasien *'), findsOneWidget);
      expect(find.text('Tanggal Lahir *'), findsOneWidget);
      expect(find.text('Daftar Akun Sekarang'), findsOneWidget);
      expect(find.text('Masuk di sini'), findsOneWidget);
    });

    testWidgets('submitting empty form displays required field errors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: RegisterView())),
      );

      final submitBtn = find.text('Daftar Akun Sekarang');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Masukkan nama lengkap.'), findsOneWidget);
      expect(find.text('Masukkan nomor telepon.'), findsOneWidget);
      expect(find.text('Masukkan alamat email.'), findsOneWidget);
      expect(find.text('Pilih tanggal lahir.'), findsOneWidget);
    });
  });
}
