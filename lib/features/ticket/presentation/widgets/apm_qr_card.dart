import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import '../../domain/entities/ticket.dart';

/// Kartu Pemindai Optik Kiosk APM (High-Contrast QR Code & Kontrol Kecerahan)
class ApmQrCard extends StatelessWidget {
  const ApmQrCard({
    super.key,
    required this.ticket,
    required this.isMaxBrightness,
    required this.onToggleBrightness,
    this.onSimulateCheckIn,
  });

  final Ticket ticket;
  final bool isMaxBrightness;
  final ValueChanged<bool> onToggleBrightness;
  final VoidCallback? onSimulateCheckIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isMaxBrightness ? Colors.white : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMaxBrightness
              ? AppColors.brandGoldenCaramel
              : AppColors.brandSoftSand.withValues(alpha: 0.8),
          width: isMaxBrightness ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isMaxBrightness
                ? AppColors.brandGoldenCaramel.withValues(alpha: 0.25)
                : AppColors.brandDeepChocolate.withValues(alpha: 0.06),
            blurRadius: isMaxBrightness ? 24 : 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header petunjuk scan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brandGoldenCaramel.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 18,
                      color: AppColors.brandGoldenCaramel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pemindai Kiosk APM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                ],
              ),
              // Tombol toggle kecerahan layar
              InkWell(
                onTap: () => onToggleBrightness(!isMaxBrightness),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isMaxBrightness
                        ? AppColors.brandGoldenCaramel
                        : AppColors.brandCreamLinen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isMaxBrightness
                          ? AppColors.brandGoldenCaramel
                          : AppColors.brandSoftSand,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isMaxBrightness
                            ? Icons.brightness_high_rounded
                            : Icons.brightness_6_rounded,
                        size: 14,
                        color: isMaxBrightness
                            ? Colors.white
                            : AppColors.brandDarkEspresso,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isMaxBrightness ? 'Terang Maks' : 'Mode Terang',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isMaxBrightness
                              ? Colors.white
                              : AppColors.brandDarkEspresso,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Area QR Code dengan sudut braket target optik pemindai
          CustomPaint(
            painter: _ScannerBracketPainter(
              bracketColor: isMaxBrightness
                  ? AppColors.brandGoldenCaramel
                  : AppColors.brandWarmBronze,
            ),
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Semantics(
                label: 'QR Code untuk pemindaian di mesin Anjungan Pasien Mandiri',
                value: ticket.qrPayload,
                child: QrImageView(
                  data: ticket.qrPayload,
                  version: QrVersions.auto,
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
          ),
          const SizedBox(height: 12),

          // Kotak Kode Booking Numerik 13 Digit dengan tombol salin
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.brandSoftSand,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KODE BOOKING APM',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      ticket.bookingCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                IconButton(
                  icon: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: AppColors.brandDarkEspresso,
                  ),
                  tooltip: 'Salin Kode Booking',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ticket.bookingCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Kode booking ${ticket.bookingCode} berhasil disalin',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Text(
            ticket.isCheckedIn
                ? '✓ Tiket ini telah diverifikasi di Kiosk APM'
                : 'Arahkan QR Code ini ke lensa pemindai mesin Kiosk APM saat tiba di lobi RS.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  ticket.isCheckedIn ? FontWeight.w700 : FontWeight.w500,
              color: ticket.isCheckedIn
                  ? AppColors.clinicalTeal
                  : AppColors.textMuted,
            ),
          ),

          // Opsi tombol demonstrasi / simulasi check-in mandiri
          if (!ticket.isCheckedIn && onSimulateCheckIn != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onSimulateCheckIn,
              icon: const Icon(Icons.touch_app_rounded, size: 16),
              label: const Text(
                'Simulasi Check-In Kiosk Lobi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandGoldenCaramel,
                side: const BorderSide(color: AppColors.brandGoldenCaramel),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// CustomPainter untuk menggambar 4 sudut braket pembidik kamera optik
class _ScannerBracketPainter extends CustomPainter {
  const _ScannerBracketPainter({required this.bracketColor});

  final Color bracketColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bracketColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 16.0;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top-Right
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(
        Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - cornerLength), paint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerBracketPainter oldDelegate) =>
      oldDelegate.bracketColor != bracketColor;
}
