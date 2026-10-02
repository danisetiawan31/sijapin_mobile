import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/constants/app_constants.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/features/public_services/domain/entities/bed_availability.dart';

/// Kartu ketersediaan bed per ruangan/bangsal dengan indikator 3-tier status (SSOT PRD).
class WardAvailabilityCard extends StatelessWidget {
  const WardAvailabilityCard({
    super.key,
    required this.ward,
    this.onDetailTap,
    this.onProtocolTap,
  });

  final WardAvailability ward;
  final VoidCallback? onDetailTap;
  final VoidCallback? onProtocolTap;

  IconData get _icon {
    if (ward.category == 'ICU' ||
        ward.name.toUpperCase().contains('ICU') ||
        ward.name.toUpperCase().contains('INTENSIF')) {
      return Icons.monitor_heart_rounded;
    }
    if (ward.specialty == 'Pediatri' ||
        ward.name.toUpperCase().contains('ANAK') ||
        ward.name.toUpperCase().contains('BAYI')) {
      return Icons.child_care_rounded;
    }
    if (ward.name.toUpperCase().contains('KEBIDANAN')) {
      return Icons.pregnant_woman_rounded;
    }
    return Icons.bed_rounded;
  }

  bool get _isFull => ward.status == WardStatus.full;
  bool get _isLimited => ward.status == WardStatus.limited;

  String _updateLabel(DateTime now) {
    final int freshMinutes = AppConstants.bedDataFreshnessMinutes;
    if (ward.isRealtime ||
        now.difference(ward.updatedAt).inMinutes < freshMinutes) {
      return 'Real-time';
    }
    return DateFormatter.waktuRelatif(ward.updatedAt, reference: now);
  }

  Widget _buildStatusBadge() {
    switch (ward.status) {
      case WardStatus.full:
        return const AppBadge.danger(
          label: 'Penuh (0 Bed)',
          icon: Icons.circle,
        );
      case WardStatus.limited:
        return AppBadge.warning(
          label: '${ward.availableBeds} Bed Terbatas',
          icon: Icons.circle,
        );
      case WardStatus.available:
        return AppBadge.success(
          label: '${ward.availableBeds} Bed Kosong',
          icon: Icons.circle,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color accent;
    Color iconBg;
    Color iconBorder;

    if (_isFull) {
      accent = AppColors.dangerCrimson;
      iconBg = AppColors.dangerContainer;
      iconBorder = AppColors.dangerBorder;
    } else if (_isLimited) {
      accent = AppColors.warningAmber;
      iconBg = AppColors.warningContainer;
      iconBorder = AppColors.warningBorder;
    } else {
      accent = AppColors.brandGoldenCaramel;
      iconBg = AppColors.brandCreamLinen;
      iconBorder = AppColors.borderSubtle;
    }

    final Widget content = AppCard.elevated(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris identitas + badge status 3-tier
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
              _buildStatusBadge(),
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
                        color: AppColors.dangerCrimson,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (ward.classBreakdown.isNotEmpty) ...[
            const SizedBox(height: 14),
            _ClassBreakdown(
              ward: ward,
              highlightedClass: ward.highlightedClass,
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 10),

          // Baris bawah: metadata pembaruan & aksi
          Semantics(
            container: true,
            label: ward.isRealtime
                ? 'Update: Real-time'
                : 'Update: ${_updateLabel(DateTime.now())}',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ward.isRealtime
                          ? Icons.sensors_rounded
                          : Icons.access_time_rounded,
                      size: 13,
                      color: ward.isRealtime
                          ? AppColors.clinicalTeal
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ward.isRealtime
                          ? 'Update: Real-time'
                          : 'Update: ${_updateLabel(DateTime.now())}',
                      style: TextStyle(
                        fontSize: 11,
                        color: ward.isRealtime
                            ? AppColors.clinicalTealDeep
                            : AppColors.textMuted,
                        fontWeight: ward.isRealtime
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap:
                      onDetailTap ?? (_isFull ? onProtocolTap : null) ?? () {},
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
      final isClassFull = c.availableBeds <= 0;
      final isClassLimited = c.availableBeds > 0 && c.availableBeds <= 2;

      Color badgeBg;
      Color textColor;
      if (isClassFull) {
        badgeBg = AppColors.dangerContainer.withValues(alpha: 0.5);
        textColor = AppColors.dangerCrimson;
      } else if (isClassLimited) {
        badgeBg = AppColors.warningContainer.withValues(alpha: 0.6);
        textColor = AppColors.warningAmber;
      } else if (highlighted) {
        badgeBg = AppColors.successContainer;
        textColor = AppColors.successEmerald;
      } else {
        badgeBg = AppColors.brandCreamLinen.withValues(alpha: 0.8);
        textColor = AppColors.textPrimary;
      }

      children.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
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
                color: textColor,
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
