import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Keterjangkauan server SIIJAPIN dari perangkat.
enum ServerStatus {
  /// Belum ada pemeriksaan (awal sesi).
  unknown,

  /// Server menjawab (respons HTTP apa pun, termasuk galat ber-body).
  online,

  /// Tanpa jaringan atau server tidak menjawab.
  offline,
}

/// Provider stream perubahan status konektivitas jaringan.
/// Event-driven (hemat baterai); aman di unit test tanpa platform binding.
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  try {
    WidgetsBinding.instance;
    return Connectivity().onConnectivityChanged;
  } catch (_) {
    // Pada lingkungan unit test tanpa platform binding, sediakan stream kosong aman
    return const Stream.empty();
  }
});

/// Pengamat keterjangkauan server secara realtime tanpa polling.
///
/// Probe hanya berjalan saat ada peristiwa konektivitas (debounce 10 detik):
/// nol biaya idle, nol timer periodik. Probe = satu GET ringan ke base URL;
/// respons HTTP apa pun berarti jalur ke server hidup (isi body dibuang,
/// tidak di-parse). Probe boleh tumpang-tindih; nomor generasi memastikan
/// hanya hasil terbaru yang diterima.
class ServerStatusController extends Notifier<ServerStatus> {
  static const Duration _minProbeInterval = Duration(seconds: 10);

  DateTime? _lastProbeAt;

  /// Generasi peristiwa: hasil probe basi (dari sebelum peristiwa
  /// konektivitas terbaru) dibuang agar tak menimpa state yang benar.
  /// Probe boleh tumpang-tindih (GET idempoten ringan); generasi yang
  /// memutuskan hasil mana yang diterima.
  int _generation = 0;

  @override
  ServerStatus build() {
    ref.listen<AsyncValue<List<ConnectivityResult>>>(
      connectivityStreamProvider,
      (
        AsyncValue<List<ConnectivityResult>>? previous,
        AsyncValue<List<ConnectivityResult>> next,
      ) {
        next.whenData(_onConnectivityEvent);
      },
    );
    unawaited(_probe());
    return ServerStatus.unknown;
  }

  void _onConnectivityEvent(List<ConnectivityResult> results) {
    _generation++;
    final bool hasNetwork = results.any(
      (ConnectivityResult result) => result != ConnectivityResult.none,
    );
    if (!hasNetwork) {
      state = ServerStatus.offline;
      return;
    }
    unawaited(_probe());
  }

  /// Pemeriksaan manual (tombol "Coba lagi"), mengabaikan debounce.
  Future<void> refresh() {
    _generation++;
    return _probe(force: true);
  }

  Future<void> _probe({bool force = false}) async {
    final DateTime now = DateTime.now();
    final DateTime? lastProbeAt = _lastProbeAt;
    if (!force &&
        lastProbeAt != null &&
        now.difference(lastProbeAt) < _minProbeInterval) {
      return;
    }
    final int generation = _generation;
    final bool reachable = await _checkReachable();
    if (!ref.mounted || generation != _generation) return;
    _lastProbeAt = DateTime.now();
    state = reachable ? ServerStatus.online : ServerStatus.offline;
  }

  Future<bool> _checkReachable() async {
    try {
      await ref.read(apiClientProvider).get<dynamic>('/');
      return true;
    } on DioException catch (e) {
      // Respons HTTP apa pun (termasuk envelope galat/HTML) = server hidup.
      return e.response != null;
    } catch (_) {
      return false;
    }
  }
}

final serverStatusProvider =
    NotifierProvider<ServerStatusController, ServerStatus>(
      ServerStatusController.new,
    );
