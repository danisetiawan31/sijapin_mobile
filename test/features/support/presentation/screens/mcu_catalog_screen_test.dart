import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/support/data/datasources/mcu_remote_data_source.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/mcu_catalog_screen.dart';

class _MockDioClient implements DioClient {
  final List<String> paths = <String>[];
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

Widget _wrapWithRemote(Widget home, Object? remoteData) {
  final _MockDioClient mock = _MockDioClient()..nextResponseData = remoteData;
  return ProviderScope(
    overrides: [
      mcuRemoteDataSourceProvider.overrideWithValue(
        McuRemoteDataSource(dioClient: mock),
      ),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: home),
  );
}

void main() {
  group('McuCatalogScreen Widget Tests (Epic 08 US-SUP-01)', () {
    testWidgets(
      'renders MCU catalog screen with packages and fasting guide banner',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const McuCatalogScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Memeriksa judul AppBar
        expect(find.text('Katalog Paket MCU'), findsOneWidget);

        // Memeriksa Banner Panduan Puasa (US-SUP-01)
        expect(find.text('Panduan Persiapan Puasa'), findsOneWidget);
        expect(find.textContaining('Wajib berpuasa 10–12 jam'), findsOneWidget);

        // Memeriksa judul seksi paket
        expect(
          find.text('Pilihan Paket Pemeriksaan MCU Sitanala'),
          findsOneWidget,
        );

        // Memeriksa keberadaan nama-nama paket MCU riil Sitanala
        expect(find.text('Paket MCU Standar'), findsOneWidget);
        expect(find.text('Paket Bebas Narkoba & MMPI'), findsOneWidget);
        expect(find.text('Paket MCU Komprehensif'), findsOneWidget);
        expect(find.text('Paket Psikologi & Konseling'), findsOneWidget);

        // Memeriksa tombol aksi pemilihan paket
        expect(find.text('Pilih Paket'), findsWidgets);
      },
    );

    testWidgets('tapping Pilih Paket triggers snackbar selection message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const McuCatalogScreen()),
      );
      await tester.pumpAndSettle();

      final firstSelectButton = find.text('Pilih Paket').first;
      await tester.tap(firstSelectButton);
      await tester.pump();

      expect(
        find.textContaining('Paket MCU Standar (Kode: 120050) dipilih'),
        findsOneWidget,
      );
    });

    testWidgets(
      'remote polos memperbarui kartu tanpa menghilangkan rincian tindakan',
      (tester) async {
        tester.view.physicalSize = const Size(800, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapWithRemote(const McuCatalogScreen(), <String, dynamic>{
            'status': 200,
            'success': true,
            'message': 'Katalog paket MCU berhasil dimuat',
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'tarif_id': '120050',
                'kode_tarif': '120050',
                'nama_paket': 'Paket MCU Standar',
                'nama_tarif': 'Paket MCU Standar',
                'harga': 200000,
                'deskripsi': 'Deskripsi remote',
              },
            ],
          }),
        );
        await tester.pumpAndSettle();

        expect(find.text('Deskripsi remote'), findsOneWidget);
        expect(find.text('Rp 200.000'), findsOneWidget);
        expect(find.text('Rp 180.000'), findsNothing);
        expect(find.text('Laboratorium Darah Lengkap'), findsWidgets);
        expect(find.text('Paket Psikologi & Konseling'), findsOneWidget);
        expect(find.text('Rincian Tindakan Pemeriksaan:'), findsNWidgets(4));
      },
    );

    testWidgets(
      'paket remote baru tanpa rincian tidak menampilkan seksi kosong',
      (tester) async {
        tester.view.physicalSize = const Size(800, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrapWithRemote(const McuCatalogScreen(), <String, dynamic>{
            'status': 200,
            'success': true,
            'message': 'Katalog paket MCU berhasil dimuat',
            'data': <Map<String, dynamic>>[
              <String, dynamic>{
                'id': '99',
                'nama_paket': 'Paket Uji Coba',
                'tarif': 50000,
                'deskripsi': 'Deskripsi uji coba',
              },
            ],
          }),
        );
        await tester.pumpAndSettle();

        expect(find.text('Paket Uji Coba'), findsOneWidget);
        expect(find.text('Kode Tarif: 99'), findsOneWidget);
        expect(find.text('Rp 50.000'), findsOneWidget);
        expect(find.text('Deskripsi uji coba'), findsOneWidget);
        expect(find.text('Rincian Tindakan Pemeriksaan:'), findsNWidgets(4));
      },
    );
  });
}
