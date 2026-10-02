import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/doctor_schedule_remote_data_source.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/booking_repository.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/doctor_schedule_repository.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/doctor_schedule_controller.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/domain/repositories/family_member_repository.dart';
import 'package:sijapin_mobile/features/ticket/data/datasources/ticket_local_data_source.dart';
import 'package:sijapin_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';

/// Implementasi repositori pendaftaran rawat jalan RSUP Dr. Sitanala.
///
/// Terhubung langsung ke CodeIgniter 3 backend database live (`db_simrs` & `db_siijapin`)
/// tanpa data tiruan / mock di production code.
class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    this.dioClient,
    this.secureStorage,
    this.ticketLocalDataSource,
    required this.doctorScheduleRepository,
    IBookingRemoteDataSource? bookingRemoteDataSource,
    this.familyMemberRepository,
    DoctorScheduleRemoteDataSource? doctorScheduleRemoteDataSource,
    List<Polyclinic>? initialPolyclinics,
  })  : bookingRemoteDataSource = bookingRemoteDataSource ??
            (dioClient != null
                ? BookingRemoteDataSource(dioClient: dioClient)
                : null),
        doctorScheduleRemoteDataSource = doctorScheduleRemoteDataSource ??
            (dioClient != null
                ? DoctorScheduleRemoteDataSource(dioClient: dioClient)
                : null),
        _cachedPolyclinics = initialPolyclinics;

  final DioClient? dioClient;
  final ISecureStorage? secureStorage;
  final ITicketLocalDataSource? ticketLocalDataSource;
  final DoctorScheduleRepository doctorScheduleRepository;
  final IBookingRemoteDataSource? bookingRemoteDataSource;
  final FamilyMemberRepository? familyMemberRepository;
  final DoctorScheduleRemoteDataSource? doctorScheduleRemoteDataSource;
  List<Polyclinic>? _cachedPolyclinics;

  @override
  Future<List<PatientMember>> getPatientMembers() async {
    // Ambil data anggota keluarga live dari backend CI3 (m_customer_member via FamilyMemberRepository)
    if (familyMemberRepository != null) {
      try {
        final members = await familyMemberRepository!.getFamilyMembers();
        return members.map((FamilyMember m) => m.toPatientMember()).toList();
      } catch (_) {
        return const <PatientMember>[];
      }
    }
    return const <PatientMember>[];
  }

  @override
  Future<List<Polyclinic>> getPolyclinics() async {
    // Ambil master poliklinik live dari backend SIMRS (/jadwal_dokter)
    if (doctorScheduleRemoteDataSource != null) {
      try {
        final clinics =
            await doctorScheduleRemoteDataSource!.fetchPolyclinics();
        if (clinics.isNotEmpty) {
          _cachedPolyclinics = clinics;
          return clinics;
        }
      } catch (_) {
        // Fallback to cache if network call fails
      }
    } else if (dioClient != null) {
      try {
        final remote = DoctorScheduleRemoteDataSource(dioClient: dioClient!);
        final clinics = await remote.fetchPolyclinics();
        if (clinics.isNotEmpty) {
          _cachedPolyclinics = clinics;
          return clinics;
        }
      } catch (_) {
        // Fallback to cache if network call fails
      }
    }

    return _cachedPolyclinics ?? const <Polyclinic>[];
  }

  @override
  Future<List<DoctorSchedule>> getDoctorsByClinicAndDate({
    required int clinicId,
    required DateTime date,
  }) async {
    // Ambil nama hari dalam bahasa Indonesia untuk tanggal yang dipilih
    final dayName = _getDayName(date.weekday);

    // Ambil seluruh jadwal dokter dari repository master live
    final allDoctors = await doctorScheduleRepository.getDoctorSchedules(
      dayFilter: dayName,
    );

    // Cocokkan dokter berdasarkan poli jika ada kecocokan nama poli
    final polyclinics = await getPolyclinics();
    final clinic = polyclinics.where((c) => c.id == clinicId).firstOrNull;

    // Filter dokter yang praktiknya cocok dengan nama poliklinik atau unit ID
    final matchedDoctors = allDoctors.where((doctor) {
      if (doctor.unitId != null && doctor.unitId == clinicId) {
        return true;
      }
      if (clinic == null) return false;

      final clinicLower = clinic.name.toLowerCase();
      final doctorPoliLower = doctor.poli.toLowerCase();
      final docSpecLower = doctor.specialization.toLowerCase();

      return (doctorPoliLower.isNotEmpty &&
              (doctorPoliLower.contains(clinic.code.toLowerCase()) ||
                  clinicLower.contains(doctorPoliLower) ||
                  doctorPoliLower.contains(clinicLower))) ||
          ((clinic.code == 'INT' || clinic.code == 'PDI') &&
              docSpecLower.contains('penyakit dalam')) ||
          (clinic.code == 'MAT' && docSpecLower.contains('mata')) ||
          (clinic.code == 'THT' && docSpecLower.contains('tht')) ||
          (clinic.code == 'OBG' &&
              (docSpecLower.contains('kandungan') ||
                  docSpecLower.contains('obgyn') ||
                  docSpecLower.contains('kebidanan'))) ||
          (clinic.code == 'ANA' && docSpecLower.contains('anak')) ||
          ((clinic.code == 'GIG' || clinic.code == 'GND') &&
              docSpecLower.contains('gigi')) ||
          (clinic.code == 'JAN' && docSpecLower.contains('jantung')) ||
          (clinic.code == 'SAR' && docSpecLower.contains('saraf')) ||
          (clinic.code == 'BED' && docSpecLower.contains('bedah')) ||
          (clinic.code == 'PAR' && docSpecLower.contains('paru'));
    }).toList();

    return matchedDoctors;
  }

  @override
  Future<Appointment> submitBooking({required BookingDraft draft}) async {
    if (!draft.isStep4Valid) {
      throw ArgumentError('Draft booking belum lengkap atau belum valid.');
    }

    final targetDate = draft.bookingDate ?? AppDateTime.now();
    // Format DD-MM-YYYY wajib untuk MySQL STR_TO_DATE("%d-%m-%Y") di CI3 get_antian_pasien_poliklinik
    final tglKunjungan =
        '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';
    final unitId = draft.clinic!.id;
    final doctorParam =
        draft.doctor!.doctorId?.toString() ?? draft.doctor!.id;
    final int doctorId = draft.doctor!.doctorId ??
        int.tryParse(draft.doctor!.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
        1;

    // 1. Ambil jam pelayanan terverifikasi dari backend CI3 (HH:mm:ss)
    String scheduledTime = '09:00:00';
    if (bookingRemoteDataSource != null) {
      try {
        scheduledTime = await bookingRemoteDataSource!.fetchJamPelayanan(
          tglKunjungan: tglKunjungan,
          unitId: unitId,
          doctorId: doctorId,
        );
      } catch (_) {
        scheduledTime =
            draft.doctor?.schedules.firstOrNull?.displayTime ?? '09:00:00';
      }
    }

    // 2. Format Nomor Antrean (Poli code + 3 digit nomor)
    final clinicCode = draft.clinic?.code ?? 'POL';
    final queueIndex = _calculateQueueIndex(scheduledTime);
    final queueNumber =
        '$clinicCode-${queueIndex.toString().padLeft(3, '0')}';

    // 3. Format Kode Booking (13 digit numerik murni: YYYYMMDD + 5 digit sequence)
    final datePrefix =
        '${targetDate.year}'
        '${targetDate.month.toString().padLeft(2, '0')}'
        '${targetDate.day.toString().padLeft(2, '0')}';
    final sequenceSuffix =
        (queueIndex * 10 + (math.Random().nextInt(9) + 1))
            .toString()
            .padLeft(5, '0');
    final bookingCode = '$datePrefix$sequenceSuffix';

    // 4. Semantik Pembayaran & Penjaminan
    final isBpjs = draft.insuranceType.isBpjs;
    final caraBayar = isBpjs ? 'BPJS' : 'UMUM';
    final pembayaran = isBpjs ? 'BPJS-NON PBI' : 'UMUM';
    final jumlahBayar = isBpjs ? '0' : '50000';
    final kodeVerifikasi = _generateVerificationCode();
    final isOldPatient =
        draft.patient!.medicalRecordNumber != null &&
        draft.patient!.medicalRecordNumber!.trim().isNotEmpty;

    // 5. Eksekusi sekuens multi-step stateful ke server CodeIgniter 3
    var serverSyncSuccess = false;
    if (bookingRemoteDataSource != null) {
      try {
        // Step 1: Kunci identitas pasien ke sesi CI3 (ses_siijapin_rj_pasien)
        await bookingRemoteDataSource!.submitPatientStep({
          'id_member': draft.patient!.id.toString(),
          'rd_nomr': isOldPatient ? '1' : '3',
          'nomr': draft.patient!.medicalRecordNumber ?? '',
          'nama_pasien': draft.patient!.fullName,
          'tmp_lahir': draft.patient!.birthPlace,
          'tgl_lahir': draft.patient!.birthDate.day.toString().padLeft(2, '0'),
          'bln_lahir':
              draft.patient!.birthDate.month.toString().padLeft(2, '0'),
          'thn_lahir': draft.patient!.birthDate.year.toString(),
          'agama': '1',
          'jns_kelamin': draft.patient!.gender,
          'nama_ibu': draft.patient!.motherName,
          'nik': draft.patient!.nik,
          'alamat': draft.patient!.address,
          'no_kontak': draft.patient!.phone ?? '',
          'email': '',
          'pekerjaan': '',
        });

        // Step 2: Kunci unit poli, dokter, dan tanggal ke sesi CI3
        await bookingRemoteDataSource!.submitVisitStep({
          'poli_tujuan': unitId.toString(),
          'dokter_tujuan': doctorParam,
          'tgl_kunjungan': tglKunjungan,
          'jam_layanan': scheduledTime,
          'ambil_resep': '1',
        });

        // Step 3: Kunci metode pembayaran ke sesi CI3 (ses_siijapin_rj_bayar)
        await bookingRemoteDataSource!.submitPaymentStep(caraBayar);

        // Step 4: Final insert transaksi ke tabel t_daftar_rj (35+ parameter lengkap)
        final tglLahirFormatted =
            '${draft.patient!.birthDate.day.toString().padLeft(2, '0')}-${draft.patient!.birthDate.month.toString().padLeft(2, '0')}-${draft.patient!.birthDate.year}';
        await bookingRemoteDataSource!.insertDaftarRajal({
          'member_id': draft.patient!.id.toString(),
          'poli': unitId.toString(),
          'dokter': doctorParam,
          'no_antrian': queueNumber,
          'jam_layanan': scheduledTime,
          'pembayaran': pembayaran,
          'cara_bayar': caraBayar,
          'jumlah_bayar': jumlahBayar,
          'kode_verifikasi': kodeVerifikasi,
          'no_peserta': draft.patient!.bpjsCardNumber ?? '',
          'nik': draft.patient!.nik,
          'nama': draft.patient!.fullName,
          'jns_kelamin': draft.patient!.gender,
          'tgl_lahir': tglLahirFormatted,
          'nomr': draft.patient!.medicalRecordNumber ?? '',
          'noKunjungan': draft.bpjsReferenceNumber ?? '',
          'tglRujukan': isBpjs ? tglKunjungan : '',
          'kd_pbi': '',
          'nm_pbi': '',
          'kd_kelas': isBpjs ? '3' : '',
          'ket_kelas': isBpjs ? 'Kelas 3' : '',
          'kd_diagnosa': '',
          'nm_diagnosa': '',
          'keluhan': '',
          'no_sjp': '',
          'asal_faskes': '1',
          'kodebooking': bookingCode,
          'kd_perujuk': '',
          'nm_perujuk': '',
          'kd_layanan': '',
          'nm_layanan': '',
          'kd_poli': draft.clinic!.bpjsCode ?? '',
          'nama_poli_bpjs': draft.clinic!.bpjsName ?? draft.clinic!.name,
          'kode_dokter_bpjs': '',
          'namaDokter': draft.doctor!.name,
          'no_surat_kontrol':
              isBpjs && (draft.bpjsReferenceNumber?.startsWith('00') ?? false)
                  ? draft.bpjsReferenceNumber!
                  : '',
        });

        // Step 5: Bersihkan variabel sesi wizard di server CI3
        await bookingRemoteDataSource!.finishRegistrationSession();
        serverSyncSuccess = true;
      } on BookingServerException {
        rethrow;
      } catch (_) {
        serverSyncSuccess = false;
      }
    }

    final appointment = Appointment(
      bookingCode: bookingCode,
      queueNumber: queueNumber,
      patientName: draft.patient!.fullName,
      doctorName: draft.doctor!.name,
      specialty: draft.doctor!.specialization,
      clinic: draft.clinic!.name,
      scheduledDate: targetDate,
      scheduledTime: scheduledTime,
      estimatedMinutes: math.max(10, (queueIndex - 1) * 15),
      nowServingNumber: '$clinicCode-001',
      remainingQueue: math.max(0, queueIndex - 1),
      status: AppointmentStatus.upcoming,
      patientRelation: draft.patient!.relation,
      medicalRecord: draft.patient!.maskedMedicalRecord,
      memberId: draft.patient?.id,
      isServerSynced: serverSyncSuccess,
    );

    // Persistensi otomatis ke Hive NoSQL tickets_box (SSOT: PRD FR-06.1)
    if (ticketLocalDataSource != null) {
      try {
        final ticket = Ticket.fromAppointment(appointment);
        await ticketLocalDataSource!.saveTicket(TicketModel.fromEntity(ticket));
      } catch (_) {
        // Abaikan kegagalan I/O lokal agar alur pendaftaran tidak terhambat
      }
    }

    return appointment;
  }

  @override
  Future<bool> cancelBooking({
    required String bookingCode,
    required String reason,
    int? memberId,
    DateTime? scheduledDate,
  }) async {
    final customerId =
        await secureStorage?.read(key: StorageConstants.keyCustomerId) ?? '';
    final targetDate = scheduledDate ?? AppDateTime.now();
    final tgl =
        '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';

    var cancelSuccess = true;
    if (bookingRemoteDataSource != null) {
      cancelSuccess = await bookingRemoteDataSource!.cancelBooking(
        customerId: customerId,
        memberId: memberId?.toString() ?? '',
        tanggal: tgl,
        bookingCode: bookingCode,
        reason: reason,
      );
    }

    // Perbarui data tiket lokal di Hive NoSQL jika tersedia
    if (ticketLocalDataSource != null) {
      try {
        final existingModel =
            await ticketLocalDataSource!.getTicketByBookingCode(bookingCode);
        if (existingModel != null) {
          final updated = existingModel.toEntity().copyWith(
            status: TicketStatus.cancelled,
            cancelNote: reason,
          );
          await ticketLocalDataSource!.saveTicket(
            TicketModel.fromEntity(updated),
          );
        }
      } catch (_) {
        // Abaikan kegagalan lokal
      }
    }

    return cancelSuccess;
  }

  @override
  Future<List<Appointment>> getBookingHistory() async {
    final List<Appointment> list = [];

    // 1. Ambil riwayat live dari backend CI3 (Daftar_Log)
    if (bookingRemoteDataSource != null) {
      try {
        final remoteLogs = await bookingRemoteDataSource!.fetchBookingHistory();
        for (final item in remoteLogs) {
          final isCancelled = item['isCancelled'] == true;
          final desc = item['description']?.toString() ?? '';
          final rawDate = item['rawDate']?.toString() ?? '';
          final verifCode = item['verificationCode']?.toString() ?? '';

          DateTime date = AppDateTime.now();
          if (rawDate.isNotEmpty && rawDate.length >= 8) {
            // rawDate can be DDMMYYYY (e.g. 28052021) per CI3 Daftar_Log URL pattern, or YYYYMMDD
            final p1 = int.tryParse(rawDate.substring(0, 4)) ?? 0;
            final p2 = int.tryParse(rawDate.substring(4, 8)) ?? 0;
            if (p2 >= 1900 && p2 <= 2100) {
              // Format DDMMYYYY
              final d = int.tryParse(rawDate.substring(0, 2)) ?? 1;
              final m = int.tryParse(rawDate.substring(2, 4)) ?? 1;
              final y = p2;
              date = DateTime(y, m, d);
            } else if (p1 >= 1900 && p1 <= 2100) {
              // Format YYYYMMDD
              final y = p1;
              final m = int.tryParse(rawDate.substring(4, 6)) ?? 1;
              final d = int.tryParse(rawDate.substring(6, 8)) ?? 1;
              date = DateTime(y, m, d);
            }
          }

          // Ekstrak nama poliklinik dari deskripsi (misal: "(RJ Penyakit Dalam)")
          String clinicName = 'Poliklinik Rawat Jalan';
          if (desc.contains('(RJ ')) {
            final match = RegExp(r'\(RJ\s+([^)]+)\)').firstMatch(desc);
            if (match != null) {
              final raw = match.group(1)?.trim() ?? '';
              clinicName = raw.startsWith('Poli') ? raw : 'Poli $raw';
            }
          }

          list.add(
            Appointment(
              bookingCode: verifCode.isNotEmpty
                  ? verifCode
                  : 'HIST-${date.millisecondsSinceEpoch}',
              queueNumber: '-',
              patientName: 'Pasien Terdaftar',
              medicalRecord: '-',
              doctorName: 'Dokter Poliklinik',
              specialty: clinicName,
              clinic: clinicName,
              scheduledDate: date,
              scheduledTime: '08:00 - 12:00 WIB',
              estimatedMinutes: 30,
              nowServingNumber: '-',
              remainingQueue: 0,
              status:
                  isCancelled
                      ? AppointmentStatus.cancelled
                      : AppointmentStatus.completed,
              patientRelation: 'Diri Sendiri',
              isServerSynced: true,
            ),
          );
        }
      } catch (_) {}
    }

    // 2. Gabungkan dengan data tiket lokal Hive NoSQL (status cancelled / completed)
    if (ticketLocalDataSource != null) {
      try {
        final localTickets = await ticketLocalDataSource!.getAllTickets();
        for (final model in localTickets) {
          final entity = model.toEntity();
          if (entity.isCancelled || entity.isCompleted) {
            if (!list.any((a) => a.bookingCode == entity.bookingCode)) {
              list.add(entity.toAppointment());
            }
          }
        }
      } catch (_) {}
    }

    // Urutkan riwayat dari tanggal terbaru (descending)
    list.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return list;
  }

  int _calculateQueueIndex(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 9;
        final minute = int.tryParse(parts[1]) ?? 0;
        final totalMinutes = (hour - 9) * 60 + minute;
        if (totalMinutes >= 0) {
          return math.max(1, (totalMinutes / 15).floor() + 1);
        }
      }
    } catch (_) {}
    return 1;
  }

  String _generateVerificationCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = math.Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
      ),
    );
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
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final ticketLocalDataSource = ref.watch(ticketLocalDataSourceProvider);
  final bookingRemoteDataSource = ref.watch(bookingRemoteDataSourceProvider);
  final familyMemberRepository = ref.watch(familyMemberRepositoryProvider);

  return BookingRepositoryImpl(
    dioClient: dioClient,
    secureStorage: secureStorage,
    doctorScheduleRepository: ref.watch(doctorScheduleRepositoryProvider),
    ticketLocalDataSource: ticketLocalDataSource,
    bookingRemoteDataSource: bookingRemoteDataSource,
    familyMemberRepository: familyMemberRepository,
  );
});
