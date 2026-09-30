import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Kontrak autentikasi biometrik perangkat (Sidik Jari / Face ID).
///
/// Dialog biometrik yang muncul sepenuhnya milik sistem operasi sehingga
/// tampilannya mengikuti native Android/iOS masing-masing perangkat.
abstract class IBiometricAuth {
  /// Menanyakan apakah perangkat mendukung & telah mendaftarkan biometrik.
  Future<bool> isAvailable();

  /// Memunculkan dialog biometrik sistem untuk autentikasi pengguna.
  Future<bool> authenticate({required String reason});
}

/// Implementasi biometrik menggunakan plugin `local_auth`.
class BiometricAuthService implements IBiometricAuth {
  BiometricAuthService([LocalAuthentication? auth])
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

/// Provider Riverpod untuk layanan biometrik.
final biometricAuthServiceProvider = Provider<IBiometricAuth>((ref) {
  return BiometricAuthService();
});
