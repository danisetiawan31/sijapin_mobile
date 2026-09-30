import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

/// Kartu hero ringkasan kapasitas rawat inap rumah sakit dan rasio BOR.
class BedCapacityHeroCard extends StatelessWidget {
  const BedCapacityHeroCard({super.key, required this.summary});

  final BedAvailabilitySummary summary;

  @override
  Widget build(BuildContext context) {
    final bor = summary.borPercent;
    return AppCard.elevated(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KAPASITAS RAWAT INAP RS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(
                Icons.hotel_rounded,
                size: 18,
                color: AppColors.brandGoldenCaramel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${summary.availableBeds}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandGoldenCaramel,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bed Siap Huni',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: 'Dari total ${summary.totalBeds} kapasitas tempat tidur ',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text:
                      '(Tingkat Keterisian: ${bor.toStringAsFixed(1).replaceAll('.', ',')}%)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 10,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.5),
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (bor / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandGoldenCaramel,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${summary.availableBeds} Tersedia',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${summary.occupiedBeds} Terisi • ${bor.toStringAsFixed(1).replaceAll('.', ',')}% BOR',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
