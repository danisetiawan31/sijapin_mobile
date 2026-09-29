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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 100, // Ruang ekstra agar tidak tertutup floating bottom navbar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Beranda RSUP Dr. Sitanala',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Akses cepat informasi dan layanan publik rumah sakit',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Grid Menu Akses Cepat (4 Pintu Masuk Layanan Support)
                    Row(
                      children: [
                        Expanded(
                          child: _QuickMenuItem(
                            title: 'Katalog MCU',
                            subtitle: 'Tarif & paket skrining',
                            icon: Icons.medical_services_outlined,
                            iconColor: AppColors.brandGoldenCaramel,
                            onTap: () => context.push(AppRoutes.mcuCatalogPath),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickMenuItem(
                            title: 'Pengaduan',
                            subtitle: 'Form aspirasi pasien',
                            icon: Icons.chat_bubble_outline_rounded,
                            iconColor: AppColors.clinicalTeal,
                            onTap: () => context.push(AppRoutes.complaintPath),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickMenuItem(
                            title: 'Standar Layanan',
                            subtitle: 'Maklumat & hak pasien',
                            icon: Icons.verified_user_outlined,
                            iconColor: AppColors.brandWarmBronze,
                            onTap: () =>
                                context.push(AppRoutes.serviceStandardsPath),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickMenuItem(
                            title: 'Alur BPJS',
                            subtitle: '5 langkah berobat RS',
                            icon: Icons.alt_route_rounded,
                            iconColor: AppColors.successEmerald,
                            onTap: () => context.push(AppRoutes.bpjsFlowPath),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget Kartu Menu Pintas di Beranda
class _QuickMenuItem extends StatelessWidget {
  const _QuickMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
