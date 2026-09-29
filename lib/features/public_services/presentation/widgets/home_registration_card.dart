import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Kartu Pahlawan (Hero Bento Card) Pendaftaran Rawat Jalan di Beranda.
///
/// Disempurnakan dengan standar Impeccable Craft:
/// - Squircle container 20dp dengan pendaran radial lembut keemasan Sitanala
/// - Badge status "Layanan Utama" berkilau dengan ikon auto_awesome
/// - Kontainer ikon kalender klinis 3D-embossed berlapis
/// - Status chip kredibilitas "Terhubung SISRUTE & BPJS"
/// - Floating CTA button bergradien karamel keemasan dengan ambient glow
class HomeRegistrationCard extends StatelessWidget {
  const HomeRegistrationCard({super.key, required this.onRegisterTap});

  /// Aksi saat tombol "Daftar Poli" ditekan.
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onRegisterTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.brandGoldenCaramel.withValues(alpha: 0.08),
        highlightColor: AppColors.brandCreamLinen.withValues(alpha: 0.5),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderCardSubtle, width: 1.2),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.white, AppColors.surfaceWarm],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDeepChocolate.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: AppColors.brandGoldenCaramel.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // Pendaran radial lembut keemasan di sudut kanan bawah
              Positioned(
                right: -30,
                bottom: -30,
                child: IgnorePointer(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.brandSoftSand.withValues(alpha: 0.22),
                          AppColors.brandSoftSand.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Konten Utama Kartu
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge Pill "Layanan Utama" dengan ikon bintang
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warningContainer,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.warningBorder,
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 11,
                                      color: AppColors.brandGoldenCaramel,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Layanan Utama',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.warningText,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pendaftaran Rawat Jalan',
                                style: TextStyle(
                                  fontSize: 18.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandDarkEspresso,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Booking poli reguler & eksekutif BPJS / Umum tanpa perlu antre panjang di loket registrasi.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Ikon Kalender Klinis Embossed
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.surfaceLighter,
                                AppColors.brandCreamLinen,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.brandSoftSand.withValues(
                                alpha: 0.6,
                              ),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowWarm.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.edit_calendar_rounded,
                              color: AppColors.brandGoldenCaramel,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Baris Pemisah & Tombol CTA Bawah
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.borderSubtle.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Status Chip SISRUTE & BPJS
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.clinicalContainer,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.clinicalBorder,
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.clinicalTeal,
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Terhubung SISRUTE & BPJS',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.clinicalTeal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Floating CTA Button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.brandGoldenCaramelDark,
                                  AppColors.brandGoldenCaramel,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.brandGoldenCaramel
                                      .withValues(alpha: 0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: AppColors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              child: InkWell(
                                onTap: onRegisterTap,
                                borderRadius: BorderRadius.circular(999),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Daftar Poli',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textWhite,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: AppColors.textWhite,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
