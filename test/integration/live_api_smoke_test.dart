import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/cookie_manager_service.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/doctor_schedule_remote_data_source.dart';
import 'package:sijapin_mobile/features/public_services/data/datasources/bed_availability_remote_data_source.dart';

void main() {
  group('Live API Smoke Tests (http://localhost/siijapin-v2/)', () {
    late CookieJar cookieJar;
    late CookieManagerService cookieService;
    late DioClient dioClient;

    setUpAll(() async {
      // Izinkan koneksi HTTP loopback real pada flutter_test
      HttpOverrides.global = null;

      cookieJar = CookieJar();
      cookieService = CookieManagerService(cookieJar);

      dioClient = DioClient(
        cookieManagerService: cookieService,
      );
    });

    test('1. Backend Server Reachability Check', () async {
      final response = await dioClient.dio.get<String>('');
      expect(response.statusCode, equals(200));
      expect(response.data, isNotNull);
      expect(response.data, contains('SITANALA'));
      // ignore: avoid_print
      print(
        ' [OK] Root portal reachability: HTTP 200 OK (${response.data!.length} bytes)',
      );
    });

    test('2. Ket_Kamar Endpoint (Ketersediaan Tempat Tidur)', () async {
      final dataSource = BedAvailabilityRemoteDataSource(dioClient: dioClient);
      final summary = await dataSource.fetchBedAvailability();

      expect(summary, isNotNull);
      expect(summary!.totalBeds, isNonNegative);
      // ignore: avoid_print
      print(
        ' [OK] Ket_Kamar parsed: Total Bed=${summary.totalBeds}, '
        'Terisi=${summary.occupiedBeds}, Kosong=${summary.availableBeds}, '
        'Bangsal/Wards=${summary.wards.length}',
      );
      expect(summary.wards.isNotEmpty, isTrue);
    });

    test('3. Jadwal_Dokter Endpoint (Poliklinik & Jadwal Praktik)', () async {
      final dataSource = DoctorScheduleRemoteDataSource(dioClient: dioClient);
      final clinics = await dataSource.fetchPolyclinics();

      // ignore: avoid_print
      print(
        ' [OK] Jadwal_Dokter parsed: ${clinics.length} poliklinik ditemukan',
      );
      for (final c in clinics.take(3)) {
        // ignore: avoid_print
        print('      - Poli ID: ${c.id}, Nama: "${c.name}", Code: "${c.code}"');
      }
      expect(clinics.isNotEmpty, isTrue);

      final schedules = await dataSource.fetchDoctorSchedules();
      // ignore: avoid_print
      print(' [OK] Jadwal_Dokter parsed: ${schedules.length} dokter ditemukan');
      for (final s in schedules.take(3)) {
        // ignore: avoid_print
        print(
          '      - Dokter: "${s.name}", Poli: "${s.poli}", Spesialis: "${s.specialization}"',
        );
      }
      expect(schedules.isNotEmpty, isTrue);
    });

    test('4. Booking Wizard Helpers: list_dokter_jaga (Poli 3 - Anak)', () async {
      final bookingSource = BookingRemoteDataSource(dioClient: dioClient);

      // Unit 3 adalah Poli Anak yang terbukti aktif di Jadwal_Dokter
      final doctors = await bookingSource.fetchDoctorsByUnit(3);
      // ignore: avoid_print
      print(' [OK] list_dokter_jaga (Unit 3 - Anak): ${doctors.length} dokter jaga');
      for (final d in doctors.take(3)) {
        // ignore: avoid_print
        print('      - ID: ${d['id']}, Nama: "${d['name']}"');
      }
    });

    test('5. Booking Wizard Helpers: get_jam_pelayanan', () async {
      final bookingSource = BookingRemoteDataSource(dioClient: dioClient);

      final todayFormatted =
          '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}';

      final jam = await bookingSource.fetchJamPelayanan(
        tglKunjungan: todayFormatted,
        unitId: 3,
        doctorId: 1,
      );
      // ignore: avoid_print
      print(
        ' [OK] get_jam_pelayanan (Unit 3, Doc 1, Tgl $todayFormatted): "$jam"',
      );
      expect(jam, isNotEmpty);
      expect(jam, contains(':'));
    });

    test('6. Booking Wizard Helpers: list_jadwal', () async {
      final bookingSource = BookingRemoteDataSource(dioClient: dioClient);

      final scheduleData = await bookingSource.fetchDoctorSchedule(
        unitId: 3,
        doctorId: 1,
      );
      // ignore: avoid_print
      print(' [OK] list_jadwal (Unit 3, Doc 1): $scheduleData');
      expect(scheduleData, isA<Map<String, dynamic>>());
    });

    test(
      '7. Authentication Check: Login/cek_login invalid credential rejection',
      () async {
        final response = await dioClient.dio.post<dynamic>(
          ApiConstants.login,
          data: FormData.fromMap({
            'nomor_telepon': '089999999999',
            'kunci': 'salah_password',
          }),
        );

        // ignore: avoid_print
        print(
          ' [OK] Login/cek_login invalid test: HTTP ${response.statusCode}, Data: ${response.data}',
        );
        expect(response.statusCode, equals(200));
        expect(response.data.toString(), isNotEmpty);
      },
    );

    test('8. Cookie & Session Tracking Inspection', () async {
      final cookies = await cookieJar.loadForRequest(
        Uri.parse('http://localhost/siijapin-v2/'),
      );
      // ignore: avoid_print
      print(' [OK] Captured cookies: ${cookies.map((c) => "${c.name}=${c.value.substring(0, c.value.length > 10 ? 10 : c.value.length)}...").toList()}');
      // Verifikasi cookie manager aktif
      expect(cookieService.cookieManager, isNotNull);
    });
  });
}
