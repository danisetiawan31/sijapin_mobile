import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Banner kontak admisi rawat inap dan panggilan darurat dengan copywriting rapi.
class BedAdmissionBanner extends StatelessWidget {
  const BedAdmissionBanner({super.key, required this.onCallTap});

  final VoidCallback onCallTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_in_talk_rounded,
              size: 18,
              color: AppColors.brandGoldenCaramel,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.admissionBannerTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Admisi: ${AppConstants.hospitalPhoneNumber}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.brandGoldenCaramel,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: onCallTap,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.callActionText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.call_rounded,
                      size: 14,
                      color: AppColors.textWhite,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
