import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_controller.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/booking_screen.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/history_filter_bar.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/qr_ticket_sheet.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/visit_proof_sheet.dart';

final _testHistory = [
  Appointment(
    bookingCode: '2026091200089',
    queueNumber: 'MAT-008',
    patientName: 'Siti Rahmah',
    doctorName: 'dr. Hendra, Sp.M.',
    specialty: 'Spesialis Mata',
    clinic: 'Poli Mata',
    scheduledDate: DateTime(2026, 9, 12, 9, 30),
    scheduledTime: '09.30 WIB',
    estimatedMinutes: 0,
    nowServingNumber: 'MAT-008',
    remainingQueue: 0,
    status: AppointmentStatus.completed,
    patientRelation: 'Keluarga',
    medicalRecord: '0456**',
  ),
  Appointment(
    bookingCode: '2026080400122',
    queueNumber: 'PDI-006',
    patientName: 'Ahmad Dhani Setiawan',
    doctorName: 'dr. Era Medina, Sp.PD',
    specialty: 'Spesialis Penyakit Dalam',
    clinic: 'Poli Penyakit Dalam',
    scheduledDate: DateTime(2026, 8, 4, 10, 0),
    scheduledTime: '10.00 WIB',
    estimatedMinutes: 0,
    nowServingNumber: 'PDI-006',
    remainingQueue: 0,
    status: AppointmentStatus.completed,
    patientRelation: 'Diri Sendiri',
    medicalRecord: '0123**',
  ),
  Appointment(
    bookingCode: '2026071500045',
    queueNumber: 'THT-004',
    patientName: 'Ahmad Dhani Setiawan',
    doctorName: 'dr. Rian Pramudita, Sp.THT',
    specialty: 'Spesialis THT-KL',
    clinic: 'Poli THT-KL',
    scheduledDate: DateTime(2026, 7, 15, 8, 30),
    scheduledTime: '08.30 WIB',
    estimatedMinutes: 0,
    nowServingNumber: 'THT-004',
    remainingQueue: 0,
    status: AppointmentStatus.cancelled,
    patientRelation: 'Diri Sendiri',
    medicalRecord: '0123**',
    cancelNote: 'Dibatalkan oleh pasien (H-1)',
  ),
];

Appointment get _defaultActiveAppointment {
  final now = AppDateTime.now();
  return Appointment(
    bookingCode: '260930014221',
    queueNumber: 'MAT-014',
    patientName: 'Rhesa Panjaitan',
    doctorName: 'dr. Hendra Prasetyo, Sp.M.',
    specialty: 'Spesialis Mata',
    clinic: 'Poli Mata',
    scheduledDate: AppDateTime.wibDateTime(
      now.year,
      now.month,
      now.day + 1,
      9,
      30,
    ),
    scheduledTime: '09:30 WIB',
    estimatedMinutes: 15,
    nowServingNumber: 'MAT-011',
    remainingQueue: 3,
    patientRelation: 'Diri Sendiri',
    medicalRecord: '0123***',
    isServerSynced: true,
  );
}

ProviderContainer _createContainer({
  Appointment? activeAppointment,
  bool overrideActive = false,
}) {
  final effective = overrideActive ? activeAppointment : (activeAppointment ?? _defaultActiveAppointment);
  return ProviderContainer(
    overrides: [
      appointmentHistoryProvider.overrideWithValue(_testHistory),
      activeAppointmentProvider.overrideWithValue(effective),
    ],
  );
}

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(theme: AppTheme.lightTheme, home: const BookingScreen()),
  );
}

void main() {
  group('BookingScreen (tiket antrean digital)', () {
    testWidgets('menampilkan tiket aktif sesuai desain tiket', (tester) async {
      final container = _createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Janji Temu'), findsOneWidget);
      expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);

      // Heading bagian dan penanda hari kunjungan.
      expect(find.text('Tiket Kunjungan Aktif'), findsOneWidget);
      expect(find.text('Kunjungan Besok'), findsOneWidget);

      // Pil jadwal dan kode booking.
      expect(find.text('Besok, 09:30 WIB'), findsOneWidget);
      expect(find.text('260930014221'), findsOneWidget);

      // Blok poli, dokter, dan panel pasien.
      expect(find.text('Poli Mata'), findsOneWidget);
      expect(find.text('dr. Hendra Prasetyo, Sp.M.'), findsOneWidget);
      expect(find.text('Rhesa Panjaitan'), findsOneWidget);
      expect(find.text('0123***'), findsOneWidget);

      // Nomor antrean dan estimasi jam periksa.
      expect(find.text('014'), findsOneWidget);
      expect(find.text('09:30 - 10:15'), findsOneWidget);
      expect(find.text('Hadir 20 mnt awal'), findsOneWidget);

      // Aksi tiket dan callout check-in mandiri.
      expect(find.text('Buka Tiket QR APM'), findsOneWidget);
      expect(find.text('Batalkan Janji'), findsOneWidget);
      expect(find.text('Batas batal: H-1 s/d 23:59 WIB'), findsOneWidget);
      expect(find.text('Check-in Mandiri Cepat (APM)'), findsOneWidget);
      expect(find.text('Layanan Buka 06.30 WIB'), findsOneWidget);
      expect(find.text('Petunjuk Arah RS'), findsNothing);
    });

    testWidgets('tiket aktif tetap utuh pada layar sempit', (tester) async {
      final container = _createContainer();
      addTearDown(container.dispose);
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Poli Mata'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Buka Tiket QR APM'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Buka Tiket QR APM'), findsOneWidget);

      await tester.tap(find.text('Buka Tiket QR APM'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(QrTicketSheet), findsOneWidget);
      expect(find.text('Kode QR Anjungan Mandiri'), findsOneWidget);
    });

    testWidgets('Buka Tiket QR APM menampilkan bottom sheet QR', (
      tester,
    ) async {
      final container = _createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Buka Tiket QR APM'));
      await tester.pump();
      await tester.tap(find.text('Buka Tiket QR APM'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(QrTicketSheet), findsOneWidget);
      expect(find.text('Siap Scan di Mesin APM'), findsOneWidget);
      expect(find.text('Kode QR Anjungan Mandiri'), findsOneWidget);
      expect(
        find.textContaining('MAT-014 (dr. Hendra Prasetyo'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Tutup Tiket'));
      await tester.pump();
      await tester.tap(find.text('Tutup Tiket'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Kode QR Anjungan Mandiri'), findsNothing);
    });

    testWidgets('membatalkan janji temu melalui dialog konfirmasi', (
      tester,
    ) async {
      final container = _createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.ensureVisible(find.text('Batalkan Janji'));
      await tester.pump();
      await tester.tap(find.text('Batalkan Janji'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Batal Janji Temu?'), findsOneWidget);

      await tester.tap(find.text('Ya, Batalkan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Belum Ada Janji Temu'), findsOneWidget);
      expect(find.text('014'), findsNothing);
    });

    testWidgets('menampilkan state kosong saat tidak ada janji temu', (
      tester,
    ) async {
      final container = _createContainer(overrideActive: true);
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Belum Ada Janji Temu'), findsOneWidget);
      expect(find.text('Cari Dokter'), findsOneWidget);
    });

    testWidgets('berpindah ke Riwayat Selesai menampilkan daftar kunjungan', (
      tester,
    ) async {
      final container = _createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.text('Tiket Aktif'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Poli Mata'), findsAtLeastNWidgets(1));
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

      expect(find.text('2026091200089'), findsOneWidget);
      expect(find.text('2026080400122'), findsOneWidget);
      expect(find.text('2026071500045'), findsOneWidget);
      expect(find.text('Poli Mata • dr. Hendra, Sp.M.'), findsOneWidget);
      expect(find.text('Siti Rahmah (Keluarga • RM: 0456**)'), findsOneWidget);
      expect(find.text('Dibatalkan oleh pasien (H-1)'), findsOneWidget);
      expect(find.text('Butuh Salinan Rekam Medis?'), findsOneWidget);
      expect(find.text('Tiket Kunjungan Aktif'), findsNothing);
    });

    testWidgets('filter Riwayat Selesai menyaring kartu sesuai status', (
      tester,
    ) async {
      final container = _createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.tap(find.text('Riwayat Selesai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(
        find.descendant(
          of: find.byType(HistoryFilterBar),
          matching: find.text('Dibatalkan'),
        ),
      );
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(HistoryFilterBar),
          matching: find.text('Dibatalkan'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2026071500045'), findsOneWidget);
      expect(find.text('2026091200089'), findsNothing);
      expect(find.text('2026080400122'), findsNothing);
    });

    testWidgets('Lihat Bukti Kunjungan membuka bottom sheet bukti', (
      tester,
    ) async {
      final container = _createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      await tester.tap(find.text('Riwayat Selesai'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.ensureVisible(find.text('Lihat Bukti Kunjungan').first);
      await tester.pump();
      await tester.tap(find.text('Lihat Bukti Kunjungan').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(VisitProofSheet), findsOneWidget);
      expect(find.text('Bukti Kunjungan'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(VisitProofSheet),
          matching: find.text('2026091200089'),
        ),
        findsOneWidget,
      );
      expect(find.text('No. Rekam Medis'), findsOneWidget);

      await tester.ensureVisible(
        find.descendant(
          of: find.byType(VisitProofSheet),
          matching: find.text('Tutup'),
        ),
      );
      await tester.pump();
      await tester.tap(
        find.descendant(
          of: find.byType(VisitProofSheet),
          matching: find.text('Tutup'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(VisitProofSheet), findsNothing);
    });

    testWidgets('ikon sinkron menampilkan status antrean terbaru', (
      tester,
    ) async {
      final container = _createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));
      await tester.pump();

      expect(find.byIcon(Icons.sync_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.sync_rounded));
      await tester.pump();
      expect(find.bySemanticsLabel('Perbarui status antrean'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Status antrean terbaru'), findsOneWidget);
    });
  });
}
