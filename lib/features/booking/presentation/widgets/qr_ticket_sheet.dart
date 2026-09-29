import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/pulse_dot.dart';

/// Bottom sheet kode QR Anjungan Mandiri untuk discan di mesin APM.
class QrTicketSheet extends StatelessWidget {
  const QrTicketSheet({super.key, required this.appointment});

  final Appointment appointment;

  static Future<void> show(BuildContext context, Appointment appointment) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.brandDarkEspresso.withValues(alpha: 0.5),
      builder: (BuildContext _) => QrTicketSheet(appointment: appointment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successEmerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: AppColors.successEmerald.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PulseDot(color: AppColors.successEmerald, size: 8),
                      Flexible(
                        child: Text(
                          'Siap Scan di Mesin APM',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kode QR Anjungan Mandiri',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.brandDarkEspresso,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tunjukkan QR code ini ke optical scanner mesin APM di lobi '
                'lantai 1.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _QrFrame(bookingCode: appointment.bookingCode),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandCreamLinen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Antrean Poli:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        '${appointment.queueNumber} (${appointment.doctorName})',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Tutup Tiket',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bingkai putus-putus berisi QR check-in dan kode booking.
class _QrFrame extends StatelessWidget {
  const _QrFrame({required this.bookingCode});

  final String bookingCode;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedBorderPainter(
        color: AppColors.brandSoftSand,
        strokeWidth: 2,
        radius: 16,
      ),
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'QR check-in janji temu',
              value: bookingCode,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: bookingCode,
                  size: 180,
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
              bookingCode,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Menggaris putus-putus mengikuti keliling persegi dengan sudut membulat.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const double dash = 7;
    const double gap = 5;
    for (final metric in path.computeMetrics()) {
      double start = 0;
      while (start < metric.length) {
        final double end = math.min(start + dash, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
