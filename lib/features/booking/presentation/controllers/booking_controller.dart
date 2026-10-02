import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Riwayat kunjungan yang sudah selesai atau dibatalkan (terhubung ke modul tiket).
final appointmentHistoryProvider = Provider<List<Appointment>>((ref) {
  final ticketState = ref.watch(ticketControllerProvider);
  final List<Appointment> history = [];

  final currentTicket = ticketState.ticket;
  if (currentTicket != null &&
      (currentTicket.isCancelled || currentTicket.isCompleted)) {
    history.add(currentTicket.toAppointment());
  }

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
