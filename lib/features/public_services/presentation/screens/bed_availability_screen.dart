import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../booking/presentation/widgets/pulse_dot.dart';
import '../../domain/entities/bed_availability.dart';
import '../controllers/bed_availability_controller.dart';
import '../widgets/ward_availability_card.dart';

/// Layar Ketersediaan Kamar Rawat Inap & ICU.
///
/// Referensi visual: `stitch_design/Ketersedian-Kamar/screen.png`.
/// Rute: `/bed-availability` (di luar shell, tanpa bottom nav).
class BedAvailabilityScreen extends ConsumerWidget {
  const BedAvailabilityScreen({super.key});

  static const List<String> _classFilters = <String>[
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka panggilan telepon ke ${AppConstants.emergencyPhoneNumber}',
            ),
            backgroundColor: AppColors.dangerCrimson,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka panggilan telepon ke ${AppConstants.emergencyPhoneNumber}',
            ),
            backgroundColor: AppColors.dangerCrimson,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bedAvailabilityListProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header: kembali + judul + status live
            _ScreenHeader(onBack: () => context.pop()),

            // 2. Konten scrollable
            Expanded(
              child: state.summary.when(
                data: (summary) => _Content(
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

/// Header layar: tombol kembali, judul tengah, pil Live SIMRS.
class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceBg,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: AppColors.surfaceCard,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.borderSubtle),
            ),
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ),
          ),
          const Text(
            'Ketersediaan Kamar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brandDarkEspresso,
              letterSpacing: -0.3,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.successBorder.withValues(alpha: 0.6),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulseDot(color: AppColors.successEmerald, size: 8),
                SizedBox(width: 6),
                Text(
                  'Live SIMRS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successEmerald,
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

/// Konten utama setelah data tersedia.
class _Content extends StatelessWidget {
  const _Content({
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
          _HeroCard(summary: summary),
          const SizedBox(height: 16),
          _ClassFilterChips(
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
          _AdmissionBanner(onCallTap: onCallTap),
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

/// Kartu hero ringkasan kapasitas + BOR.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});

  final BedAvailabilitySummary summary;

  @override
  Widget build(BuildContext context) {
    final bor = summary.borPercent;
    return AppCard.elevated(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KAPASITAS RAWAT INAP RS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(
                Icons.hotel_rounded,
                size: 18,
                color: AppColors.brandGoldenCaramel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${summary.availableBeds}',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandGoldenCaramel,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Bed Siap Huni',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              text: 'Dari total ${summary.totalBeds} kapasitas tempat tidur ',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text:
                      '(Tingkat Keterisian: ${bor.toStringAsFixed(1).replaceAll('.', ',')}%)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 10,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.5),
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (bor / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.brandGoldenCaramel,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${summary.availableBeds} Tersedia',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${summary.occupiedBeds} Terisi • ${bor.toStringAsFixed(1).replaceAll('.', ',')}% BOR',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Strip chip filter kelas horizontal.
class _ClassFilterChips extends StatelessWidget {
  const _ClassFilterChips({
    required this.selectedClass,
    required this.onSelected,
  });

  final String selectedClass;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BedAvailabilityScreen._classFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = BedAvailabilityScreen._classFilters[index];
          final bool isActive = label == selectedClass;
          return GestureDetector(
            onTap: () => onSelected(label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.brandGoldenCaramel
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isActive
                      ? AppColors.brandGoldenCaramel
                      : AppColors.borderSubtle,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? AppColors.textWhite
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Banner bantuan admisi dengan tombol telepon.
class _AdmissionBanner extends StatelessWidget {
  const _AdmissionBanner({required this.onCallTap});

  final VoidCallback onCallTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_in_talk_rounded,
              size: 18,
              color: AppColors.brandGoldenCaramel,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Butuh info rujukan ranap mende…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Admisi: ${AppConstants.emergencyPhoneNumber}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.brandGoldenCaramel,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: onCallTap,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.emergencyCallAction,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.call_rounded,
                      size: 14,
                      color: AppColors.textWhite,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shimmer saat pemuatan awal.
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
