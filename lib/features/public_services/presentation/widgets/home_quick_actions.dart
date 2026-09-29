import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Grid 4 Tombol Aksi Cepat Bantuan & Informasi di Beranda.
///
/// Mengadopsi desain resmi Google Stitch (project `projects/2575501304420738712`):
/// - 1. Pengaduan Pasien
/// - 2. Standar Layanan RS
/// - 3. Alur Rujukan BPJS
/// - 4. Lokasi & Peta RSUP Dr. Sitanala
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
        const Text(
          'Bantuan & Informasi Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.brandDarkEspresso,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionChipCard(
                label: 'Pengaduan',
                icon: Icons.chat_bubble_outline_rounded,
                onTap: onComplaintTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Standar\nLayanan',
                icon: Icons.description_outlined,
                onTap: onServiceStandardsTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Alur\nBPJS',
                icon: Icons.verified_user_outlined,
                onTap: onBpjsFlowTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionChipCard(
                label: 'Lokasi\nRS',
                icon: Icons.location_on_outlined,
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
    required this.onTap,
  });

  final String label;
  final IconData icon;
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
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
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.brandCreamLinen,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.brandGoldenCaramel,
                  size: 20,
                ),
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
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
