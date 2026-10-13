import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/api_client.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/features/auth/data/datasources/auth_rest_data_source.dart';

class MockApiClient implements ApiClient {
  String? lastPath;
  Object? lastData;
  Object? nextData;
  ApiException? definitiveError;
  DioException? transportError;

  @override
  Dio get dio => throw UnimplementedError();

  @override
  ISecureStorage get secureStorage => throw UnimplementedError();

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    final ApiException? definitive = definitiveError;
    if (definitive != null) {
      throw definitive;
    }
    final DioException? transport = transportError;
    if (transport != null) {
      throw transport;
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: nextData as T?,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    lastData = data;
    final ApiException? definitive = definitiveError;
    if (definitive != null) {
      throw definitive;
    }
    final DioException? transport = transportError;
    if (transport != null) {
      throw transport;
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: nextData as T?,
    );
  }
}

void main() {
  group('AuthRestDataSource', () {
    late MockApiClient apiClient;
    late AuthRestDataSource dataSource;

    setUp(() {
      apiClient = MockApiClient();
      dataSource = AuthRestDataSource(apiClient: apiClient);
    });

    test('loginRest posts form-encoded nomor_telepon/kunci', () async {
      apiClient.nextData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Login berhasil.',
        'data': <String, dynamic>{
          'token': 'tok-xyz',
          'token_type': 'Bearer',
          'expires_at': '2026-11-11T00:00:00+07:00',
        },
        'errors': null,
        'meta': <String, dynamic>{'version': '2.0'},
      };

      final Map<String, dynamic> payload = await dataSource.loginRest(
        phoneNumber: '0812000000',
        password: 'rahasia',
      );

      expect(apiClient.lastPath, ApiConstants.apiV1Login);
      // Backend CI3 hanya membaca $_POST: wajib FormData, bukan JSON.
      final Object? sent = apiClient.lastData;
      expect(sent, isA<FormData>());
      final Map<String, String> fields = <String, String>{
        for (final MapEntry<String, String> entry in (sent as FormData).fields)
          entry.key: entry.value,
      };
      expect(fields, <String, String>{
        'nomor_telepon': '0812000000',
        'kunci': 'rahasia',
      });
      expect(payload['token'], 'tok-xyz');
    });

    test('loginRest throws ApiException on malformed body', () async {
      apiClient.nextData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'OK',
        'data': null,
        'errors': null,
        'meta': null,
      };

      await expectLater(
        dataSource.loginRest(phoneNumber: '0812', password: 'x'),
        throwsA(isA<ApiException>()),
      );
    });

    test('logoutRest hits apiV1Logout and swallows transport errors', () async {
      apiClient.transportError = DioException(
        requestOptions: RequestOptions(path: ApiConstants.apiV1Logout),
        type: DioExceptionType.connectionError,
      );

      await dataSource.logoutRest();

      expect(apiClient.lastPath, ApiConstants.apiV1Logout);
    });

    test('fetchRestProfile returns data map with int id tolerated', () async {
      apiClient.nextData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Profil berhasil dimuat.',
        'data': <String, dynamic>{
          'id_customer': 163958,
          'nama': 'Ahmad Dani',
          'nomor_telepon': '0812000000',
          'email': 'ahmad@example.com',
          'tanggal_lahir': '1990-05-20',
          'jenis_kelamin': 'L',
          'alamat': 'Tangerang',
        },
        'errors': null,
        'meta': <String, dynamic>{'version': '2.0'},
      };

      final Map<String, dynamic> profile = await dataSource.fetchRestProfile();

      expect(apiClient.lastPath, ApiConstants.apiV1Profile);
      expect(profile['nama'], 'Ahmad Dani');
      expect(profile['id_customer'], 163958);
    });

    test('fetchRestProfile throws ApiException on malformed body', () async {
      apiClient.nextData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'OK',
        'data': null,
        'errors': null,
        'meta': null,
      };

      await expectLater(
        dataSource.fetchRestProfile(),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
