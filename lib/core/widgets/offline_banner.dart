import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/server_status_controller.dart';
import '../theme/app_colors.dart';

/// Strip status keterjangkauan server (R-31: menandai state nyata, bukan
/// dekorasi). Hanya tampil saat [ServerStatus.offline]; tombol "Coba lagi"
/// memicu probe ulang.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ServerStatus status = ref.watch(serverStatusProvider);
    if (status != ServerStatus.offline) {
      return const SizedBox.shrink();
    }
    return Semantics(
      liveRegion: true,
      label: 'Tidak dapat menjangkau server rumah sakit',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: AppColors.dangerContainer,
          border: Border(
            bottom: BorderSide(color: AppColors.dangerBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 18,
              color: AppColors.dangerCrimson,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Tidak dapat menjangkau server. Periksa koneksi internet Anda.',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dangerCrimson,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                unawaited(ref.read(serverStatusProvider.notifier).refresh());
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.dangerCrimson,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(48, 36),
              ),
              child: const Text(
                'Coba lagi',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
