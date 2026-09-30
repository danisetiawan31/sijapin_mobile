import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/pulse_dot.dart';

/// Header layar ketersediaan kamar: tombol kembali, judul tengah, dan status Live SIMRS.
class BedAvailabilityHeader extends StatelessWidget {
  const BedAvailabilityHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceBg,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: AppColors.surfaceCard,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.borderSubtle),
            ),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ),
          ),
          const Text(
            'Ketersediaan Kamar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brandDarkEspresso,
              letterSpacing: -0.3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.successBorder.withValues(alpha: 0.6),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseDot(color: AppColors.successEmerald, size: 8),
                SizedBox(width: 6),
                Text(
                  'Live SIMRS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successEmerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
