import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/bed_admission_banner.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/bed_availability_header.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/bed_capacity_hero_card.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/bed_class_filter_bar.dart';

void main() {
  Widget buildTestable(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('BedAvailability Modular Widgets Tests', () {
    testWidgets(
      'BedAvailabilityHeader renders title, subtitle, and back button tap',
      (tester) async {
        var backTapped = false;
        await tester.pumpWidget(
          buildTestable(BedAvailabilityHeader(onBack: () => backTapped = true)),
        );

        expect(find.text('Ketersediaan Kamar'), findsOneWidget);
        expect(find.text('Live SIMRS'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back_rounded));
        expect(backTapped, isTrue);

        await tester.pump(const Duration(milliseconds: 500));
      },
    );

    testWidgets('BedCapacityHeroCard renders metrics and progress correctly', (
      tester,
    ) async {
      const summary = BedAvailabilitySummary(
        totalBeds: 100,
        availableBeds: 25,
        wards: [],
      );

      await tester.pumpWidget(
        buildTestable(const BedCapacityHeroCard(summary: summary)),
      );

      expect(find.text('KAPASITAS RAWAT INAP RS'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('Bed Siap Huni'), findsOneWidget);
      expect(find.text('25 Tersedia'), findsOneWidget);
      expect(find.textContaining('75 Terisi'), findsOneWidget);
      expect(find.textContaining('75,0%'), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'BedClassFilterBar triggers onSelected when filter chip is tapped',
      (tester) async {
        String? selectedFilter;
        await tester.pumpWidget(
          buildTestable(
            BedClassFilterBar(
              filters: const ['Semua Kelas', 'Kelas 1', 'VIP'],
              selectedClass: 'Semua Kelas',
              onSelected: (filter) => selectedFilter = filter,
            ),
          ),
        );

        expect(find.text('Semua Kelas'), findsOneWidget);
        expect(find.text('Kelas 1'), findsOneWidget);

        await tester.tap(find.text('Kelas 1'));
        expect(selectedFilter, 'Kelas 1');
      },
    );

    testWidgets(
      'BedAdmissionBanner renders professional copy, phone and responds to call action',
      (tester) async {
        var callTapped = false;
        await tester.pumpWidget(
          buildTestable(BedAdmissionBanner(onCallTap: () => callTapped = true)),
        );

        expect(
          find.text('Butuh info rujukan rawat inap mendesak?'),
          findsOneWidget,
        );
        expect(find.text('Admisi: (021) 552-3059'), findsOneWidget);
        expect(find.text('Panggil'), findsOneWidget);

        await tester.tap(find.text('Panggil'));
        expect(callTapped, isTrue);
      },
    );
  });
}
