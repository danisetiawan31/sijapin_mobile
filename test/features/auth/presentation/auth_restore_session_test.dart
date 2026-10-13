import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/api_client.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';

class _FakeSecureStorage implements ISecureStorage {
  _FakeSecureStorage(this._store);

  final Map<String, String> _store;

  @override
  Future<void> write({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _store.containsKey(key);
}

class _FakeApiClient implements ApiClient {
  _FakeApiClient(this.nextData);

  Object? nextData;

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
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: nextData as T?,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, dynamic> _profileEnvelope() => <String, dynamic>{
  'status': 200,
  'success': true,
  'message': 'Profil berhasil dimuat.',
  'data': <String, dynamic>{
    'id_customer': 163958,
    'nama': 'Pasien Setup Runner',
    'nomor_telepon': '081299990001',
    'email': 'runner@sitanala.id',
    'tanggal_lahir': '17-05-1990',
    'jenis_kelamin': 'L',
    'alamat': 'Jl. Dr. Sitanala No. 99, Tangerang',
  },
};

void main() {
  group('AuthController.restoreSession (spesifikasi §2)', () {
    test('tanpa token tersimpan → false', () async {
      final container = ProviderContainer(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(
            _FakeSecureStorage(<String, String>{}),
          ),
        ],
      );
      addTearDown(container.dispose);

      final bool ok = await container
          .read(authControllerProvider.notifier)
          .restoreSession();
      expect(ok, isFalse);
      expect(container.read(activeSessionUserProvider), isNull);
    });

    test('token kedaluwarsa → false + token dihapus', () async {
      final store = <String, String>{
        StorageConstants.keyBearerToken: 'tua',
        StorageConstants.keyBearerExpiresAt: '2020-01-01 00:00:00',
      };
      final container = ProviderContainer(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(
            _FakeSecureStorage(store),
          ),
        ],
      );
      addTearDown(container.dispose);

      final bool ok = await container
          .read(authControllerProvider.notifier)
          .restoreSession();
      expect(ok, isFalse);
      expect(store.containsKey(StorageConstants.keyBearerToken), isFalse);
    });

    test('token valid + profil ok → true + sesi terisi data server', () async {
      final store = <String, String>{
        StorageConstants.keyBearerToken: 'segar',
        StorageConstants.keyBearerExpiresAt: '2099-01-01 00:00:00',
      };
      final container = ProviderContainer(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(
            _FakeSecureStorage(store),
          ),
          apiClientProvider.overrideWithValue(
            _FakeApiClient(_profileEnvelope()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final bool ok = await container
          .read(authControllerProvider.notifier)
          .restoreSession();
      expect(ok, isTrue);
      final user = container.read(activeSessionUserProvider);
      expect(user?.fullName, equals('Pasien Setup Runner'));
      expect(user?.phone, equals('081299990001'));
      expect(user?.birthDate, equals(DateTime(1990, 5, 17)));
    });

    test('token valid + profil hampa → false', () async {
      final store = <String, String>{
        StorageConstants.keyBearerToken: 'segar',
        StorageConstants.keyBearerExpiresAt: '2099-01-01 00:00:00',
      };
      final container = ProviderContainer(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(
            _FakeSecureStorage(store),
          ),
          apiClientProvider.overrideWithValue(
            _FakeApiClient(<String, dynamic>{
              'status': 200,
              'success': true,
              'message': 'ok',
              'data': <String, dynamic>{'nama': '', 'nomor_telepon': ''},
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      final bool ok = await container
          .read(authControllerProvider.notifier)
          .restoreSession();
      expect(ok, isFalse);
    });
  });
}
