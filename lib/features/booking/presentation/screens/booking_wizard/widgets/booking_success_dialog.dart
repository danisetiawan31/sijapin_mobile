import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';

/// Modal dialog sukses pendaftaran janji temu rawat jalan.
class BookingSuccessDialog extends StatelessWidget {
  const BookingSuccessDialog({
    super.key,
    required this.appointment,
    this.onFinished,
  });

  final Appointment appointment;
  final VoidCallback? onFinished;

  /// Memunculkan dialog sukses
  static Future<void> show(
    BuildContext context,
    Appointment appointment, {
    VoidCallback? onFinished,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BookingSuccessDialog(
        appointment: appointment,
        onFinished: onFinished,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceCard,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Sukses dengan Lingkaran Bertingkat
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.clinicalTeal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 40,
                  color: AppColors.clinicalTeal,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Judul & Keterangan
            Text(
              'Janji Temu Berhasil Dibuat!',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pendaftaran rawat jalan Anda telah tercatat resmi di SIMRS RSUP Dr. Sitanala.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            // Card Highlight Nomor Antrean & Kode Booking
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.brandCreamLinen,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.brandSoftSand),
              ),
              child: Column(
                children: [
                  const Text(
                    'Nomor Antrean Anda',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandWarmBronze,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.queueNumber,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.borderSubtle, height: 1),
                  const SizedBox(height: 10),

                  // Kode Booking 13 Digit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Kode Booking: ${appointment.bookingCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: AppColors.brandWarmBronze,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: 'Salin Kode Booking',
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: appointment.bookingCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kode booking berhasil disalin'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Catatan APM Kiosk
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.qr_code_2_rounded,
                  size: 16,
                  color: AppColors.brandGoldenCaramel,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tiket digital dan QR Code untuk check-in mesin APM telah aktif di menu Janji Temu.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tombol Navigasi ke Tab Janji Temu
            AppPrimaryButton(
              label: 'Buka Tiket Janji Temu ➔',
              onPressed: () {
                Navigator.of(context).pop(); // Tutup Dialog
                onFinished?.call();
                context.go(AppRoutes.bookingPath); // Pindah ke Tab Janji Temu
              },
            ),
          ],
        ),
      ),
    );
  }
}
