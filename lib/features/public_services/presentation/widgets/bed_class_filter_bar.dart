import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Bilah filter kategori kelas rawat inap horizontal dengan feedback sentuh Material & Semantics.
class BedClassFilterBar extends StatelessWidget {
  const BedClassFilterBar({
    super.key,
    required this.filters,
    required this.selectedClass,
    required this.onSelected,
  });

  final List<String> filters;
  final String selectedClass;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final label = filters[index];
          final bool isActive = label == selectedClass;
          return Semantics(
            button: true,
            selected: isActive,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(label),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.brandGoldenCaramel
                        : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isActive
                          ? AppColors.brandGoldenCaramel
                          : AppColors.borderSubtle,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? AppColors.textWhite
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
