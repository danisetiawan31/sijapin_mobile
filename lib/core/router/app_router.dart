import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/booking/presentation/screens/booking_screen.dart';
import '../../features/booking/presentation/screens/doctor_schedule_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/public_services/presentation/screens/home_screen.dart';
import 'app_routes.dart';
import 'main_shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorHome = GlobalKey<NavigatorState>(
  debugLabel: 'homeNav',
);
final GlobalKey<NavigatorState> _shellNavigatorBooking =
    GlobalKey<NavigatorState>(debugLabel: 'bookingNav');
final GlobalKey<NavigatorState> _shellNavigatorDoctors =
    GlobalKey<NavigatorState>(debugLabel: 'doctorsNav');
final GlobalKey<NavigatorState> _shellNavigatorProfile =
    GlobalKey<NavigatorState>(debugLabel: 'profileNav');

/// Konfigurasi GoRouter terpusat untuk SIIJAPIN Mobile.
///
/// Menggunakan [StatefulShellRoute.indexedStack] untuk 4 tab utama
/// guna mempertahankan state halaman dan posisi scroll masing-masing tab.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splashPath,
    observers: [SentryNavigatorObserver()],
    routes: [
      // Rute Mandiri di Luar Shell (Tidak Memiliki Bottom Navigation Bar)
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        parentNavigatorKey: _rootNavigatorKey,
        // builder: (context, state) => const LoginScreen(),
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: AppRoutes.registerPath,
        name: AppRoutes.registerName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterView(),
      ),
      // Stateful Shell Route untuk 4 Tab Utama Persisten
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Beranda
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHome,
            routes: [
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.homeName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),

          // Tab 2: Janji Temu
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBooking,
            routes: [
              GoRoute(
                path: AppRoutes.bookingPath,
                name: AppRoutes.bookingName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: BookingScreen()),
              ),
            ],
          ),

          // Tab 3: Jadwal Dokter
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDoctors,
            routes: [
              GoRoute(
                path: AppRoutes.doctorsPath,
                name: AppRoutes.doctorsName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DoctorScheduleScreen()),
              ),
            ],
          ),

          // Tab 4: Profil
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfile,
            routes: [
              GoRoute(
                path: AppRoutes.profilePath,
                name: AppRoutes.profileName,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
