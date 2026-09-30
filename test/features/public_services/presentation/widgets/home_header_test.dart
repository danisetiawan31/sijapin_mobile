import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_header.dart';

void main() {
  group('HomeHeader Widget Test', () {
    testWidgets(
      'menampilkan nama dan identitas RSUP Dr. Sitanala dengan benar',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: HomeHeader())),
        );

        expect(find.text(AppConstants.hospitalName), findsOneWidget);
        expect(find.text(AppConstants.hospitalTagline), findsOneWidget);
        expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);
      },
    );

    testWidgets('menampilkan tombol lonceng dan merespons interaksi tap', (
      tester,
    ) async {
      var notificationTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              hasUnreadNotifications: true,
              onNotificationTap: () {
                notificationTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pump();

      expect(notificationTapped, isTrue);
    });

    testWidgets('menampilkan tombol Masuk pada mode tamu dan merespons tap', (
      tester,
    ) async {
      var loginTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeHeader(
              isLoggedIn: false,
              onLoginTap: () {
                loginTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Masuk'), findsOneWidget);
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);

      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(loginTapped, isTrue);
    });

    testWidgets(
      'menampilkan tombol Profil dengan inisial saat isLoggedIn bernilai true',
      (tester) async {
        var profileTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeHeader(
                isLoggedIn: true,
                userName: 'Dhani',
                onProfileTap: () {
                  profileTapped = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Masuk'), findsNothing);
        expect(find.text('Dhani'), findsOneWidget);
        expect(find.text('D'), findsOneWidget); // Inisial avatar

        await tester.tap(find.text('Dhani'));
        await tester.pump();

        expect(profileTapped, isTrue);
      },
    );
  });
}
