import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/core/widgets/app_loading_state.dart';
import 'package:sijapin_mobile/core/widgets/app_text_field.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/doctor_schedule_controller.dart';

/// Tab 3: Jadwal Dokter Spesialis & Poliklinik
class DoctorScheduleScreen extends ConsumerWidget {
  const DoctorScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(doctorScheduleListProvider);
    final searchController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.brandDarkEspresso,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
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
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: AppBadge.success(
                label: '52 Dokter Aktif',
                icon: Icons.circle,
                fontSize: 11,
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
                controller: searchController,
                hint: 'Cari nama dokter atau spesialis...',
                prefixIcon: Icons.search_rounded,
                onChanged: (value) {
                  ref.read(doctorScheduleListProvider.notifier).search(value);
                },
              ),
            ),

            // Specialty Filter Chips
            SizedBox(height: 48, child: _SpecialtyFilterChips()),

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
                        _DoctorCard(schedule: schedules[index]),
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

/// Specialty filter chips horizontal scroll
class _SpecialtyFilterChips extends ConsumerWidget {
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
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: _specialties.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, index) {
        final specialty = _specialties[index];
        final isActive = specialty == 'Semua Poli'; // Default active
        return _FilterChip(
          label: specialty,
          isActive: isActive,
          onTap: () {
            ref
                .read(doctorScheduleListProvider.notifier)
                .filterBySpecialty(isActive ? 'Semua Poli' : specialty);
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

/// Doctor card matching the screenshot design
class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.schedule});

  final DoctorSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(schedule.name);
    final specialtyBadge = _getSpecialtyBadge(schedule.specialization);

    return AppCard.elevated(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Avatar + Name + Specialty badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.brandCreamLinen,
                backgroundImage: schedule.photoUrl != null
                    ? NetworkImage(schedule.photoUrl!)
                    : null,
                child: schedule.photoUrl == null
                    ? Text(
                        initials,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandWarmBronze,
                            ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name & Specialization
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.specialization,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              // Specialty badge
              specialtyBadge,
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Schedule panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                ...schedule.schedules.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.day,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.displayTime,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Row 3: Status badge + CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Praktik Reguler badge
              if (schedule.status == DoctorPracticeStatus.reguler)
                const AppBadge.success(
                  label: 'Praktik Reguler',
                  icon: Icons.circle,
                  fontSize: 11,
                )
              else if (schedule.status == DoctorPracticeStatus.libur)
                const AppBadge.warning(label: 'Libur / Cuti', fontSize: 11)
              else
                const AppBadge.neutral(label: 'Praktik Reguler', fontSize: 11),

              // Daftar Janji Temu button
              AppPrimaryButton(
                label: 'Daftar Janji Temu',
                icon: Icons.arrow_forward_rounded,
                width: 160,
                onPressed: () {
                  // TODO: Navigate to booking flow with doctor context
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Buka pendaftaran untuk ${schedule.name}'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.brandDarkEspresso,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  Widget _getSpecialtyBadge(String specialization) {
    // Map specialization to badge label
    String badgeLabel;
    if (specialization.contains('Penyakit Dalam')) {
      badgeLabel = 'Penyakit Dalam';
    } else if (specialization.contains('Mata')) {
      badgeLabel = 'Poli Mata';
    } else if (specialization.contains('Obstetri') ||
        specialization.contains('Ginekologi')) {
      badgeLabel = 'Kebidanan & Obgyn';
    } else if (specialization.contains('THT')) {
      badgeLabel = 'THT-KL';
    } else if (specialization.contains('Anak')) {
      badgeLabel = 'Poli Anak';
    } else {
      badgeLabel = specialization;
    }

    return AppBadge.neutral(label: badgeLabel, fontSize: 11);
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
