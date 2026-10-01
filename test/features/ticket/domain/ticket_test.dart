import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';

void main() {
  group('Ticket Domain Entity Tests (SSOT PRD FR-05 & FR-06)', () {
    final targetDate = AppDateTime.wibDateTime(2026, 10, 15, 9, 0);

    final sampleTicket = Ticket(
      bookingCode: '2026101500014',
      queueNumber: 'MAT-014',
      patientName: 'Ahmad Dhani Setiawan',
      medicalRecord: '01-••-45',
      doctorName: 'dr. Hendra, Sp.M.',
      specialty: 'Spesialis Mata',
      clinic: 'Poli Mata',
      scheduledDate: targetDate,
      scheduledTime: '09:00 WIB',
      estimatedMinutes: 30,
      nowServingNumber: 'MAT-011',
      remainingQueue: 3,
      status: TicketStatus.upcoming,
      isServerSynced: true,
    );

    test('qrPayload must strictly be numeric bookingCode per PRD FR-05.2', () {
      expect(sampleTicket.qrPayload, equals('2026101500014'));
      expect(sampleTicket.qrPayload.contains('|'), isFalse);
      expect(int.tryParse(sampleTicket.qrPayload), isNotNull);
    });

    test('cancelDeadline must be H-1 at 23:59 WIB per PRD FR-05.4', () {
      final deadline = sampleTicket.cancelDeadline;
      expect(deadline.year, equals(2026));
      expect(deadline.month, equals(10));
      expect(deadline.day, equals(14));
      expect(deadline.hour, equals(AppConfig.cancellationDeadlineHour));
      expect(deadline.minute, equals(AppConfig.cancellationDeadlineMinute));
    });

    test(
      'canCancel returns true when before deadline and status is upcoming',
      () {
        // Waktu periksa di masa depan
        expect(sampleTicket.canCancel, isTrue);

        // Jika sudah dibatalkan, canCancel harus false
        final cancelled = sampleTicket.copyWith(status: TicketStatus.cancelled);
        expect(cancelled.canCancel, isFalse);

        // Jika sudah check-in, canCancel harus false
        final checkedIn = sampleTicket.copyWith(status: TicketStatus.checkedIn);
        expect(checkedIn.canCancel, isFalse);
      },
    );

    test('bidirectional mapping with Appointment preserves all fields', () {
      final appointment = sampleTicket.toAppointment();
      expect(appointment.bookingCode, equals(sampleTicket.bookingCode));
      expect(appointment.queueNumber, equals(sampleTicket.queueNumber));
      expect(appointment.status, equals(AppointmentStatus.upcoming));
      expect(appointment.isServerSynced, isTrue);

      final convertedBack = Ticket.fromAppointment(appointment);
      expect(convertedBack.bookingCode, equals(sampleTicket.bookingCode));
      expect(convertedBack.status, equals(TicketStatus.upcoming));
    });

    test('maskedMedicalRecord applies UU PDP masking if raw unmasked RM is supplied', () {
      final unmaskedTicket = sampleTicket.copyWith(medicalRecord: '012345');
      expect(unmaskedTicket.maskedMedicalRecord, equals('01••45'));

      final alreadyMasked = sampleTicket.copyWith(medicalRecord: '01-••-45');
      expect(alreadyMasked.maskedMedicalRecord, equals('01-••-45'));

      final nullTicket = Ticket(
        bookingCode: '2026101500014',
        queueNumber: 'MAT-014',
        patientName: 'Ahmad Dhani Setiawan',
        medicalRecord: null,
        doctorName: 'dr. Hendra, Sp.M.',
        specialty: 'Spesialis Mata',
        clinic: 'Poli Mata',
        scheduledDate: targetDate,
        scheduledTime: '09:00 WIB',
        estimatedMinutes: 30,
        nowServingNumber: 'MAT-011',
        remainingQueue: 3,
        status: TicketStatus.upcoming,
      );
      expect(nullTicket.maskedMedicalRecord, equals('-'));
    });
  });
}
