import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/pulse_dot.dart';

import '../../domain/entities/ticket.dart';

/// Kartu Fisik Digital Boarding Pass Antrean Poliklinik RSUP Dr. Sitanala
class TicketBoardingPass extends StatelessWidget {
  const TicketBoardingPass({
    super.key,
    required this.ticket,
    required this.onOpenApmQr,
    this.onCancel,
    this.isCancelling = false,
  });

  final Ticket ticket;
  final VoidCallback onOpenApmQr;
  final VoidCallback? onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(ticket.status);
    final statusLabel = _getStatusLabel(ticket.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.brandGoldenCaramel.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDeepChocolate.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Accent Brand Header
            _buildPassHeader(statusLabel, statusColor),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Nomor Antrean & Live Status
                  _buildQueueHeroSection(),

                  const SizedBox(height: 20),

                  // Bento Grid: Informasi Dokter & Pasien
                  _buildBentoDetailsSection(),
                ],
              ),
            ),

            // Perforated Tear-Line (Garis Sobekan Tiket Fisik)
            _buildPerforationDivider(),

            // Bagian Bawah: Aksi APM & Pembatalan
            _buildBottomActionSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPassHeader(String statusLabel, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandDarkEspresso,
            AppColors.brandDarkEspresso.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.brandGoldenCaramel.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 16,
                  color: AppColors.brandGoldenCaramel,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RSUP Dr. Sitanala',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'Rawat Jalan • ${AppConfig.appName}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueHeroSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandCreamLinen, Colors.white],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.brandGoldenCaramel.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'NOMOR ANTREAN ANDA',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandGoldenCaramel.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: AppColors.brandGoldenCaramel,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.scheduledTime,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Nomor Antrean Super-Besar (MAT-014)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ticket.queueNumber,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: AppColors.brandDarkEspresso,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Live Tracker Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ticket.remainingQueue == 0
                  ? AppColors.clinicalTeal.withValues(alpha: 0.15)
                  : AppColors.brandWarmBronze.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseDot(
                  size: 8,
                  color: ticket.remainingQueue == 0
                      ? AppColors.clinicalTeal
                      : AppColors.brandGoldenCaramel,
                ),
                const SizedBox(width: 8),
                Text(
                  ticket.remainingQueue == 0
                      ? 'Sedang Dipanggil di Poli Sekarang!'
                      : '${ticket.remainingQueue} Pasien Lagi Sebelum Anda (Sekarang: ${ticket.nowServingNumber})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ticket.remainingQueue == 0
                        ? AppColors.clinicalTeal
                        : AppColors.brandDarkEspresso,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoDetailsSection() {
    return Column(
      children: [
        // Kartu Dokter & Poliklinik
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.brandCreamLinen.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.brandSoftSand.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.brandGoldenCaramel.withValues(
                  alpha: 0.2,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.brandDarkEspresso,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.doctorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ticket.clinic} • ${ticket.clinicLocation}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Kartu Pasien & Rekam Medis
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.brandCreamLinen.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.brandSoftSand.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PASIEN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ticket.patientName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'NO. REKAM MEDIS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ticket.maskedMedicalRecord,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerforationDivider() {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Garis Putus-Putus
          LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 6.0;
              const dashSpace = 4.0;
              final dashCount = (constraints.maxWidth / (dashWidth + dashSpace))
                  .floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(dashCount, (_) {
                  return Container(
                    width: dashWidth,
                    height: 1.5,
                    margin: const EdgeInsets.symmetric(
                      horizontal: dashSpace / 2,
                    ),
                    color: AppColors.brandSoftSand,
                  );
                }),
              );
            },
          ),
          // Lekukan Kiri
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.surfaceBg,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Lekukan Kanan
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.surfaceBg,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          // Tombol Buka Pemindai APM
          ElevatedButton.icon(
            onPressed: onOpenApmQr,
            icon: const Icon(Icons.qr_code_2_rounded, size: 20),
            label: const Text(
              'Buka QR Mesin APM Lobi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGoldenCaramel,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          if (ticket.canCancel && onCancel != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: isCancelling ? null : onCancel,
              icon: isCancelling
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.dangerCrimson,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: AppColors.dangerCrimson,
                    ),
              label: Text(
                isCancelling ? 'Membatalkan...' : 'Batalkan Janji Temu',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dangerCrimson,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Batas pembatalan mandiri: ${DateFormatter.hariTanggalPanjang(ticket.cancelDeadline)} pukul 23:59 WIB',
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.upcoming:
        return AppColors.brandGoldenCaramel;
      case TicketStatus.checkedIn:
        return AppColors.clinicalTeal;
      case TicketStatus.completed:
        return AppColors.clinicalTeal;
      case TicketStatus.cancelled:
        return AppColors.dangerCrimson;
    }
  }

  String _getStatusLabel(TicketStatus status) {
    switch (status) {
      case TicketStatus.upcoming:
        return 'Terdaftar';
      case TicketStatus.checkedIn:
        return 'Checked-In APM';
      case TicketStatus.completed:
        return 'Selesai';
      case TicketStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}
