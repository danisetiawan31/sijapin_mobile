import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppBadgeVariant { success, warning, danger, neutral, clinical }

/// Badge status indikator berbentuk kapsul (*pill badge*) khas RSUP Dr. Sitanala.
///
/// Digunakan untuk menandai ketersediaan tempat tidur, status praktik dokter,
/// kategori jaminan pasien (BPJS/Umum), dan urgensi medis.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
    this.fontSize = 11,
  });

  /// Factory untuk status tersedia / aktif (Hijau Sitanala)
  const AppBadge.success({
    super.key,
    required this.label,
    this.icon = Icons.check_circle_outline_rounded,
    this.fontSize = 11,
  }) : variant = AppBadgeVariant.success;

  /// Factory untuk status terbatas / perhatian (Kuning Amber)
  const AppBadge.warning({
    super.key,
    required this.label,
    this.icon = Icons.warning_amber_rounded,
    this.fontSize = 11,
  }) : variant = AppBadgeVariant.warning;

  /// Factory untuk status penuh / cuti / batal (Merah Crimson)
  const AppBadge.danger({
    super.key,
    required this.label,
    this.icon = Icons.cancel_outlined,
    this.fontSize = 11,
  }) : variant = AppBadgeVariant.danger;

  /// Factory untuk label netral / BPJS / kategori (Warm Bronze & Cream Linen)
  const AppBadge.neutral({
    super.key,
    required this.label,
    this.icon,
    this.fontSize = 11,
  }) : variant = AppBadgeVariant.neutral;

  /// Factory untuk riwayat klinis / resume medis (Clinical Teal)
  const AppBadge.clinical({
    super.key,
    required this.label,
    this.icon,
    this.fontSize = 11,
  }) : variant = AppBadgeVariant.clinical;

  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Color bgColor;
    Border? border;

    switch (variant) {
      case AppBadgeVariant.success:
        textColor = AppColors.successEmerald;
        bgColor = AppColors.successEmerald.withValues(alpha: 0.12);
        border = Border.all(
          color: AppColors.successEmerald.withValues(alpha: 0.25),
        );
        break;

      case AppBadgeVariant.warning:
        textColor = AppColors.warningAmber;
        bgColor = AppColors.warningAmber.withValues(alpha: 0.12);
        border = Border.all(
          color: AppColors.warningAmber.withValues(alpha: 0.25),
        );
        break;

      case AppBadgeVariant.danger:
        textColor = AppColors.dangerCrimson;
        bgColor = AppColors.dangerCrimson.withValues(alpha: 0.12);
        border = Border.all(
          color: AppColors.dangerCrimson.withValues(alpha: 0.25),
        );
        break;

      case AppBadgeVariant.neutral:
        textColor = AppColors.brandWarmBronze;
        bgColor = AppColors.brandCreamLinen;
        border = Border.all(color: AppColors.borderSubtle);
        break;

      case AppBadgeVariant.clinical:
        textColor = AppColors.clinicalTeal;
        bgColor = AppColors.clinicalTeal.withValues(alpha: 0.12);
        border = Border.all(
          color: AppColors.clinicalTeal.withValues(alpha: 0.25),
        );
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(9999),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
