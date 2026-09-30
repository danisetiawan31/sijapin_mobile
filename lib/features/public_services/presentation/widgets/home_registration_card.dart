import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_vectors.dart';
import '../../../../core/theme/app_colors.dart';

/// Kartu Pahlawan (Hero Card) Pendaftaran Rawat Jalan di Beranda.
///
/// Mengadopsi pattern elegan dan modern yang selaras dengan kartu MCU:
/// - Baris atas: Badge kalender toska + pill "Layanan Utama" di kiri, dan badge jadwal terverifikasi di kanan
/// - Tipografi hierarki tinggi: Judul tebal & subjudul terpadu yang mudah dibaca
/// - Tombol pill "Daftar Sekarang ➔" selaras di sisi kiri bawah subjudul (F-pattern)
/// - Sisi kanan: Ilustrasi registrasi klinis vektor 2D/3D dengan ShaderMask fade halus tanpa watermark dedaunan
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
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.clinicalBorder.withValues(alpha: 0.65),
              width: 1.2,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.clinicalSurfaceLight,
                AppColors.clinicalSurfaceAlt,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.clinicalTeal.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: AppColors.brandDarkEspresso.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Ilustrasi Vektor Registrasi Klinis di Sisi Kanan dengan Mask Halus
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: 155,
                  child: IgnorePointer(
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.white,
                          ],
                          stops: [0.0, 0.40, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: SvgPicture.asset(
                        AppVectors.outpatientRegistration,
                        fit: BoxFit.contain,
                        alignment: const Alignment(0.65, 0.0),
                      ),
                    ),
                  ),
                ),

                // Konten Teks dan Aksi Utama (Sisi Kiri Kartu)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Baris Atas: Badge Ikon Kalender dan Pill "Layanan Utama"
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bulatan Toska dengan Ikon Kalender Medis
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.clinicalTeal,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Pill Badge "Layanan Utama"
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.clinicalContainer.withValues(
                                alpha: 0.9,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.clinicalBorder.withValues(
                                  alpha: 0.8,
                                ),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  size: 13,
                                  color: AppColors.clinicalTeal,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Layanan Utama',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.clinicalTealDeep,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Judul Pendaftaran Rawat Jalan
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width > 400
                              ? 240
                              : MediaQuery.sizeOf(context).width * 0.56,
                        ),
                        child: const Text(
                          'Pendaftaran Rawat Jalan',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandDarkEspresso,
                            letterSpacing: -0.3,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Subjudul Deskripsi
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width > 400
                              ? 230
                              : MediaQuery.sizeOf(context).width * 0.54,
                        ),
                        child: const Text(
                          'Booking poli reguler & eksekutif BPJS / Umum tanpa antre di loket',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tombol Pill "Daftar Sekarang ➔"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.clinicalTeal,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.clinicalTeal.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                                letterSpacing: 0.1,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 15,
                              color: AppColors.white,
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
      ),
    );
  }
}
