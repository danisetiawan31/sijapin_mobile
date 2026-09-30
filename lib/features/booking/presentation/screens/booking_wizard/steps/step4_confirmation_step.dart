import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';

/// Langkah 4: Konfirmasi Ringkasan Pendaftaran & Persetujuan (US-BOOK-04).
class Step4ConfirmationStep extends ConsumerWidget {
  const Step4ConfirmationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final wizardState = ref.watch(bookingWizardControllerProvider);
    final controller = ref.read(bookingWizardControllerProvider.notifier);
    final draft = wizardState.draft;

    final patient = draft.patient;
    final clinic = draft.clinic;
    final date = draft.bookingDate;
    final doctor = draft.doctor;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    '4',
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
                'Konfirmasi Pendaftaran',
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
              'Pastikan seluruh data pendaftaran rawat jalan Anda sudah benar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pesan Error jika ada
          if (wizardState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dangerBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.dangerCrimson,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      wizardState.errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.dangerCrimson,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Kartu Ringkasan Bento Pendaftaran
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Data Pasien
                _SummaryRow(
                  icon: Icons.person_rounded,
                  title: 'Pasien yang Berobat',
                  value: patient?.fullName ?? '-',
                  subtitle:
                      'NIK: ${patient?.maskedNik ?? '-'}  •  '
                      '${patient?.isNewPatient ?? true ? 'Pasien Baru' : 'RM: ${patient?.maskedMedicalRecord}'}  '
                      '(${patient?.relation ?? '-'})',
                ),
                const Divider(color: AppColors.borderSubtle, height: 24),

                // 2. Data Penjaminan
                _SummaryRow(
                  icon: Icons.health_and_safety_rounded,
                  title: 'Jalur Penjaminan',
                  value: draft.insuranceType.label,
                  subtitle: draft.insuranceType.isBpjs
                      ? 'No. Rujukan: ${draft.bpjsReferenceNumber ?? '-'}'
                      : 'Pembayaran mandiri di loket kasir rumah sakit',
                ),
                const Divider(color: AppColors.borderSubtle, height: 24),

                // 3. Poliklinik & Jadwal
                _SummaryRow(
                  icon: Icons.local_hospital_rounded,
                  title: 'Poliklinik & Tanggal Kunjungan',
                  value: clinic?.name ?? '-',
                  subtitle: date != null
                      ? '${DateFormatter.hariTanggalPanjang(date)}  •  ${clinic?.floor ?? '-'}'
                      : '-',
                ),
                const Divider(color: AppColors.borderSubtle, height: 24),

                // 4. Dokter DPJP
                _SummaryRow(
                  icon: Icons.medical_services_rounded,
                  title: 'Dokter DPJP',
                  value: doctor?.name ?? '-',
                  subtitle:
                      '${doctor?.specialization ?? '-'}  •  '
                      '${doctor?.schedules.firstOrNull?.displayTime ?? '-'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Petunjuk Kedatangan Rumah Sakit (Ground Truth Kemenkes)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brandSoftSand),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.brandWarmBronze,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Ketentuan Kedatangan Rawat Jalan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Hadir di RSUP Dr. Sitanala 30 menit sebelum sesi praktik.\n'
                  '2. Scan barcode QR tiket digital Anda di mesin Anjungan Pasien Mandiri (APM) lobi rawat jalan.\n'
                  '3. Siapkan kartu identitas fisik (KTP/KIA) dan kartu BPJS asli untuk verifikasi berkas.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppColors.brandDarkEspresso,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checkbox Persetujuan
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.setAgreement(!draft.isAgreedToTerms),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: draft.isAgreedToTerms,
                      onChanged: (val) => controller.setAgreement(val ?? false),
                      activeColor: AppColors.brandGoldenCaramel,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Saya menyatakan data pendaftaran ini benar dan saya menyetujui seluruh ketentuan layanan RSUP Dr. Sitanala Tangerang.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandDarkEspresso,
                            height: 1.35,
                          ),
                        ),
                      ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.brandCreamLinen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.brandWarmBronze),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
