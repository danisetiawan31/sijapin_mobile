import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_bento_status_cards.dart';

void main() {
  group('HomeBentoStatusCards Widget Tests', () {
    testWidgets(
      'renders bed and doctor cards with correct badges and triggers',
      (tester) async {
        var bedTapped = false;
        var doctorTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeBentoStatusCards(
                onBedAvailabilityTap: () {
                  bedTapped = true;
                },
                onDoctorScheduleTap: () {
                  doctorTapped = true;
                },
                availableBedsCount: 20,
                activeDoctorsCount: 45,
              ),
            ),
          ),
        );

        // Verifikasi teks kartu kamar
        expect(find.textContaining('Ketersediaan'), findsOneWidget);
        expect(find.text('Rawat inap & ICU'), findsOneWidget);
        expect(find.text('20 Bed Kosong'), findsOneWidget);

        // Verifikasi teks kartu dokter
        expect(find.textContaining('Jadwal'), findsOneWidget);
        expect(find.text('Cari spesialis & jam'), findsOneWidget);
        expect(find.text('45 Dokter Aktif'), findsOneWidget);

        // Verifikasi ikon
        expect(find.byIcon(Icons.bed_rounded), findsOneWidget);
        expect(find.byIcon(Icons.assignment_ind_rounded), findsOneWidget);
        expect(find.byIcon(Icons.north_east_rounded), findsNWidgets(2));

        // Verifikasi tap kartu kamar
        await tester.tap(find.textContaining('Ketersediaan'));
        await tester.pumpAndSettle();
        expect(bedTapped, isTrue);

        // Verifikasi tap kartu dokter
        await tester.tap(find.textContaining('Jadwal'));
        await tester.pumpAndSettle();
        expect(doctorTapped, isTrue);
      },
    );
  });
}
