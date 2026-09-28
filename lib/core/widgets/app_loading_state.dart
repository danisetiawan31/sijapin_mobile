import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../theme/app_colors.dart';

// ============================================================
// AppLoadingState — Shimmer Skeleton (Aturan 8: Zero Red-Screen)
// ============================================================

/// Tampilan loading standar menggunakan efek shimmer (skeletonizer).
///
/// Gunakan [AppLoadingState.list] untuk menampilkan placeholder list.
/// Gunakan [AppLoadingState.wrap] untuk membungkus widget nyata saat loading.
class AppLoadingState extends StatelessWidget {
  /// Mode: list placeholder card shimmer sebanyak [itemCount]
  const AppLoadingState.list({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  }) : _mode = _LoadingMode.list,
       child = null;

  /// Mode: membungkus widget [child] dengan efek skeleton
  const AppLoadingState.wrap({super.key, required Widget this.child})
    : _mode = _LoadingMode.wrap,
      itemCount = 5,
      itemHeight = 80;

  final _LoadingMode _mode;
  final int itemCount;
  final double itemHeight;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (_mode == _LoadingMode.wrap && child != null) {
      return Skeletonizer(child: child!);
    }

    // Mode list: placeholder cards shimmer
    return Skeletonizer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
        ),
      ),
    );
  }
}

enum _LoadingMode { list, wrap }
