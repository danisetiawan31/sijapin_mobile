import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Satu tab pada [BookingTabSwitch] beserta jumlah tiket aktif bila ada.
class BookingTabItem {
  const BookingTabItem(this.label, {this.count});

  final String label;
  final int? count;
}

/// Pemilih tab Janji Temu (Tiket Aktif / Riwayat Selesai).
///
/// Wadah cream linen dengan radius 16, tab aktif memakai aksen
/// `#AA7409` dan menampilkan jumlah tiket dalam pil transparan.
class BookingTabSwitch extends StatelessWidget {
  const BookingTabSwitch({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<BookingTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int index = 0; index < tabs.length; index++) ...[
            if (index > 0) const SizedBox(width: 6),
            Expanded(
              child: _Segment(
                tab: tabs[index],
                isSelected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final BookingTabItem tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int? count = tab.count;
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
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  tab.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected && count != null && count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
