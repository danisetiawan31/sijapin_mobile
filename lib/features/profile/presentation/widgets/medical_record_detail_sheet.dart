import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/medical_record.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/medical_record_card.dart';

/// Bottom sheet resume lengkap satu catatan riwayat medis.
///
/// Backdrop gelap hangat mengikuti DESIGN.md §5 level 3, dan isi resume
/// memakai aksen `clinical-teal` sebagai penanda klinis.
class MedicalRecordDetailSheet extends StatelessWidget {
  const MedicalRecordDetailSheet({super.key, required this.record});

  final MedicalRecord record;

  static Future<void> show(BuildContext context, MedicalRecord record) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.brandDarkEspresso.withValues(alpha: 0.45),
      builder: (BuildContext _) => MedicalRecordDetailSheet(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: AppBadge.clinical(
                  label: record.type.label,
                  icon: record.type.icon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                record.diagnosis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormatter.tanggalPanjang(record.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 16),
              _DetailRow(label: 'Poli', value: record.clinic),
              const SizedBox(height: 12),
              _DetailRow(label: 'Dokter', value: record.doctorName),
              if (record.medicalRecordNumber != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'No. Rekam Medis',
                  value: record.medicalRecordNumber!,
                  isMono: true,
                ),
              ],
              const SizedBox(height: 16),
              _SummaryBlock(text: record.summary),
              if (record.hasTreatment) ...[
                const SizedBox(height: 16),
                _ListBlock(title: 'Tindakan', items: record.treatment),
              ],
              if (record.hasMedication) ...[
                const SizedBox(height: 16),
                _ListBlock(title: 'Resep Obat', items: record.medication),
              ],
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: 'Tutup',
                icon: Icons.close_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isMono = false,
  });

  final String label;
  final String value;
  final bool isMono;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: isMono ? 'monospace' : null,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.brandDarkEspresso,
            ),
          ),
        ),
      ],
    );
  }
}

/// Blok ringkasan pemeriksaan dengan latar linen hangat.
class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RINGKASAN',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.brandDarkEspresso,
            ),
          ),
        ],
      ),
    );
  }
}

/// Blok daftar tindakan atau resep obat.
class _ListBlock extends StatelessWidget {
  const _ListBlock({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        for (final String item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.clinicalTeal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}
