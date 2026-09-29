import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Kartu Horizontal Paket Medical Check Up (MCU) di Beranda.
///
/// Mengadopsi desain resmi Google Stitch (project `projects/2575501304420738712`):
/// - Ikon lingkaran medis hangat dengan aksen keemasan
/// - Badge pill "Skrining Preventif"
/// - Chip kategori paket (Pranikah, Eksekutif, Bebas Narkoba)
/// - Indikator "Hasil Lab & Konsul Dokter"
/// - Tombol aksi "Lihat Paket ➔"
class HomeMcuCard extends StatelessWidget {
  const HomeMcuCard({
    super.key,
    required this.onMcuTap,
  });

  /// Aksi saat kartu atau tombol "Lihat Paket" ditekan.
  final VoidCallback onMcuTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onMcuTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.brandSoftSand.withValues(alpha: 0.6),
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white,
                AppColors.surfaceWarmAlt,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Atas: Ikon Lingkaran + Info Paket
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.goldenSoftLinen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brandGoldenCaramel.withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.brandGoldenCaramel,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge "Skrining Preventif"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldenSoftContainer.withValues(
                              alpha: 0.65,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                size: 12,
                                color: AppColors.brandGoldenCaramel,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Skrining Preventif',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.goldenTextDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Paket Medical Check Up (MCU)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandDarkEspresso,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Pemeriksaan kesehatan menyeluruh & deteksi dini terpadu',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Baris Chip Kategori Paket MCU
              const Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _McuCategoryChip(label: '💍 Pranikah'),
                  _McuCategoryChip(label: '💼 Eksekutif'),
                  _McuCategoryChip(label: '🧪 Bebas Narkoba'),
                ],
              ),
              const SizedBox(height: 12),
              // Baris Bawah: Garis Pemisah + Hasil Lab + Tombol "Lihat Paket"
              Container(
                padding: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderSubtle.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: AppColors.clinicalTeal,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Hasil Lab & Konsul Dokter',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.clinicalTeal,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandCreamLinen,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.brandGoldenCaramel.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat Paket',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGoldenCaramel,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 13,
                            color: AppColors.brandGoldenCaramel,
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

class _McuCategoryChip extends StatelessWidget {
  const _McuCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarmAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
