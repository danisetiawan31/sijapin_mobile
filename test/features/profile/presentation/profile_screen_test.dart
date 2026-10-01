import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/screens/profile_screen.dart';

Future<void> _pumpProfile(WidgetTester tester, {bool signedIn = true}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (!signedIn) currentUserProfileProvider.overrideWithValue(null),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProfileScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('menampilkan identitas dan data diri pasien yang login', (
    tester,
  ) async {
    await _pumpProfile(tester);

    expect(find.text('Profil Saya'), findsOneWidget);
    expect(find.text('Rina Puspita Sari'), findsOneWidget);
    expect(find.text('Data Diri'), findsOneWidget);
    expect(find.text('Golongan Darah'), findsOneWidget);
    expect(find.text('Anggota Keluarga'), findsOneWidget);
    expect(find.text('Kunci Biometrik (Sidik Jari / Face ID)'), findsOneWidget);
    expect(find.text('Masuk Cepat dan aman ke Aplikasi'), findsOneWidget);
    expect(find.text('Kode Kunci (PIN)'), findsOneWidget);
    expect(find.text('Belum dibuat'), findsOneWidget);
    expect(find.text('Hotline Rumah Sakit'), findsOneWidget);
    expect(find.text('Tentang Sijapin'), findsOneWidget);
    expect(find.text('Keluar dari Akun'), findsOneWidget);
  });

  testWidgets('menyorot data yang belum lengkap dengan badge peringatan', (
    tester,
  ) async {
    await _pumpProfile(tester);

    expect(find.text('Data Belum Lengkap'), findsOneWidget);
    expect(find.text('Belum diisi'), findsOneWidget);
  });

  testWidgets('menampilkan ajakan masuk ketika belum ada sesi', (tester) async {
    await _pumpProfile(tester, signedIn: false);

    expect(find.text('Belum Masuk'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Data Diri'), findsNothing);
  });

  testWidgets('toggle pengingat janji temu mengubah state controller', (
    tester,
  ) async {
    await _pumpProfile(tester);

    Finder reminderSwitch() => find.byKey(const ValueKey('reminder-switch'));

    expect(tester.widget<Switch>(reminderSwitch()).value, isTrue);

    await tester.tap(find.text('Pengingat Janji Temu'));
    await tester.pumpAndSettle();

    expect(tester.widget<Switch>(reminderSwitch()).value, isFalse);
    expect(find.text('Nonaktif'), findsOneWidget);
  });

  testWidgets(
    'keluar dari akun meminta konfirmasi lalu mengembalikan state tamu',
    (tester) async {
      await _pumpProfile(tester);

      await tester.tap(find.text('Keluar dari Akun'));
      await tester.pumpAndSettle();
      expect(find.text('Keluar dari aplikasi?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Keluar'));
      await tester.pumpAndSettle();

      expect(find.text('Belum Masuk'), findsOneWidget);
    },
  );
}
