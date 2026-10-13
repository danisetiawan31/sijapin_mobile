import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage_service.dart';
import '../storage/storage_constants.dart';

/// Sinyal sesi Bearer kedaluwarsa untuk router (aturan global PANDUAN §1:
/// 401 JSON → hapus token → layar login). Interceptor 401 ([ApiClient])
/// tidak boleh mengimpor feature (pelanggaran lapis), maka ia hanya
/// memanggil [handleSessionExpired] di sini; router mengamati notifier.
final sessionExpiryNotifierProvider = Provider<ValueNotifier<bool>>((ref) {
  return ValueNotifier<bool>(false);
});

/// Dipanggil tepat sekali per sinyal 401: hapus token tersimpan lalu
/// kibarkan sinyal agar router mengarah ke login. Aman dipanggil ulang.
Future<void> handleSessionExpired(Ref ref) async {
  try {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.delete(key: StorageConstants.keyBearerToken);
    await storage.delete(key: StorageConstants.keyBearerExpiresAt);
  } catch (_) {
    // Penyimpanan gagal: sinyal navigasi tetap dikibarkan di bawah.
  }
  ref.read(sessionExpiryNotifierProvider).value = true;
}

/// Menurunkan sinyal (dipakai setelah redirect login / login sukses).
void clearSessionExpired(Ref ref) {
  ref.read(sessionExpiryNotifierProvider).value = false;
}
