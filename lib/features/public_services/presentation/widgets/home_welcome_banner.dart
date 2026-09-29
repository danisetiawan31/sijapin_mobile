import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Banner Sambutan Hangat di Beranda:
/// "Halo, 👋 Selamat Datang di RSUP Dr. Sitanala"
/// dengan nuansa gradien Golden Caramel & Soft Sand khas RSUP Dr. Sitanala yang hangat,
/// ramah, dan bercahaya.
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
        border: Border.all(
          color: AppColors.brandGoldenCaramelDark.withValues(alpha: 0.4),
          width: 1,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandGoldenCaramelDark,
            AppColors.brandGoldenCaramel,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandGoldenCaramelDark.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Cincin aura ambient di latar belakang
          Positioned(
            right: -25,
            bottom: -25,
            child: IgnorePointer(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          Positioned(
            right: 35,
            top: -35,
            child: IgnorePointer(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.08),
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
                          fontWeight: FontWeight.w700,
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
                          color: AppColors.white.withValues(alpha: 0.90),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Sisi Kanan: Ilustrasi Avatar Dokter dengan Frame Putih Bersih
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandDarkEspresso.withValues(
                          alpha: 0.18,
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
                          color: AppColors.goldenSoftLinen,
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            size: 42,
                            color: AppColors.brandGoldenCaramel,
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
