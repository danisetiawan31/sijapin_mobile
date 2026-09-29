import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/public_services/presentation/screens/home_screen.dart';

void main() {
  group('HomeScreen Full Assembly Widget Tests', () {
    testWidgets(
      'renders all modular sections and widgets on Beranda correctly',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

        // 1. Verifikasi Header RS
        expect(find.text('RSUP Dr. Sitanala'), findsOneWidget);
        expect(find.text('Selamat Datang di SIIJAPIN'), findsOneWidget);

        // 2. Verifikasi Judul Section 1
        expect(find.text('Layanan Poliklinik & Pasien'), findsOneWidget);
        expect(find.text('Semua'), findsOneWidget);

        // 3. Verifikasi Hero Card Pendaftaran Rawat Jalan
        expect(find.text('Layanan Utama'), findsOneWidget);
        expect(find.text('Pendaftaran Rawat Jalan'), findsOneWidget);
        expect(find.text('Daftar Poli'), findsOneWidget);

        // 4. Verifikasi Bento Duo Cards
        expect(find.textContaining('Ketersediaan'), findsOneWidget);
        expect(find.textContaining('Jadwal'), findsOneWidget);
        expect(find.text('18 Bed Kosong'), findsOneWidget);
        expect(find.text('52 Dokter Aktif'), findsOneWidget);

        // Scroll ke bawah untuk melihat komponen berikutnya
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -400),
        );
        await tester.pumpAndSettle();

        // 5. Verifikasi Bento MCU
        expect(find.text('Paket Medical Check Up (MCU)'), findsOneWidget);
        expect(find.text('Skrining Preventif'), findsOneWidget);
        expect(find.text('Lihat Paket'), findsOneWidget);

        // 6. Verifikasi Bantuan & Informasi Cepat
        expect(find.text('Bantuan & Informasi Cepat'), findsOneWidget);
        expect(find.text('Pengaduan'), findsOneWidget);
        expect(find.textContaining('Standar'), findsOneWidget);
        expect(find.textContaining('Alur'), findsOneWidget);
        expect(find.textContaining('Lokasi'), findsOneWidget);

        // 7. Verifikasi Emergency Banner
        expect(find.text('IGD & Ambulans 24 Jam'), findsOneWidget);
        expect(find.textContaining('(021) 552-3059'), findsOneWidget);
        expect(find.text('Panggil'), findsOneWidget);
      },
    );
  });
}
