import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/app_config.dart';
import 'core/network/cookie_manager_service.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';

export 'features/auth/presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi basis data lokal Hive CE
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // Inisialisasi direktori penyimpanan persisten cookie session CI3
  final cookieManagerService = await CookieManagerService.createPersistent();

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.enableAutoSessionTracking = true;
    },
    appRunner: () => runApp(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(localStorageService),
          cookieManagerServiceProvider.overrideWithValue(cookieManagerService),
        ],
        child: const SiijapinApp(),
      ),
    ),
  );
}

/// Root widget aplikasi SIIJAPIN Mobile dengan dukungan GoRouter
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
