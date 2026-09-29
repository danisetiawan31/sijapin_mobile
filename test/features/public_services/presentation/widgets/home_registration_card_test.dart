import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_registration_card.dart';

void main() {
  group('HomeRegistrationCard Widget Tests', () {
    testWidgets('renders all labels, badges, and icons correctly', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeRegistrationCard(
              onRegisterTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Verifikasi judul dan teks penjelas
      expect(find.text('Layanan Utama'), findsOneWidget);
      expect(find.text('Pendaftaran Rawat Jalan'), findsOneWidget);
      expect(
        find.textContaining('Booking poli reguler & eksekutif'),
        findsOneWidget,
      );
      expect(find.text('Daftar Sekarang'), findsOneWidget);

      // Verifikasi ikon kalender dan chevron
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      // Verifikasi tap trigger
      await tester.tap(find.text('Daftar Sekarang'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
