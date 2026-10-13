import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/auth/data/datasources/auth_remote_data_source.dart';

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
  group('AuthRemoteDataSource register REST authority (PANDUAN §1)', () {
    late _MockDioClient mock;
    late AuthRemoteDataSource ds;

    setUp(() {
      mock = _MockDioClient();
      ds = AuthRemoteDataSource(dioClient: mock);
    });

    Future<Map<String, dynamic>> doRegister() => ds.register(
      fullName: 'Pasien Tes',
      phoneNumber: '081234567890',
      email: 'pasien@tes.id',
      birthDate: DateTime(1990, 5, 17),
      gender: 'L',
      password: 'Rahasia123!',
    );

    test('register memakai path PANDUAN + Accept: application/json', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Pendaftaran berhasil.',
        'data': null,
      };
      final result = await doRegister();
      expect(mock.paths.single, equals(ApiConstants.register));
      expect(
        mock.optionsSeen.single?.headers?['Accept'],
        equals('application/json'),
      );
      expect(result['ret'], equals('success'));
      expect(result['msg'], equals('Pendaftaran berhasil.'));
    });

    test(
      'jawaban definitif gagal dilempar verbatim (tanpa fallback)',
      () async {
        mock.nextResponseData = <String, dynamic>{
          'status': 400,
          'success': false,
          'message': 'Nomor telepon sudah terdaftar.',
        };
        expect(() => doRegister(), throwsA(isA<ApiException>()));
        expect(mock.paths, hasLength(1));
      },
    );
  });
}
