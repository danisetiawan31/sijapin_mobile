import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Header permanen (pinned) untuk layar Beranda SIIJAPIN Mobile.
///
/// Menampilkan identitas resmi RSUP Dr. Sitanala, akses notifikasi instan
/// dengan indikator unread, dan tombol login / profil pasien yang selalu
/// dapat dijangkau dari posisi scroll mana pun.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.hasUnreadNotifications = true,
    this.onNotificationTap,
    this.onLoginTap,
    this.onProfileTap,
    this.showBottomDivider = true,
  });

  /// Status apakah pasien sudah terautentikasi atau masih mode tamu.
  final bool isLoggedIn;

  /// Nama pasien yang ditampilkan saat [isLoggedIn] bernilai true.
  final String? userName;

  /// Menampilkan dot merah indikator pemberitahuan baru pada tombol lonceng.
  final bool hasUnreadNotifications;

  /// Callback saat tombol lonceng notifikasi ditekan.
  final VoidCallback? onNotificationTap;

  /// Callback saat tombol "Masuk" ditekan (mode tamu).
  final VoidCallback? onLoginTap;

  /// Callback saat tombol profil ditekan (mode terautentikasi).
  final VoidCallback? onProfileTap;

  /// Menampilkan garis pemisah halus di perbatasan bawah saat konten bergulir.
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        border: showBottomDivider
            ? Border(
                bottom: BorderSide(
                  color: AppColors.borderSubtle.withValues(alpha: 0.6),
                  width: 1,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Sisi Kiri: Logo Rumah Sakit & Identitas (Expanded agar responsif di layar kecil)
          Expanded(child: _buildHospitalBrand(context)),
          const SizedBox(width: 8),

          // Sisi Kanan: Lonceng Notifikasi & Tombol Masuk / Profil
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationButton(context),
              const SizedBox(width: 8),
              if (isLoggedIn)
                _buildProfileButton(context)
              else
                _buildLoginButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalBrand(BuildContext context) {
    return Semantics(
      label: 'Identitas Resmi RSUP Dr. Sitanala Tangerang',
      child: Row(
        children: [
          // Logo RSUP Dr. Sitanala (Squircle Badge Emas)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.brandGoldenCaramel.withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.local_hospital_rounded,
                size: 20,
                color: AppColors.brandGoldenCaramel,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Teks Judul & Subjudul (Flexible agar tidak overflow)
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.hospitalName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDarkEspresso,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  AppConstants.hospitalTagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return Semantics(
      button: true,
      label: hasUnreadNotifications
          ? 'Notifikasi, ada pemberitahuan baru'
          : 'Notifikasi',
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onNotificationTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.dangerCrimson,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceCard,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Masuk ke akun SIIJAPIN',
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onLoginTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 17,
                  color: AppColors.brandGoldenCaramel,
                ),
                SizedBox(width: 4),
                Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandGoldenCaramel,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    final displayName = userName ?? 'Pasien';
    return Semantics(
      button: true,
      label: 'Profil $displayName',
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.brandGoldenCaramel.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandDarkEspresso.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGoldenCaramel,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 70),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandDarkEspresso,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
