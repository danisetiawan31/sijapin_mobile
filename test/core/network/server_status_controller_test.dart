import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/api_client.dart';
import 'package:sijapin_mobile/core/network/server_status_controller.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';

class _FakeSecureStorage implements ISecureStorage {
  final Map<String, String> _store = <String, String>{};

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

class _MutableStub {
  _MutableStub({this.refuse = false});

  bool refuse;
}

Dio _stubDio(_MutableStub stub) {
  final Dio dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        if (stub.refuse) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
            true,
          );
          return;
        }
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: '<html>login</html>',
          ),
          true,
        );
      },
    ),
  );
  return dio;
}

ProviderContainer _container(
  _MutableStub stub,
  List<ConnectivityResult> event,
) {
  return ProviderContainer(
    overrides: [
      apiClientProvider.overrideWithValue(
        ApiClient(secureStorage: _FakeSecureStorage(), dio: _stubDio(stub)),
      ),
      connectivityStreamProvider.overrideWith(
        (Ref ref) => Stream<List<ConnectivityResult>>.value(event),
      ),
    ],
  );
}

Future<void> _settle() {
  return Future<void>.delayed(const Duration(milliseconds: 100));
}

Future<void> _readAndSettle(ProviderContainer container) async {
  container.read(serverStatusProvider);
  container.listen<ServerStatus>(serverStatusProvider, (a, b) {});
  await _settle();
}

void main() {
  group('ServerStatusController', () {
    test('offline when interface reports none', () async {
      final ProviderContainer container = _container(
        _MutableStub(),
        const <ConnectivityResult>[ConnectivityResult.none],
      );
      addTearDown(container.dispose);
      await _readAndSettle(container);

      expect(container.read(serverStatusProvider), ServerStatus.offline);
    });

    test('online when network up and server answers', () async {
      final ProviderContainer container = _container(
        _MutableStub(),
        const <ConnectivityResult>[ConnectivityResult.wifi],
      );
      addTearDown(container.dispose);
      await _readAndSettle(container);

      expect(container.read(serverStatusProvider), ServerStatus.online);
    });

    test('offline when network up but server refuses', () async {
      final ProviderContainer container = _container(
        _MutableStub(refuse: true),
        const <ConnectivityResult>[ConnectivityResult.wifi],
      );
      addTearDown(container.dispose);
      await _readAndSettle(container);

      expect(container.read(serverStatusProvider), ServerStatus.offline);
    });

    test('refresh forces re-probe past debounce', () async {
      final _MutableStub stub = _MutableStub();
      final ProviderContainer container = _container(
        stub,
        const <ConnectivityResult>[ConnectivityResult.wifi],
      );
      addTearDown(container.dispose);
      await _readAndSettle(container);
      expect(container.read(serverStatusProvider), ServerStatus.online);

      stub.refuse = true;
      await container.read(serverStatusProvider.notifier).refresh();

      expect(container.read(serverStatusProvider), ServerStatus.offline);
    });
  });
}
