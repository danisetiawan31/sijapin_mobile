import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/widgets/app_bottom_nav_bar.dart';

void main() {
  group('AppBottomNavBar Widget Tests', () {
    testWidgets('renders all 4 tabs with correct labels and icons', (
      tester,
    ) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: selectedIndex,
              onTap: (index) => selectedIndex = index,
            ),
          ),
        ),
      );

      // Verifikasi 4 label tampil
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Janji Temu'), findsOneWidget);
      expect(find.text('Jadwal'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Verifikasi ikon profil menggunakan person (bukan support_agent)
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tab is tapped', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      // Tap Tab 2: Janji Temu
      await tester.tap(find.text('Janji Temu'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 1);

      // Tap Tab 3: Jadwal
      await tester.tap(find.text('Jadwal'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 2);

      // Tap Tab 4: Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 3);
    });

    testWidgets('renders badge notification when provided in badgeCounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
              badgeCounts: const {1: 3}, // 3 tiket aktif pada tab Janji Temu
            ),
          ),
        ),
      );

      // Verifikasi badge angka 3 tampil
      expect(find.text('3'), findsOneWidget);
    });
  });
}
