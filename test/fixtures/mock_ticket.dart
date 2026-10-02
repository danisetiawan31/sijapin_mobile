import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';

/// Fixture data tiket pengujian unit/widget yang merefleksikan janji temu aktif
Ticket get kMockActiveTicket {
  final now = AppDateTime.now();
  return Ticket(
    bookingCode: '260930014221',
    queueNumber: 'MAT-014',
    patientName: 'Rhesa Panjaitan',
    medicalRecord: '0123***',
    doctorName: 'dr. Hendra Prasetyo, Sp.M.',
    specialty: 'Spesialis Mata',
    clinic: 'Poli Mata',
    clinicLocation: 'Lantai 2 - Gedung Rawat Jalan',
    scheduledDate: AppDateTime.wibDateTime(
      now.year,
      now.month,
      now.day + 1,
      9,
      30,
    ),
    scheduledTime: '09.30 ${AppConfig.timeZoneAbbr}',
    estimatedMinutes: 15,
    nowServingNumber: 'MAT-011',
    remainingQueue: 3,
    patientRelation: 'Diri Sendiri',
    isServerSynced: true,
    status: TicketStatus.upcoming,
  );
}
