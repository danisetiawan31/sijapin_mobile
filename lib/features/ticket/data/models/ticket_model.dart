import '../../domain/entities/ticket.dart';

/// Data Transfer Object (DTO) untuk serialisasi dan persistensi tiket di Hive NoSQL
class TicketModel {
  const TicketModel({
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
    required this.status,
    required this.clinicLocation,
    required this.guarantor,
    this.patientRelation,
    this.medicalRecord,
    this.cancelNote,
    this.memberId,
    this.checkInTime,
    this.createdAt,
    this.isServerSynced = true,
  });

  final String bookingCode;
  final String queueNumber;
  final String patientName;
  final String doctorName;
  final String specialty;
  final String clinic;
  final String clinicLocation;
  final DateTime scheduledDate;
  final String scheduledTime;
  final int estimatedMinutes;
  final String nowServingNumber;
  final int remainingQueue;
  final String status;
  final String guarantor;
  final String? patientRelation;
  final String? medicalRecord;
  final String? cancelNote;
  final int? memberId;
  final DateTime? checkInTime;
  final DateTime? createdAt;
  final bool isServerSynced;

  /// Konversi dari entitas domain ke model persistensi
  factory TicketModel.fromEntity(Ticket entity) {
    return TicketModel(
      bookingCode: entity.bookingCode,
      queueNumber: entity.queueNumber,
      patientName: entity.patientName,
      doctorName: entity.doctorName,
      specialty: entity.specialty,
      clinic: entity.clinic,
      clinicLocation: entity.clinicLocation,
      scheduledDate: entity.scheduledDate,
      scheduledTime: entity.scheduledTime,
      estimatedMinutes: entity.estimatedMinutes,
      nowServingNumber: entity.nowServingNumber,
      remainingQueue: entity.remainingQueue,
      status: entity.status.name,
      guarantor: entity.guarantor,
      patientRelation: entity.patientRelation,
      medicalRecord: entity.medicalRecord,
      cancelNote: entity.cancelNote,
      memberId: entity.memberId,
      checkInTime: entity.checkInTime,
      createdAt: entity.createdAt,
      isServerSynced: entity.isServerSynced,
    );
  }

  /// Konversi dari model persistensi ke entitas domain
  Ticket toEntity() {
    TicketStatus ticketStatus;
    try {
      ticketStatus = TicketStatus.values.byName(status);
    } catch (_) {
      ticketStatus = TicketStatus.upcoming;
    }

    return Ticket(
      bookingCode: bookingCode,
      queueNumber: queueNumber,
      patientName: patientName,
      doctorName: doctorName,
      specialty: specialty,
      clinic: clinic,
      clinicLocation: clinicLocation,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      estimatedMinutes: estimatedMinutes,
      nowServingNumber: nowServingNumber,
      remainingQueue: remainingQueue,
      status: ticketStatus,
      guarantor: guarantor,
      patientRelation: patientRelation,
      medicalRecord: medicalRecord,
      cancelNote: cancelNote,
      memberId: memberId,
      checkInTime: checkInTime,
      createdAt: createdAt,
      isServerSynced: isServerSynced,
    );
  }

  /// Serialisasi ke Map untuk disimpan di Hive box
  Map<String, dynamic> toMap() {
    return {
      'bookingCode': bookingCode,
      'queueNumber': queueNumber,
      'patientName': patientName,
      'doctorName': doctorName,
      'specialty': specialty,
      'clinic': clinic,
      'clinicLocation': clinicLocation,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime,
      'estimatedMinutes': estimatedMinutes,
      'nowServingNumber': nowServingNumber,
      'remainingQueue': remainingQueue,
      'status': status,
      'guarantor': guarantor,
      'patientRelation': patientRelation,
      'medicalRecord': medicalRecord,
      'cancelNote': cancelNote,
      'memberId': memberId,
      'checkInTime': checkInTime?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'isServerSynced': isServerSynced,
    };
  }

  /// Deserialisasi dari Map Hive
  factory TicketModel.fromMap(Map<dynamic, dynamic> map) {
    return TicketModel(
      bookingCode: map['bookingCode'] as String? ?? '',
      queueNumber: map['queueNumber'] as String? ?? '',
      patientName: map['patientName'] as String? ?? '',
      doctorName: map['doctorName'] as String? ?? '',
      specialty: map['specialty'] as String? ?? '',
      clinic: map['clinic'] as String? ?? '',
      clinicLocation:
          map['clinicLocation'] as String? ?? 'Lantai 2 - Gedung Rawat Jalan',
      scheduledDate:
          DateTime.tryParse(map['scheduledDate'] as String? ?? '') ??
          DateTime.now(),
      scheduledTime: map['scheduledTime'] as String? ?? '',
      estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 0,
      nowServingNumber: map['nowServingNumber'] as String? ?? '',
      remainingQueue: (map['remainingQueue'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? TicketStatus.upcoming.name,
      guarantor: map['guarantor'] as String? ?? 'BPJS Kesehatan',
      patientRelation: map['patientRelation'] as String?,
      medicalRecord: map['medicalRecord'] as String?,
      cancelNote: map['cancelNote'] as String?,
      memberId: (map['memberId'] as num?)?.toInt(),
      checkInTime: map['checkInTime'] != null
          ? DateTime.tryParse(map['checkInTime'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      isServerSynced: map['isServerSynced'] as bool? ?? true,
    );
  }
}
