import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage_service.dart';
import '../storage/storage_constants.dart';

/// State kode kunci (PIN) aplikasi — fallback saat biometrik gagal.
class PasscodeState {
  const PasscodeState({this.hasPasscode = false, this.initialized = false});

  /// Apakah user sudah membuat Kode Kunci (PIN).
  final bool hasPasscode;

  /// Menandai preferensi sudah dimuat dari penyimpanan aman.
  final bool initialized;

  PasscodeState copyWith({bool? hasPasscode, bool? initialized}) {
    return PasscodeState(
      hasPasscode: hasPasscode ?? this.hasPasscode,
      initialized: initialized ?? this.initialized,
    );
  }
}

/// Controller kode kunci (PIN): membuat, memverifikasi, dan menghapus.
class PasscodeController extends AsyncNotifier<PasscodeState> {
  static const int minLength = 4;
  static const int maxLength = 6;

  @override
  Future<PasscodeState> build() async {
    final ISecureStorage storage = ref.watch(secureStorageServiceProvider);
    final bool has = await storage.containsKey(
      key: StorageConstants.keyPasscodeHash,
    );
    return PasscodeState(hasPasscode: has, initialized: true);
  }

  /// Apakah user sudah memiliki kode kunci tersimpan.
  Future<bool> hasPasscode() async {
    final ISecureStorage storage = ref.read(secureStorageServiceProvider);
    return storage.containsKey(key: StorageConstants.keyPasscodeHash);
  }

  /// Membuat/mengubah kode kunci. Hanya angka 4-6 digit yang diterima.
  Future<bool> setPasscode(String pin) async {
    final String trimmed = pin.trim();
    if (!_isValidPin(trimmed)) return false;

    final ISecureStorage storage = ref.read(secureStorageServiceProvider);
    final String salt = _generateSalt();
    final String hash = _hashPin(trimmed, salt);

    await storage.write(key: StorageConstants.keyPasscodeSalt, value: salt);
    await storage.write(key: StorageConstants.keyPasscodeHash, value: hash);

    state = AsyncData(
      state.value?.copyWith(hasPasscode: true, initialized: true) ??
          const PasscodeState(hasPasscode: true, initialized: true),
    );
    return true;
  }

  /// Memverifikasi kode kunci. Mengembalikan `true` bila cocok.
  Future<bool> verifyPasscode(String pin) async {
    final ISecureStorage storage = ref.read(secureStorageServiceProvider);
    final String? salt = await storage.read(
      key: StorageConstants.keyPasscodeSalt,
    );
    final String? hash = await storage.read(
      key: StorageConstants.keyPasscodeHash,
    );
    if (salt == null || hash == null) return false;

    return _hashPin(pin.trim(), salt) == hash;
  }

  /// Menghapus kode kunci sehingga tidak lagi diminta saat masuk.
  Future<bool> disablePasscode() async {
    final ISecureStorage storage = ref.read(secureStorageServiceProvider);
    await storage.delete(key: StorageConstants.keyPasscodeSalt);
    await storage.delete(key: StorageConstants.keyPasscodeHash);

    state = AsyncData(
      state.value?.copyWith(hasPasscode: false, initialized: true) ??
          const PasscodeState(hasPasscode: false, initialized: true),
    );
    return true;
  }

  bool _isValidPin(String pin) {
    if (pin.length < minLength || pin.length > maxLength) return false;
    return RegExp(r'^[0-9]+$').hasMatch(pin);
  }

  String _generateSalt() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((int b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _hashPin(String pin, String saltHex) {
    final Digest digest = sha256.convert(utf8.encode('$saltHex:$pin'));
    return digest.toString();
  }
}

/// Provider controller kode kunci (PIN).
final passcodeControllerProvider =
    AsyncNotifierProvider<PasscodeController, PasscodeState>(
      PasscodeController.new,
    );

/// Preferensi Kode Kunci tersimpan (khusus baca storage). Dipakai splash untuk
/// menampilkan opsi fallback PIN tanpa memicu build controller yang lebih berat.
final passcodeEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    final ISecureStorage storage = ref.watch(secureStorageServiceProvider);
    return await storage.containsKey(key: StorageConstants.keyPasscodeHash);
  } catch (_) {
    return false;
  }
});
