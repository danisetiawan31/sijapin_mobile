import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';
import 'package:sijapin_mobile/features/ticket/presentation/widgets/kiosk_arrival_stepper.dart';

Widget _buildWrapper({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KioskArrivalStepper Widget Tests (Task ID BPJS Progression)', () {
    testWidgets('marks step 2 as active when ticket is upcoming', (
      tester,
    ) async {
      final ticket = Ticket(
        bookingCode: '2026101500014',
        queueNumber: 'MAT-014',
        patientName: 'Rhesa Panjaitan',
        doctorName: 'dr. Hendra Prasetyo, Sp.M.',
        specialty: 'Spesialis Mata',
        clinic: 'Poli Mata',
        scheduledDate: AppDateTime.now().add(const Duration(days: 1)),
        scheduledTime: '09:30 WIB',
        estimatedMinutes: 15,
        nowServingNumber: 'MAT-011',
        remainingQueue: 3,
        isServerSynced: true,
        status: TicketStatus.upcoming,
      );

      await tester.pumpWidget(
        _buildWrapper(child: KioskArrivalStepper(ticket: ticket)),
      );

      expect(find.text('Alur Kedatangan di Rumah Sakit'), findsOneWidget);
      expect(find.text('Booking Online'), findsOneWidget);
      expect(find.text('Check-In Kiosk APM'), findsOneWidget);
      expect(find.text('Panggilan Layanan Poli'), findsOneWidget);
      expect(find.text('Tahap Ini'), findsOneWidget);
    });

    testWidgets('marks step 2 as completed when ticket is checked in', (
      tester,
    ) async {
      final ticket = Ticket(
        bookingCode: '2026101500014',
        queueNumber: 'MAT-014',
        patientName: 'Rhesa Panjaitan',
        doctorName: 'dr. Hendra Prasetyo, Sp.M.',
        specialty: 'Spesialis Mata',
        clinic: 'Poli Mata',
        scheduledDate: AppDateTime.now().add(const Duration(days: 1)),
        scheduledTime: '09:30 WIB',
        estimatedMinutes: 15,
        nowServingNumber: 'MAT-011',
        remainingQueue: 3,
        isServerSynced: true,
        status: TicketStatus.checkedIn,
        checkInTime: AppDateTime.now(),
      );

      await tester.pumpWidget(
        _buildWrapper(child: KioskArrivalStepper(ticket: ticket)),
      );

      expect(
        find.text('Check-in terverifikasi di mesin Anjungan'),
        findsOneWidget,
      );
      expect(find.text('Menunggu dipanggil oleh perawat poli'), findsOneWidget);
    });
  });
}
