import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/features/support/data/datasources/feedback_remote_data_source.dart';
import 'package:sijapin_mobile/features/support/data/datasources/mcu_remote_data_source.dart';
import 'package:sijapin_mobile/features/support/domain/entities/mcu_catalog.dart';

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
        'data': <String, dynamic>{
          'selected_mcu_id': '',
          'paket': <Map<String, dynamic>>[
            <String, dynamic>{
              'tarif_id': '29950',
              'kode_tarif': '120053',
              'nama_paket': 'General Gold',
              'nama_tarif': 'General Gold',
              'harga': 0,
            },
          ],
          'detail': <Map<String, dynamic>>[],
        },
      };
      final packages = await ds.fetchPaketList();
      expect(mock.paths.single, equals(ApiConstants.mcuPaket));
      expect(
        mock.optionsSeen.single?.headers?['Accept'],
        equals('application/json'),
      );
      expect(packages.single.name, equals('General Gold'));
    });

    test('fetchPaketList memadukan detail ke paket per tarif_id_m (harga + rincian)', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Daftar paket MCU berhasil dimuat.',
        'data': <String, dynamic>{
          'selected_mcu_id': '',
          'paket': <Map<String, dynamic>>[
            <String, dynamic>{
              'tarif_id': '29950',
              'kode_tarif': '120053',
              'nama_paket': 'General Gold',
              'nama_tarif': 'General Gold',
              'harga': 0,
            },
            <String, dynamic>{
              'tarif_id': '56129',
              'kode_tarif': '12009444',
              'nama_paket': 'General Gold (Promo HUT 74)',
              'nama_tarif': 'General Gold (Promo HUT 74)',
              'harga': 0,
            },
          ],
          'detail': <Map<String, dynamic>>[
            <String, dynamic>{
              'tarif_id_m': '29950',
              'tarif_id': '30103',
              'nama_tarif': 'Pemeriksaan Fisik Dokter MCU',
              'harga': 797000,
            },
            <String, dynamic>{
              'tarif_id_m': '29950',
              'tarif_id': '30104',
              'nama_tarif': 'Laboratorium Darah Lengkap',
              'harga': 797000,
            },
          ],
        },
      };
      final packages = await ds.fetchPaketList();
      expect(packages, hasLength(2));
      expect(packages.first.name, equals('General Gold'));
      expect(packages.first.kodeTarif, equals('120053'));
      expect(packages.first.price, equals(797000));
      expect(
        packages.first.examinations.map((McuCatalogExamination e) => e.nama),
        containsAll(<String>[
          'Pemeriksaan Fisik Dokter MCU',
          'Laboratorium Darah Lengkap',
        ]),
      );
      expect(packages[1].name, equals('General Gold (Promo HUT 74)'));
      expect(packages[1].price, equals(0));
      expect(packages[1].examinations, isEmpty);
    });

    test(
      'fetchPaketList menerima data berbentuk daftar paket langsung',
      () async {
        mock.nextResponseData = <String, dynamic>{
          'status': 200,
          'success': true,
          'message': 'ok',
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'tarif_id': '29950',
              'kode_tarif': '120053',
              'nama_paket': 'General Gold',
              'harga': 1000,
            },
          ],
        };
        final packages = await ds.fetchPaketList();
        expect(packages, hasLength(1));
        expect(packages.single.name, equals('General Gold'));
        expect(packages.single.price, equals(1000));
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

    test(
      'fetchPatientList membuka bungkus data.member backend nyata',
      () async {
        mock.nextResponseData = <String, dynamic>{
          'status': 200,
          'success': true,
          'message': 'Data anggota pasien MCU berhasil dimuat',
          'data': <String, dynamic>{
            'member': <Map<String, dynamic>>[
              <String, dynamic>{
                'id_member': '1',
                'nomr': '00123456',
                'nama': 'Bambang Sutrisno',
                'nik': '3671010101900001',
              },
            ],
          },
        };
        final patients = await ds.fetchPatientList();
        expect(mock.paths.single, equals(ApiConstants.mcuPendaftaran));
        expect(
          mock.optionsSeen.single?.headers?['Accept'],
          equals('application/json'),
        );
        expect(patients, hasLength(1));
        expect(patients.single.idMember, equals('1'));
        expect(patients.single.nama, equals('Bambang Sutrisno'));
        expect(patients.single.nomr, equals('00123456'));
        expect(patients.single.nik, equals('3671010101900001'));
        expect(patients.single.isNewPatient, isFalse);
      },
    );

    test('fetchPatientList data.member kosong → daftar kosong', () async {
      mock.nextResponseData = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Daftar anggota keluarga MCU berhasil dimuat.',
        'data': <String, dynamic>{'member': <Map<String, dynamic>>[]},
      };
      expect(await ds.fetchPatientList(), isEmpty);
    });

    test(
      'fetchPatientList melempar message verbatim saat success:false',
      () async {
        mock.nextResponseData = <String, dynamic>{
          'status': 404,
          'success': false,
          'message': 'Pasien tidak ditemukan atau bukan milik akun Anda',
          'data': null,
          'errors': <String, dynamic>{'id_member': 'Pasien tidak ditemukan'},
        };
        expect(
          () => ds.fetchPatientList(),
          throwsA(
            isA<ApiException>().having(
              (ApiException e) => e.message,
              'message',
              'Pasien tidak ditemukan atau bukan milik akun Anda',
            ),
          ),
        );
      },
    );

    test('fetchPatientList HTML/non-JSON → daftar kosong', () async {
      mock.nextResponseData = '<html>bukan json</html>';
      expect(await ds.fetchPatientList(), isEmpty);
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
