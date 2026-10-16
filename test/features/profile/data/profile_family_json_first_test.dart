import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/profile/data/datasources/profile_remote_data_source.dart';

import '../../../fixtures/mock_family_members.dart';

class _MockDioClient implements DioClient {
  final List<String> paths = [];
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
  group('ProfileRemoteDataSource family REST authority (PANDUAN §3)', () {
    late _MockDioClient mock;
    late ProfileRemoteDataSource ds;

    setUp(() {
      mock = _MockDioClient();
      ds = ProfileRemoteDataSource(dioClient: mock);
    });

    test('fetchFamilyMembers memakai GET Daftar_Kunj_Raja dulu', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'ok',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id_member': '44411',
            'nama': 'Anak Pasien',
            'nik': '3671012345678901',
            'nomr': '718893',
          },
        ],
      };
      final members = await ds.fetchFamilyMembers();
      expect(mock.paths.first, equals(ApiConstants.listPasien));
      expect(members, hasLength(1));
      expect(members!.first.fullName, equals('Anak Pasien'));
      expect(members.first.medicalRecordNumber, equals('718893'));
    });

    test('saveFamilyMember JSON envelope dinormalisasi ke ret/msg', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Pasien tersimpan.',
        'data': null,
      };
      final result = await ds.saveFamilyMember(kMockFamilyMembers.first);
      expect(mock.paths.single, equals(ApiConstants.inputPasien));
      expect(result['ret'], equals('success'));
      expect(result['msg'], equals('Pasien tersimpan.'));
    });
  });
}
