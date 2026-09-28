import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/presentation/views/login_view.dart';

void main() {
  testWidgets('login view renders required authentication controls', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginView()),
      ),
    );

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Nomor WhatsApp / Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('Daftar di sini'), findsOneWidget);
  });
}
