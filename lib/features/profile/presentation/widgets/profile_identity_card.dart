import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/data_masker.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_profile.dart';

/// Kartu identitas utama pasien di tab Profil.
///
/// Mengikuti DESIGN.md §2 (kontras teks gelap di atas container terang) dan
/// §6 (avatar di dalam kontainer bersudut lembut `rounded.md`).
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final bool isLengkap = user.hasProfileComplete;

    return AppCard.elevated(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _InitialsAvatar(initials: user.initials),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DataMasker.maskEmail(user.email),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLengkap)
                      const AppBadge.success(label: 'Data Terverifikasi')
                    else
                      const AppBadge.warning(label: 'Data Belum Lengkap'),
                  ],
                ),
              ),
            ],
          ),
          if (!isLengkap) ...[
            const SizedBox(height: 16),
            const _ProfileIncompleteNotice(),
          ],
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.brandSoftSand),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.brandDeepChocolate,
        ),
      ),
    );
  }
}

class _ProfileIncompleteNotice extends StatelessWidget {
  const _ProfileIncompleteNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningAmber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.warningAmber.withValues(alpha: 0.28),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, size: 18, color: AppColors.warningAmber),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lengkapi NIK dan tanggal lahir agar proses pendaftaran '
              'janji temu lebih cepat diproses.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu ringkasan data diri pasien (NIK disensor sesuai UU PDP No. 27/2022).
class ProfileDataCard extends StatelessWidget {
  const ProfileDataCard({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final int? umur = DateFormatter.umur(birthDate: user.birthDate);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Diri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.brandDarkEspresso,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pastikan data sesuai dengan identitas resmi untuk expedite layanan.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ProfileInfoRow(
            label: 'NIK',
            value: DataMasker.maskNik(user.nik),
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),
          ProfileInfoRow(
            label: 'Nomor HP',
            value: DataMasker.maskPhone(user.phone),
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 12),
          ProfileInfoRow(
            label: 'Jenis Kelamin',
            value: user.gender == 'L' ? 'Laki-laki' : 'Perempuan',
            icon: user.gender == 'L'
                ? Icons.male_rounded
                : Icons.female_rounded,
          ),
          const SizedBox(height: 12),
          ProfileInfoRow(
            label: 'Golongan Darah',
            value: user.bloodType.trim().isEmpty
                ? 'Belum diisi'
                : user.bloodType,
            icon: Icons.bloodtype_outlined,
          ),
          const SizedBox(height: 12),
          ProfileInfoRow(
            label: 'Tanggal Lahir',
            value: user.birthDate == null
                ? 'Belum diisi'
                : (umur == null
                      ? DateFormatter.tanggalPanjang(user.birthDate!)
                      : '${DateFormatter.tanggalPanjang(user.birthDate!)} '
                            '($umur tahun)'),
            icon: Icons.cake_outlined,
          ),
          const SizedBox(height: 12),
          ProfileInfoRow(
            label: 'Alamat',
            value: user.address.trim().isEmpty ? 'Belum diisi' : user.address,
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          ProfileInfoRow(
            label: 'Anggota Sejak',
            value: DateFormatter.tanggalPendek(user.memberSince),
            icon: Icons.verified_user_outlined,
          ),
        ],
      ),
    );
  }
}

/// Baris label-nilai pada [ProfileDataCard].
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.brandCreamLinen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: AppColors.brandWarmBronze),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.02,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
