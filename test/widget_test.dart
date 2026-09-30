import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/biometrics/biometric_auth_service.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/main.dart';

/// Fake penyimpanan aman in-memory agar tidak bergantung pada plugin native.
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

/// Fake biometrik: perangkat mendukung & autentikasi selalu sukses.
class _FakeBiometricAuth implements IBiometricAuth {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> authenticate({required String reason}) async => true;
}

void main() {
  testWidgets('SiijapinApp bootstrap smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(_FakeSecureStorage()),
          biometricAuthServiceProvider.overrideWithValue(_FakeBiometricAuth()),
        ],
        child: const SiijapinApp(),
      ),
    );

    expect(find.text(AppConfig.appName), findsOneWidget);
    expect(find.text('RSUP Dr. Sitanala Tangerang'), findsOneWidget);
    expect(find.text('Memuat aplikasi...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump();
    await tester.pump();

    // expect(find.text('Home'), findsOneWidget);
    expect(find.text('Layanan Poliklinik & Pasien'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Selamat Datang di SIIJAPIN'), findsOneWidget);
    expect(find.text('Selamat Datang di RSUP Dr. Sitanala'), findsOneWidget);
  });
}
