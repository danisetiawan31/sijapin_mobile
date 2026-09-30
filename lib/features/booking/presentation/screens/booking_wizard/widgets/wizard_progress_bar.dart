import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Indikator progress langkah wizard pendaftaran rawat jalan (4 langkah).
class WizardProgressBar extends StatelessWidget {
  const WizardProgressBar({
    super.key,
    required this.currentStep,
    required this.onStepTapped,
  });

  /// Indeks langkah aktif (0..3)
  final int currentStep;

  /// Callback saat indikator langkah ditekan
  final ValueChanged<int> onStepTapped;

  static const List<String> _stepTitles = <String>[
    'Pasien',
    'Poli & Tgl',
    'Dokter',
    'Konfirmasi',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDarkEspresso.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < _stepTitles.length; i++) ...[
            Expanded(
              child: _StepIndicatorItem(
                stepIndex: i,
                title: _stepTitles[i],
                isActive: i == currentStep,
                isCompleted: i < currentStep,
                onTap: () => onStepTapped(i),
              ),
            ),
            if (i < _stepTitles.length - 1)
              Container(
                width: 16,
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                color: i < currentStep
                    ? AppColors.brandGoldenCaramel
                    : AppColors.borderSubtle,
              ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicatorItem extends StatelessWidget {
  const _StepIndicatorItem({
    required this.stepIndex,
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.onTap,
  });

  final int stepIndex;
  final String title;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color textColor;
    final Widget iconOrNumber;

    if (isCompleted) {
      circleColor = AppColors.brandGoldenCaramel;
      textColor = AppColors.brandDarkEspresso;
      iconOrNumber = const Icon(
        Icons.check_rounded,
        size: 14,
        color: Colors.white,
      );
    } else if (isActive) {
      circleColor = AppColors.brandDarkEspresso;
      textColor = AppColors.brandDarkEspresso;
      iconOrNumber = Text(
        '${stepIndex + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    } else {
      circleColor = AppColors.borderSubtle;
      textColor = AppColors.textMuted;
      iconOrNumber = Text(
        '${stepIndex + 1}',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return GestureDetector(
      onTap: isCompleted ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.brandDarkEspresso.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(child: iconOrNumber),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive || isCompleted
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
