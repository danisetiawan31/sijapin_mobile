import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/support/data/datasources/mcu_remote_data_source.dart';
import 'package:sijapin_mobile/features/support/domain/entities/mcu_patient.dart';
import 'package:sijapin_mobile/features/support/presentation/controllers/mcu_patient_controller.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/mcu_catalog_screen.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/mcu_patient_step_screen.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';

const _signedInUser = UserProfile(
  fullName: 'Rina Puspita Sari',
  email: 'rina.puspita@warga.go.id',
  phone: '081234567890',
);

class _TestSessionNotifier extends ActiveSessionUserNotifier {
  _TestSessionNotifier(this._user);

  final UserProfile? _user;

  @override
  UserProfile? build() => _user;
}

class _MockDioClient implements DioClient {
  final List<String> paths = <String>[];
  dynamic nextResponseData;
  Object? nextError;

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
    if (nextError != null) throw nextError!;
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
    if (nextError != null) throw nextError!;
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: nextResponseData as T?,
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _catalogEnvelope() {
  return <String, dynamic>{
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
          'tarif_id': '29940',
          'kode_tarif': '120043',
          'nama_paket': 'Office B',
          'nama_tarif': 'Office B',
          'harga': 0,
        },
        <String, dynamic>{
          'tarif_id': '54245',
          'kode_tarif': '120091',
          'nama_paket': 'Buku Kuning',
          'nama_tarif': 'Buku Kuning',
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
        <String, dynamic>{
          'tarif_id_m': '29940',
          'tarif_id': '29982',
          'nama_tarif': 'Review Dokter Spesialis Okupasi',
          'harga': 1092000,
        },
      ],
    },
  };
}

Widget _wrapWithRemote(
  Widget home, {
  Object? remoteData,
  Object? error,
  bool signedIn = true,
}) {
  final _MockDioClient mock = _MockDioClient()
    ..nextResponseData = remoteData
    ..nextError = error;
  return ProviderScope(
    overrides: [
      activeSessionUserProvider.overrideWith(
        () => _TestSessionNotifier(signedIn ? _signedInUser : null),
      ),
      mcuRemoteDataSourceProvider.overrideWithValue(
        McuRemoteDataSource(dioClient: mock),
      ),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: home),
  );
}

void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('McuCatalogScreen Widget Tests (Epic 08 US-SUP-01)', () {
    testWidgets('menampilkan seluruh paket asli dari REST (paket + detail)', (
      tester,
    ) async {
      _useTallScreen(tester);

      await tester.pumpWidget(
        _wrapWithRemote(
          const McuCatalogScreen(),
          remoteData: _catalogEnvelope(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Katalog Paket MCU'), findsOneWidget);
      expect(find.text('Panduan Persiapan Puasa'), findsOneWidget);
      expect(
        find.text('Pilihan Paket Pemeriksaan MCU Sitanala'),
        findsOneWidget,
      );

      expect(find.text('General Gold'), findsOneWidget);
      expect(find.text('Office B'), findsOneWidget);
      expect(find.text('Buku Kuning'), findsOneWidget);

      expect(find.text('Rp 797.000'), findsOneWidget);
      expect(find.text('Rp 1.092.000'), findsOneWidget);
      expect(find.text('Laboratorium Darah Lengkap'), findsOneWidget);
      expect(find.text('Review Dokter Spesialis Okupasi'), findsOneWidget);

      expect(find.text('Paket MCU Standar'), findsNothing);
      expect(find.text('Menampilkan contoh paket (offline)'), findsNothing);
    });

    testWidgets('menandai fallback offline ketika permintaan gagal', (
      tester,
    ) async {
      _useTallScreen(tester);

      await tester.pumpWidget(
        _wrapWithRemote(
          const McuCatalogScreen(),
          error: StateError('jaringan mati'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Menampilkan contoh paket (offline)'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Paket MCU Standar'), findsOneWidget);
    });

    testWidgets('pengguna login dengan 401 tidak diminta masuk lagi', (
      tester,
    ) async {
      _useTallScreen(tester);

      await tester.pumpWidget(
        _wrapWithRemote(
          const McuCatalogScreen(),
          error: DioException(
            requestOptions: RequestOptions(path: 'Pendaftaran_MCU_Paket'),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: 'Pendaftaran_MCU_Paket'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Masuk untuk melihat Katalog Paket MCU'), findsNothing);
      expect(find.text('Menampilkan contoh paket (offline)'), findsOneWidget);
      expect(find.text('Paket MCU Standar'), findsOneWidget);
    });

    testWidgets('tamu langsung melihat gerbang masuk tanpa request', (
      tester,
    ) async {
      _useTallScreen(tester);

      await tester.pumpWidget(
        _wrapWithRemote(
          const McuCatalogScreen(),
          remoteData: _catalogEnvelope(),
          signedIn: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Masuk untuk melihat Katalog Paket MCU'),
        findsOneWidget,
      );
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('General Gold'), findsNothing);
    });

    testWidgets('tapping Pilih Paket membuka Langkah 1 MCU (Pilih Pasien)', (
      tester,
    ) async {
      _useTallScreen(tester);

      final _MockDioClient mock = _MockDioClient()
        ..nextResponseData = _catalogEnvelope();
      final GoRouter router = GoRouter(
        initialLocation: AppRoutes.mcuCatalogPath,
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.mcuCatalogPath,
            name: AppRoutes.mcuCatalogName,
            builder: (context, state) => const McuCatalogScreen(),
          ),
          GoRoute(
            path: AppRoutes.mcuPatientStepPath,
            name: AppRoutes.mcuPatientStepName,
            builder: (context, state) => McuPatientStepScreen(
              selectedPackage: state.extra is McuPackageItem
                  ? state.extra as McuPackageItem
                  : null,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeSessionUserProvider.overrideWith(
              () => _TestSessionNotifier(_signedInUser),
            ),
            familyMemberRepositoryProvider.overrideWithValue(
              FamilyMemberRepositoryImpl(),
            ),
            mcuRemoteDataSourceProvider.overrideWithValue(
              McuRemoteDataSource(dioClient: mock),
            ),
            mcuPatientsProvider.overrideWith(
              (ref) => Future.value(const <McuPatient>[]),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pilih Paket').first);
      await tester.pumpAndSettle();

      expect(find.text('Pilih Pasien Berobat'), findsOneWidget);
      expect(find.textContaining('LANGKAH 1 DARI 3'), findsOneWidget);
      expect(find.text('Lanjut: Pilih Jadwal MCU'), findsOneWidget);
    });
  });
}
