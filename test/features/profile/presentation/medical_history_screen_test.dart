import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/screens/medical_history_screen.dart';

import 'package:sijapin_mobile/features/profile/domain/entities/user_profile.dart';

const testUser = UserProfile(
  customerId: '4',
  fullName: 'Rina Puspita Sari',
  email: 'rina.puspita@warga.go.id',
  phone: '081234567890',
  nik: '3671044508940002',
  gender: 'P',
  bloodType: 'O',
  address: 'Jl. Cileduk Raya No. 24, Tangerang',
);

Future<void> _pumpHistory(
  WidgetTester tester, {
  bool signedIn = true,
  Size size = const Size(1080, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.medicalHistoryPath,
    routes: [
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => const Scaffold(body: Text('LoginScreen')),
      ),
      GoRoute(
        path: AppRoutes.medicalHistoryPath,
        name: AppRoutes.medicalHistoryName,
        builder: (context, state) => const MedicalHistoryScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProfileProvider.overrideWithValue(
          signedIn ? testUser : null,
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menampilkan ringkasan kosong yang jujur saat login', (
    tester,
  ) async {
    await _pumpHistory(tester);

    expect(find.text('Riwayat Medis'), findsOneWidget);
    expect(find.text('0 catatan rekam medis'), findsOneWidget);
    expect(find.text('Belum Ada Riwayat Medis'), findsOneWidget);
    expect(find.text('Hipertensi Primer Grade 1'), findsNothing);
    expect(
      find.textContaining('Rekam medis resmi dapat diminta di Loket 1'),
      findsOneWidget,
    );
  });

  testWidgets('empty state menyebut penyebab dan kapan data muncul', (
    tester,
  ) async {
    await _pumpHistory(tester);

    expect(find.text('Belum Ada Riwayat Medis'), findsOneWidget);
    expect(find.textContaining('kunjungan pertama'), findsOneWidget);
  });

  testWidgets('menampilkan ajakan masuk ketika belum ada sesi', (tester) async {
    await _pumpHistory(tester, signedIn: false);

    expect(find.text('Belum Masuk'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
    expect(find.text('4 catatan rekam medis'), findsNothing);
  });

  testWidgets('layar tetap utuh pada ukuran sempit 360x640', (tester) async {
    await _pumpHistory(tester, size: const Size(360, 640));

    expect(find.text('Riwayat Medis'), findsOneWidget);
    expect(find.text('Belum Ada Riwayat Medis'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
