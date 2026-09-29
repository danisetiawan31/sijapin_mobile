import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Tampilan QR check-in layar penuh untuk discan di Kiosk APM.
class QrTicketDialog extends StatelessWidget {
  const QrTicketDialog({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tiket QR Check-in',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.brandDarkEspresso,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              appointment.patientName,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Semantics(
                label: 'QR check-in janji temu',
                value: appointment.bookingCode,
                child: QrImageView(
                  data: appointment.bookingCode,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.brandDarkEspresso,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              appointment.bookingCode,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.brandDarkEspresso,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tunjukkan kode ini di Kiosk APM untuk check-in',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandCreamLinen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _InfoRow(label: 'Pasien', value: appointment.patientName),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Nomor Antrean',
                    value: appointment.queueNumber,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Dokter', value: appointment.doctorName),
                  const SizedBox(height: 8),
                  _InfoRow(label: 'Poli', value: appointment.clinic),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Jadwal',
                    value:
                        '${DateFormatter.tanggalPanjang(appointment.scheduledDate)} \u00b7 ${appointment.scheduledTime}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
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
    );
  }
}
