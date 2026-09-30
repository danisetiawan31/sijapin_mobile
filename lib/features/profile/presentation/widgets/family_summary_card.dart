import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

/// Kartu ringkasan jumlah anggota, jaminan BPJS, dan anggota utama.
class FamilySummaryCard extends StatelessWidget {
  const FamilySummaryCard({super.key, required this.members});

  final List<FamilyMember> members;

  @override
  Widget build(BuildContext context) {
    final List<FamilyMember> bpjsMembers = members
        .where(
          (FamilyMember member) => member.insurance == FamilyInsurance.bpjs,
        )
        .toList();
    final FamilyMember? utama = members
        .where((FamilyMember member) => member.isPrimary)
        .firstOrNull;

    return AppCard.filled(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandGoldenCaramel.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.groups_2_outlined,
              size: 22,
              color: AppColors.brandGoldenCaramel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${members.length} anggota keluarga',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${bpjsMembers.length} memakai BPJS • '
                  'Utama: ${utama?.fullName ?? 'Belum ada'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
