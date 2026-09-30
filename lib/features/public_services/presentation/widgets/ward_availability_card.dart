import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

/// Kartu ketersediaan bed per ruangan/bangsal.
///
/// Referensi visual: `.ai-docs/stitch_design/Ketersedian-Kamar/screen.png`.
/// Varian penuh (ICU) memakai bingkai rose sesuai desain.
class WardAvailabilityCard extends StatelessWidget {
  const WardAvailabilityCard({
    super.key,
    required this.ward,
    this.onDetailTap,
    this.onProtocolTap,
  });

  final WardAvailability ward;

  /// Aksi "Detail Ruangan" (fase-2 placeholder bila null).
  final VoidCallback? onDetailTap;

  /// Aksi "Protokol IGD" khusus ruangan penuh (fase-2 placeholder bila null).
  final VoidCallback? onProtocolTap;

  IconData get _icon {
    if (ward.category == 'ICU') return Icons.monitor_heart_rounded;
    if (ward.specialty == 'Pediatri') return Icons.child_care_rounded;
    return Icons.bed_rounded;
  }

  bool get _isFull => ward.status == WardStatus.full;

  String _updateLabel(DateTime now) {
    final int freshMinutes = AppConstants.bedDataFreshnessMinutes;
    if (ward.isRealtime ||
        now.difference(ward.updatedAt).inMinutes < freshMinutes) {
      return 'Real-time';
    }
    return DateFormatter.waktuRelatif(ward.updatedAt, reference: now);
  }

  void _placeholder(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = _isFull
        ? AppColors.dangerCrimson
        : AppColors.brandGoldenCaramel;
    final Color iconBg = _isFull
        ? AppColors.dangerContainer
        : AppColors.brandCreamLinen;
    final Color iconBorder = _isFull
        ? AppColors.dangerBorder
        : AppColors.borderSubtle;

    final Widget content = AppCard.elevated(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris identitas + badge status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: iconBorder),
                ),
                child: Icon(_icon, size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ward.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ward.specialty} • ${ward.floorBuilding}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (_isFull)
                const AppBadge.danger(
                  label: 'Penuh (0 Bed)',
                  icon: Icons.circle,
                )
              else
                AppBadge.success(
                  label: '${ward.availableBeds} Bed Kosong',
                  icon: Icons.circle,
                ),
            ],
          ),

          // Rincian kelas atau catatan peringatan
          if (_isFull) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.dangerContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.dangerBorder.withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.dangerCrimson,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hubungi IGD untuk rujukan darurat antar-RS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.dangerCrimson,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            _ClassBreakdown(
              ward: ward,
              highlightedClass: ward.highlightedClass,
            ),
          ],

          // Footer: pembaruan + tautan aksi
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSubtle, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isFull
                          ? Icons.history_toggle_off_rounded
                          : Icons.schedule_rounded,
                      size: 14,
                      color: _isFull
                          ? AppColors.dangerCrimson
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Update: ${_updateLabel(DateTime.now())}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _isFull ? FontWeight.w500 : FontWeight.w400,
                        color: _isFull
                            ? AppColors.dangerCrimson
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap:
                      onDetailTap ??
                      (_isFull ? onProtocolTap : null) ??
                      () => _placeholder(
                        context,
                        _isFull
                            ? 'Protokol IGD segera hadir'
                            : 'Detail ruangan segera hadir',
                      ),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isFull ? 'Protokol IGD' : 'Detail Ruangan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Varian penuh memakai bingkai rose (AppCard tidak menyediakan
    // override border, jadi dibungkus — bukan duplikasi komponen).
    if (!_isFull) return content;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.dangerBorder.withValues(alpha: 0.6),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

/// Kapsul rincian bed per kelas dengan pemisah titik.
class _ClassBreakdown extends StatelessWidget {
  const _ClassBreakdown({required this.ward, required this.highlightedClass});

  final WardAvailability ward;
  final String? highlightedClass;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    for (int i = 0; i < ward.classBreakdown.length; i++) {
      final c = ward.classBreakdown[i];
      final bool highlighted = c.className == highlightedClass;
      children.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.successContainer
                : AppColors.brandCreamLinen.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(999),
            border: highlighted
                ? Border.all(
                    color: AppColors.successBorder.withValues(alpha: 0.4),
                  )
                : null,
          ),
          child: Text.rich(
            TextSpan(
              text: '${c.className}: ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: highlighted
                    ? AppColors.successEmerald
                    : AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '${c.availableBeds} bed',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      );
      if (i < ward.classBreakdown.length - 1) {
        children.add(
          const Text(
            '•',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.borderSubtle,
            ),
          ),
        );
      }
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
