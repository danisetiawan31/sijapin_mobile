import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Data sementara sampai endpoint janji temu tersedia.
final activeAppointmentProvider = Provider<Appointment?>((ref) {
  final now = DateTime.now();
  return Appointment(
    bookingCode: '260930014221',
    queueNumber: 'MAT-014',
    patientName: 'Rhesa Panjaitan',
    doctorName: 'dr. Hendra Prasetyo, Sp.M.',
    specialty: 'Spesialis Mata',
    clinic: 'Poli Mata',
    scheduledDate: DateTime(now.year, now.month, now.day + 1, 9, 30),
    scheduledTime: '09.30 WIB',
    estimatedMinutes: 15,
    nowServingNumber: 'MAT-011',
    remainingQueue: 3,
  );
});

/// Riwayat janji temu yang sudah selesai atau dibatalkan (hanya dibaca).
final appointmentHistoryProvider = Provider<List<Appointment>>((ref) {
  return <Appointment>[
    Appointment(
      bookingCode: '260812001133',
      queueNumber: 'MAT-008',
      patientName: 'Rhesa Panjaitan',
      doctorName: 'dr. Hendra Prasetyo, Sp.M.',
      specialty: 'Spesialis Mata',
      clinic: 'Poli Mata',
      scheduledDate: DateTime(2026, 8, 12, 10, 0),
      scheduledTime: '10.00 WIB',
      estimatedMinutes: 0,
      nowServingNumber: 'MAT-008',
      remainingQueue: 0,
      status: AppointmentStatus.completed,
    ),
    Appointment(
      bookingCode: '260705000914',
      queueNumber: 'MAT-003',
      patientName: 'Rhesa Panjaitan',
      doctorName: 'dr. Anita Kusuma, Sp.M.',
      specialty: 'Spesialis Mata',
      clinic: 'Poli Mata',
      scheduledDate: DateTime(2026, 7, 5, 8, 30),
      scheduledTime: '08.30 WIB',
      estimatedMinutes: 0,
      nowServingNumber: 'MAT-003',
      remainingQueue: 0,
      status: AppointmentStatus.cancelled,
    ),
  ];
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

  Future<void> cancelAppointment() async {
    if (state.appointment == null || state.isCancelling) return;
    state = state.copyWith(isCancelling: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(clearAppointment: true, isCancelling: false);
  }
}

final bookingControllerProvider =
    NotifierProvider<BookingController, BookingState>(BookingController.new);
