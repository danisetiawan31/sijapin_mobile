import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

/// Filter hubungan keluarga pada daftar anggota.
enum FamilyMemberFilter { semua, spouse, child, parent, sibling }

extension FamilyMemberFilterLabel on FamilyMemberFilter {
  String get label {
    switch (this) {
      case FamilyMemberFilter.semua:
        return 'Semua';
      case FamilyMemberFilter.spouse:
        return 'Pasangan';
      case FamilyMemberFilter.child:
        return 'Anak';
      case FamilyMemberFilter.parent:
        return 'Orang Tua';
      case FamilyMemberFilter.sibling:
        return 'Saudara';
    }
  }

  FamilyRelation? get relation {
    switch (this) {
      case FamilyMemberFilter.semua:
        return null;
      case FamilyMemberFilter.spouse:
        return FamilyRelation.spouse;
      case FamilyMemberFilter.child:
        return FamilyRelation.child;
      case FamilyMemberFilter.parent:
        return FamilyRelation.parent;
      case FamilyMemberFilter.sibling:
        return FamilyRelation.sibling;
    }
  }
}

/// Bilah filter hubungan keluarga: kapsul aktif warna karamel keemasan.
class FamilyFilterBar extends StatelessWidget {
  const FamilyFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final FamilyMemberFilter selected;
  final ValueChanged<FamilyMemberFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: FamilyMemberFilter.values.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final FamilyMemberFilter filter = FamilyMemberFilter.values[index];
          return FamilyFilterChip(
            label: filter.label,
            isSelected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

/// Chip pilihan filter kategori hubungan keluarga.
class FamilyFilterChip extends StatelessWidget {
  const FamilyFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.brandGoldenCaramel
                  : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: isSelected
                    ? AppColors.brandGoldenCaramel
                    : AppColors.borderSubtle,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
