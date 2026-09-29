import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Kartu riwayat kunjungan: status, kode booking, poli & dokter, pasien, dan
/// tautan cepat melihat bukti kunjungan.
class AppointmentHistoryCard extends StatelessWidget {
  const AppointmentHistoryCard({
    super.key,
    required this.appointment,
    required this.onViewProof,
  });

  final Appointment appointment;
  final VoidCallback onViewProof;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCompleted = appointment.isCompleted;
    final String dateLabel = DateFormatter.tanggalPendek(
      appointment.scheduledDate,
    );
    final String patientMeta = <String>[
      if (appointment.patientRelation != null) appointment.patientRelation!,
      if (appointment.medicalRecord != null) 'RM: ${appointment.medicalRecord}',
    ].join(' \u2022 ');

    return AppCard.outlined(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (isCompleted)
                const AppBadge.success(label: 'Selesai', fontSize: 12)
              else
                const AppBadge.danger(label: 'Dibatalkan', fontSize: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '\u2022 $dateLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            appointment.bookingCode,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.brandDarkEspresso,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${appointment.clinic} \u2022 ${appointment.doctorName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.brandDarkEspresso,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            patientMeta.isEmpty
                ? appointment.patientName
                : '${appointment.patientName} ($patientMeta)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (appointment.cancelNote != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: AppBadge.neutral(
                label: appointment.cancelNote!,
                icon: Icons.info_outline_rounded,
                fontSize: 12,
              ),
            ),
          ],
          if (isCompleted) ...[
            const SizedBox(height: 4),
            _ProofLink(onTap: onViewProof),
          ],
        ],
      ),
    );
  }
}

/// Tautan cepat "Lihat Bukti Kunjungan" dengan warna aksen karamel.
class _ProofLink extends StatelessWidget {
  const _ProofLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brandGoldenCaramel,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          minimumSize: const Size(48, 48),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lihat Bukti Kunjungan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
