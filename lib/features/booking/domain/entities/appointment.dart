enum AppointmentStatus { upcoming, ongoing, completed, cancelled }

class Appointment {
  const Appointment({
    required this.bookingCode,
    required this.queueNumber,
    required this.patientName,
    required this.doctorName,
    required this.specialty,
    required this.clinic,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.estimatedMinutes,
    required this.nowServingNumber,
    required this.remainingQueue,
    this.status = AppointmentStatus.upcoming,
  });

  /// Kodebooking 13 digit numerik untuk discan di Kiosk APM.
  final String bookingCode;

  /// Nomor antrean pasien, contoh: MAT-014.
  final String queueNumber;
  final String patientName;
  final String doctorName;
  final String specialty;
  final String clinic;
  final DateTime scheduledDate;

  /// Jam periksa terformat, contoh: 09.30 WIB.
  final String scheduledTime;

  /// Estimasi menit menuju nomor antrean pasien.
  final int estimatedMinutes;

  /// Nomor antrean yang sedang dilayani.
  final String nowServingNumber;
  final int remainingQueue;
  final AppointmentStatus status;

  /// Batas pembatalan H-1 pukul 21.00 WIB.
  DateTime get cancelDeadline {
    final day = scheduledDate;
    return DateTime(day.year, day.month, day.day - 1, 21);
  }

  bool get canCancel =>
      status == AppointmentStatus.upcoming &&
      DateTime.now().isBefore(cancelDeadline);

  bool get hasPassed =>
      status == AppointmentStatus.completed ||
      status == AppointmentStatus.cancelled;

  Appointment copyWith({
    AppointmentStatus? status,
    String? nowServingNumber,
    int? remainingQueue,
    int? estimatedMinutes,
  }) {
    return Appointment(
      bookingCode: bookingCode,
      queueNumber: queueNumber,
      patientName: patientName,
      doctorName: doctorName,
      specialty: specialty,
      clinic: clinic,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      nowServingNumber: nowServingNumber ?? this.nowServingNumber,
      remainingQueue: remainingQueue ?? this.remainingQueue,
      status: status ?? this.status,
    );
  }
}
