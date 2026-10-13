import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/booking_remote_data_source.dart';

class _MockDioClient implements DioClient {
  final List<Options?> seenOptions = [];
  dynamic nextResponseData;
  bool shouldThrowTransport = false;

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
    seenOptions.add(options);
    if (shouldThrowTransport) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionTimeout,
      );
    }
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
    seenOptions.add(options);
    if (shouldThrowTransport) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        type: DioExceptionType.connectionTimeout,
      );
    }
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
  group('BookingRemoteDataSource REST authority (PANDUAN §4–§5)', () {
    late _MockDioClient mock;
    late BookingRemoteDataSource ds;

    setUp(() {
      mock = _MockDioClient();
      ds = BookingRemoteDataSource(dioClient: mock);
    });

    test('wizard POST mengirim Accept: application/json', () async {
      mock.nextResponseData = <String, dynamic>{'ret': 'success', 'msg': 'ok'};
      await ds.submitPatientStep(<String, dynamic>{'nama_pasien': 'Tes'});
      expect(mock.seenOptions, isNotEmpty);
      expect(
        mock.seenOptions.last?.headers?['Accept'],
        equals('application/json'),
      );
    });

    test('insert final memakai envelope-aware flat success', () async {
      mock.nextResponseData = <String, dynamic>{
        'success': true,
        'message': 'Pendaftaran rawat jalan berhasil',
        'daftar_id': 12345,
        'kodebooking': '2026101500042',
        'kode_verifikasi': 'A1B2C3',
      };
      final result = await ds.insertDaftarRajal(<String, dynamic>{
        'member_id': '44411',
      });
      expect(result['success'], isTrue);
      expect(result['kodebooking'], equals('2026101500042'));
    });

    test('submit gagal definitif (ret:fail) dilempar verbatim', () async {
      mock.nextResponseData = <String, dynamic>{
        'ret': 'fail',
        'msg': 'Hak akses ditolak.',
      };
      expect(
        () => ds.submitPatientStep(<String, dynamic>{'id_member': '999999'}),
        throwsA(
          isA<BookingServerException>().having(
            (e) => e.message,
            'message',
            'Hak akses ditolak.',
          ),
        ),
      );
    });

    test('cekStatusQrcode memakai endpoint PANDUAN §5 + Accept JSON', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'ok',
        'data': <String, dynamic>{'dipanggil': true},
      };
      final calls = <String>[];
      final wrapped = _PathRecordingDioClient(mock, calls);
      final ds2 = BookingRemoteDataSource(dioClient: wrapped);
      final result = await ds2.cekStatusQrcode(
        tanggal: '15-10-2026',
        kodeVerifikasi: 'A1B2C3',
      );
      expect(calls.single, equals(ApiConstants.checkInCekStatus));
      expect(result['dipanggil'], isTrue);
    });

    test(
      'riwayat JSON: envelope data.riwayat diterjemahkan ke kontrak repo',
      () async {
        mock.nextResponseData = <String, dynamic>{
          'status': 200,
          'success': true,
          'message': 'Riwayat antrean berhasil dimuat.',
          'data': <String, dynamic>{
            'riwayat': <Map<String, dynamic>>[
              <String, dynamic>{
                'daftar': '2',
                'tipe_layanan': 'Rawat Jalan',
                'tgl_rencana_kunjungan': '15-10-2026',
                'tgl_rencana_kunjungan_raw': '15102026',
                'kode_verifikasi': 'A1B2C3',
                'mcu_id': '',
                'st_batal': '0',
                'is_batal': false,
              },
            ],
            'terakhir': <Map<String, dynamic>>[],
          },
        };
        final history = await ds.fetchBookingHistory();
        expect(history, hasLength(1));
        expect(history.first['verificationCode'], equals('A1B2C3'));
        expect(history.first['rawDate'], equals('15102026'));
        expect(history.first['daftarType'], equals('2'));
        expect(history.first['isCancelled'], isFalse);
      },
    );

    test('riwayat success:false dilempar (tanpa fallback scrape)', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 400,
        'success': false,
        'message': 'Sesi berakhir.',
      };
      expect(() => ds.fetchBookingHistory(), throwsA(isA<ApiException>()));
    });
  });
}

class _PathRecordingDioClient implements DioClient {
  final _MockDioClient inner;
  final List<String> calls;

  _PathRecordingDioClient(this.inner, this.calls);

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    calls.add(path);
    return inner.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    calls.add(path);
    return inner.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
