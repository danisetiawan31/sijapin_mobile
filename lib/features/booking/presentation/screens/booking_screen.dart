import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/entities/appointment.dart';
import '../controllers/booking_controller.dart';
import '../widgets/appointment_history_card.dart';
import '../widgets/booking_tab_switch.dart';
import '../widgets/live_queue_pulse.dart';
import '../widgets/qr_ticket_dialog.dart';
import '../widgets/queue_ticket_card.dart';

/// Tab 2: Janji Temu — tiket antrean digital dan riwayat kunjungan.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  static const List<String> _tabs = <String>['Tiket Aktif', 'Riwayat Selesai'];

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final BookingState state = ref.watch(bookingControllerProvider);
    final BookingController controller = ref.read(
      bookingControllerProvider.notifier,
    );
    final Appointment? appointment = state.appointment;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookingTitle(
              isRefreshing: state.isRefreshing,
              onRefresh: () => _refreshQueue(context, controller),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: BookingTabSwitch(
                labels: _tabs,
                selectedIndex: _selectedTab,
                onSelected: (int index) => setState(() => _selectedTab = index),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                child: _selectedTab == 0
                    ? _ActiveTab(
                        appointment: appointment,
                        isCancelling: state.isCancelling,
                        onCancel: () =>
                            _confirmCancel(context, controller, appointment),
                        onOpenQr: () => _openQrTicket(context, appointment),
                      )
                    : const _HistoryTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    BookingController controller,
    Appointment? appointment,
  ) async {
    if (appointment == null) return;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Batal Janji Temu?'),
          content: Text(
            'Janji temu dengan ${appointment.doctorName} pada '
            '${DateFormatter.hariTanggalPanjang(appointment.scheduledDate)} '
            'pukul ${appointment.scheduledTime} akan dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Kembali'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.dangerCrimson,
              ),
              child: const Text('Ya, Batalkan'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;
    await controller.cancelAppointment();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Janji temu berhasil dibatalkan')),
    );
  }

  Future<void> _refreshQueue(
    BuildContext context,
    BookingController controller,
  ) async {
    await controller.refreshQueue();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Status antrean terbaru')));
  }

  void _openQrTicket(BuildContext context, Appointment? appointment) {
    if (appointment == null) return;
    showDialog<void>(
      context: context,
      builder: (BuildContext _) => QrTicketDialog(appointment: appointment),
    );
  }
}

class _ActiveTab extends StatelessWidget {
  const _ActiveTab({
    required this.appointment,
    required this.isCancelling,
    required this.onCancel,
    required this.onOpenQr,
  });

  final Appointment? appointment;
  final bool isCancelling;
  final VoidCallback onCancel;
  final VoidCallback onOpenQr;

  @override
  Widget build(BuildContext context) {
    if (appointment == null) return const _NoAppointmentState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QueueTicketCard(
          appointment: appointment!,
          isCancelling: isCancelling,
          onCancel: onCancel,
          onOpenQr: onOpenQr,
        ),
        const SizedBox(height: 16),
        LiveQueuePulse(appointment: appointment!),
        const SizedBox(height: 16),
        _CancelNote(appointment: appointment!),
      ],
    );
  }
}

/// Riwayat janji temu — tampilan saja, tanpa aksi.
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Appointment> history = ref.watch(appointmentHistoryProvider);

    if (history.isEmpty) {
      return const AppEmptyState(
        title: 'Belum Ada Riwayat',
        message: 'Janji temu yang sudah selesai akan tampil di sini.',
        icon: Icons.history_rounded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final Appointment appointment in history) ...[
          AppointmentHistoryCard(appointment: appointment),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BookingTitle extends StatelessWidget {
  const _BookingTitle({required this.isRefreshing, required this.onRefresh});

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Janji Temu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.01,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tiket antrean dan check-in Kiosk APM',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isRefreshing ? null : onRefresh,
            tooltip: 'Perbarui status antrean',
            iconSize: 22,
            color: AppColors.brandWarmBronze,
            disabledColor: AppColors.textMuted,
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.brandGoldenCaramel,
                      ),
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _CancelNote extends StatelessWidget {
  const _CancelNote({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return AppCard.outlined(
      padding: const EdgeInsets.all(12),
      child: Row(
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
              'Pembatalan hanya dapat dilakukan paling lambat H-1 pukul 21.00 WIB, '
              'yaitu ${DateFormatter.tanggalPendek(appointment.cancelDeadline)} pukul 21.00 WIB.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// State kosong: tidak ada janji temu aktif.
class _NoAppointmentState extends StatelessWidget {
  const _NoAppointmentState();

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'Belum Ada Janji Temu',
      message:
          'Pilih dokter dan jadwal yang tersedia untuk membuat janji temu.',
      icon: Icons.event_available_outlined,
      actionButton: AppPrimaryButton(
        label: 'Cari Dokter',
        icon: Icons.search_rounded,
        onPressed: () => context.go(AppRoutes.doctorsPath),
      ),
    );
  }
}
