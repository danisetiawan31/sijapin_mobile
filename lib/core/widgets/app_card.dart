import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppCardVariant { elevated, highlighted, outlined, filled }

/// Kartu Squircle berstandar resmi RSUP Dr. Sitanala (DESIGN.md §6 & §5).
///
/// Menyediakan sudut melengkung 20px (squircle), border halus, dan
/// bayangan hangat (*warm ambient shadow*).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 20.0,
    this.backgroundColor,
  });

  /// Factory untuk kartu berbayang hangat standar (Level 1)
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 20.0,
    this.backgroundColor,
  }) : variant = AppCardVariant.elevated;

  /// Factory untuk kartu aktif / antrean hari-H berbingkai emas (Level 2)
  const AppCard.highlighted({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 20.0,
    this.backgroundColor,
  }) : variant = AppCardVariant.highlighted;

  /// Factory untuk kartu flat dengan outline tipis tanpa bayangan (Level 0)
  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 20.0,
    this.backgroundColor,
  }) : variant = AppCardVariant.outlined;

  /// Factory untuk kartu berlatar krem lembut (Cream Linen Container)
  const AppCard.filled({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderRadius = 20.0,
    this.backgroundColor,
  }) : variant = AppCardVariant.filled;

  final Widget child;
  final AppCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Color cardBg;
    Border border;
    List<BoxShadow>? shadows;

    switch (variant) {
      case AppCardVariant.elevated:
        cardBg = backgroundColor ?? AppColors.surfaceCard;
        border = Border.all(color: AppColors.borderSubtle);
        shadows = [
          BoxShadow(
            color: AppColors.brandDarkEspresso.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;

      case AppCardVariant.highlighted:
        cardBg = backgroundColor ?? AppColors.surfaceCard;
        border = Border.all(color: AppColors.brandGoldenCaramel, width: 2);
        shadows = [
          BoxShadow(
            color: AppColors.brandGoldenCaramel.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ];
        break;

      case AppCardVariant.outlined:
        cardBg = backgroundColor ?? AppColors.surfaceCard;
        border = Border.all(color: AppColors.borderSubtle);
        shadows = null;
        break;

      case AppCardVariant.filled:
        cardBg = backgroundColor ?? AppColors.brandCreamLinen;
        border = Border.all(color: AppColors.borderSubtle);
        shadows = null;
        break;
    }

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: shadows,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
