import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Baris riwayat janji temu — hanya untuk dibaca, tanpa aksi.
class AppointmentHistoryCard extends StatelessWidget {
  const AppointmentHistoryCard({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCompleted = appointment.status == AppointmentStatus.completed;

    return AppCard.outlined(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_outline_rounded
                  : Icons.cancel_outlined,
              size: 22,
              color: isCompleted
                  ? AppColors.successEmerald
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormatter.tanggalPanjang(appointment.scheduledDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const AppBadge.success(label: 'Selesai')
                    else
                      const AppBadge.neutral(label: 'Dibatalkan'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.doctorName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.brandDarkEspresso,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${appointment.specialty} \u00b7 ${appointment.scheduledTime}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
