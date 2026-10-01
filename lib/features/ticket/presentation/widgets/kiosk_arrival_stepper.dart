import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

import '../../domain/entities/ticket.dart';

/// Stepper 3 Tahap Kedatangan Fisik Pasien di RSUP Dr. Sitanala (Task ID BPJS)
class KioskArrivalStepper extends StatelessWidget {
  const KioskArrivalStepper({super.key, required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final isStep1Done = true; // Booking selalu selesai
    final isStep2Done = ticket.isCheckedIn || ticket.isCompleted;
    final isStep2Active = !isStep2Done && !ticket.isCancelled;
    final isStep3Done = ticket.isCompleted;
    final isStep3Active = isStep2Done && !isStep3Done && !ticket.isCancelled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandSoftSand.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDeepChocolate.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 16,
                color: AppColors.brandGoldenCaramel,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Alur Kedatangan di Rumah Sakit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildStepRow(
            stepNumber: '1',
            title: 'Booking Online',
            subtitle: 'Tiket & nomor antrean telah diterbitkan',
            isCompleted: isStep1Done,
            isActive: false,
            isLast: false,
          ),
          _buildStepRow(
            stepNumber: '2',
            title: 'Check-In Kiosk APM',
            subtitle: isStep2Done
                ? 'Check-in terverifikasi di mesin Anjungan'
                : 'Pindai barcode tiket di mesin lobi lantai 1',
            isCompleted: isStep2Done,
            isActive: isStep2Active,
            isLast: false,
          ),
          _buildStepRow(
            stepNumber: '3',
            title: 'Panggilan Layanan Poli',
            subtitle: isStep3Done
                ? 'Pemeriksaan dokter selesai'
                : (isStep3Active
                      ? 'Menunggu dipanggil oleh perawat poli'
                      : 'Menunggu proses check-in APM'),
            isCompleted: isStep3Done,
            isActive: isStep3Active,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    Color indicatorBg;
    Widget iconWidget;

    if (isCompleted) {
      indicatorBg = AppColors.clinicalTeal;
      iconWidget = const Icon(Icons.check, size: 12, color: Colors.white);
    } else if (isActive) {
      indicatorBg = AppColors.brandGoldenCaramel;
      iconWidget = Text(
        stepNumber,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    } else {
      indicatorBg = AppColors.brandSoftSand.withValues(alpha: 0.5);
      iconWidget = Text(
        stepNumber,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: indicatorBg,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.brandGoldenCaramel.withValues(
                              alpha: 0.35,
                            ),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: iconWidget,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? AppColors.clinicalTeal.withValues(alpha: 0.5)
                        : AppColors.brandSoftSand.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isActive
                                ? AppColors.brandDarkEspresso
                                : (isCompleted
                                      ? AppColors.brandDarkEspresso
                                      : AppColors.textMuted),
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandGoldenCaramel.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Tahap Ini',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGoldenCaramel,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
