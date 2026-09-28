import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/router/app_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';

Widget _buildAppWithRouter(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouterProvider);
        return MaterialApp.router(
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    ),
  );
}

void main() {
  group('Centralized Navigation Shell Tests (US-CORE Phase 4)', () {
    // testWidgets(
    //   'initial route (/) loads SplashScreen and shows Sitanala branding',
    //   (tester) async {
    //     final container = ProviderContainer();
    //     addTearDown(container.dispose);

    //     await tester.pumpWidget(_buildAppWithRouter(container));
    //     await tester.pumpAndSettle();

    //     expect(find.text(AppConfig.appName), findsOneWidget);
    //     expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);
    //   },
    // );
    testWidgets(
      'initial route (/) loads SplashScreen and shows Sitanala branding',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pump();

        expect(find.text(AppConfig.appName), findsOneWidget);
        expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);
        expect(find.text('Memuat aplikasi...'), findsOneWidget);
      },
    );
    testWidgets(
      'navigating to /home renders MainShellScaffold with 4-tab NavigationBar',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.homePath);
        await tester.pumpAndSettle();

        // Verifikasi layar Beranda tampil
        expect(find.text('Beranda RSUP Dr. Sitanala'), findsOneWidget);

        // Verifikasi NavigationBar Material 3 dengan 4 Tab tampil
        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.text('Beranda'), findsOneWidget);
        expect(find.text('Janji Temu'), findsOneWidget);
        expect(find.text('Dokter'), findsOneWidget);
        expect(find.text('Profil'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping navigation tabs switches between screens while keeping shell',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.homePath);
        await tester.pumpAndSettle();

        // Tap Tab 2: Janji Temu
        await tester.tap(find.text('Janji Temu'));
        await tester.pumpAndSettle();
        expect(find.text('Tiket & Janji Temu Pasien'), findsOneWidget);

        // Tap Tab 3: Dokter
        await tester.tap(find.text('Dokter'));
        await tester.pumpAndSettle();
        expect(find.text('Jadwal Praktik Poliklinik'), findsOneWidget);

        // Tap Tab 4: Profil
        await tester.tap(find.text('Profil'));
        await tester.pumpAndSettle();
        expect(find.text('Profil & Anggota Keluarga'), findsOneWidget);

        // Tap Tab 1: Kembali ke Beranda
        await tester.tap(find.text('Beranda'));
        await tester.pumpAndSettle();
        expect(find.text('Beranda RSUP Dr. Sitanala'), findsOneWidget);
      },
    );

    testWidgets(
      'navigating to /login renders outside shell without NavigationBar',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.loginPath);
        await tester.pumpAndSettle();

        // Verifikasi layar Login tampil
        // expect(find.text('Layar Masuk Akun SIIJAPIN'), findsOneWidget);
        expect(find.text('Selamat Datang'), findsOneWidget);

        // NavigationBar TIDAK boleh ada di halaman login (rute di luar shell)
        expect(find.byType(NavigationBar), findsNothing);
      },
    );
  });
}
