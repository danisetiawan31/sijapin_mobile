import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Denyut antrean langsung (§9.E DESIGN.md).
///
/// Menampilkan nomor yang sedang dilayani, nomor Anda, sisa pasien, dan
/// estimasi waktu. Titik hijau berkedip lembut menandakan antrean berjalan.
class LiveQueuePulse extends StatefulWidget {
  const LiveQueuePulse({super.key, required this.appointment});

  final Appointment appointment;

  @override
  State<LiveQueuePulse> createState() => _LiveQueuePulseState();
}

class _LiveQueuePulseState extends State<LiveQueuePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appointment = widget.appointment;
    final double progress = 1 / (1 + appointment.remainingQueue);

    return AppCard(
      variant: AppCardVariant.outlined,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.successEmerald.withValues(
                        alpha: 0.4 + (0.6 * _controller.value),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sedang Dilayani: ${appointment.nowServingNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Anda',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appointment.queueNumber,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.brandDarkEspresso,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${appointment.remainingQueue} pasien lagi',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.brandDarkEspresso,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Estimasi ~${appointment.estimatedMinutes} menit',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _QueueProgress(progress: progress),
        ],
      ),
    );
  }
}

class _QueueProgress extends StatelessWidget {
  const _QueueProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.brandCreamLinen,
            borderRadius: BorderRadius.circular(9999),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: constraints.maxWidth * progress.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              color: AppColors.brandGoldenCaramel,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        );
      },
    );
  }
}
