import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_header.dart';

/// Tab 1: Beranda Layanan Publik & Informasi RSUP Dr. Sitanala
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Pinned Top Header (Identitas RS, Notifikasi, Masuk / Profil)
            HomeHeader(
              onLoginTap: () => context.push(AppRoutes.loginPath),
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Belum ada notifikasi baru'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            // Konten Scrollable Beranda
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 100, // Ruang ekstra agar tidak tertutup floating bottom navbar
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_hospital_rounded,
                        size: 64,
                        color: AppColors.brandGoldenCaramel,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Beranda RSUP Dr. Sitanala',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
