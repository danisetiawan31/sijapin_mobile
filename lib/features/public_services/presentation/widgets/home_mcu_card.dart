import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Kartu Horizontal Paket Medical Check Up (MCU) di Beranda.
///
/// Mengadopsi styling elegan dan modern sesuai referensi visual resmi:
/// - Baris atas: Badge (+) toska + pill "Skrining Preventif" di kiri, dan badge hati toska melayang di kanan
/// - Tipografi hierarki tinggi: Judul tebal & subjudul terpadu yang mudah dibaca
/// - Tombol pill "Lihat Paket ➔" di sisi kiri bawah subjudul
/// - Sisi kanan: Ilustrasi stetoskop & medical checklist dengan watermark botani yang menyatu halus
class HomeMcuCard extends StatelessWidget {
  const HomeMcuCard({super.key, required this.onMcuTap});

  /// Aksi saat kartu atau tombol "Lihat Paket" ditekan.
  final VoidCallback onMcuTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onMcuTap,
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
                // Watermark Dedaunan Botani Lembut di Latar Belakang Kanan
                Positioned(
                  right: -10,
                  bottom: -15,
                  width: 120,
                  height: 120,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.20,
                      child: Image.asset(
                        'assets/images/leaves_bl.png',
                        fit: BoxFit.contain,
                        color: AppColors.clinicalTeal,
                        colorBlendMode: BlendMode.srcIn,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

                // Ilustrasi Medis MCU di Sisi Kanan Kartu dengan Mask Halus
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
                          stops: [0.0, 0.45, 1.0],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.asset(
                        'assets/images/mcu_illustration.png',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0.65, 0.0),
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),

                // Konten Kartu (Padding Utama)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Baris Atas: Badge (+) dan Pill "Skrining Preventif"
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bulatan Toska dengan Ikon Tambah (+)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.clinicalTeal,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.add_rounded,
                              size: 19,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Pill Badge "Skrining Preventif"
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
                                  Icons.spa_rounded,
                                  size: 13,
                                  color: AppColors.clinicalTeal,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Skrining Preventif',
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

                      // Judul Paket MCU
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width > 400
                              ? 240
                              : MediaQuery.sizeOf(context).width * 0.56,
                        ),
                        child: const Text(
                          'Paket Medical Check Up (MCU)',
                          style: TextStyle(
                            fontSize: 16,
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
                          'Pemeriksaan kesehatan menyeluruh & deteksi dini terpadu',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Tombol Pill "Lihat Paket ➔"
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
                              'Lihat Paket',
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
