import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/features/public_services/presentation/widgets/home_welcome_banner.dart';

void main() {
  group('HomeWelcomeBanner Widget Tests', () {
    testWidgets('renders greeting, hospital welcome title, and subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeWelcomeBanner())),
      );

      expect(find.text(AppConstants.welcomeGreeting), findsOneWidget);
      expect(find.text(AppConstants.welcomeTitle), findsOneWidget);
      expect(find.text(AppConstants.welcomeSubtitle), findsOneWidget);
    });
  });
}
