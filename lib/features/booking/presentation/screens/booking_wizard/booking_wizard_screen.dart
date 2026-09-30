import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';

import 'steps/step1_patient_step.dart';
import 'steps/step2_clinic_date_step.dart';
import 'steps/step3_doctor_step.dart';
import 'steps/step4_confirmation_step.dart';
import 'widgets/booking_success_dialog.dart';
import 'widgets/wizard_progress_bar.dart';

/// Layar utama Wizard Pendaftaran Rawat Jalan 4 Langkah (Epic 05).
class BookingWizardScreen extends ConsumerWidget {
  const BookingWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wizardState = ref.watch(bookingWizardControllerProvider);
    final controller = ref.read(bookingWizardControllerProvider.notifier);
    final draft = wizardState.draft;
    final currentStep = draft.currentStep;

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            currentStep == 0
                ? Icons.close_rounded
                : Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.brandDarkEspresso,
          ),
          onPressed: () {
            if (currentStep == 0) {
              context.pop();
            } else {
              controller.previousStep();
            }
          },
        ),
        title: Column(
          children: [
            const Text(
              'Pendaftaran Rawat Jalan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Langkah ${currentStep + 1} dari 4',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Indikator Langkah 1-2-3-4
            WizardProgressBar(
              currentStep: currentStep,
              onStepTapped: (index) => controller.goToStep(index),
            ),

            // Konten Langkah Aktif
            Expanded(
              child: IndexedStack(
                index: currentStep,
                children: const [
                  Step1PatientStep(),
                  Step2ClinicDateStep(),
                  Step3DoctorStep(),
                  Step4ConfirmationStep(),
                ],
              ),
            ),

            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                border: const Border(
                  top: BorderSide(color: AppColors.borderSubtle, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandDarkEspresso.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tombol Kembali
                  if (currentStep > 0) ...[
                    AppSecondaryButton(
                      label: 'Kembali',
                      width: 105,
                      onPressed: wizardState.isSubmitting
                          ? null
                          : () => controller.previousStep(),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Tombol Lanjut / Konfirmasi
                  Expanded(
                    child: AppPrimaryButton(
                      label: currentStep == 3
                          ? (wizardState.isSubmitting
                                ? 'Memproses Pendaftaran...'
                                : 'Konfirmasi & Buat Janji')
                          : 'Lanjutkan ➔',
                      isLoading: wizardState.isSubmitting,
                      onPressed:
                          !draft.canProceedCurrentStep ||
                              wizardState.isSubmitting
                          ? null
                          : () async {
                              if (currentStep < 3) {
                                controller.nextStep();
                              } else {
                                // Final submit di Step 4
                                final appointment = await controller
                                    .submitBooking();
                                if (appointment != null && context.mounted) {
                                  // Tampilkan Modal Dialog Sukses
                                  await BookingSuccessDialog.show(
                                    context,
                                    appointment,
                                  );
                                }
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
