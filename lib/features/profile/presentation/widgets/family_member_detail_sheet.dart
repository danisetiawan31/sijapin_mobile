import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/data_masker.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_badge.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_card.dart';

/// Bottom sheet profil lengkap satu anggota keluarga.
///
/// Backdrop gelap hangat mengikuti DESIGN.md §5 level 3, dan aksi utama
/// diletakkan di bagian bawah (thumb zone, DESIGN.md §4.2).
class FamilyMemberDetailSheet extends StatelessWidget {
  const FamilyMemberDetailSheet({super.key, required this.member});

  final FamilyMember member;

  static Future<void> show(BuildContext context, FamilyMember member) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.brandDarkEspresso.withValues(alpha: 0.45),
      builder: (BuildContext _) => FamilyMemberDetailSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int? umur = DateFormatter.umur(birthDate: member.birthDate);

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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.brandCreamLinen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.brandSoftSand),
                    ),
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDeepChocolate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: AppColors.brandDarkEspresso,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            AppBadge.neutral(
                              label: member.relation.label,
                              icon: member.relation.icon,
                            ),
                            AppBadge.neutral(
                              label: member.insurance.label,
                              icon: Icons.health_and_safety_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 16),
              _DetailRow(label: 'NIK', value: DataMasker.maskNik(member.nik)),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Tanggal Lahir',
                value: member.birthDate == null
                    ? 'Belum diisi'
                    : '${DateFormatter.tanggalPanjang(member.birthDate!)}'
                          '${umur == null ? '' : ' ($umur tahun)'}',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Jenis Kelamin',
                value: member.gender == 'L' ? 'Laki-laki' : 'Perempuan',
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Golongan Darah',
                value: member.bloodType.trim().isEmpty
                    ? 'Belum diisi'
                    : member.bloodType,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Nomor HP',
                value: member.phone.trim().isEmpty
                    ? 'Belum diisi'
                    : DataMasker.maskPhone(member.phone),
              ),
              if (member.insuranceNumber != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'No. Kartu BPJS',
                  value: DataMasker.maskBpjs(member.insuranceNumber),
                  isMono: true,
                ),
              ],
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Layanan Terakhir',
                value: member.lastServiceDate == null
                    ? 'Belum pernah berobat'
                    : DateFormatter.tanggalPanjang(member.lastServiceDate!),
              ),
              if (member.healthNote != null) ...[
                const SizedBox(height: 16),
                _NoteBlock(text: member.healthNote!),
              ],
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: 'Buat Janji Temu',
                icon: Icons.event_available_outlined,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
              AppSecondaryButton(
                label: 'Hapus Anggota',
                icon: Icons.delete_outline_rounded,
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

/// Blok catatan kesehatan dengan latar linen hangat (DESIGN.md §7.C).
class _NoteBlock extends StatelessWidget {
  const _NoteBlock({required this.text});

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
            'CATATAN KESEHATAN',
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
