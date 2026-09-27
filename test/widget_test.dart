import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/main.dart';

void main() {
  testWidgets('SiijapinApp bootstrap smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SiijapinApp()));

    // Verifikasi branding RSUP Dr. Sitanala muncul di root app
    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);
  });
}
