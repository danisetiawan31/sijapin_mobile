import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_bento_status_cards.dart';

void main() {
  group('HomeBentoStatusCards Widget Tests', () {
    testWidgets(
      'renders bed and doctor cards with correct labels and triggers',
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
        expect(find.textContaining('Ketersediaan'), findsWidgets);
        expect(find.text('Rawat inap & ICU'), findsOneWidget);
        expect(find.text('Lihat Ketersediaan'), findsOneWidget);

        // Verifikasi teks kartu dokter
        expect(find.text('Jadwal Dokter'), findsOneWidget);
        expect(find.text('Cari spesialis & jam praktik'), findsOneWidget);
        expect(find.text('Lihat Jadwal'), findsOneWidget);

        // Verifikasi ikon
        expect(find.byIcon(Icons.bed_rounded), findsOneWidget);
        expect(find.byIcon(Icons.person_rounded), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));

        // Verifikasi tap kartu kamar
        await tester.tap(find.text('Lihat Ketersediaan'));
        await tester.pumpAndSettle();
        expect(bedTapped, isTrue);

        // Verifikasi tap kartu dokter
        await tester.tap(find.text('Lihat Jadwal'));
        await tester.pumpAndSettle();
        expect(doctorTapped, isTrue);
      },
    );
  });
}
