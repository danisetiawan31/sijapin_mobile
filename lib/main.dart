import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/app_config.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init((options) {
    options.dsn = AppConfig.sentryDsn;
    options.tracesSampleRate = 1.0;
    options.enableAutoSessionTracking = true;
  }, appRunner: () => runApp(const ProviderScope(child: SiijapinApp())));
}

/// Root widget aplikasi SIIJAPIN Mobile.
class SiijapinApp extends StatefulWidget {
  const SiijapinApp({super.key});

  @override
  State<SiijapinApp> createState() => _SiijapinAppState();
}

class _SiijapinAppState extends State<SiijapinApp> {
  late final router = AppRouter.create();

  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
