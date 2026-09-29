import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/main.dart';

void main() {
  testWidgets('SiijapinApp bootstrap smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SiijapinApp()));

    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);
    expect(find.text('Memuat aplikasi...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    // expect(find.text('Home'), findsOneWidget);
    expect(find.text('Beranda RSUP Dr. Sitanala'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Selamat Datang di SIIJAPIN'), findsOneWidget);
  });
}
