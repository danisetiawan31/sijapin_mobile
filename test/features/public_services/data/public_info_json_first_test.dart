import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/doctor_schedule_remote_data_source.dart';
import 'package:sijapin_mobile/features/public_services/data/datasources/bed_availability_remote_data_source.dart';

class _MockDioClient implements DioClient {
  final List<String> paths = [];
  final List<Options?> optionsSeen = [];
  dynamic nextResponseData;

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
    paths.add(path);
    optionsSeen.add(options);
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: nextResponseData as T?,
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
    paths.add(path);
    optionsSeen.add(options);
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: nextResponseData as T?,
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('BedAvailabilityRemoteDataSource JSON-first (PANDUAN §2)', () {
    late _MockDioClient mock;
    late BedAvailabilityRemoteDataSource ds;

    setUp(() {
      mock = _MockDioClient();
      ds = BedAvailabilityRemoteDataSource(dioClient: mock);
    });

    test('fetch memakai path PANDUAN + Accept JSON + envelope parse', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'ok',
        'data': <String, dynamic>{
          'kelas': <Map<String, dynamic>>[
            <String, dynamic>{
              'ruangan': 'Anak',
              'kelas': 'I',
              'total': '10',
              'terisi': '4',
              'tersedia': '6',
            },
          ],
        },
      };
      final summary = await ds.fetchBedAvailability();
      expect(mock.paths.single, equals(ApiConstants.bedAvailability));
      expect(
        mock.optionsSeen.single?.headers?['Accept'],
        equals('application/json'),
      );
      expect(summary, isNotNull);
      expect(summary!.wards, hasLength(1));
      expect(summary.availableBeds, equals(6));
    });
  });

  group('DoctorScheduleRemoteDataSource JSON-first (PANDUAN §2)', () {
    late _MockDioClient mock;
    late DoctorScheduleRemoteDataSource ds;

    setUp(() {
      mock = _MockDioClient();
      ds = DoctorScheduleRemoteDataSource(dioClient: mock);
    });

    test('fetchPolyclinics memakai path PANDUAN + Accept JSON', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'ok',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'UNIT_ID': 12, 'NAMA_UNIT': 'Saraf'},
        ],
      };
      final clinics = await ds.fetchPolyclinics();
      expect(mock.paths.single, equals(ApiConstants.doctorSchedule));
      expect(
        mock.optionsSeen.single?.headers?['Accept'],
        equals('application/json'),
      );
      expect(clinics, hasLength(1));
      expect(clinics.first.name, equals('Saraf'));
    });

    test(
      'fetchDoctorSchedules(unitId) memakai path cari + Accept JSON',
      () async {
        mock.nextResponseData = <String, dynamic>{
          'status': 200,
          'success': true,
          'message': 'ok',
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'NAMA_DOKTER': 'dr. Tes Sp.S',
              'SENIN': '08:00 - 12:00',
              'SELASA': 'LIBUR',
            },
          ],
        };
        final doctors = await ds.fetchDoctorSchedules(unitId: 12);
        expect(
          mock.paths.single,
          startsWith('${ApiConstants.doctorSchedule}/cari/12'),
        );
        expect(doctors, hasLength(1));
        expect(doctors.first.name, equals('dr. Tes Sp.S'));
      },
    );
  });
}
