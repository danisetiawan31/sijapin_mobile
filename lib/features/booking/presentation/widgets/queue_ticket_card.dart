import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Tiket antrean digital ala kartu THB (§7.A dan §9.D DESIGN.md).
///
/// Susunan: nomor antrean besar di atas, detail dokter di tengah, QR check-in
/// di bawah, dipisah garis perforasi dengan takukan di tepi kiri dan kanan.
class QueueTicketCard extends StatelessWidget {
  const QueueTicketCard({
    super.key,
    required this.appointment,
    required this.isCancelling,
    required this.onCancel,
    required this.onOpenQr,
  });

  final Appointment appointment;
  final bool isCancelling;
  final VoidCallback onCancel;
  final VoidCallback onOpenQr;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TicketHeader(appointment: appointment),
          const _PerforatedDivider(),
          _TicketDetails(appointment: appointment),
          const _PerforatedDivider(),
          _TicketCheckIn(appointment: appointment),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: 'Buka Tiket QR',
                    icon: Icons.qr_code_2_rounded,
                    onPressed: onOpenQr,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: AppDangerButton(
                    label: 'Batal Janji Temu',
                    icon: Icons.close_rounded,
                    isLoading: isCancelling,
                    onPressed: appointment.canCancel ? onCancel : null,
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

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: AppColors.brandCreamLinen,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Poli',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppBadge.neutral(label: appointment.specialty),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              appointment.clinic,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.brandDarkEspresso,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormatter.hariTanggalPanjang(appointment.scheduledDate)} \u00b7 ${appointment.scheduledTime}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketDetails extends StatelessWidget {
  const _TicketDetails({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailRow(
            icon: Icons.medical_services_outlined,
            label: 'Dokter',
            value: appointment.doctorName,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Pasien',
            value: appointment.patientName,
          ),
          const Divider(height: 24, color: AppColors.borderSubtle),
          _QueueSummary(appointment: appointment),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Nomor antrean di kiri, estimasi pasien diperiksa di kanan.
class _QueueSummary extends StatelessWidget {
  const _QueueSummary({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nomor Antrean',
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
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Estimasi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${appointment.remainingQueue} pasien',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.brandDarkEspresso,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '~${appointment.estimatedMinutes} menit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.brandWarmBronze),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.brandDarkEspresso,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TicketCheckIn extends StatelessWidget {
  const _TicketCheckIn({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          Semantics(
            label: 'QR check-in janji temu',
            value: appointment.bookingCode,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: QrImageView(
                data: appointment.bookingCode,
                size: 132,
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
          const SizedBox(height: 12),
          Text(
            appointment.bookingCode,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.brandDarkEspresso,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
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
        ],
      ),
    );
  }
}

class _PerforatedDivider extends StatelessWidget {
  const _PerforatedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          const _Notch(),
          Expanded(child: CustomPaint(painter: _DashedLinePainter())),
          const _Notch(),
        ],
      ),
    );
  }
}

/// Takukan setengah lingkaran di tepi kartu agar tampak seperti tiket sobek.
class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.surfaceBg,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderSubtle
      ..strokeWidth = 1.4;
    const dash = 6.0;
    const gap = 5.0;
    final double y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
