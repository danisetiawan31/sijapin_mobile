import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/home_widgets.dart';

/// Tab 1: Beranda Layanan Publik & Informasi RSUP Dr. Sitanala.
///
/// Disusun secara modular dengan mengadopsi 100% desain resmi Google Stitch
/// (project `projects/2575501304420738712`):
/// - Header RS permanen (pinned top)
/// - Section 1: Layanan Poliklinik & Pasien (Hero Rawat Jalan, Bento Status Duo, Bento MCU)
/// - Section 2: Bantuan & Informasi Cepat (Grid 4 Aksi Cepat + Banner IGD 24 Jam)
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
                  top: 14,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // Komponen 1: Hero Card Pendaftaran Rawat Jalan
                    HomeRegistrationCard(
                      onRegisterTap: () => context.go(AppRoutes.bookingPath),
                    ),
                    const SizedBox(height: 12),

                    // Komponen 2: Dua Kartu Bento Sejajar (Kamar & Dokter)
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

                    // Komponen 3: Kartu Horizontal MCU
                    HomeMcuCard(
                      onMcuTap: () => context.push(AppRoutes.mcuCatalogPath),
                    ),
                    const SizedBox(height: 20),

                    // Komponen 4: Grid 4 Aksi Cepat (Pengaduan, Standar Layanan, Alur BPJS, Lokasi)
                    HomeQuickActions(
                      onComplaintTap: () =>
                          context.push(AppRoutes.complaintPath),
                      onServiceStandardsTap: () =>
                          context.push(AppRoutes.serviceStandardsPath),
                      onBpjsFlowTap: () => context.push(AppRoutes.bpjsFlowPath),
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

                    // Komponen 5: Banner Gawat Darurat IGD 24 Jam
                    const HomeEmergencyBanner(),
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
