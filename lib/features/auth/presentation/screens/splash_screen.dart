import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Layar inisial awal (Splash Screen) aplikasi SIIJAPIN Mobile.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.delay = const Duration(milliseconds: 1200),
    this.autoRedirect = true,
  });

  /// Durasi tampilan branding sebelum transisi ke beranda
  final Duration delay;

  /// Flag pengaktifan auto-redirect (dapat dinonaktifkan untuk pengujian unit/widget)
  final bool autoRedirect;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    if (widget.autoRedirect) {
      _navigationTimer = Timer(widget.delay, () {
        if (mounted) {
          context.go(AppRoutes.homePath);
        }
      });
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_hospital_rounded,
                  size: 72,
                  color: AppColors.brandWarmBronze,
                ),
                const SizedBox(height: 16),
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text('RSUP Dr. Sitanala Tangerang'),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                const Text('Memuat aplikasi...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
