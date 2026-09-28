import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/presentation/views/register_view.dart';

void main() {
  testWidgets('register view renders required registration controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: RegisterView())),
    );

    expect(find.text('Buat Akun Pasien'), findsOneWidget);
    expect(find.text('Nama Lengkap Pasien *'), findsOneWidget);
    expect(find.text('Nomor WhatsApp / HP *'), findsOneWidget);
    expect(find.text('Tanggal Lahir *'), findsOneWidget);
    expect(find.text('Daftar Akun Sekarang'), findsOneWidget);
    expect(find.text('Masuk di sini'), findsOneWidget);
  });
}
