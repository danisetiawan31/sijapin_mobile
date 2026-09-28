import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/routing/app_router.dart';

class RouterTestHost extends StatelessWidget {
  final GoRouter router;

  const RouterTestHost({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}

void main() {
  testWidgets('router starts at splash and reaches Login then Register', (tester) async {
    final router = AppRouter.create();

    await tester.pumpWidget(RouterTestHost(router: router));
    await tester.pump();

    expect(find.text('SIIJAPIN Mobile'), findsOneWidget);
    expect(find.text('Memuat aplikasi...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Buka Profile'), findsNothing);
    expect(find.text('Uji Login'), findsNothing);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat Datang'), findsOneWidget);

    await tester.tap(find.text('Daftar di sini'));
    await tester.pumpAndSettle();
    expect(find.text('Buat Akun Pasien'), findsOneWidget);

    router.dispose();
  });
}
