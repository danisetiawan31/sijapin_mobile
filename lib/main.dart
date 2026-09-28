import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init((options) {
    options.dsn = AppConfig.sentryDsn;
    options.tracesSampleRate = 1.0;
    options.enableAutoSessionTracking = true;
  }, appRunner: () => runApp(const ProviderScope(child: SiijapinApp())));
}

/// Root widget aplikasi SIIJAPIN Mobile
class SiijapinApp extends StatelessWidget {
  const SiijapinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorObservers: [SentryNavigatorObserver()],
      home: const SplashScreen(),
    );
  }
}

/// Layar inisial awal (Splash / Landing Placeholder)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital_rounded,
                size: 72,
                color: AppColors.brandWarmBronze,
              ),
              SizedBox(height: 16),
              Text(
                AppConfig.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'RSUP Dr. Sitanala Tangerang',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
