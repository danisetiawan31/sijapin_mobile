import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

enum HistoryFilter { semua, selesai, dibatalkan }

extension HistoryFilterLabel on HistoryFilter {
  String get label {
    switch (this) {
      case HistoryFilter.semua:
        return 'Semua';
      case HistoryFilter.selesai:
        return 'Selesai';
      case HistoryFilter.dibatalkan:
        return 'Dibatalkan';
    }
  }
}

/// Bilah filter kunjungan: `Semua`, `Selesai`, `Dibatalkan`.
///
/// Kapsul aktif memakai espresso solid, kapsul tidak aktif putih dengan border
/// tipis `borderSubtle` mengikuti token DESIGN.md.
class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final HistoryFilter filter in HistoryFilter.values) ...[
          Flexible(
            child: _FilterChip(
              label: filter.label,
              isSelected: filter == selected,
              onTap: () => onSelected(filter),
            ),
          ),
          if (filter != HistoryFilter.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandDarkEspresso
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandDarkEspresso
                  : AppColors.borderSubtle,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandDarkEspresso.withValues(alpha: 0.2),
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
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
