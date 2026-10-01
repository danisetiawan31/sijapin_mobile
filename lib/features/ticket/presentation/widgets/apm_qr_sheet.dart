import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import '../controllers/ticket_controller.dart';
import 'apm_qr_card.dart';

/// Modal Bottom Sheet untuk Pemindaian QR Code di Mesin Kiosk APM Lobi RS
class ApmQrSheet extends ConsumerWidget {
  const ApmQrSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.brandDarkEspresso.withValues(alpha: 0.65),
      builder: (BuildContext _) => const ApmQrSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketState = ref.watch(ticketControllerProvider);
    final ticket = ticketState.ticket;
    final controller = ref.read(ticketControllerProvider.notifier);

    if (ticket == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: ticketState.isMaxBrightness ? Colors.white : AppColors.surfaceCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.brandSoftSand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kartu QR APM Kontras Tinggi
              ApmQrCard(
                ticket: ticket,
                isMaxBrightness: ticketState.isMaxBrightness,
                onToggleBrightness: (val) => controller.setMaxBrightness(val),
                onSimulateCheckIn: () async {
                  await controller.confirmApmCheckIn();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.clinicalTeal,
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Check-in APM Berhasil Diverifikasi!'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Tombol Tutup
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.brandDarkEspresso,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
