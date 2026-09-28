import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_bottom_nav_bar.dart';

/// Shell Scaffold utama aplikasi SIIJAPIN Mobile.
///
/// Menggunakan [AppBottomNavBar] dengan 4 tab navigasi persisten
/// yang menjaga state halaman masing-masing tab melalui [StatefulNavigationShell].
class MainShellScaffold extends StatelessWidget {
  const MainShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onDestinationSelected,
      ),
    );
  }
}
