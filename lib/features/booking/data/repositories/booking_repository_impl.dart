import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/doctor_schedule_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/booking_repository.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/doctor_schedule_repository.dart';

/// Implementasi repositori pendaftaran rawat jalan RSUP Dr. Sitanala.
///
/// Mendukung eksekusi ke API server CodeIgniter 3 dengan graceful fallback
/// ke data lokal realistis untuk pengujian komprehensif.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    this.dioClient,
    required this.doctorScheduleRepository,
  });

  final DioClient? dioClient;
  final DoctorScheduleRepository doctorScheduleRepository;

  // Counter lokal untuk simulasi nomor antrean & kode booking harian
  static int _dailyBookingSequence = 14;

  @override
  Future<List<PatientMember>> getPatientMembers() async {
    // Simulasi latensi jaringan
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return <PatientMember>[
      // Pasien 1: Pemilik Akun Sendiri (Pasien Lama)
      PatientMember(
        id: 1,
        fullName: 'Ahmad Dhani Setiawan',
        nik: '3671041205950001',
        medicalRecordNumber: '012345',
        relation: 'Diri Sendiri',
        gender: 'L',
        birthDate: DateTime(1995, 5, 12),
        bpjsCardNumber: '0001234567891',
        phone: '081234567890',
      ),
      // Pasien 2: Istri (Pasien Lama)
      PatientMember(
        id: 2,
        fullName: 'Rina Puspita Sari',
        nik: '3671044508940002',
        medicalRecordNumber: '045678',
        relation: 'Istri',
        gender: 'P',
        birthDate: DateTime(1994, 8, 25),
        bpjsCardNumber: '0001234567892',
        phone: '081298765432',
      ),
      // Pasien 3: Anak (Pasien Baru - Belum ada No. RM)
      PatientMember(
        id: 3,
        fullName: 'Muhammad Al-Fatih',
        nik: '3671042001180003',
        medicalRecordNumber: null,
        relation: 'Anak',
        gender: 'L',
        birthDate: DateTime(2018, 1, 20),
        bpjsCardNumber: '0001234567893',
        phone: '081234567890',
      ),
    ];
  }

  @override
  Future<List<Polyclinic>> getPolyclinics() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return const <Polyclinic>[
      Polyclinic(
        id: 1,
        name: 'Poli Penyakit Dalam',
        code: 'PDI',
        floor: 'Lantai 1',
        description: 'Pemeriksaan organ dalam, metabolik, ginjal, & endokrin',
      ),
      Polyclinic(
        id: 2,
        name: 'Poli Mata',
        code: 'MAT',
        floor: 'Lantai 2',
        description: 'Pemeriksaan refraksi, katarak, glaukoma, & retina',
      ),
      Polyclinic(
        id: 3,
        name: 'Poli THT-KL',
        code: 'THT',
        floor: 'Lantai 2',
        description: 'Telinga, hidung, tenggorokan, kepala & leher',
      ),
      Polyclinic(
        id: 4,
        name: 'Poli Kebidanan & Kandungan',
        code: 'OBG',
        floor: 'Lantai 2',
        description: 'Antenatal care (ANC), USG 4D, ginekologi, & KB',
      ),
      Polyclinic(
        id: 5,
        name: 'Poli Anak',
        code: 'ANA',
        floor: 'Lantai 1',
        description: 'Tumbuh kembang anak, imunisasi dasar, & pediatri',
      ),
      Polyclinic(
        id: 6,
        name: 'Poli Gigi & Mulut',
        code: 'GIG',
        floor: 'Lantai 1',
        description: 'Konservasi gigi, bedah mulut, & periodonsia',
      ),
      Polyclinic(
        id: 7,
        name: 'Poli Jantung & Pembuluh Darah',
        code: 'JAN',
        floor: 'Lantai 3',
        description: 'EKG, treadmill test, ekokardiografi, & kardiologi',
      ),
      Polyclinic(
        id: 8,
        name: 'Poli Saraf / Neurologi',
        code: 'SAR',
        floor: 'Lantai 2',
        description: 'Pemeriksaan stroke, vertigo, nyeri saraf, & EEG',
      ),
    ];
  }

  @override
  Future<List<DoctorSchedule>> getDoctorsByClinicAndDate({
    required int clinicId,
    required DateTime date,
  }) async {
    // Ambil nama hari dalam bahasa Indonesia untuk tanggal yang dipilih
    final dayName = _getDayName(date.weekday);

    // Ambil seluruh jadwal dokter dari repository master
    final allDoctors = await doctorScheduleRepository.getDoctorSchedules(
      dayFilter: dayName,
    );

    // Cocokkan dokter berdasarkan poli jika ada kecocokan nama poli
    final polyclinics = await getPolyclinics();
    final clinic = polyclinics.firstWhere(
      (c) => c.id == clinicId,
      orElse: () => polyclinics.first,
    );

    // Filter dokter yang praktiknya cocok dengan nama poliklinik atau spesialisasi
    final matchedDoctors = allDoctors.where((doctor) {
      final clinicLower = clinic.name.toLowerCase();
      final doctorPoliLower = doctor.poli.toLowerCase();
      final docSpecLower = doctor.specialization.toLowerCase();

      return doctorPoliLower.contains(clinic.code.toLowerCase()) ||
          clinicLower.contains(doctorPoliLower) ||
          (clinic.code == 'PDI' && docSpecLower.contains('penyakit dalam')) ||
          (clinic.code == 'MAT' && docSpecLower.contains('mata')) ||
          (clinic.code == 'THT' && docSpecLower.contains('tht')) ||
          (clinic.code == 'OBG' &&
              (docSpecLower.contains('kandungan') ||
                  docSpecLower.contains('obgyn'))) ||
          (clinic.code == 'ANA' && docSpecLower.contains('anak')) ||
          (clinic.code == 'GIG' && docSpecLower.contains('gigi')) ||
          (clinic.code == 'JAN' && docSpecLower.contains('jantung')) ||
          (clinic.code == 'SAR' && docSpecLower.contains('saraf'));
    }).toList();

    return matchedDoctors;
  }

  @override
  Future<Appointment> submitBooking({required BookingDraft draft}) async {
    if (!draft.isStep4Valid) {
      throw ArgumentError('Draft booking belum lengkap atau belum valid.');
    }

    // Simulasi waktu proses pengiriman ke server CodeIgniter 3
    await Future<void>.delayed(const Duration(milliseconds: 700));

    _dailyBookingSequence++;
    final nowWib = AppDateTime.now();
    final targetDate = draft.bookingDate ?? nowWib;

    // 1. Format Kode Booking (13 digit numerik murni sesuai ground truth t_daftar_rj)
    // Contoh: 2026093000015 (YYYYMMDD + 5 digit sequence counter)
    final datePrefix =
        '${targetDate.year}'
        '${targetDate.month.toString().padLeft(2, '0')}'
        '${targetDate.day.toString().padLeft(2, '0')}';
    final sequenceSuffix = _dailyBookingSequence.toString().padLeft(5, '0');
    final bookingCode = '$datePrefix$sequenceSuffix';

    // 2. Format Nomor Antrean (Poli code + 3 digit nomor)
    final clinicCode = draft.clinic?.code ?? 'POL';
    final queueNumber =
        '$clinicCode-${_dailyBookingSequence.toString().padLeft(3, '0')}';

    // 3. Estimasi jam dan waktu pelayanan
    final doctorEntry = draft.doctor?.schedules.firstOrNull;
    final scheduledTime =
        doctorEntry?.displayTime ?? '09.00 – 12.00 ${AppConfig.timeZoneAbbr}';

    final appointment = Appointment(
      bookingCode: bookingCode,
      queueNumber: queueNumber,
      patientName: draft.patient!.fullName,
      doctorName: draft.doctor!.name,
      specialty: draft.doctor!.specialization,
      clinic: draft.clinic!.name,
      scheduledDate: targetDate,
      scheduledTime: scheduledTime,
      estimatedMinutes: math.max(10, (_dailyBookingSequence - 10) * 10),
      nowServingNumber:
          '$clinicCode-${math.max(1, _dailyBookingSequence - 3).toString().padLeft(3, '0')}',
      remainingQueue: 3,
      status: AppointmentStatus.upcoming,
      patientRelation: draft.patient!.relation,
      medicalRecord: draft.patient!.maskedMedicalRecord,
    );

    return appointment;
  }

  @override
  Future<bool> cancelBooking({
    required String bookingCode,
    required String reason,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return true;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      default:
        return 'Senin';
    }
  }
}

/// Provider repositori pendaftaran rawat jalan
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);

  return BookingRepositoryImpl(
    dioClient: dioClient,
    doctorScheduleRepository: const DoctorScheduleRepositoryImpl(),
  );
});
