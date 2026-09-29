import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/pulse_dot.dart';

/// Tiket kunjungan aktif sesuai desain tiket antrean digital.
///
/// Susunan mengikuti mockup tiket: strip gradien di atas, baris waktu dan
/// kode booking, blok poli dan dokter, panel pasien/rekam medis, garis
/// perforasi, nomor antrean dan estimasi jam periksa, lalu aksi buka QR
/// Anjungan Mandiri beserta pembatalan.
class QueueTicketCard extends StatelessWidget {
  const QueueTicketCard({
    super.key,
    required this.appointment,
    required this.isCancelling,
    required this.onCancel,
    required this.onOpenQr,
  });

  /// Durasi satu slot konsultasi untuk rentang estimasi jam periksa.
  static const Duration _visitWindow = Duration(minutes: 45);

  /// Anjuran hadir lebih awal agar tidak melewati nomor antrean.
  static const String _arrivalAdvice = 'Hadir 20 mnt awal';

  final Appointment appointment;
  final bool isCancelling;
  final VoidCallback onCancel;
  final VoidCallback onOpenQr;

  @override
  Widget build(BuildContext context) {
    final String mulaiJam = DateFormatter.jamMenit(appointment.scheduledDate);
    final String selesaiJam = DateFormatter.jamMenit(
      appointment.scheduledDate.add(_visitWindow),
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandGoldenCaramel.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDeepChocolate.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GradientStrip(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ScheduleRow(appointment: appointment),
                const SizedBox(height: 16),
                _ClinicRow(appointment: appointment),
                const SizedBox(height: 16),
                _PatientPanel(appointment: appointment),
              ],
            ),
          ),
          const _PerforatedDivider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _QueueAndEstimateRow(
                  queueNumber: _nomorAntrean,
                  window: '$mulaiJam - $selesaiJam',
                ),
                const SizedBox(height: 16),
                _OpenQrButton(onPressed: onOpenQr),
                const SizedBox(height: 4),
                _CancelActionRow(
                  isCancelling: isCancelling,
                  onCancel: appointment.canCancel ? onCancel : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Nomor antrean tanpa prefiks poli, contoh: `MAT-014` menjadi `014`.
  String get _nomorAntrean => appointment.queueNumber.split('-').last;
}

/// Strip gradien di tepi atas kartu sebagai penanda tiket aktif.
class _GradientStrip extends StatelessWidget {
  const _GradientStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandGoldenCaramel,
            AppColors.brandSoftSand,
            AppColors.brandWarmBronze,
          ],
        ),
      ),
    );
  }
}

/// Baris waktu kunjungan di pil hijau berdenyut dan kode booking monospace.
class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final String hari = DateFormatter.hariRelatif(appointment.scheduledDate);
    final String jam = DateFormatter.jamMenit(appointment.scheduledDate);

    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successEmerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: AppColors.successEmerald.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PulseDot(color: AppColors.successEmerald, size: 8),
                Flexible(
                  child: Text(
                    '$hari, $jam ${AppConfig.timeZoneAbbr}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successEmerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              appointment.bookingCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Blok poli dengan ikon dan nama dokter.
class _ClinicRow extends StatelessWidget {
  const _ClinicRow({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.brandCreamLinen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.brandSoftSand.withValues(alpha: 0.5),
            ),
          ),
          child: const Icon(
            Icons.monitor_heart_outlined,
            size: 24,
            color: AppColors.brandGoldenCaramel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.clinic,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                appointment.doctorName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandWarmBronze,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Panel berisi nama pasien dan nomor rekam medis tersamar.
class _PatientPanel extends StatelessWidget {
  const _PatientPanel({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _PanelField(
              label: 'Nama Pasien',
              value: appointment.patientName,
            ),
          ),
          const SizedBox(width: 12),
          _PanelField(
            label: 'Rekam Medis (RM)',
            value: appointment.medicalRecord ?? 'Belum diisi',
            isMono: true,
            isRightAligned: true,
          ),
        ],
      ),
    );
  }
}

class _PanelField extends StatelessWidget {
  const _PanelField({
    required this.label,
    required this.value,
    this.isMono = false,
    this.isRightAligned = false,
  });

  final String label;
  final String value;
  final bool isMono;
  final bool isRightAligned;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRightAligned
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: isRightAligned ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontFamily: isMono ? 'monospace' : null,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.brandDarkEspresso,
          ),
        ),
      ],
    );
  }
}

/// Nomor antrean di kiri, estimasi jam periksa di kanan.
class _QueueAndEstimateRow extends StatelessWidget {
  const _QueueAndEstimateRow({required this.queueNumber, required this.window});

  final String queueNumber;
  final String window;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _QueueNumberBox(queueNumber: queueNumber)),
          const SizedBox(width: 12),
          Expanded(child: _EstimateBox(window: window)),
        ],
      ),
    );
  }
}

class _QueueNumberBox extends StatelessWidget {
  const _QueueNumberBox({required this.queueNumber});

  final String queueNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandCreamLinen, AppColors.surfaceCard],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.brandSoftSand.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NOMOR ANTREAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.brandWarmBronze,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  queueNumber,
                  style: const TextStyle(
                    fontSize: 44,
                    height: 1.1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstimateBox extends StatelessWidget {
  const _EstimateBox({required this.window});

  final String window;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTIMASI JAM PERIKSA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              window,
              style: const TextStyle(
                fontSize: 17,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: AppColors.brandDarkEspresso,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.brandSoftSand.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: AppColors.brandWarmBronze,
                ),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    QueueTicketCard._arrivalAdvice,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandWarmBronze,
                    ),
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

/// Aksi utama bergradien untuk membuka tiket QR Anjungan Mandiri.
class _OpenQrButton extends StatelessWidget {
  const _OpenQrButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const BorderRadius radius = BorderRadius.all(Radius.circular(16));

    return Semantics(
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            colors: [AppColors.brandGoldenCaramel, AppColors.brandWarmBronze],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandGoldenCaramel.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2_rounded, size: 20, color: Colors.white),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Buka Tiket QR APM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Aksi pembatalan berupa tombol teks crimson beserta batas waktunya.
class _CancelActionRow extends StatelessWidget {
  const _CancelActionRow({required this.isCancelling, required this.onCancel});

  final bool isCancelling;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.dangerCrimson,
              disabledForegroundColor: AppColors.textMuted,
              minimumSize: const Size(0, 40),
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isCancelling)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.dangerCrimson,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.close_rounded, size: 14),
                const SizedBox(width: 4),
                const Flexible(
                  child: Text(
                    'Batalkan Janji',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Batas batal: H-1 s/d ${AppConfig.cancellationDeadlineHour}:00 ${AppConfig.timeZoneAbbr}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// Garis perforasi dengan takukan setengah lingkaran di tepi kiri dan kanan.
class _PerforatedDivider extends StatelessWidget {
  const _PerforatedDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: CustomPaint(painter: _DashedLinePainter()),
            ),
          ),
          Positioned(left: -10, top: 0, child: _Notch()),
          Positioned(right: -10, top: 0, child: _Notch()),
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
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.surfaceBg,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderSubtle
      ..strokeWidth = 1.5;
    const dash = 8.0;
    const gap = 6.0;
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
