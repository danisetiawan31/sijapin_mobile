import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/doctor_schedule_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';

class MockDioClient implements DioClient {
  final List<String> callPaths = [];
  final List<dynamic> callData = [];
  bool shouldThrow = false;

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    callPaths.add(path);
    callData.add(data);
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Network failure',
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: {'ret': 'success'} as T?,
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    callPaths.add(path);
    callData.add(queryParameters);
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Network failure',
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: {'ret': 'success'} as T?,
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSecureStorage implements ISecureStorage {
  final Map<String, String> values = {};

  @override
  Future<void> write({required String key, required String value}) async {
    values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => values[key];

  @override
  Future<void> delete({required String key}) async {
    values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    values.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      values.containsKey(key);
}

void main() {
  group('BookingRepositoryImpl Stateful Sequence Tests', () {
    late MockDioClient mockDio;
    late MockSecureStorage mockStorage;
    late BookingRepositoryImpl repository;

    final testPatient = PatientMember(
      id: 101,
      fullName: 'Ahmad Fauzi Rahman',
      nik: '3671041205950001',
      medicalRecordNumber: '012345',
      relation: 'Diri Sendiri',
      gender: 'L',
      birthDate: DateTime(1995, 5, 12),
      birthPlace: 'Tangerang',
      motherName: 'Siti Maryam',
      address: 'Jl. Daan Mogot KM 20',
      phone: '081234567890',
    );

    const testClinic = Polyclinic(
      id: 2,
      name: 'Poli Mata',
      code: 'MAT',
      floor: 'Lantai 2',
      description: 'Pemeriksaan mata',
    );

    const testDoctor = DoctorSchedule(
      id: 'doc-02',
      name: 'dr. Hendra Prasetyo, Sp.M.',
      specialization: 'Spesialis Mata',
      poli: 'Mata',
      schedules: [
        DoctorScheduleEntry(day: 'Rabu', startTime: '09.00', endTime: '12.00'),
      ],
      status: DoctorPracticeStatus.reguler,
    );

    setUp(() {
      mockDio = MockDioClient();
      mockStorage = MockSecureStorage();
      mockStorage.write(key: StorageConstants.keyCustomerId, value: 'cust-999');

      repository = BookingRepositoryImpl(
        dioClient: mockDio,
        secureStorage: mockStorage,
        doctorScheduleRepository: const DoctorScheduleRepositoryImpl(),
      );
    });

    test(
      'submitBooking mengeksekusi sekuens 4 langkah ke CodeIgniter 3',
      () async {
        final draft = BookingDraft(
          currentStep: 3,
          patient: testPatient,
          insuranceType: InsuranceType.bpjs,
          bpjsReferenceNumber: '0001R0010926P000123',
          clinic: testClinic,
          doctor: testDoctor,
          bookingDate: DateTime(2026, 10, 15),
          isAgreedToTerms: true,
        );

        final appointment = await repository.submitBooking(draft: draft);

        expect(appointment.patientName, equals('Ahmad Fauzi Rahman'));
        expect(appointment.doctorName, equals('dr. Hendra Prasetyo, Sp.M.'));
        expect(appointment.bookingCode, startsWith('20261015'));
        expect(appointment.queueNumber, startsWith('MAT-'));

        // Verifikasi 5 tahapan panggilan CI3 (termasuk session cleanup finish_daftar)
        expect(mockDio.callPaths.length, equals(5));
        expect(mockDio.callPaths[0], equals(ApiConstants.bookingInputPasien));
        expect(
          mockDio.callPaths[1],
          equals(ApiConstants.bookingInputKunjungan),
        );
        expect(
          mockDio.callPaths[2],
          equals(ApiConstants.bookingInputPembayaran),
        );
        expect(mockDio.callPaths[3], equals(ApiConstants.bookingInsertRajal));
        expect(mockDio.callPaths[4], equals(ApiConstants.bookingFinishDaftar));
        expect(appointment.isServerSynced, isTrue);

        // Verifikasi payload Step 1: Pasien
        final step1Data = mockDio.callData[0] as FormData;
        final step1Map = Map.fromEntries(step1Data.fields);
        expect(step1Map['id_member'], equals('101'));
        expect(step1Map['rd_nomr'], equals('1'));
        expect(step1Map['nama_pasien'], equals('Ahmad Fauzi Rahman'));

        // Verifikasi payload Step 2: Kunjungan
        final step2Data = mockDio.callData[1] as FormData;
        final step2Map = Map.fromEntries(step2Data.fields);
        expect(step2Map['poli_tujuan'], equals('2'));
        expect(step2Map['dokter_tujuan'], equals('doc-02'));
        expect(step2Map['tgl_kunjungan'], equals('15-10-2026'));

        // Verifikasi payload Step 3: Pembayaran
        final step3Data = mockDio.callData[2] as FormData;
        final step3Map = Map.fromEntries(step3Data.fields);
        expect(step3Map['cara_bayar'], equals('BPJS'));

        // Verifikasi payload Step 4: Final Insert
        final step4Data = mockDio.callData[3] as FormData;
        final step4Map = Map.fromEntries(step4Data.fields);
        expect(step4Map['member_id'], equals('101'));
        expect(step4Map['poli'], equals('2'));
        expect(step4Map['dokter'], equals('doc-02'));
        expect(step4Map['noKunjungan'], equals('0001R0010926P000123'));
        expect(step4Map['no_antrian'], startsWith('MAT-'));
        expect(step4Map['nomr'], equals('012345'));
        expect(step4Map['tgl_lahir'], equals('12-05-1995'));
        expect(appointment.memberId, equals(101));
      },
    );

    test(
      'submitBooking tetap menerbitkan tiket saat offline / gagal koneksi',
      () async {
        mockDio.shouldThrow = true;

        final draft = BookingDraft(
          currentStep: 3,
          patient: testPatient,
          insuranceType: InsuranceType.umum,
          clinic: testClinic,
          doctor: testDoctor,
          bookingDate: DateTime(2026, 10, 15),
          isAgreedToTerms: true,
        );

        final appointment = await repository.submitBooking(draft: draft);

        expect(appointment.patientName, equals('Ahmad Fauzi Rahman'));
        expect(appointment.queueNumber, startsWith('MAT-'));
        expect(appointment.memberId, equals(101));
        expect(appointment.isServerSynced, isFalse);
      },
    );

    test(
      'cancelBooking mengirim permintaan pembatalan ke Daftar_Log/daftar_batal',
      () async {
        final success = await repository.cancelBooking(
          bookingCode: '2026101500015',
          reason: 'Ada keperluan mendadak',
          memberId: 101,
          scheduledDate: DateTime(2026, 10, 15),
        );

        expect(success, isTrue);
        expect(mockDio.callPaths.length, equals(1));
        expect(mockDio.callPaths[0], equals(ApiConstants.bookingBatalAntrian));

        final formData = mockDio.callData[0] as FormData;
        final map = Map.fromEntries(formData.fields);
        expect(map['customer_id'], equals('cust-999'));
        expect(map['member_id'], equals('101'));
        expect(map['kodebooking'], equals('2026101500015'));
        expect(map['alasan'], equals('Ada keperluan mendadak'));
        expect(map['tanggal'], equals('15-10-2026'));
      },
    );
  });
}
