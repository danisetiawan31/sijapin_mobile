import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/doctor_schedule_controller.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/doctor_avatar.dart';

/// Reusable DoctorCard widget untuk direktori jadwal dokter publik (US-PUB-02)
/// dan Wizard Pendaftaran Rawat Jalan Step 3 (US-BOOK-03: Pemilihan DPJP).
class DoctorCard extends ConsumerWidget {
  const DoctorCard({
    super.key,
    required this.schedule,
    this.onActionPressed,
    this.actionLabel,
    this.actionIcon = Icons.arrow_forward_rounded,
    this.activeDay,
    this.isSelected = false,
    this.onTapCard,
  });

  /// Data entitas dokter dan jadwal praktiknya
  final DoctorSchedule schedule;

  /// Callback ketika tombol aksi (CTA) ditekan
  final VoidCallback? onActionPressed;

  /// Kustomisasi label tombol aksi (default: 'Daftar Janji Temu')
  final String? actionLabel;

  /// Kustomisasi ikon tombol aksi (default: Icons.arrow_forward_rounded)
  final IconData? actionIcon;

  /// Hari aktif yang disorot. Jika null, membaca [selectedDoctorDayProvider]
  final String? activeDay;

  /// Status apakah kartu sedang dipilih (berguna saat pemilihan DPJP Step 3)
  final bool isSelected;

  /// Callback opsional ketika seluruh kartu ditekan
  final VoidCallback? onTapCard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentActiveDay = activeDay ?? ref.watch(selectedDoctorDayProvider);
    final specialtyBadge = _getSpecialtyBadge(schedule.specialization);
    final isLibur = schedule.status == DoctorPracticeStatus.libur;

    return AppCard(
      variant:
          isSelected ? AppCardVariant.highlighted : AppCardVariant.elevated,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      onTap: onTapCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Gender-based Avatar + Name + Specialty badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar ilustrasi medis berbasis gender & inisial Sitanala
              DoctorAvatar(
                name: schedule.name,
                gender: schedule.gender,
                photoUrl: schedule.photoUrl,
                radius: 28,
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
            child: schedule.schedules.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      'Tidak ada jadwal praktik aktif saat ini.',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      ...schedule.schedules.map((entry) {
                        final isEntryActiveDay =
                            currentActiveDay != 'Semua Hari' &&
                                entry.day == currentActiveDay;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: isEntryActiveDay
                              ? const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4)
                              : EdgeInsets.zero,
                          decoration: isEntryActiveDay
                              ? BoxDecoration(
                                  color: AppColors.brandGoldenCaramel
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                isEntryActiveDay
                                    ? Icons.event_available_rounded
                                    : Icons.access_time_rounded,
                                size: 16,
                                color: isEntryActiveDay
                                    ? AppColors.brandWarmBronze
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.day,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: isEntryActiveDay
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isEntryActiveDay
                                          ? AppColors.brandDarkEspresso
                                          : AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.displayTime,
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isEntryActiveDay
                                            ? AppColors.brandDarkEspresso
                                            : AppColors.textSecondary,
                                        fontWeight: isEntryActiveDay
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
          ),

          const SizedBox(height: 12),

          // Row 3: Status badge + CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Praktik Reguler / Libur badge
              if (schedule.status == DoctorPracticeStatus.reguler)
                const AppBadge.success(
                  label: 'Praktik Reguler',
                  icon: Icons.circle,
                  fontSize: 11,
                )
              else if (isLibur)
                const AppBadge.warning(label: 'Libur / Cuti', fontSize: 11)
              else
                const AppBadge.neutral(label: 'Praktik Reguler', fontSize: 11),

              // CTA button
              AppPrimaryButton(
                label: isLibur ? 'Dokter Cuti' : (actionLabel ?? 'Daftar Janji Temu'),
                icon: isLibur ? null : actionIcon,
                width: 160,
                onPressed: isLibur
                    ? null
                    : (onActionPressed ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Buka pendaftaran untuk ${schedule.name}'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.brandDarkEspresso,
                            ),
                          );
                        }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getSpecialtyBadge(String specialization) {
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
