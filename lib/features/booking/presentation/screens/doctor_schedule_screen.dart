import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/core/widgets/app_loading_state.dart';
import 'package:sijapin_mobile/core/widgets/app_text_field.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/doctor_schedule_controller.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/doctor_card.dart';

/// Tab 3: Jadwal Dokter Spesialis & Poliklinik
class DoctorScheduleScreen extends ConsumerStatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  ConsumerState<DoctorScheduleScreen> createState() =>
      _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends ConsumerState<DoctorScheduleScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(doctorSearchQueryProvider);
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(doctorScheduleListProvider);
    final currentQuery = ref.watch(doctorSearchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.brandDarkEspresso,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal Dokter',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            Text(
              'RSUP Dr. Sitanala Tangerang',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: schedulesAsync.maybeWhen(
                data: (list) => AppBadge.success(
                  label: '${list.length} Dokter Aktif',
                  icon: Icons.circle,
                  fontSize: 11,
                ),
                orElse: () => const AppBadge.neutral(
                  label: 'Memuat...',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSubtle),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: AppTextField(
                label: 'Pencarian',
                controller: _searchController,
                hint: 'Cari nama dokter atau spesialis...',
                prefixIcon: Icons.search_rounded,
                suffixIcon: currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(doctorSearchQueryProvider.notifier)
                              .setQuery('');
                        },
                      )
                    : null,
                onChanged: (value) {
                  ref.read(doctorSearchQueryProvider.notifier).setQuery(value);
                },
              ),
            ),

            // Day Filter Chips (Senin – Jumat)
            const SizedBox(height: 38, child: _DayFilterChips()),
            const SizedBox(height: 8),

            // Specialty Filter Chips
            const SizedBox(height: 38, child: _SpecialtyFilterChips()),

            // Doctor Cards List
            Expanded(
              child: schedulesAsync.when(
                data: (schedules) {
                  if (schedules.isEmpty) {
                    return const AppEmptyState(
                      title: 'Tidak Ada Jadwal Dokter',
                      message:
                          'Jadwal praktik untuk filter ini belum tersedia.',
                      icon: Icons.event_busy_rounded,
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: schedules.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) =>
                        DoctorCard(schedule: schedules[index]),
                  );
                },
                loading: () =>
                    const AppLoadingState.list(itemCount: 5, itemHeight: 180),
                error: (error, stack) => AppErrorState(
                  title: 'Gagal Memuat Jadwal',
                  message: 'Terjadi kesalahan saat memuat jadwal dokter. Silakan coba lagi.',
                  onRetry: () => ref.invalidate(doctorScheduleListProvider),
                ),
              ),
            ),

            // Footer info card
            const _FooterInfoCard(),
          ],
        ),
      ),
    );
  }
}

/// Day filter chips horizontal scroll (Senin – Jumat)
class _DayFilterChips extends ConsumerWidget {
  const _DayFilterChips();

  static const List<String> _days = <String>[
    'Semua Hari',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDay = ref.watch(selectedDoctorDayProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: _days.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, index) {
        final day = _days[index];
        final isActive = day == activeDay;
        return _DayChip(
          label: day,
          isActive: isActive,
          onTap: () {
            ref.read(selectedDoctorDayProvider.notifier).setDay(day);
          },
        );
      },
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandDarkEspresso
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive
                ? AppColors.brandDarkEspresso
                : AppColors.borderSubtle,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.brandDarkEspresso.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive && label != 'Semua Hari') ...[
              const Icon(
                Icons.calendar_today_rounded,
                size: 11,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Specialty filter chips horizontal scroll
class _SpecialtyFilterChips extends ConsumerWidget {
  const _SpecialtyFilterChips();

  static const List<String> _specialties = <String>[
    'Semua Poli',
    'Penyakit Dalam',
    'Mata',
    'Anak',
    'Kebidanan & Obgyn',
    'THT-KL',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSpecialty = ref.watch(selectedDoctorSpecialtyProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: _specialties.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, index) {
        final specialty = _specialties[index];
        final isActive = specialty == activeSpecialty;
        return _FilterChip(
          label: specialty,
          isActive: isActive,
          onTap: () {
            ref
                .read(selectedDoctorSpecialtyProvider.notifier)
                .setSpecialty(specialty);
          },
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandGoldenCaramel
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive
                ? AppColors.brandGoldenCaramel
                : AppColors.borderSubtle,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.brandGoldenCaramel.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Footer info card
class _FooterInfoCard extends StatelessWidget {
  const _FooterInfoCard();

  @override
  Widget build(BuildContext context) {
    return AppCard.filled(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 5),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Jadwal dokter dapat berubah sewaktu-waktu sesuai penugasan Dinas RSUP Dr. Sitanala.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
