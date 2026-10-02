import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
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
import '../widgets/history_filter_bar.dart';
import '../widgets/pulse_dot.dart';
import '../widgets/qr_ticket_sheet.dart';
import '../widgets/queue_ticket_card.dart';
import '../widgets/visit_proof_sheet.dart';
import '../../../ticket/domain/entities/ticket.dart';
import '../../../ticket/presentation/controllers/ticket_controller.dart';
import '../../../ticket/presentation/widgets/kiosk_arrival_stepper.dart';
import '../../../ticket/presentation/widgets/offline_status_banner.dart';

/// Tab 2: Janji Temu — tiket antrean digital dan riwayat kunjungan.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  static const String _activeTabLabel = 'Tiket Aktif';
  static const String _historyTabLabel = 'Riwayat Selesai';

  int _selectedTab = 0;
  HistoryFilter _historyFilter = HistoryFilter.semua;

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
            _BookingHeader(
              isRefreshing: state.isRefreshing,
              onRefresh: () => _refreshQueue(context, controller),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: BookingTabSwitch(
                tabs: <BookingTabItem>[
                  BookingTabItem(
                    _activeTabLabel,
                    count: appointment == null ? 0 : 1,
                  ),
                  const BookingTabItem(_historyTabLabel),
                ],
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
                    : _HistoryTab(
                        filter: _historyFilter,
                        onFilterChanged: (HistoryFilter filter) =>
                            setState(() => _historyFilter = filter),
                      ),
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
    QrTicketSheet.show(context, appointment);
  }
}

class _ActiveTab extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final Appointment? current = appointment;
    if (current == null) return const _NoAppointmentState();

    final ticketState = ref.watch(ticketControllerProvider);
    final isOffline = ticketState.isOffline || !current.isServerSynced;
    final displayTicket = ticketState.ticket ?? Ticket.fromAppointment(current);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isOffline) OfflineStatusBanner(isUnsynced: !current.isServerSynced),
        _ActiveSectionHeader(appointment: current),
        const SizedBox(height: 12),
        QueueTicketCard(
          appointment: current,
          isCancelling: isCancelling,
          onCancel: onCancel,
          onOpenQr: onOpenQr,
        ),
        const SizedBox(height: 16),
        KioskArrivalStepper(ticket: displayTicket),
        const SizedBox(height: 16),
        const _ApmCallout(),
        const SizedBox(height: 16),
        const _CallCenterNote(),
      ],
    );
  }
}

/// Judul bagian tiket aktif dengan titik berdenyut dan penanda hari kunjungan.
class _ActiveSectionHeader extends StatelessWidget {
  const _ActiveSectionHeader({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final String hari = DateFormatter.hariRelatif(appointment.scheduledDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseDot(size: 10),
                Flexible(
                  child: Text(
                    'Tiket Kunjungan Aktif',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandGoldenCaramel.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: AppColors.brandGoldenCaramel.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'Kunjungan $hari',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandGoldenCaramel,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Penjelasan check-in mandiri lewat mesin Anjungan Pasien Mandiri.
class _ApmCallout extends StatelessWidget {
  const _ApmCallout();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandCreamLinen, AppColors.surfaceCard],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brandSoftSand.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandGoldenCaramel.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.contactless_outlined,
              size: 22,
              color: AppColors.brandGoldenCaramel,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check-in Mandiri Cepat (APM)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.brandDarkEspresso,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tiket QR dapat langsung di-scan di mesin ',
                      ),
                      TextSpan(
                        text: 'Anjungan Pasien Mandiri (APM)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' lobi gedung rawat jalan RSUP Dr. Sitanala '
                            'tanpa perlu antre di loket pendaftaran.',
                      ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 12,
                      color: AppColors.brandGoldenCaramel,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Layanan Buka ${AppConfig.admissionServiceOpenTime} ${AppConfig.timeZoneAbbr}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandGoldenCaramel,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tautan Call Center rumah sakit untuk panduan kedatangan poli.
class _CallCenterNote extends StatelessWidget {
  const _CallCenterNote();

  static const String _phoneNumber = '(021) 552-3059';
  static const String _dialNumber = '0215523059';

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          children: [
            TextSpan(text: 'Butuh panduan kedatangan poli? Hubungi '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: _CallCenterLink(),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Menyalakan aplikasi telepon; diabaikan bila platform tidak mendukung.
  static Future<void> _dial() async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: _dialNumber));
    } on Object {
      // Tidak ada aplikasi telepon di platform ini.
    }
  }
}

class _CallCenterLink extends StatelessWidget {
  const _CallCenterLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _CallCenterNote._dial,
      child: const Text(
        'Call Center RSUP Dr. Sitanala ${_CallCenterNote._phoneNumber}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.brandWarmBronze,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Riwayat kunjungan selesai dan dibatalkan — dapat difilter per status.
class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.filter, required this.onFilterChanged});

  final HistoryFilter filter;
  final ValueChanged<HistoryFilter> onFilterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Appointment> history = ref.watch(appointmentHistoryProvider);
    final List<Appointment> filtered = history.where(_matchesFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HistoryFilterBar(selected: filter, onSelected: onFilterChanged),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const AppEmptyState(
            title: 'Belum Ada Riwayat',
            message: 'Kunjungan dengan status ini akan tampil di sini.',
            icon: Icons.history_rounded,
          )
        else
          for (final Appointment appointment in filtered) ...[
            AppointmentHistoryCard(
              appointment: appointment,
              onViewProof: () => VisitProofSheet.show(context, appointment),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 4),
        const _MedicalRecordHelpCard(),
      ],
    );
  }

  bool _matchesFilter(Appointment appointment) {
    switch (filter) {
      case HistoryFilter.semua:
        return true;
      case HistoryFilter.selesai:
        return appointment.isCompleted;
      case HistoryFilter.dibatalkan:
        return appointment.isCancelled;
    }
  }
}

/// Callout bantuan salinan resume medis resmi.
class _MedicalRecordHelpCard extends StatelessWidget {
  const _MedicalRecordHelpCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard.outlined(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.brandCreamLinen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: AppColors.brandWarmBronze,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Butuh Salinan Rekam Medis?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.brandDarkEspresso,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Permohonan salinan resume medis resmi dilayani di loket lantai 1 '
            'RSUP Dr. Sitanala atau melalui Call Center (021) 552-3059.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header Janji Temu: judul terpusat dengan aksen karamel dan tombol sinkron.
class _BookingHeader extends StatelessWidget {
  const _BookingHeader({required this.isRefreshing, required this.onRefresh});

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Janji Temu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                    SizedBox(width: 6),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.brandGoldenCaramel,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 6, height: 6),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'RSUP Dr. Sitanala Tangerang',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _RefreshButton(isRefreshing: isRefreshing, onPressed: onRefresh),
        ],
      ),
    );
  }
}

/// Tombol sinkron berbentuk lingkaran putih yang berputar saat ditekan.
class _RefreshButton extends StatefulWidget {
  const _RefreshButton({required this.isRefreshing, required this.onPressed});

  final bool isRefreshing;
  final VoidCallback onPressed;

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didUpdateWidget(covariant _RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing == oldWidget.isRefreshing) return;
    if (widget.isRefreshing) {
      _spin.repeat();
    } else {
      _spin
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _handlePressed() {
    if (widget.isRefreshing) return;
    _spin.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: Material(
          color: AppColors.surfaceCard,
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.borderSubtle),
          ),
          elevation: 1.5,
          shadowColor: AppColors.brandDarkEspresso.withValues(alpha: 0.16),
          child: InkWell(
            onTap: _handlePressed,
            customBorder: const CircleBorder(),
            child: Semantics(
              button: true,
              label: 'Perbarui status antrean',
              child: SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _spin,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.rotate(
                        angle: _spin.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.sync_rounded,
                      size: 19,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
