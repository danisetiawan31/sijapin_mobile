import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/app_config.dart';
import 'core/network/cookie_manager_service.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_date_time.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi basis data zona waktu resmi RSUP Dr. Sitanala (WIB / Asia/Jakarta)
  AppDateTime.initialize();

  // Konfigurasi status bar & navigasi agar menyatu 1 warna tanpa shadow/scrim
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: AppColors.surfaceBg,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Inisialisasi basis data lokal Hive CE
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Inisialisasi direktori penyimpanan persisten cookie session CI3
  final cookieManagerService = await CookieManagerService.createPersistent();

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.enableAutoSessionTracking = false;
    },
    appRunner: () {
      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details);
        debugPrint('FLUTTER_ERROR_EX: ${details.exception}');
        debugPrint('FLUTTER_STACK:\n${details.stack}');
      };

      ErrorWidget.builder = (FlutterErrorDetails details) {
        return Material(
          color: AppColors.brandDarkEspresso,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                'ERROR:\n${details.exceptionAsString()}\n\nSTACK TRACE:\n${details.stack}',
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        );
      };

      runApp(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(localStorageService),
            cookieManagerServiceProvider.overrideWithValue(
              cookieManagerService,
            ),
          ],
          child: const SiijapinApp(),
        ),
      );
    },
  );
}

/// Root widget aplikasi SIIJAPIN Mobile dengan dukungan GoRouter.
class SiijapinApp extends ConsumerWidget {
  const SiijapinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
