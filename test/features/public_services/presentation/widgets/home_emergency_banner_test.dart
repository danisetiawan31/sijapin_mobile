import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_emergency_banner.dart';

void main() {
  group('HomeEmergencyBanner Widget Tests', () {
    testWidgets(
      'renders title, phone number, and triggers onCallTap on button tap',
      (tester) async {
        var callTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeEmergencyBanner(
                onCallTap: () => callTapped = true,
                phoneNumber: '(021) 552-3059',
              ),
            ),
          ),
        );

        // Verifikasi teks
        expect(find.text('IGD & Ambulans 24 Jam'), findsOneWidget);
        expect(find.text('Panggilan : (021) 552-3059'), findsOneWidget);
        expect(find.text('Panggil'), findsOneWidget);

        // Verifikasi ikon
        expect(find.byIcon(Icons.emergency_rounded), findsOneWidget);
        expect(find.byIcon(Icons.call_rounded), findsOneWidget);

        // Verifikasi tap tombol panggil
        await tester.tap(find.text('Panggil'));
        await tester.pumpAndSettle();
        expect(callTapped, isTrue);
      },
    );
  });
}
