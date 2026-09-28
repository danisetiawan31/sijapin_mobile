import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Item data definisi tab navigasi bawah aplikasi SIIJAPIN Mobile.
class AppNavBarItem {
  const AppNavBarItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.tooltip,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String? tooltip;
}

/// Bottom Navigation Bar kustom berbasis Design System RSUP Dr. Sitanala.
///
/// Menghadirkan desain *tactile floating pill* berlatar putih dengan bayangan
/// hangat (*warm ambient shadow*), indikator kapsul karamel keemasan, dan haptic feedback.
/// Ikon menggunakan standar SSOT: Beranda, Janji Temu (Tiket), Dokter, dan Profil.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badgeCounts,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Peta penanda jumlah notifikasi per index tab (opsional)
  final Map<int, int>? badgeCounts;

  /// Daftar 4 tab navigasi baku SIIJAPIN Mobile (SSOT)
  static const List<AppNavBarItem> items = [
    AppNavBarItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      tooltip: 'Beranda Layanan',
    ),
    AppNavBarItem(
      label: 'Janji Temu',
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number_rounded,
      tooltip: 'Tiket & Janji Temu',
    ),
    AppNavBarItem(
      label: 'Dokter',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      tooltip: 'Jadwal Poliklinik & Dokter',
    ),
    AppNavBarItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      tooltip: 'Profil Pasien & Keluarga',
    ),
  ];

  void _handleTap(int index) {
    HapticFeedback.lightImpact();
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandDarkEspresso.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              final badgeCount = badgeCounts?[index] ?? 0;

              return Expanded(
                child: Semantics(
                  selected: isSelected,
                  label: item.tooltip ?? item.label,
                  button: true,
                  child: InkWell(
                    onTap: () => _handleTap(index),
                    borderRadius: BorderRadius.circular(28),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandCreamLinen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.brandGoldenCaramel.withValues(
                                  alpha: 0.25,
                                ),
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isSelected ? item.activeIcon : item.icon,
                                size: 22,
                                color: isSelected
                                    ? AppColors.brandGoldenCaramel
                                    : AppColors.textMuted,
                              ),
                              if (badgeCount > 0)
                                Positioned(
                                  top: -3,
                                  right: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: AppColors.dangerCrimson,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 14,
                                      minHeight: 14,
                                    ),
                                    child: Text(
                                      badgeCount > 99
                                          ? '99+'
                                          : badgeCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.brandGoldenCaramel
                                  : AppColors.textSecondary,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
