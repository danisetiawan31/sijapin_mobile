import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/config/app_config.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';

/// Langkah 2: Pemilihan Poliklinik Spesialis & Tanggal Kunjungan Kerja (US-BOOK-02).
class Step2ClinicDateStep extends ConsumerWidget {
  const Step2ClinicDateStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wizardState = ref.watch(bookingWizardControllerProvider);
    final controller = ref.read(bookingWizardControllerProvider.notifier);
    final polyclinicsAsync = ref.watch(polyclinicsProvider);
    final draft = wizardState.draft;

    final availableDates = _generateAvailableWeekdays();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Pemilihan Poliklinik
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.brandDarkEspresso,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Pilih Poliklinik Tujuan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Text(
              'Tentukan poliklinik spesialis yang akan dituju.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Daftar Poliklinik
          polyclinicsAsync.when(
            data: (clinics) {
              // Auto-select poli pertama jika belum ada dan bukan pre-selected doctor
              if (draft.clinic == null &&
                  draft.doctor == null &&
                  clinics.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.setClinic(clinics.first);
                });
              }

              return Column(
                children: [
                  for (final clinic in clinics) ...[
                    _ClinicItemCard(
                      clinic: clinic,
                      isSelected: draft.clinic?.id == clinic.id,
                      onTap: () => controller.setClinic(clinic),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) => Text('Gagal memuat poli: $err'),
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 20),

          // Section 2: Pemilihan Tanggal Kunjungan
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.brandDarkEspresso,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Pilih Tanggal Kunjungan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Text(
              'Hanya hari kerja operasional rumah sakit (Senin s/d Jumat).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal Date Chips
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableDates.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final date = availableDates[index];
                final isSelected =
                    draft.bookingDate != null &&
                    draft.bookingDate!.year == date.year &&
                    draft.bookingDate!.month == date.month &&
                    draft.bookingDate!.day == date.day;

                // Auto-select tanggal kerja pertama jika belum dipilih
                if (draft.bookingDate == null && index == 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.setBookingDate(date);
                  });
                }

                return _DateSelectionCard(
                  date: date,
                  isSelected: isSelected,
                  onTap: () => controller.setBookingDate(date),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Callout Jadwal Operasional
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brandSoftSand),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  size: 18,
                  color: AppColors.brandGoldenCaramel,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pendaftaran dibuka untuk kunjungan H+1 s/d H+7. '
                    'Pelayanan poli pukul ${AppConfig.admissionServiceOpenTime} – 15.00 ${AppConfig.timeZoneAbbr}.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.brandDarkEspresso,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Menghasilkan 7 hari kerja berikutnya (Senin-Jumat) mulai dari besok (H+1)
  List<DateTime> _generateAvailableWeekdays() {
    final List<DateTime> dates = [];
    final now = AppDateTime.now();
    var cursor = DateTime(now.year, now.month, now.day + 1);

    while (dates.length < 7) {
      if (cursor.weekday != DateTime.saturday &&
          cursor.weekday != DateTime.sunday) {
        dates.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return dates;
  }
}

class _ClinicItemCard extends StatelessWidget {
  const _ClinicItemCard({
    required this.clinic,
    required this.isSelected,
    required this.onTap,
  });

  final Polyclinic clinic;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandGoldenCaramel.withValues(alpha: 0.08)
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandGoldenCaramel
                  : AppColors.borderSubtle,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brandGoldenCaramel
                      : AppColors.brandCreamLinen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  clinic.code,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : AppColors.brandDarkEspresso,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clinic.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.clinicalContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  clinic.floor,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.clinicalTeal,
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

class _DateSelectionCard extends StatelessWidget {
  const _DateSelectionCard({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayName = _formatDayName(date.weekday);
    final monthName = _formatMonthName(date.month);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 72,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandDarkEspresso
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandDarkEspresso
                  : AppColors.borderSubtle,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandDarkEspresso.withValues(
                        alpha: 0.25,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white70 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      default:
        return '';
    }
  }

  String _formatMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }
}
