import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/data_masker.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

/// Label dan ikon hubungan keluarga sesuai DESIGN.md §6 (ikon dalam kontainer
/// bersudut lembut).
extension FamilyRelationLabel on FamilyRelation {
  String get label {
    switch (this) {
      case FamilyRelation.spouse:
        return 'Suami / Istri';
      case FamilyRelation.child:
        return 'Anak';
      case FamilyRelation.parent:
        return 'Orang Tua';
      case FamilyRelation.sibling:
        return 'Saudara';
    }
  }

  IconData get icon {
    switch (this) {
      case FamilyRelation.spouse:
        return Icons.favorite_outline_rounded;
      case FamilyRelation.child:
        return Icons.child_care_outlined;
      case FamilyRelation.parent:
        return Icons.elderly_outlined;
      case FamilyRelation.sibling:
        return Icons.diversity_1_outlined;
    }
  }
}

/// Label singkat jaminan kesehatan anggota keluarga.
extension FamilyInsuranceLabel on FamilyInsurance {
  String get label {
    switch (this) {
      case FamilyInsurance.bpjs:
        return 'BPJS';
      case FamilyInsurance.umum:
        return 'Umum';
      case FamilyInsurance.selfPay:
        return 'Biaya Sendiri';
    }
  }
}

/// Kartu satu anggota keluarga terdaftar.
///
/// Mengikuti DESIGN.md §5 & §8: kartu squircle bertahap, bukan tabel datar,
/// dengan hierarki nama, hubungan, serta data identitas tersamar.
class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  final FamilyMember member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int? umur = DateFormatter.umur(birthDate: member.birthDate);

    return AppCard.elevated(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InitialsAvatar(initials: member.initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${member.relation.label} • ${member.gender == 'L' ? 'Laki-laki' : 'Perempuan'}'
                      '${umur == null ? '' : ', $umur tahun'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        AppBadge.neutral(
                          label: member.insurance.label,
                          icon: Icons.health_and_safety_outlined,
                        ),
                        if (member.isPrimary)
                          const AppBadge.warning(label: 'Anggota Utama')
                        else if (member.hasProfileComplete)
                          const AppBadge.success(
                            label: 'Data Lengkap',
                            icon: Icons.check_circle_outline_rounded,
                          )
                        else
                          const AppBadge.warning(
                            label: 'Belum Lengkap',
                            icon: Icons.warning_amber_rounded,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'NIK ${DataMasker.maskNik(member.nik)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              const Text(
                'Lihat Detail',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandGoldenCaramel,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.brandGoldenCaramel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Avatar inisial dalam kontainer bersudut lembut (DESIGN.md §6).
class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandSoftSand),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.brandDeepChocolate,
        ),
      ),
    );
  }
}
