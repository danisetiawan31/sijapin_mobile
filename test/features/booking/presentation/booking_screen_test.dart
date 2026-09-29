import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_controller.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/booking_screen.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/qr_ticket_dialog.dart';

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: AppTheme.lightTheme, home: const BookingScreen()),
  );
}

void main() {
  group('BookingScreen (tiket antrean digital)', () {
    testWidgets('menampilkan nomor antrean, detail dokter, dan kode booking', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Janji Temu'), findsOneWidget);
      expect(find.text('MAT-014'), findsAtLeastNWidgets(1));
      expect(find.text('Rhesa Panjaitan'), findsOneWidget);
      expect(find.text('dr. Hendra Prasetyo, Sp.M.'), findsOneWidget);
      expect(find.text('Spesialis Mata'), findsOneWidget);
      expect(find.text('Poli Mata'), findsOneWidget);
      expect(find.text('Nomor Antrean'), findsOneWidget);
      expect(find.text('3 pasien'), findsOneWidget);
      expect(find.text('~15 menit'), findsOneWidget);
      expect(find.text('260930014221'), findsOneWidget);
      expect(find.text('Buka Tiket QR'), findsOneWidget);
      expect(find.text('Batal Janji Temu'), findsOneWidget);
      expect(find.text('Petunjuk Arah RS'), findsNothing);
    });

    testWidgets('Buka Tiket QR menampilkan QR check-in layar penuh', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Buka Tiket QR'));
      await tester.pump();
      await tester.tap(find.text('Buka Tiket QR'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Tiket QR Check-in'), findsOneWidget);
      expect(find.byType(QrTicketDialog), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);

      await tester.ensureVisible(find.text('Tutup'));
      await tester.pump();
      await tester.tap(find.text('Tutup'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Tiket QR Check-in'), findsNothing);
    });

    testWidgets('menampilkan denyut antrean langsung', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Sedang Dilayani: MAT-011'), findsOneWidget);
      expect(find.text('3 pasien lagi'), findsOneWidget);
      expect(find.text('Estimasi ~15 menit'), findsOneWidget);
    });

    testWidgets('membatalkan janji temu melalui dialog konfirmasi', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Batal Janji Temu'));
      await tester.pump();
      await tester.tap(find.text('Batal Janji Temu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Batal Janji Temu?'), findsOneWidget);

      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Belum Ada Janji Temu'), findsOneWidget);
      expect(find.text('MAT-014'), findsNothing);
    });

    testWidgets('menampilkan state kosong saat tidak ada janji temu', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [activeAppointmentProvider.overrideWithValue(null)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Belum Ada Janji Temu'), findsOneWidget);
      expect(find.text('Cari Dokter'), findsOneWidget);
    });

    testWidgets('berpindah ke Riwayat Selesai menampilkan daftar kunjungan', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Tiket Aktif'), findsOneWidget);
      expect(find.text('MAT-014'), findsAtLeastNWidgets(1));
      expect(
        (tester.widget<Text>(find.text('Tiket Aktif'))).style?.color,
        Colors.white,
      );

      await tester.tap(find.text('Riwayat Selesai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        (tester.widget<Text>(find.text('Riwayat Selesai'))).style?.color,
        Colors.white,
      );
      expect(
        (tester.widget<Text>(find.text('Tiket Aktif'))).style?.color,
        isNot(Colors.white),
      );

      expect(find.text('dr. Hendra Prasetyo, Sp.M.'), findsOneWidget);
      expect(find.text('dr. Anita Kusuma, Sp.M.'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);
      expect(find.text('MAT-014'), findsNothing);
    });
    testWidgets('ikon refresh memperbarui sisa antrean', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      expect(find.text('3 pasien lagi'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('2 pasien'), findsOneWidget);
      expect(find.text('2 pasien lagi'), findsOneWidget);
      expect(find.text('Status antrean terbaru'), findsOneWidget);
    });
  });
}
