import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/doctor_schedule_screen.dart';

Widget _buildDoctorScheduleScreen() {
  return const ProviderScope(
    child: MaterialApp(
      themeMode: ThemeMode.light,
      home: DoctorScheduleScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DoctorScheduleScreen Widget Tests', () {
    testWidgets('renders header, search bar, filter chips, and doctor cards',
        (tester) async {
      await tester.pumpWidget(_buildDoctorScheduleScreen());

      // Tunggu delay Future simulasi di repository
      await tester.pumpAndSettle();

      // Verifikasi App Bar & Header
      expect(find.text('Jadwal Dokter'), findsOneWidget);
      expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);
      expect(find.textContaining('Dokter Aktif'), findsOneWidget);

      // Verifikasi Search Bar
      expect(find.text('Cari nama dokter atau spesialis...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verifikasi Filter Chips baku
      expect(find.text('Semua Poli'), findsOneWidget);
      expect(find.text('Penyakit Dalam'), findsAtLeast(1));
      expect(find.text('Mata'), findsAtLeast(1));
      expect(find.text('Anak'), findsAtLeast(1));

      // Verifikasi salah satu dokter sampel awal muncul
      expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);
    });

    testWidgets('tapping filter chip Mata activates chip and filters doctor list',
        (tester) async {
      await tester.pumpWidget(_buildDoctorScheduleScreen());
      await tester.pumpAndSettle();

      // Sebelum klik filter, dr. Era Medina (Penyakit Dalam) tampil
      expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);

      // Tap chip 'Mata'
      await tester.tap(find.text('Mata'));
      await tester.pumpAndSettle();

      // Setelah filter 'Mata', dokter Mata tampil, dokter Penyakit Dalam hilang
      expect(find.text('dr. Hendra, Sp.M'), findsOneWidget);
      expect(find.text('dr. Era Medina, Sp.PD'), findsNothing);
    });

    testWidgets(
        'tapping Kebidanan & Obgyn matches Obstetri & Ginekologi doctor properly',
        (tester) async {
      await tester.pumpWidget(_buildDoctorScheduleScreen());
      await tester.pumpAndSettle();

      // Scroll chip agar Kebidanan & Obgyn terlihat jika perlu
      final obgynChip = find.text('Kebidanan & Obgyn');
      await tester.ensureVisible(obgynChip);
      await tester.tap(obgynChip);
      await tester.pumpAndSettle();

      // Dokter Obstetri & Ginekologi tampil
      expect(find.text('dr. Damas Hendriansyah, Sp.OG'), findsOneWidget);
      expect(find.text('dr. Era Medina, Sp.PD'), findsNothing);
    });

    testWidgets('typing in search bar filters doctor list by name',
        (tester) async {
      await tester.pumpWidget(_buildDoctorScheduleScreen());
      await tester.pumpAndSettle();

      // Ketik 'Era' pada kolom pencarian
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Era');
      await tester.pumpAndSettle();

      // Hanya dokter dengan nama Era yang tampil
      expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);
      expect(find.text('dr. Hendra, Sp.M'), findsNothing);

      // Verifikasi tombol clear muncul dan dapat ditekan
      final clearButton = find.byIcon(Icons.close_rounded);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pumpAndSettle();

      // Setelah di-clear, list kembali menampilkan semua
      expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);
      expect(find.text('dr. Hendra, Sp.M'), findsOneWidget);
    });
  });
}
