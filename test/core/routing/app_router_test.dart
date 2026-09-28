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
  testWidgets('router starts at the splash integration point', (tester) async {
    final router = AppRouter.create();

    await tester.pumpWidget(RouterTestHost(router: router));
    await tester.pump();

    expect(find.text('SIIJAPIN Mobile'), findsOneWidget);
    expect(find.text('Lanjut ke Aplikasi'), findsOneWidget);

    router.dispose();
  });
}
