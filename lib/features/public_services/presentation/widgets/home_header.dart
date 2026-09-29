import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Header dinamis Beranda SIIJAPIN Mobile.
///
/// Menampilkan sapaan kontekstual berdasarkan waktu, search pill interaktif
/// untuk pencarian dokter/poliklinik/layanan, serta akses notifikasi dan
/// tombol login / profil pasien yang selalu terjangkau.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.isLoggedIn = false,
    this.userName,
    this.hasUnreadNotifications = true,
    this.onNotificationTap,
    this.onLoginTap,
    this.onProfileTap,
    this.onSearchTap,
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

  /// Callback saat search pill ditekan.
  final VoidCallback? onSearchTap;

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
                  color: AppColors.borderSubtle.withValues(alpha: 0.5),
                  width: 0.5,
                ),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Sisi Kiri: Identitas Resmi RSUP Dr. Sitanala
          Expanded(child: _buildHospitalIdentity()),

          // Sisi Kanan: Notifikasi & Tombol Masuk/Profil
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationButton(),
              const SizedBox(width: 8),
              if (isLoggedIn) _buildProfileButton() else _buildLoginButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalIdentity() {
    return Semantics(
      label: '${AppConstants.hospitalName}, ${AppConstants.hospitalTagline}',
      child: Row(
        children: [
          // Logo RSUP Sitanala (Embossed Cross)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.goldenSoftLinen.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: AppColors.brandGoldenCaramel.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGoldenCaramel.withValues(alpha: 0.10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.local_hospital_rounded,
                color: AppColors.brandGoldenCaramel,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Teks Identitas
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
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandDarkEspresso,
                    letterSpacing: -0.3,
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
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.6),
                width: 0.8,
              ),
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

  Widget _buildLoginButton() {
    return Semantics(
      button: true,
      label: 'Masuk ke akun SIIJAPIN',
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onLoginTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.goldenSoftLinen.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.brandGoldenCaramel.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandGoldenCaramel.withValues(alpha: 0.12),
                  blurRadius: 8,
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
                  child: const Center(
                    child: Icon(
                      Icons.login_rounded,
                      size: 13,
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandDarkEspresso,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
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
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.clinicalContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.clinicalBorder, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.clinicalTeal,
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
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 70),
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.clinicalTealDeep,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppColors.clinicalTeal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
