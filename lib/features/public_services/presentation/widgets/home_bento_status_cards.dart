import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Komponen Dua Kartu Bento Sejajar di Beranda:
/// 1. Ketersediaan Kamar (status bed kosong rawat inap & ICU)
/// 2. Jadwal Dokter (informasi poliklinik & dokter spesialis aktif)
///
/// Mengadopsi desain resmi Google Stitch (project `projects/2575501304420738712`):
/// - Dua kolom seimbang (Row + Expanded)
/// - Indikator status live (Pill badge bernuansa hijau & krem coklat)
/// - Ikon navigasi sudut kanan atas (arrow_outward)
class HomeBentoStatusCards extends StatelessWidget {
  const HomeBentoStatusCards({
    super.key,
    required this.onBedAvailabilityTap,
    required this.onDoctorScheduleTap,
    this.availableBedsCount = AppConstants.defaultAvailableBeds,
    this.activeDoctorsCount = AppConstants.defaultActiveDoctors,
  });

  /// Aksi saat kartu Ketersediaan Kamar ditekan.
  final VoidCallback onBedAvailabilityTap;

  /// Aksi saat kartu Jadwal Dokter ditekan.
  final VoidCallback onDoctorScheduleTap;

  /// Jumlah sisa tempat tidur kosong saat ini.
  final int availableBedsCount;

  /// Jumlah dokter yang bertugas/aktif praktik hari ini.
  final int activeDoctorsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Kartu Kiri: Ketersediaan Kamar
        Expanded(
          child: _BentoCard(
            onTap: onBedAvailabilityTap,
            icon: Icons.bed_rounded,
            iconColor: AppColors.successEmerald,
            iconBgColor: AppColors.successContainer,
            iconBorderColor: AppColors.successBorder,
            title: 'Ketersediaan\nKamar',
            subtitle: 'Rawat inap & ICU',
            badgeWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.successBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$availableBedsCount Bed Kosong',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successEmerald,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Kartu Kanan: Jadwal Dokter
        Expanded(
          child: _BentoCard(
            onTap: onDoctorScheduleTap,
            icon: Icons.assignment_ind_rounded,
            iconColor: AppColors.brandGoldenCaramel,
            iconBgColor: AppColors.brandCreamLinen,
            iconBorderColor: AppColors.borderSubtle,
            title: 'Jadwal\nDokter',
            subtitle: 'Cari spesialis & jam',
            badgeWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandCreamLinen,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.medical_services_outlined,
                    size: 12,
                    color: AppColors.brandWarmBronze,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$activeDoctorsCount Dokter Aktif',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDeepChocolate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.iconBorderColor,
    required this.title,
    required this.subtitle,
    required this.badgeWidget,
  });

  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color iconBorderColor;
  final String title;
  final String subtitle;
  final Widget badgeWidget;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
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
              // Baris Ikon + Tombol Panah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: iconBorderColor),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const Icon(
                    Icons.north_east_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Judul & Subjudul
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandDarkEspresso,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              // Garis Pemisah & Badge Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppColors.borderSubtle),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: badgeWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
