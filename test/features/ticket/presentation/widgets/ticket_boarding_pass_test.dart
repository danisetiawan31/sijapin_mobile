import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';
import 'package:sijapin_mobile/features/ticket/presentation/widgets/ticket_boarding_pass.dart';

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

  group('TicketBoardingPass Widget Tests', () {
    late Ticket testTicket;

    setUp(() {
      testTicket = Ticket(
        bookingCode: '2026101500014',
        queueNumber: 'MAT-014',
        patientName: 'Rhesa Panjaitan',
        medicalRecord: '0123***',
        doctorName: 'dr. Hendra Prasetyo, Sp.M.',
        specialty: 'Spesialis Mata',
        clinic: 'Poli Mata',
        clinicLocation: 'Lantai 2 - Gedung Rawat Jalan',
        scheduledDate: AppDateTime.now().add(const Duration(days: 3)),
        scheduledTime: '09:30 WIB',
        estimatedMinutes: 15,
        nowServingNumber: 'MAT-011',
        remainingQueue: 3,
        patientRelation: 'Diri Sendiri',
        isServerSynced: true,
        status: TicketStatus.upcoming,
      );
    });

    testWidgets(
      'renders hero queue number, clinic, doctor, and patient details',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: TicketBoardingPass(ticket: testTicket, onOpenApmQr: () {}),
          ),
        );

        // RSUP branding
        expect(find.text('RSUP Dr. Sitanala'), findsOneWidget);
        expect(find.text('Terdaftar'), findsOneWidget);

        // Hero queue
        expect(find.text('NOMOR ANTREAN ANDA'), findsOneWidget);
        expect(find.text('MAT-014'), findsOneWidget);
        expect(find.text('09:30 WIB'), findsOneWidget);

        // Live queue tracker
        expect(
          find.text('3 Pasien Lagi Sebelum Anda (Sekarang: MAT-011)'),
          findsOneWidget,
        );

        // Bento cards
        expect(find.text('dr. Hendra Prasetyo, Sp.M.'), findsOneWidget);
        expect(
          find.text('Poli Mata • Lantai 2 - Gedung Rawat Jalan'),
          findsOneWidget,
        );
        expect(find.text('Rhesa Panjaitan'), findsOneWidget);
        expect(find.text('0123***'), findsOneWidget);
      },
    );

    testWidgets('triggers onOpenApmQr callback when button tapped', (
      tester,
    ) async {
      bool opened = false;

      await tester.pumpWidget(
        _buildWrapper(
          child: TicketBoardingPass(
            ticket: testTicket,
            onOpenApmQr: () => opened = true,
          ),
        ),
      );

      await tester.tap(find.text('Buka QR Mesin APM Lobi'));
      await tester.pump();

      expect(opened, isTrue);
    });

    testWidgets(
      'triggers onCancel when cancellation button tapped before deadline',
      (tester) async {
        bool cancelled = false;

        await tester.pumpWidget(
          _buildWrapper(
            child: TicketBoardingPass(
              ticket: testTicket,
              onOpenApmQr: () {},
              onCancel: () => cancelled = true,
            ),
          ),
        );

        expect(find.text('Batalkan Janji Temu'), findsOneWidget);
        await tester.tap(find.text('Batalkan Janji Temu'));
        await tester.pump();

        expect(cancelled, isTrue);
      },
    );
  });
}
