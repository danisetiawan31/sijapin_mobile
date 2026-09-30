import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/doctor_card.dart';

/// Langkah 3: Pemilihan Dokter DPJP & Sesi Praktik (US-BOOK-03).
///
/// Mengintegrasikan widget reusable [DoctorCard] dengan prop `isSelected`
/// dan tombol aksi kustom.
class Step3DoctorStep extends ConsumerWidget {
  const Step3DoctorStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wizardState = ref.watch(bookingWizardControllerProvider);
    final controller = ref.read(bookingWizardControllerProvider.notifier);
    final draft = wizardState.draft;

    final clinic = draft.clinic;
    final date = draft.bookingDate;

    if (clinic == null || date == null) {
      return const Center(
        child: Text('Harap pilih poliklinik dan tanggal terlebih dahulu.'),
      );
    }

    final doctorsAsync = ref.watch(
      doctorsByClinicAndDateProvider((clinicId: clinic.id, date: date)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Konteks Pilihan (Poli & Tanggal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brandSoftSand),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_hospital_rounded,
                  size: 18,
                  color: AppColors.brandWarmBronze,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${clinic.name}  •  ${DateFormatter.hariTanggalPanjang(date)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Judul Section
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
                    '3',
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
                'Pilih Dokter DPJP',
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
              'Pilih dokter yang akan menangani pemeriksaan Anda.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar Dokter via DoctorCard Reusable
          doctorsAsync.when(
            data: (doctors) {
              if (doctors.isEmpty) {
                return const AppEmptyState(
                  title: 'Tidak Ada Dokter Jaga',
                  message:
                      'Tidak ada dokter berpraktik pada poli dan hari ini. '
                      'Silakan kembali ke langkah sebelumnya untuk mengubah tanggal.',
                  icon: Icons.event_busy_rounded,
                );
              }

              // Auto-select dokter pertama yang berstatus reguler jika belum ada yang dipilih
              if (draft.doctor == null) {
                final firstAvailable = doctors.where(
                  (d) => d.status == DoctorPracticeStatus.reguler,
                );
                if (firstAvailable.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.setDoctor(firstAvailable.first);
                  });
                }
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctors.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final DoctorSchedule doctor = doctors[index];
                  final isSelected = draft.doctor?.id == doctor.id;

                  return DoctorCard(
                    schedule: doctor,
                    isSelected: isSelected,
                    actionLabel: isSelected
                        ? 'Dokter Terpilih ✓'
                        : 'Pilih Dokter Ini',
                    actionIcon: isSelected
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    onActionPressed: () => controller.setDoctor(doctor),
                    onTapCard: () => controller.setDoctor(doctor),
                  );
                },
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, _) =>
                Center(child: Text('Gagal memuat jadwal dokter: $err')),
          ),
        ],
      ),
    );
  }
}
