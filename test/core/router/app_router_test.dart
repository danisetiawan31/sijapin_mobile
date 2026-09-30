import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/router/app_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/app_bottom_nav_bar.dart';

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
      'navigating to /home renders MainShellScaffold with 4-tab AppBottomNavBar',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.homePath);
        await tester.pumpAndSettle();

        // Verifikasi layar Beranda tampil
        expect(find.text('Layanan Poliklinik & Pasien'), findsOneWidget);

        // Verifikasi AppBottomNavBar dengan 4 Tab tampil
        expect(find.byType(AppBottomNavBar), findsOneWidget);
        expect(find.text('Beranda'), findsOneWidget);
        expect(find.text('Janji Temu'), findsOneWidget);
        expect(find.text('Jadwal'), findsOneWidget);
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

        // Label tab dicari di dalam AppBottomNavBar agar tidak bentrok dengan
        // teks layar (mis. "Dokter" pada detail tiket antrean).
        final navBar = find.byType(AppBottomNavBar);

        // Tap Tab 2: Janji Temu
        await tester.tap(
          find.descendant(of: navBar, matching: find.text('Janji Temu')),
        );
        // Titik berdenyut pada BookingScreen berjalan terus, jadi tidak memakai
        // pumpAndSettle yang akan menunggu animasi selesai.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('Tiket Aktif'), findsOneWidget);
        expect(find.text('Tiket Kunjungan Aktif'), findsOneWidget);

        // Tap Tab 3: Jadwal
        await tester.tap(
          find.descendant(of: navBar, matching: find.text('Jadwal')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Jadwal Dokter'), findsOneWidget);
        expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);

        // Tap Tab 4: Profil
        await tester.tap(
          find.descendant(of: navBar, matching: find.text('Profil')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Profil Saya'), findsOneWidget);
        expect(find.text('Data Diri'), findsOneWidget);

        // Tap Tab 1: Kembali ke Beranda
        await tester.tap(
          find.descendant(of: navBar, matching: find.text('Beranda')),
        );
        await tester.pumpAndSettle();
        expect(find.text('Layanan Poliklinik & Pasien'), findsOneWidget);
      },
    );

    testWidgets(
      'navigating to /login renders outside shell without AppBottomNavBar',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.loginPath);
        await tester.pumpAndSettle();

        // Verifikasi layar Login tampil
        expect(find.text('Selamat Datang'), findsOneWidget);

        // AppBottomNavBar TIDAK boleh ada di halaman login (rute di luar shell)
        expect(find.byType(AppBottomNavBar), findsNothing);
      },
    );

    testWidgets(
      'navigating to /register renders outside shell without AppBottomNavBar',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.registerPath);
        await tester.pumpAndSettle();

        // Verifikasi layar Register tampil
        expect(find.text('Buat Akun Pasien'), findsOneWidget);

        // AppBottomNavBar TIDAK boleh ada di halaman register (rute di luar shell)
        expect(find.byType(AppBottomNavBar), findsNothing);
      },
    );

    testWidgets(
      'navigating to /mcu renders McuCatalogScreen outside shell without AppBottomNavBar',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.mcuCatalogPath);
        await tester.pumpAndSettle();

        expect(find.text('Katalog Paket MCU'), findsOneWidget);
        expect(find.text('Panduan Persiapan Puasa'), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsNothing);
      },
    );

    testWidgets(
      'navigating to /profile/medical-history renders MedicalHistoryScreen inside shell',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.medicalHistoryPath);
        await tester.pumpAndSettle();

        expect(find.text('Riwayat Medis'), findsOneWidget);
        expect(find.text('4 catatan rekam medis'), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsOneWidget);
      },
    );

    testWidgets(
      'navigating to /support/complaint renders ComplaintScreen outside shell without AppBottomNavBar',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.complaintPath);
        await tester.pumpAndSettle();

        expect(find.text('Form Pengaduan Layanan'), findsOneWidget);
        expect(find.text('Kanal Bantuan Resmi Kemenkes RI'), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsNothing);
      },
    );

    testWidgets(
      'navigating to /support/service-standards renders ServiceStandardsScreen outside shell',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.serviceStandardsPath);
        await tester.pumpAndSettle();

        expect(find.text('Standar Pelayanan Publik'), findsOneWidget);
        expect(find.text('Maklumat Pelayanan'), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsNothing);
      },
    );

    testWidgets(
      'navigating to /support/bpjs-flow renders BpjsFlowScreen outside shell',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildAppWithRouter(container));
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);
        router.go(AppRoutes.bpjsFlowPath);
        await tester.pumpAndSettle();

        expect(find.text('Alur Pasien BPJS Kesehatan'), findsOneWidget);
        expect(find.text('5 Langkah Berobat dengan BPJS'), findsOneWidget);
        expect(find.byType(AppBottomNavBar), findsNothing);
      },
    );
  });
}
