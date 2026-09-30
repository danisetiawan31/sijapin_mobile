import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage_service.dart';
import '../storage/storage_constants.dart';
import 'biometric_auth_service.dart';

/// State kunci biometrik aplikasi (Sidik Jari / Face ID).
class BiometricState {
  const BiometricState({
    this.enabled = false,
    this.available = false,
    this.initialized = false,
  });

  /// Apakah kunci biometrik sedang aktif dan akan ditanyakan saat splash.
  final bool enabled;

  /// Apakah perangkat mendukung & memiliki biometrik terdaftar.
  final bool available;

  /// Tandai bahwa preferensi sudah dimuat dari penyimpanan aman.
  final bool initialized;

  BiometricState copyWith({bool? enabled, bool? available, bool? initialized}) {
    return BiometricState(
      enabled: enabled ?? this.enabled,
      available: available ?? this.available,
      initialized: initialized ?? this.initialized,
    );
  }
}

/// Publisher helper untuk membaca preferensi dari secure storage.
final biometricControllerProvider =
    AsyncNotifierProvider<BiometricController, BiometricState>(
      BiometricController.new,
    );

/// Preferensi Kunci Biometrik tersimpan (khusus baca storage, tanpa panggilan
/// plugin biometrik). Dipakai splash untuk memutuskan meminta autentikasi
/// tanpa memicu build controller yang lebih berat.
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    final storage = ref.watch(secureStorageServiceProvider);
    final String? stored = await storage.read(
      key: StorageConstants.keyBiometricEnabled,
    );
    return stored == 'true';
  } catch (_) {
    return false;
  }
});

/// Controller layanan biometrik: memuat preferensi, mengaktifkan/menonaktifkan
/// kunci biometrik dengan konfirmasi biometrik sistem.
class BiometricController extends AsyncNotifier<BiometricState> {
  @override
  Future<BiometricState> build() async {
    final storage = ref.watch(secureStorageServiceProvider);
    final IBiometricAuth auth = ref.watch(biometricAuthServiceProvider);

    final bool available = await auth.isAvailable();
    final String? stored = await storage.read(
      key: StorageConstants.keyBiometricEnabled,
    );

    return BiometricState(
      enabled: stored == 'true',
      available: available,
      initialized: true,
    );
  }

  /// Preferensi biometrik yang tersimpan (aman dibaca kapan pun).
  Future<bool> isEnabled() async {
    final storage = ref.read(secureStorageServiceProvider);
    final String? stored = await storage.read(
      key: StorageConstants.keyBiometricEnabled,
    );
    return stored == 'true';
  }

  /// Menyalakan kunci biometrik. User wajib autentikasi biometrik sistem
  /// terlebih dahulu; bila gagal/batal, preferensi tetap nonaktif.
  Future<bool> enableWithAuthentication() async {
    final IBiometricAuth auth = ref.read(biometricAuthServiceProvider);
    final bool ok = await auth.authenticate(
      reason:
          'Konfirmasi Sidik Jari / Face ID untuk mengaktifkan Kunci Biometrik',
    );
    if (!ok) return false;

    await _persist(true);
    state = AsyncData(state.value?.copyWith(enabled: true) ?? _enabledState());
    return true;
  }

  /// Mematikan kunci biometrik tanpa konfirmasi ulang.
  Future<bool> disable() async {
    await _persist(false);
    state = AsyncData(
      state.value?.copyWith(enabled: false) ?? _disabledState(),
    );
    return true;
  }

  Future<void> _persist(bool value) async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.write(
      key: StorageConstants.keyBiometricEnabled,
      value: '$value',
    );
  }

  BiometricState _enabledState() =>
      const BiometricState(enabled: true, initialized: true);

  BiometricState _disabledState() =>
      const BiometricState(enabled: false, initialized: true);
}
