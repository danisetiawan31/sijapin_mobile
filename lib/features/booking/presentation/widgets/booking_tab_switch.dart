import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Pemilih tab Janji Temu (Tiket Aktif / Riwayat Selesai).
///
/// Tab aktif memakai warna aksen `#AA7409` yang sama dengan tombol aksi primer
/// "Buka Tiket QR" agar konsisten dengan hierarki aksi di DESIGN.md.
class BookingTabSwitch extends StatelessWidget {
  const BookingTabSwitch({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          for (int index = 0; index < labels.length; index++)
            Expanded(
              child: _Segment(
                label: labels[index],
                isSelected: index == selectedIndex,
                onTap: () => onSelected(index),
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandGoldenCaramel
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandGoldenCaramel.withValues(
                        alpha: 0.35,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
