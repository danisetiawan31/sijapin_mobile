import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';
import 'package:sijapin_mobile/features/ticket/presentation/widgets/apm_qr_card.dart';

Widget _buildWrapper({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApmQrCard Widget Tests (Optical Scanner Ergonomics)', () {
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

    testWidgets('renders QR view and booking code correctly', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: ApmQrCard(
            ticket: testTicket,
            isMaxBrightness: false,
            onToggleBrightness: (_) {},
          ),
        ),
      );

      expect(find.text('Pemindai Kiosk APM'), findsOneWidget);
      expect(find.text('Mode Terang'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('2026101500014'), findsOneWidget);
      expect(
        find.text(
          'Arahkan QR Code ini ke lensa pemindai mesin Kiosk APM saat tiba di lobi RS.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('toggles brightness mode when button tapped', (tester) async {
      bool brightnessToggled = false;

      await tester.pumpWidget(
        _buildWrapper(
          child: ApmQrCard(
            ticket: testTicket,
            isMaxBrightness: false,
            onToggleBrightness: (val) => brightnessToggled = val,
          ),
        ),
      );

      await tester.tap(find.text('Mode Terang'));
      await tester.pump();

      expect(brightnessToggled, isTrue);
    });

    testWidgets('triggers onSimulateCheckIn callback when tapped', (tester) async {
      bool simulated = false;

      await tester.pumpWidget(
        _buildWrapper(
          child: ApmQrCard(
            ticket: testTicket,
            isMaxBrightness: false,
            onToggleBrightness: (_) {},
            onSimulateCheckIn: () => simulated = true,
          ),
        ),
      );

      expect(find.text('Simulasi Check-In Kiosk Lobi'), findsOneWidget);
      await tester.tap(find.text('Simulasi Check-In Kiosk Lobi'));
      await tester.pump();

      expect(simulated, isTrue);
    });
  });
}
