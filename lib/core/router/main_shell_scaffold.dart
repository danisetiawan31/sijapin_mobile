import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

/// Shell Scaffold utama aplikasi SIIJAPIN Mobile.
///
/// Menggunakan Material 3 [NavigationBar] dengan 4 tab navigasi persisten
/// yang menjaga state halaman masing-masing tab melalui [StatefulNavigationShell].
class MainShellScaffold extends StatelessWidget {
  const MainShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    HapticFeedback.lightImpact();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: AppColors.surfaceCard,
        indicatorColor: AppColors.brandGoldenCaramel.withValues(alpha: 0.15),
        elevation: 4,
        shadowColor: AppColors.brandDarkEspresso.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: AppColors.brandGoldenCaramel,
            ),
            label: 'Beranda',
            tooltip: 'Beranda Layanan',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(
              Icons.confirmation_number_rounded,
              color: AppColors.brandGoldenCaramel,
            ),
            label: 'Janji Temu',
            tooltip: 'Tiket & Janji Temu',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(
              Icons.calendar_month_rounded,
              color: AppColors.brandGoldenCaramel,
            ),
            label: 'Dokter',
            tooltip: 'Jadwal Poliklinik & Dokter',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: AppColors.brandGoldenCaramel,
            ),
            label: 'Profil',
            tooltip: 'Profil Pasien & Akun',
          ),
        ],
      ),
    );
  }
}
