import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/medical_record.dart';

/// Label dan ikon klinis untuk setiap [MedicalRecordType].
extension MedicalRecordTypeLabel on MedicalRecordType {
  String get label {
    switch (this) {
      case MedicalRecordType.consultation:
        return 'Kunjungan Poli';
      case MedicalRecordType.laboratory:
        return 'Hasil Lab';
      case MedicalRecordType.prescription:
        return 'Resep Obat';
      case MedicalRecordType.inpatient:
        return 'Rawat Inap';
    }
  }

  IconData get icon {
    switch (this) {
      case MedicalRecordType.consultation:
        return Icons.local_hospital_outlined;
      case MedicalRecordType.laboratory:
        return Icons.biotech_rounded;
      case MedicalRecordType.prescription:
        return Icons.medication_rounded;
      case MedicalRecordType.inpatient:
        return Icons.bed_rounded;
    }
  }
}

/// Kartu satu catatan riwayat medis di dalam linimasa.
///
/// Mengikuti DESIGN.md §8: bukan tabel datar, melainkan kartu bertahap
/// dengan hierarchy label, diagnosis, dan ajakan membuka resume.
class MedicalRecordCard extends StatelessWidget {
  const MedicalRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  final MedicalRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.tanggalPanjang(record.date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      record.clinic,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppBadge.clinical(
                label: record.type.label,
                icon: record.type.icon,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  record.doctorName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DIAGNOSIS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.diagnosis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Resume',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.clinicalTeal.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.clinicalTeal.withValues(alpha: 0.9),
                  ),
                ],
              ),
              if (record.medicalRecordNumber != null)
                Flexible(
                  child: Text(
                    'RM ${record.medicalRecordNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Linimasa vertikal catatan riwayat medis dengan penanda teal.
class MedicalRecordTimeline extends StatelessWidget {
  const MedicalRecordTimeline({
    super.key,
    required this.records,
    required this.onRecordTap,
  });

  final List<MedicalRecord> records;
  final ValueChanged<MedicalRecord> onRecordTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int index = 0; index < records.length; index++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TimelineRail(isLast: index == records.length - 1),
                Expanded(
                  child: MedicalRecordCard(
                    record: records[index],
                    onTap: () => onRecordTap(records[index]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Titik penanda dan garis penghubung antar catatan.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.isLast});

  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.clinicalTeal,
              shape: BoxShape.circle,
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: AppColors.clinicalTeal.withValues(alpha: 0.2),
              ),
            ),
        ],
      ),
    );
  }
}
