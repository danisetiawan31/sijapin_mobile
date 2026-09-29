import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Grid 4 Tombol Aksi Cepat Bantuan & Informasi di Beranda.
///
/// Mengadopsi desain resmi Google Stitch & Mockup Acuan:
/// - 1. Pengaduan Pasien (Aksen Clinical Teal)
/// - 2. Standar Layanan RS (Aksen Golden Caramel)
/// - 3. Alur Rujukan BPJS (Aksen Success Emerald)
/// - 4. Lokasi & Peta RSUP Dr. Sitanala (Aksen Warning Amber)
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
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.clinicalTeal,
                iconBgColor: AppColors.clinicalContainer,
                onTap: onComplaintTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Standar\nLayanan',
                icon: Icons.description_outlined,
                iconColor: AppColors.brandGoldenCaramel,
                iconBgColor: AppColors.goldenSoftLinen,
                onTap: onServiceStandardsTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Alur\nBPJS',
                icon: Icons.verified_user_outlined,
                iconColor: AppColors.successEmerald,
                iconBgColor: AppColors.successContainer,
                onTap: onBpjsFlowTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Lokasi\nRS',
                icon: Icons.location_on_outlined,
                iconColor: AppColors.warningAmber,
                iconBgColor: AppColors.warningContainer,
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
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.borderSubtle.withValues(alpha: 0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDarkEspresso.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 21)),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDarkEspresso,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
