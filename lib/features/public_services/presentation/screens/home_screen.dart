import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_widgets.dart';

/// Tab 1: Beranda Layanan Publik & Informasi RSUP Dr. Sitanala.
///
/// Redesain Impeccable — menghapus sindrom "kotak-di-dalam-kotak" dengan:
/// - Header dinamis berisi sapaan kontekstual + search pill
/// - Hero card bergradien gelap sebagai focal point
/// - Status Bento dengan metrik besar dan live dot
/// - Quick actions dalam format pill chips berwarna
/// - Banner darurat IGD yang compact
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: AppColors.surfaceBg,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surfaceBg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header Dinamis (Sapaan + Search + Notifikasi + Login)
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
                onSearchTap: () {
                  // TODO: Navigasi ke halaman pencarian
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur pencarian segera hadir'),
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
                    top: 14,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Sapaan Ramah & Identitas (Mockup Acuan)
                      const HomeWelcomeBanner(),
                      const SizedBox(height: 16),

                      // Header Section 1: Layanan Poliklinik & Pasien
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Layanan Poliklinik & Pasien',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brandDarkEspresso,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.go(AppRoutes.doctorsPath),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Semua',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brandGoldenCaramel,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: AppColors.brandGoldenCaramel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Hero Card: Pendaftaran Rawat Jalan
                      HomeRegistrationCard(
                        onRegisterTap: () => context.go(AppRoutes.bookingPath),
                      ),
                      const SizedBox(height: 12),

                      // Status Bento: Kamar & Dokter
                      HomeBentoStatusCards(
                        onBedAvailabilityTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Informasi Kamar: 18 Bed Kosong (VIP, Kelas 1, 2, 3)',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        onDoctorScheduleTap: () =>
                            context.go(AppRoutes.doctorsPath),
                      ),
                      const SizedBox(height: 12),

                      // Kartu MCU Horizontal Compact
                      HomeMcuCard(
                        onMcuTap: () => context.push(AppRoutes.mcuCatalogPath),
                      ),
                      const SizedBox(height: 18),

                      // Aksi Cepat: Pill Chips
                      HomeQuickActions(
                        onComplaintTap: () =>
                            context.push(AppRoutes.complaintPath),
                        onServiceStandardsTap: () =>
                            context.push(AppRoutes.serviceStandardsPath),
                        onBpjsFlowTap: () =>
                            context.push(AppRoutes.bpjsFlowPath),
                        onHospitalLocationTap: () {
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Lokasi ${AppConstants.hospitalName}',
                              ),
                              content: const Text(
                                '${AppConstants.hospitalAddress}\n\n${AppConstants.hospitalOperatingHours}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Banner Darurat IGD
                      const HomeEmergencyBanner(),
                    ],
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
