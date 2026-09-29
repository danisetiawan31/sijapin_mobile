import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Banner Sambutan Hangat di Beranda:
/// "Halo, 👋 Selamat Datang di RSUP Dr. Sitanala"
/// dengan ilustrasi ramah dokter dan nuansa gradien klinis segar.
class HomeWelcomeBanner extends StatelessWidget {
  const HomeWelcomeBanner({super.key, this.userName});

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final greetingName = userName != null
        ? 'Halo, $userName 👋'
        : AppConstants.welcomeGreeting;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.clinicalTeal, AppColors.clinicalTealLight],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.clinicalTeal.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Background ambient rings
          Positioned(
            right: -20,
            bottom: -20,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: -30,
            child: IgnorePointer(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),

          // Konten Utama
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sisi Kiri: Teks Sambutan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greetingName,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white.withValues(alpha: 0.95),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        AppConstants.welcomeTitle,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          height: 1.25,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppConstants.welcomeSubtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: AppColors.white.withValues(alpha: 0.88),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Sisi Kanan: Ilustrasi Avatar Dokter
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandDarkEspresso.withValues(
                          alpha: 0.15,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/doctor_avatar.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.clinicalMint,
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            size: 42,
                            color: AppColors.clinicalTeal,
                          ),
                        );
                      },
                    ),
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
