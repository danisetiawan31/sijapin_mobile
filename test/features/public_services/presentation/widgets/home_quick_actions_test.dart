import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_quick_actions.dart';

void main() {
  group('HomeQuickActions Widget Tests', () {
    testWidgets('renders all 4 action cards and handles taps correctly', (
      tester,
    ) async {
      var complaintTapped = false;
      var standardsTapped = false;
      var bpjsTapped = false;
      var locationTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeQuickActions(
              onComplaintTap: () => complaintTapped = true,
              onServiceStandardsTap: () => standardsTapped = true,
              onBpjsFlowTap: () => bpjsTapped = true,
              onHospitalLocationTap: () => locationTapped = true,
            ),
          ),
        ),
      );

      // Verifikasi judul section
      expect(find.text('Bantuan & Informasi Cepat'), findsOneWidget);

      // Verifikasi teks 4 menu
      expect(find.text('Pengaduan'), findsOneWidget);
      expect(find.textContaining('Standar'), findsOneWidget);
      expect(find.textContaining('Alur'), findsOneWidget);
      expect(find.textContaining('Lokasi'), findsOneWidget);

      // Verifikasi tap Pengaduan
      await tester.tap(find.text('Pengaduan'));
      await tester.pumpAndSettle();
      expect(complaintTapped, isTrue);

      // Verifikasi tap Standar Layanan
      await tester.tap(find.textContaining('Standar'));
      await tester.pumpAndSettle();
      expect(standardsTapped, isTrue);

      // Verifikasi tap Alur BPJS
      await tester.tap(find.textContaining('Alur'));
      await tester.pumpAndSettle();
      expect(bpjsTapped, isTrue);

      // Verifikasi tap Lokasi RS
      await tester.tap(find.textContaining('Lokasi'));
      await tester.pumpAndSettle();
      expect(locationTapped, isTrue);
    });
  });
}
