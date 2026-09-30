import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';

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
    this.patientRelation,
    this.medicalRecord,
    this.cancelNote,
    this.memberId,
    this.isServerSynced = true,
  });

  /// Status sinkronisasi ke server SIMRS (false jika dibuat saat offline)
  final bool isServerSynced;

  /// ID anggota keluarga (member_id di m_customer_member & t_daftar_rj)
  final int? memberId;

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

  /// Hubungan pasien dengan pemilik akun: `Diri Sendiri` atau `Keluarga`.
  final String? patientRelation;

  /// Nomor rekam medis tersamar, contoh: `0456**`.
  final String? medicalRecord;

  /// Alasan pembatalan, contoh: `Dibatalkan oleh pasien (H-1)`.
  final String? cancelNote;

  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;

  /// Batas pembatalan H-1 pukul 23:59 WIB.
  DateTime get cancelDeadline {
    final wibDate = AppDateTime.toWib(scheduledDate);
    return AppDateTime.wibDateTime(
      wibDate.year,
      wibDate.month,
      wibDate.day - 1,
      AppConfig.cancellationDeadlineHour,
      AppConfig.cancellationDeadlineMinute,
      59,
    );
  }

  bool get canCancel =>
      status == AppointmentStatus.upcoming &&
      AppDateTime.now().isBefore(cancelDeadline);

  bool get hasPassed =>
      status == AppointmentStatus.completed ||
      status == AppointmentStatus.cancelled;

  Appointment copyWith({
    AppointmentStatus? status,
    String? nowServingNumber,
    int? remainingQueue,
    int? estimatedMinutes,
    String? cancelNote,
    int? memberId,
    bool? isServerSynced,
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
      patientRelation: patientRelation,
      medicalRecord: medicalRecord,
      cancelNote: cancelNote ?? this.cancelNote,
      memberId: memberId ?? this.memberId,
      isServerSynced: isServerSynced ?? this.isServerSynced,
    );
  }
}
