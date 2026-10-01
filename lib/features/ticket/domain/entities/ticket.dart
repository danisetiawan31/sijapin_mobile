import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Status siklus hidup tiket pendaftaran antrean rawat jalan
enum TicketStatus {
  /// Terdaftar secara online, menunggu hari-H untuk check-in (Task 1 BPJS)
  upcoming,

  /// Pasien telah tiba di RS dan memindai QR Code di mesin Kiosk APM (Task 2 BPJS)
  checkedIn,

  /// Pemeriksaan poliklinik selesai (Task 6/7 BPJS)
  completed,

  /// Pendaftaran dibatalkan mandiri oleh pasien (maksimal H-1 23:59 WIB)
  cancelled,
}

/// Entitas bisnis resmi untuk Tiket Antrean Digital & Integrasi Kiosk APM
/// Merujuk pada SSOT: PRD FR-05, FR-06 & Juknis 7 Task ID BPJS
class Ticket {
  const Ticket({
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
    this.status = TicketStatus.upcoming,
    this.clinicLocation = 'Lantai 2 - Gedung Rawat Jalan',
    this.guarantor = 'BPJS Kesehatan',
    this.patientRelation,
    this.medicalRecord,
    this.cancelNote,
    this.memberId,
    this.checkInTime,
    this.createdAt,
    this.isServerSynced = true,
  });

  /// Kode booking 13 digit numerik murni (misal: 2026092500014)
  final String bookingCode;

  /// Nomor antrean poliklinik (misal: MAT-014 atau 014)
  final String queueNumber;

  /// Nama lengkap pasien yang berobat
  final String patientName;

  /// Nama dokter pemeriksa DPJP
  final String doctorName;

  /// Spesialisasi dokter (misal: Spesialis Mata)
  final String specialty;

  /// Nama unit poliklinik (misal: Poli Mata)
  final String clinic;

  /// Lokasi lantai/ruangan di RSUP Dr. Sitanala
  final String clinicLocation;

  /// Tanggal kunjungan berobat
  final DateTime scheduledDate;

  /// Jam layanan dokter terformat (contoh: 08:30 WIB)
  final String scheduledTime;

  /// Estimasi durasi menit menuju giliran pasien
  final int estimatedMinutes;

  /// Nomor antrean yang sedang dilayani saat ini
  final String nowServingNumber;

  /// Sisa antrean di depan pasien
  final int remainingQueue;

  /// Status siklus hidup tiket
  final TicketStatus status;

  /// Jalur penjaminan (BPJS Kesehatan / Pasien Umum)
  final String guarantor;

  /// Hubungan pasien dengan pemilik akun: `Diri Sendiri` atau `Keluarga`
  final String? patientRelation;

  /// Nomor rekam medis tersensor (contoh: 01-••-45)
  final String? medicalRecord;

  /// Catatan alasan pembatalan jika dibatalkan
  final String? cancelNote;

  /// ID anggota keluarga di tabel m_customer_member
  final int? memberId;

  /// Waktu saat check-in fisik di mesin Kiosk APM
  final DateTime? checkInTime;

  /// Waktu saat reservasi tiket dibuat
  final DateTime? createdAt;

  /// Status sinkronisasi ke server SIMRS (false jika dibuat saat offline)
  final bool isServerSynced;

  /// Payload QR Code: Murni string numerik KODE_BOOKING sesuai mandat PRD FR-05.2
  /// Dilarang membubuhkan format pipa teks guna menjamin keterbacaan scanner 2D APM
  String get qrPayload => bookingCode;

  /// Masking nomor rekam medis sesuai mandat NFR-01 & UU Perlindungan Data Pribadi (UU PDP)
  String get maskedMedicalRecord {
    if (medicalRecord == null || medicalRecord!.trim().isEmpty) return '-';
    final raw = medicalRecord!.trim();
    if (raw.contains('*') || raw.contains('•')) return raw;
    if (raw.length <= 4) return '•••';
    return '${raw.substring(0, 2)}••${raw.substring(raw.length - 2)}';
  }

  bool get isUpcoming => status == TicketStatus.upcoming;
  bool get isCheckedIn => status == TicketStatus.checkedIn;
  bool get isCompleted => status == TicketStatus.completed;
  bool get isCancelled => status == TicketStatus.cancelled;

  /// Batas waktu pembatalan mandiri: H-1 pukul 23:59 WIB (PRD FR-05.4)
  DateTime get cancelDeadline {
    final wibDate = AppDateTime.toWib(scheduledDate);
    return AppDateTime.wibDateTime(
      wibDate.year,
      wibDate.month,
      wibDate.day - 1,
      AppConfig.cancellationDeadlineHour,
      AppConfig.cancellationDeadlineMinute,
    );
  }

  /// Pasien hanya dapat membatalkan jika status masih upcoming dan belum lewat H-1 23:59 WIB
  bool get canCancel {
    if (status != TicketStatus.upcoming) return false;
    final nowWib = AppDateTime.now();
    return nowWib.isBefore(cancelDeadline);
  }

  /// Konversi ke entitas Appointment untuk kompatibilitas mundur
  Appointment toAppointment() {
    AppointmentStatus appStatus;
    switch (status) {
      case TicketStatus.upcoming:
        appStatus = AppointmentStatus.upcoming;
        break;
      case TicketStatus.checkedIn:
        appStatus = AppointmentStatus.ongoing;
        break;
      case TicketStatus.completed:
        appStatus = AppointmentStatus.completed;
        break;
      case TicketStatus.cancelled:
        appStatus = AppointmentStatus.cancelled;
        break;
    }

    return Appointment(
      bookingCode: bookingCode,
      queueNumber: queueNumber,
      patientName: patientName,
      doctorName: doctorName,
      specialty: specialty,
      clinic: clinic,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      estimatedMinutes: estimatedMinutes,
      nowServingNumber: nowServingNumber,
      remainingQueue: remainingQueue,
      status: appStatus,
      patientRelation: patientRelation,
      medicalRecord: medicalRecord,
      cancelNote: cancelNote,
      memberId: memberId,
      isServerSynced: isServerSynced,
    );
  }

  /// Pembuatan Ticket dari Appointment
  factory Ticket.fromAppointment(
    Appointment appointment, {
    String clinicLocation = 'Lantai 2 - Gedung Rawat Jalan',
    String guarantor = 'BPJS Kesehatan',
  }) {
    TicketStatus ticketStatus;
    switch (appointment.status) {
      case AppointmentStatus.upcoming:
        ticketStatus = TicketStatus.upcoming;
        break;
      case AppointmentStatus.ongoing:
        ticketStatus = TicketStatus.checkedIn;
        break;
      case AppointmentStatus.completed:
        ticketStatus = TicketStatus.completed;
        break;
      case AppointmentStatus.cancelled:
        ticketStatus = TicketStatus.cancelled;
        break;
    }

    return Ticket(
      bookingCode: appointment.bookingCode,
      queueNumber: appointment.queueNumber,
      patientName: appointment.patientName,
      doctorName: appointment.doctorName,
      specialty: appointment.specialty,
      clinic: appointment.clinic,
      scheduledDate: appointment.scheduledDate,
      scheduledTime: appointment.scheduledTime,
      estimatedMinutes: appointment.estimatedMinutes,
      nowServingNumber: appointment.nowServingNumber,
      remainingQueue: appointment.remainingQueue,
      status: ticketStatus,
      clinicLocation: clinicLocation,
      guarantor: guarantor,
      patientRelation: appointment.patientRelation,
      medicalRecord: appointment.medicalRecord,
      cancelNote: appointment.cancelNote,
      memberId: appointment.memberId,
      isServerSynced: appointment.isServerSynced,
    );
  }

  Ticket copyWith({
    String? bookingCode,
    String? queueNumber,
    String? patientName,
    String? doctorName,
    String? specialty,
    String? clinic,
    String? clinicLocation,
    DateTime? scheduledDate,
    String? scheduledTime,
    int? estimatedMinutes,
    String? nowServingNumber,
    int? remainingQueue,
    TicketStatus? status,
    String? guarantor,
    String? patientRelation,
    String? medicalRecord,
    String? cancelNote,
    int? memberId,
    DateTime? checkInTime,
    DateTime? createdAt,
    bool? isServerSynced,
  }) {
    return Ticket(
      bookingCode: bookingCode ?? this.bookingCode,
      queueNumber: queueNumber ?? this.queueNumber,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      clinic: clinic ?? this.clinic,
      clinicLocation: clinicLocation ?? this.clinicLocation,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      nowServingNumber: nowServingNumber ?? this.nowServingNumber,
      remainingQueue: remainingQueue ?? this.remainingQueue,
      status: status ?? this.status,
      guarantor: guarantor ?? this.guarantor,
      patientRelation: patientRelation ?? this.patientRelation,
      medicalRecord: medicalRecord ?? this.medicalRecord,
      cancelNote: cancelNote ?? this.cancelNote,
      memberId: memberId ?? this.memberId,
      checkInTime: checkInTime ?? this.checkInTime,
      createdAt: createdAt ?? this.createdAt,
      isServerSynced: isServerSynced ?? this.isServerSynced,
    );
  }
}
