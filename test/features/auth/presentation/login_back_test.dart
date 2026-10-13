import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/features/auth/presentation/screens/login_view.dart';

Future<void> _pumpLoginAlone(WidgetTester tester) async {
  final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <GoRoute>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginView(),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Text('HomeStub')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(child: MaterialApp.router(routerConfig: router)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LoginView system back', () {
    testWidgets('kembali ke beranda tanpa menambah stack saat rute tunggal', (
      tester,
    ) async {
      await _pumpLoginAlone(tester);
      expect(find.text('Selamat Datang'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('HomeStub'), findsOneWidget);
    });
  });
}
