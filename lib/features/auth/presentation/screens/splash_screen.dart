import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Layar inisial awal (Splash Screen) aplikasi SIIJAPIN Mobile.
///
/// Menampilkan branding RSUP Dr. Sitanala selama 2 detik sebelum
/// otomatis mengarahkan pasien ke Beranda utama ([AppRoutes.homePath]).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.delay = const Duration(seconds: 2),
    this.autoRedirect = true,
  });

  /// Durasi tampilan branding sebelum transisi ke beranda
  final Duration delay;

  /// Flag pengaktifan auto-redirect (dapat dinonaktifkan untuk testing)
  final bool autoRedirect;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.autoRedirect) {
      _timer = Timer(widget.delay, _onSplashComplete);
    }
  }

  void _onSplashComplete() {
    if (!mounted) return;
    context.go(AppRoutes.homePath);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
              SizedBox(height: 32),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.brandGoldenCaramel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
