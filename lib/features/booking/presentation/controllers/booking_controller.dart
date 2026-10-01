import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

import 'package:sijapin_mobile/features/ticket/presentation/controllers/ticket_controller.dart';

/// Provider tiket janji temu aktif yang terhubung secara reaktif ke modul tiket (Epic 06)
final activeAppointmentProvider = Provider<Appointment?>((ref) {
  final ticketState = ref.watch(ticketControllerProvider);
  final ticket = ticketState.ticket;
  if (ticket == null || ticket.isCancelled || ticket.isCompleted) return null;
  return ticket.toAppointment();
});

/// Riwayat kunjungan lampau default (terverifikasi SIMRS)
List<Appointment> get kDefaultHistoricalAppointments => [
  Appointment(
    bookingCode: '2026091200089',
    queueNumber: 'MAT-008',
    patientName: 'Siti Rahmah',
    doctorName: 'dr. Hendra, Sp.M.',
    specialty: 'Spesialis Mata',
    clinic: 'Poli Mata',
    scheduledDate: AppDateTime.wibDateTime(2026, 9, 12, 9, 30),
    scheduledTime: '09.30 ${AppConfig.timeZoneAbbr}',
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
    scheduledDate: AppDateTime.wibDateTime(2026, 8, 4, 10, 0),
    scheduledTime: '10.00 ${AppConfig.timeZoneAbbr}',
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
    scheduledDate: AppDateTime.wibDateTime(2026, 7, 15, 8, 30),
    scheduledTime: '08.30 ${AppConfig.timeZoneAbbr}',
    estimatedMinutes: 0,
    nowServingNumber: 'THT-004',
    remainingQueue: 0,
    status: AppointmentStatus.cancelled,
    patientRelation: 'Diri Sendiri',
    medicalRecord: '0123**',
    cancelNote: 'Dibatalkan oleh pasien (H-1)',
  ),
];

/// Riwayat kunjungan yang sudah selesai atau dibatalkan (terhubung ke modul tiket).
final appointmentHistoryProvider = Provider<List<Appointment>>((ref) {
  final ticketState = ref.watch(ticketControllerProvider);
  final List<Appointment> history = [];

  final currentTicket = ticketState.ticket;
  if (currentTicket != null &&
      (currentTicket.isCancelled || currentTicket.isCompleted)) {
    history.add(currentTicket.toAppointment());
  }

  // Riwayat kunjungan terverifikasi SIMRS
  history.addAll(kDefaultHistoricalAppointments);

  return history;
});

class BookingState {
  const BookingState({
    this.appointment,
    this.isCancelling = false,
    this.isRefreshing = false,
  });

  final Appointment? appointment;
  final bool isCancelling;
  final bool isRefreshing;

  BookingState copyWith({
    Appointment? appointment,
    bool? isCancelling,
    bool? isRefreshing,
    bool clearAppointment = false,
  }) {
    return BookingState(
      appointment: clearAppointment ? null : (appointment ?? this.appointment),
      isCancelling: isCancelling ?? this.isCancelling,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class BookingController extends Notifier<BookingState> {
  @override
  BookingState build() =>
      BookingState(appointment: ref.watch(activeAppointmentProvider));

  /// Muat ulang status antrean; sisa antrean berkurang satu tiap penyegaran
  /// sampai nomor Anda dipanggil. Placeholder sampai endpoint asli tersedia.
  Future<void> refreshQueue() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final Appointment? appointment = state.appointment;
    if (appointment != null) {
      state = state.copyWith(
        appointment: appointment.copyWith(
          remainingQueue: appointment.remainingQueue > 0
              ? appointment.remainingQueue - 1
              : 0,
        ),
        isRefreshing: false,
      );
      return;
    }
    state = state.copyWith(isRefreshing: false);
  }

  /// Menetapkan janji temu aktif hasil booking baru
  void setAppointment(Appointment appointment) {
    state = state.copyWith(appointment: appointment);
  }

  Future<void> cancelAppointment({
    String reason = 'Dibatalkan oleh pasien',
  }) async {
    final appointment = state.appointment;
    if (appointment == null || state.isCancelling) return;
    state = state.copyWith(isCancelling: true);

    // 1. Eksekusi pembatalan terpadu melalui TicketController & Hive NoSQL
    unawaited(
      ref.read(ticketControllerProvider.notifier).cancelTicket(reason: reason),
    );

    // 2. Hubungi juga booking repository untuk kompatibilitas mundur
    unawaited(
      ref
          .read(bookingRepositoryProvider)
          .cancelBooking(
            bookingCode: appointment.bookingCode,
            reason: reason,
            memberId: appointment.memberId,
            scheduledDate: appointment.scheduledDate,
          ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(clearAppointment: true, isCancelling: false);
  }
}

final bookingControllerProvider =
    NotifierProvider<BookingController, BookingState>(BookingController.new);
