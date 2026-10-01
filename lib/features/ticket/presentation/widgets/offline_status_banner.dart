import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Banner status offline penenteram pasien saat berada di area blank spot RS (PRD FR-06.3)
class OfflineStatusBanner extends StatelessWidget {
  const OfflineStatusBanner({
    super.key,
    this.message,
    this.isUnsynced = false,
  });

  final String? message;
  final bool isUnsynced;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.brandWarmBronze.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandWarmBronze.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.brandWarmBronze.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnsynced ? Icons.cloud_off_rounded : Icons.wifi_off_rounded,
              size: 16,
              color: AppColors.brandDarkEspresso,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUnsynced ? 'Tiket Menunggu Sinkronisasi' : 'Mode Offline Aktif',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message ??
                      'Tiket tersimpan aman di perangkat. QR Code tetap valid untuk check-in di mesin Kiosk APM lobi RS.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.brandDarkEspresso.withValues(alpha: 0.85),
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
