import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';

/// Kartu pilihan pasien / anggota keluarga pada Step 1 Wizard Booking.
class PatientSelectorCard extends StatelessWidget {
  const PatientSelectorCard({
    super.key,
    required this.patient,
    required this.isSelected,
    required this.onTap,
  });

  final PatientMember patient;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.brandGoldenCaramel.withValues(alpha: 0.1),
        highlightColor: AppColors.brandCreamLinen.withValues(alpha: 0.4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandGoldenCaramel.withValues(alpha: 0.06)
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandGoldenCaramel
                  : AppColors.borderSubtle,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandGoldenCaramel.withValues(
                        alpha: 0.12,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.brandDarkEspresso.withValues(
                        alpha: 0.02,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Avatar inisial dengan background aksen Sitanala
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brandGoldenCaramel
                      : AppColors.brandCreamLinen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    patient.initials,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : AppColors.brandDarkEspresso,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Rincian identitas pasien
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            patient.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandDarkEspresso,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Badge hubungan keluarga
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandDarkEspresso.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            patient.relation,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brandDarkEspresso,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // No. RM & NIK
                    Row(
                      children: [
                        Text(
                          'NIK: ${patient.maskedNik}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            patient.isNewPatient
                                ? 'Pasien Baru'
                                : 'RM: ${patient.maskedMedicalRecord}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: patient.isNewPatient
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: patient.isNewPatient
                                  ? AppColors.clinicalTeal
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Indikator Radio Bulat
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
