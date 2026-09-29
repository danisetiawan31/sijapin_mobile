import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Kartu Pahlawan (Hero Card) Pendaftaran Rawat Jalan di Beranda.
///
/// Mengadopsi desain elegan non-AI slop:
/// - Watermark dedaunan botani alami di sudut atas kanan & bawah kiri
/// - Squircle container mint dengan ikon kalender medis
/// - Badge pill "Layanan Utama"
/// - Tipografi presisi dengan hierarki tinggi
/// - Tombol pill "Daftar Sekarang >" berwarna hijau toska tua yang berwibawa
class HomeRegistrationCard extends StatelessWidget {
  const HomeRegistrationCard({super.key, required this.onRegisterTap});

  /// Aksi saat kartu atau tombol "Daftar Sekarang" ditekan.
  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onRegisterTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: AppColors.clinicalTeal.withValues(alpha: 0.08),
        highlightColor: AppColors.clinicalContainer.withValues(alpha: 0.3),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.clinicalTeal.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Watermark Dedaunan Botani Sudut Atas Kanan
                Positioned(
                  top: 0,
                  right: 0,
                  width: 95,
                  height: 95,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/leaves_tr.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.topRight,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Watermark Dedaunan Botani Sudut Bawah Kiri
                Positioned(
                  bottom: 0,
                  left: 0,
                  width: 95,
                  height: 75,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/leaves_bl.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomLeft,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),

                // Konten Utama Kartu
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris Atas: Ikon Kalender Klinis & Badge Layanan Utama
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Kontainer Ikon Kalender Medis (Squircle Mint)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.clinicalContainer.withValues(
                                alpha: 0.75,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.clinicalTeal,
                                size: 26,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Badge Pill "Layanan Utama"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.clinicalContainer.withValues(
                                alpha: 0.85,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Layanan Utama',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.clinicalTealDeep,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Judul Pendaftaran Rawat Jalan
                      const Text(
                        'Pendaftaran Rawat Jalan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brandDarkEspresso,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subjudul Deskripsi
                      const Text(
                        'Booking poli reguler & eksekutif BPJS / Umum tanpa perlu antre panjang di loket registrasi.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Baris Aksi Bawah: Tombol "Daftar Sekarang >" di Kanan Bawah
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.clinicalTeal,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.clinicalTeal.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Daftar Sekarang',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textWhite,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textWhite,
                                  size: 16,
                                ),
                              ],
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
        ),
      ),
    );
  }
}
