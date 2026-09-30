import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Grid 4 Tombol Aksi Cepat Bantuan & Informasi di Beranda.
///
/// Desain modern & ramah mengacu pada referensi klinis RSUP Dr. Sitanala:
/// - 1. Pengaduan Pasien (Clipboard Checklist - Mint & Teal)
/// - 2. Standar Layanan RS (Dokumen Pelayanan - Pastel Peach & Orange)
/// - 3. Alur Rujukan BPJS (Perisai Verifikasi - Soft Emerald)
/// - 4. Lokasi & Peta RSUP (Pin Navigasi - Golden Cream & Amber)
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({
    super.key,
    required this.onComplaintTap,
    required this.onServiceStandardsTap,
    required this.onBpjsFlowTap,
    required this.onHospitalLocationTap,
  });

  final VoidCallback onComplaintTap;
  final VoidCallback onServiceStandardsTap;
  final VoidCallback onBpjsFlowTap;
  final VoidCallback onHospitalLocationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul & Subjudul Section
        const Text(
          AppConstants.quickActionsTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.brandDarkEspresso,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          AppConstants.quickActionsSubtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),

        // Baris 4 Kartu Aksi Cepat
        Row(
          children: [
            Expanded(
              child: _ActionChipCard(
                label: 'Pengaduan',
                icon: Icons.assignment_rounded,
                iconColor: AppColors.clinicalTeal,
                iconBgColor: AppColors.clinicalContainer,
                onTap: onComplaintTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Standar\nLayanan',
                icon: Icons.article_rounded,
                iconColor: AppColors.warningAmber,
                iconBgColor: AppColors.warningContainer,
                onTap: onServiceStandardsTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Alur BPJS',
                icon: Icons.verified_user_rounded,
                iconColor: AppColors.successEmerald,
                iconBgColor: AppColors.successContainer,
                onTap: onBpjsFlowTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Lokasi RS',
                icon: Icons.location_on_rounded,
                iconColor: AppColors.brandGoldenCaramel,
                iconBgColor: AppColors.brandCreamLinen,
                onTap: onHospitalLocationTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChipCard extends StatelessWidget {
  const _ActionChipCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: iconColor.withValues(alpha: 0.10),
        highlightColor: iconBgColor.withValues(alpha: 0.35),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.45),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDarkEspresso.withValues(alpha: 0.035),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: iconColor.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 24)),
              ),
              const SizedBox(height: 9),
              SizedBox(
                height: 30,
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDarkEspresso,
                      height: 1.2,
                      letterSpacing: -0.1,
                    ),
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
