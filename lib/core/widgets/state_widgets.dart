import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_button.dart';

// ============================================================
// AppErrorState — Pesan Error Humanis + Tombol Retry
// ============================================================

/// Tampilan state error yang ramah pengguna (termasuk lansia).
/// Mematuhi Aturan 8 (Zero Red-Screen Policy) AGENTS.md.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Terjadi Kendala Koneksi',
    this.message =
        'Gagal memuat data. Periksa koneksi internet Anda dan coba lagi.',
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
    this.retryLabel = 'Coba Lagi',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.dangerCrimson.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.dangerCrimson),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppPrimaryButton(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
                width: 160,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// AppEmptyState — Ilustrasi Data Kosong yang Tenang
// ============================================================

/// Tampilan state kosong yang menenangkan pasien.
/// Mematuhi Aturan 8 (Zero Red-Screen Policy) AGENTS.md.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    this.title = 'Belum Ada Data',
    this.message = 'Data yang Anda cari belum tersedia saat ini.',
    this.icon = Icons.inbox_rounded,
    this.actionButton,
  });

  final String title;
  final String message;
  final IconData icon;

  /// Widget tombol aksi opsional (misal "Daftar Sekarang")
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.brandSoftSand.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: AppColors.brandGoldenCaramel),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
