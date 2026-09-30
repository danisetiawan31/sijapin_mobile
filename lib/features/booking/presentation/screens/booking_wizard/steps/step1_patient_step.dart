import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_text_field.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';

import '../widgets/patient_selector_card.dart';

/// Langkah 1: Pemilihan Pasien / Anggota Keluarga & Jalur Penjaminan (US-BOOK-01).
class Step1PatientStep extends ConsumerStatefulWidget {
  const Step1PatientStep({super.key});

  @override
  ConsumerState<Step1PatientStep> createState() => _Step1PatientStepState();
}

class _Step1PatientStepState extends ConsumerState<Step1PatientStep> {
  late final TextEditingController _bpjsController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(bookingWizardControllerProvider).draft;
    _bpjsController = TextEditingController(text: draft.bpjsReferenceNumber);
  }

  @override
  void dispose() {
    _bpjsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wizardState = ref.watch(bookingWizardControllerProvider);
    final controller = ref.read(bookingWizardControllerProvider.notifier);
    final patientsAsync = ref.watch(patientMembersProvider);
    final draft = wizardState.draft;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Pemilihan Pasien
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
                'Pilih Pasien yang Berobat',
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
              'Pilih identitas pasien yang terdaftar pada akun keluarga Anda.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Daftar Pasien Keluarga
          patientsAsync.when(
            data: (patients) {
              if (patients.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: const Center(
                    child: Text('Belum ada data anggota keluarga terdaftar.'),
                  ),
                );
              }

              // Auto-select pasien pertama jika belum ada yang terpilih
              if (draft.patient == null && patients.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controller.setPatient(patients.first);
                });
              }

              return Column(
                children: [
                  for (final PatientMember p in patients) ...[
                    PatientSelectorCard(
                      patient: p,
                      isSelected: draft.patient?.id == p.id,
                      onTap: () {
                        controller.setPatient(p);
                      },
                    ),
                    const SizedBox(height: 10),
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
            error: (err, _) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dangerContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Gagal memuat daftar pasien: $err',
                style: const TextStyle(color: AppColors.dangerCrimson),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 20),

          // Section 2: Jalur Penjaminan
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
                'Jalur Penjaminan & Pembiayaan',
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
              'Tentukan metode pembayaran atau penjaminan kunjungan.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Pilihan BPJS Kesehatan
          _InsuranceOptionCard(
            type: InsuranceType.bpjs,
            isSelected: draft.insuranceType.isBpjs,
            onTap: () => controller.setInsuranceType(InsuranceType.bpjs),
            icon: Icons.health_and_safety_rounded,
          ),
          const SizedBox(height: 10),

          // Pilihan Pasien Umum
          _InsuranceOptionCard(
            type: InsuranceType.umum,
            isSelected: draft.insuranceType.isUmum,
            onTap: () => controller.setInsuranceType(InsuranceType.umum),
            icon: Icons.payments_outlined,
          ),

          // Input Nomor Rujukan jika BPJS
          if (draft.insuranceType.isBpjs) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brandCreamLinen.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.brandSoftSand.withValues(alpha: 0.8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: AppColors.brandWarmBronze,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nomor Rujukan FKTP / Surat Kontrol (SPRI) *',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    label: 'Nomor Rujukan FKTP / SPRI',
                    controller: _bpjsController,
                    hint: 'Contoh: 0123B0010926P000123',
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    maxLength: 19,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                    ],
                    onChanged: (val) {
                      controller.setBpjsReferenceNumber(val);
                    },
                    prefixIcon: Icons.confirmation_number_outlined,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Wajib diisi sesuai rujukan aktif dari Puskesmas / Klinik FKTP atau Surat Kontrol dokter RSUP Dr. Sitanala.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsuranceOptionCard extends StatelessWidget {
  const _InsuranceOptionCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  final InsuranceType type;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brandGoldenCaramel.withValues(alpha: 0.15)
                      : AppColors.brandCreamLinen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.brandWarmBronze
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.brandGoldenCaramel
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.brandGoldenCaramel
                        : AppColors.borderSubtle,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
