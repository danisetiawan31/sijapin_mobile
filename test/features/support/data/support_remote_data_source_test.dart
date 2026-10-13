import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/support/data/datasources/feedback_remote_data_source.dart';
import 'package:sijapin_mobile/features/support/data/datasources/mcu_remote_data_source.dart';

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
  group('McuRemoteDataSource REST authority (PANDUAN §6)', () {
    late _MockDioClient mock;
    late McuRemoteDataSource ds;

    setUp(() {
      mock = _MockDioClient();
      ds = McuRemoteDataSource(dioClient: mock);
    });

    test('fetchPaketList memakai path paket + Accept JSON', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'ok',
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'id': 1, 'nama_paket': 'Standar'},
        ],
      };
      final rows = await ds.fetchPaketList();
      expect(mock.paths.single, equals(ApiConstants.mcuPaket));
      expect(
        mock.optionsSeen.single?.headers?['Accept'],
        equals('application/json'),
      );
      expect(rows.single['nama_paket'], equals('Standar'));
    });

    test(
      'fetchPaketList membuka bungkus data.paket kunci backend nyata',
      () async {
        mock.nextResponseData = <String, dynamic>{
          'status': 200,
          'success': true,
          'message': 'Daftar paket MCU berhasil dimuat.',
          'data': <String, dynamic>{
            'selected_mcu_id': '120050',
            'paket': <Map<String, dynamic>>[
              <String, dynamic>{
                'tarif_id': '30055',
                'kode_tarif': '120050',
                'nama_paket': 'Standar',
                'nama_tarif': 'Paket MCU Standar',
                'harga': 180000,
              },
            ],
            'detail': <Map<String, dynamic>>[],
          },
        };
        final rows = await ds.fetchPaketList();
        expect(rows, hasLength(1));
        expect(rows.single['kode_tarif'], equals('120050'));
        expect(rows.single['nama_paket'], equals('Standar'));
        expect(rows.single['harga'], equals(180000));
      },
    );

    test('fetchPaketList HTML/non-JSON → daftar kosong', () async {
      mock.nextResponseData = '<html>bukan json</html>';
      expect(await ds.fetchPaketList(), isEmpty);
    });

    test('cekJadwal memakai FormData ke path cek_jadwal', () async {
      mock.nextResponseData = <String, dynamic>{
        'ret': 'success',
        'msg': 'Kuota tersedia.',
      };
      final result = await ds.cekJadwal(tanggal: '2026-10-20');
      expect(mock.paths.single, equals(ApiConstants.mcuCekJadwal));
      expect(result['ret'], equals('success'));
    });
  });

  group('FeedbackRemoteDataSource REST authority (PANDUAN §7)', () {
    late _MockDioClient mock;
    late FeedbackRemoteDataSource ds;

    setUp(() {
      mock = _MockDioClient();
      ds = FeedbackRemoteDataSource(dioClient: mock);
    });

    test('fetchPrefill memakai path prefill + Accept JSON', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'ok',
        'data': <String, dynamic>{'nama': 'Pasien', 'nomor_telepon': '0812'},
      };
      final prefill = await ds.fetchPrefill();
      expect(mock.paths.single, equals(ApiConstants.feedbackPrefill));
      expect(prefill['nama'], equals('Pasien'));
    });

    test('submitFeedback mengirim FormData + normalisasi ret/msg', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Saran tersimpan.',
        'data': null,
      };
      final result = await ds.submitFeedback(
        name: 'Pasien',
        phone: '0812',
        subject: 'Perihal',
        description: 'Deskripsi',
      );
      expect(mock.paths.single, equals(ApiConstants.submitFeedback));
      expect(result['ret'], equals('success'));
    });
  });
}
