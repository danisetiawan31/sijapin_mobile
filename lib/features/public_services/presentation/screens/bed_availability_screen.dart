import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../domain/entities/bed_availability.dart';
import '../controllers/bed_availability_controller.dart';
import '../widgets/bed_admission_banner.dart';
import '../widgets/bed_availability_header.dart';
import '../widgets/bed_capacity_hero_card.dart';
import '../widgets/bed_class_filter_bar.dart';
import '../widgets/ward_availability_card.dart';

export '../widgets/bed_admission_banner.dart';
export '../widgets/bed_availability_header.dart';
export '../widgets/bed_capacity_hero_card.dart';
export '../widgets/bed_class_filter_bar.dart';
export '../widgets/ward_availability_card.dart';

/// Layar Ketersediaan Kamar Rawat Inap & ICU RSUP Dr. Sitanala.
///
/// Terdekomposisi secara modular: Header, Hero Card BOR, Filter Bar, dan Banner Admisi.
/// Rute: `/bed-availability`
class BedAvailabilityScreen extends ConsumerWidget {
  const BedAvailabilityScreen({super.key});

  static const List<String> classFilters = <String>[
    'Semua Kelas',
    'Kelas 3',
    'Kelas 2',
    'Kelas 1',
    'VIP / VVIP',
    'ICU',
  ];

  Future<void> _handleCall(BuildContext context) async {
    final cleanNumber = AppConstants.emergencyPhoneDial.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showCallErrorSnack(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showCallErrorSnack(context);
      }
    }
  }

  void _showCallErrorSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tidak dapat membuka panggilan telepon ke ${AppConstants.emergencyPhoneNumber}',
        ),
        backgroundColor: AppColors.dangerCrimson,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bedAvailabilityListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header modular
            BedAvailabilityHeader(onBack: () => context.pop()),

            // 2. Konten reaktif
            Expanded(
              child: state.summary.when(
                data: (summary) => _BedAvailabilityContent(
                  summary: summary,
                  selectedClass: state.selectedClass,
                  onClassSelected: (c) => ref
                      .read(bedAvailabilityListProvider.notifier)
                      .filterByClass(c),
                  onCallTap: () => _handleCall(context),
                ),
                loading: () => const _LoadingContent(),
                error: (_, _) => AppErrorState(
                  title: 'Gagal Memuat Data Kamar',
                  message: 'Terjadi kendala saat memuat ketersediaan kamar. Silakan coba lagi.',
                  onRetry: () => ref.invalidate(bedAvailabilityListProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Konten scrollable utama setelah data ketersediaan kamar berhasil dimuat.
class _BedAvailabilityContent extends StatelessWidget {
  const _BedAvailabilityContent({
    required this.summary,
    required this.selectedClass,
    required this.onClassSelected,
    required this.onCallTap,
  });

  final BedAvailabilitySummary summary;
  final String selectedClass;
  final ValueChanged<String> onClassSelected;
  final VoidCallback onCallTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BedCapacityHeroCard(summary: summary),
          const SizedBox(height: 16),
          BedClassFilterBar(
            filters: BedAvailabilityScreen.classFilters,
            selectedClass: selectedClass,
            onSelected: onClassSelected,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ketersediaan Ruangan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              Text(
                '${summary.monitoredUnits} Unit Dipantau',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandGoldenCaramel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (summary.wards.isEmpty)
            const AppEmptyState(
              title: 'Tidak Ada Ruangan Tersedia',
              message: 'Belum ada ruangan dengan bed kosong pada kelas ini.',
              icon: Icons.bed_rounded,
            )
          else
            ...summary.wards.map(
              (ward) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: WardAvailabilityCard(ward: ward),
              ),
            ),
          const SizedBox(height: 4),
          BedAdmissionBanner(onCallTap: onCallTap),
          const SizedBox(height: 16),
          const Text(
            'SIIJAPIN • Layanan Rawat Inap RSUP Dr. Sitanala',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shimmer skeleton saat pemuatan awal.
class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: AppLoadingState.list(itemCount: 4, itemHeight: 180),
    );
  }
}
