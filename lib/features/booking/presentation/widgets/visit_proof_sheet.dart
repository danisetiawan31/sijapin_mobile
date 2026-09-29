import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Bukti kunjungan sebagai bottom sheet (Level 3 DESIGN.md).
///
/// Menampilkan kode booking, poli, dokter, jam, pasien, dan nomor rekam medis
/// tersamar yang dapat ditunjukkan di loket RSUP Dr. Sitanala.
class VisitProofSheet extends StatelessWidget {
  const VisitProofSheet({super.key, required this.appointment});

  final Appointment appointment;

  static Future<void> show(BuildContext context, Appointment appointment) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext _) => VisitProofSheet(appointment: appointment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isCompleted = appointment.isCompleted;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Bukti Kunjungan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.brandDarkEspresso,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isCompleted)
                  const AppBadge.success(label: 'Selesai', fontSize: 12)
                else
                  const AppBadge.danger(label: 'Dibatalkan', fontSize: 12),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.hariTanggalPanjang(appointment.scheduledDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brandCreamLinen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'KODE BOOKING',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.bookingCode,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.brandDarkEspresso,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProofRow(label: 'Poli', value: appointment.clinic),
                  _ProofRow(label: 'Dokter', value: appointment.doctorName),
                  _ProofRow(
                    label: 'Jam Kunjungan',
                    value: appointment.scheduledTime,
                  ),
                  _ProofRow(
                    label: 'Pasien',
                    value: appointment.patientRelation == null
                        ? appointment.patientName
                        : '${appointment.patientName} (${appointment.patientRelation})',
                  ),
                  if (appointment.medicalRecord != null)
                    _ProofRow(
                      label: 'No. Rekam Medis',
                      value: appointment.medicalRecord!,
                    ),
                ],
              ),
            ),
            if (appointment.cancelNote != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.cancelNote!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              isCompleted
                  ? 'Berkas ini dapat ditunjukkan di loket informasi RSUP Dr. Sitanala untuk keperluan administrasi.'
                  : 'Kunjungan ini dibatalkan sehingga tidak menghasilkan berkas kunjungan.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppSecondaryButton(
                label: 'Tutup',
                icon: Icons.close_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofRow extends StatelessWidget {
  const _ProofRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.brandDarkEspresso,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
