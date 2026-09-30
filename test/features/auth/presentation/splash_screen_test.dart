import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/biometrics/biometric_auth_service.dart';
import 'package:sijapin_mobile/core/passcode/passcode_controller.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/auth/presentation/screens/splash_screen.dart';

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

class _FakeBiometricAuth implements IBiometricAuth {
  _FakeBiometricAuth({required this.authenticateResult});

  bool authenticateResult;
  int authenticateCalls = 0;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate({required String reason}) async {
    authenticateCalls += 1;
    return authenticateResult;
  }
}

Future<void> _createPasscode(ProviderContainer container, String pin) async {
  await container.read(passcodeControllerProvider.notifier).setPasscode(pin);
}

Widget _buildApp(ProviderContainer container, GoRouter router) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(theme: AppTheme.lightTheme, routerConfig: router),
  );
}

void main() {
  late _FakeSecureStorage storage;
  late Map<String, String> store;
  late _FakeBiometricAuth fakeAuth;

  setUp(() {
    store = <String, String>{StorageConstants.keyBiometricEnabled: 'true'};
    fakeAuth = _FakeBiometricAuth(authenticateResult: false);
  });

  GoRouter buildRouter() {
    return GoRouter(
      initialLocation: AppRoutes.splashPath,
      routes: [
        GoRoute(
          path: AppRoutes.splashPath,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.homePath,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('HOME-TEST'))),
        ),
      ],
    );
  }

  /// Menekan tombol angka/keypad sesuai digit PIN, satu per satu.
  Future<void> tapDigits(WidgetTester tester, String pin) async {
    for (final String digit in pin.split('')) {
      await tester.tap(find.byKey(ValueKey('splash-pad-$digit')));
      await tester.pump();
    }
  }

  testWidgets(
    'biometrik ditolak sebelum passcode dibuat hanya menawarkan coba lagi',
    (tester) async {
      store.remove(StorageConstants.keyPasscodeHash);
      storage = _FakeSecureStorage(store);
      final container = ProviderContainer(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(storage),
          biometricAuthServiceProvider.overrideWithValue(fakeAuth),
        ],
      );
      addTearDown(container.dispose);
      final router = buildRouter();

      await tester.pumpWidget(_buildApp(container, router));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Autentikasi biometrik gagal atau dibatalkan'),
        findsOneWidget,
      );
      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.byKey(const ValueKey('splash-pad-1')), findsNothing);
    },
  );

  testWidgets('biometrik gagal lalu PIN benar membuka aplikasi', (
    tester,
  ) async {
    final setupContainer = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(
          _FakeSecureStorage(store),
        ),
      ],
    );
    addTearDown(setupContainer.dispose);
    await _createPasscode(setupContainer, '123456');

    storage = _FakeSecureStorage(store);
    final container = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(storage),
        biometricAuthServiceProvider.overrideWithValue(fakeAuth),
      ],
    );
    addTearDown(container.dispose);
    final router = buildRouter();

    await tester.pumpWidget(_buildApp(container, router));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    await tester.pump();

    // Biometrik ditolak -> keypad langsung tampil tanpa tap tambahan.
    expect(find.text('Masukkan Kode Kunci'), findsOneWidget);
    expect(find.byKey(const ValueKey('splash-pad-1')), findsOneWidget);

    await tapDigits(tester, '123456');
    await tester.pumpAndSettle();

    expect(find.text('HOME-TEST'), findsOneWidget);
    expect(fakeAuth.authenticateCalls, 1);
  });

  testWidgets('biometrik gagal lalu PIN salah menampilkan pesan error', (
    tester,
  ) async {
    final setupContainer = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(
          _FakeSecureStorage(store),
        ),
      ],
    );
    addTearDown(setupContainer.dispose);
    await _createPasscode(setupContainer, '123456');

    storage = _FakeSecureStorage(store);
    final container = ProviderContainer(
      overrides: [
        secureStorageServiceProvider.overrideWithValue(storage),
        biometricAuthServiceProvider.overrideWithValue(fakeAuth),
      ],
    );
    addTearDown(container.dispose);
    final router = buildRouter();

    await tester.pumpWidget(_buildApp(container, router));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    await tester.pump();

    await tapDigits(tester, '000000');
    await tester.pumpAndSettle();

    expect(find.text('Kode Kunci salah. Silakan coba lagi.'), findsOneWidget);
    expect(find.text('HOME-TEST'), findsNothing);
    expect(find.text('Gunakan biometrik'), findsOneWidget);
  });
}
