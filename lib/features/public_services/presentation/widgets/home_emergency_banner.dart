import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Banner Kontak Darurat (Emergency Hotline) IGD & Ambulans 24 Jam di Beranda.
class HomeEmergencyBanner extends StatelessWidget {
  const HomeEmergencyBanner({
    super.key,
    this.onCallTap,
    this.phoneNumber = AppConstants.emergencyPhoneNumber,
  });

  /// Aksi opsional saat tombol "Panggil" ditekan.
  final VoidCallback? onCallTap;

  /// Nomor kontak darurat IGD RSUP Dr. Sitanala.
  final String phoneNumber;

  Future<void> _handleCall(BuildContext context) async {
    onCallTap?.call();
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tidak dapat membuka panggilan telepon ke $phoneNumber',
            ),
            backgroundColor: AppColors.dangerCrimson,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tidak dapat membuka panggilan telepon ke $phoneNumber',
            ),
            backgroundColor: AppColors.dangerCrimson,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dangerBorder),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.dangerContainer, AppColors.brandCreamLinen],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dangerCrimson.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon Darurat Merah
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.dangerCrimson.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: AppColors.dangerCrimson,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Info Teks IGD
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppConstants.emergencyBannerTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dangerCrimson,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Panggilan : $phoneNumber',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Panggil
          Material(
            color: AppColors.dangerCrimson,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => _handleCall(context),
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.call_rounded,
                      color: AppColors.textWhite,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      AppConstants.emergencyCallAction,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
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
