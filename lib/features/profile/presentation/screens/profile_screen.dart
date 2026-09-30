import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/biometrics/biometric_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/passcode/passcode_controller.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/user_profile.dart';
import '../controllers/profile_controller.dart';
import '../widgets/passcode_setup_sheet.dart';
import '../widgets/profile_identity_card.dart';
import '../widgets/profile_menu_card.dart';

/// Tab 4: Profil Pasien — identitas, data diri, dan pengaturan akun.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProfileState state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );
    final UserProfile? user = state.user;
    final BiometricState biometric =
        ref.watch(biometricControllerProvider).asData?.value ??
        const BiometricState();
    final BiometricController biometricController = ref.read(
      biometricControllerProvider.notifier,
    );
    final PasscodeState passcode =
        ref.watch(passcodeControllerProvider).asData?.value ??
        const PasscodeState();
    final PasscodeController passcodeController = ref.read(
      passcodeControllerProvider.notifier,
    );

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ProfileTitle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (user == null)
                      const _SignedOutCard()
                    else
                      ProfileIdentityCard(user: user),

                    const SizedBox(height: 24),

                    if (user != null) ...[
                      ProfileDataCard(user: user),
                      const SizedBox(height: 24),
                    ],

                    ProfileMenuCard(
                      title: 'Akun',
                      children: [
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Edit Profil',
                          subtitle: 'Nama, NIK, alamat, data kesehatan',
                          onTap: () => _showComingSoon(context, 'Edit Profil'),
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuItem(
                          icon: Icons.lock_outline_rounded,
                          label: 'Ganti Kata Sandi',
                          onTap: () =>
                              _showComingSoon(context, 'Ganti Kata Sandi'),
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuItem(
                          icon: Icons.fingerprint_rounded,
                          label: 'Kunci Biometrik (Sidik Jari / Face ID)',
                          subtitle: 'Masuk Cepat dan aman ke Aplikasi',
                          onTap: () => _handleBiometricToggle(
                            context,
                            biometric,
                            biometricController,
                            !biometric.enabled,
                          ),
                          trailing: Switch.adaptive(
                            key: const ValueKey('biometric-switch'),
                            value: biometric.enabled,
                            activeThumbColor: AppColors.brandGoldenCaramel,
                            onChanged: (bool value) => _handleBiometricToggle(
                              context,
                              biometric,
                              biometricController,
                              value,
                            ),
                          ),
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuItem(
                          icon: Icons.pin_rounded,
                          label: 'Kode Kunci (PIN)',
                          subtitle: passcode.hasPasscode
                              ? 'Fallback saat biometrik gagal'
                              : 'Belum dibuat',
                          iconColor: AppColors.brandWarmBronze,
                          onTap: () => _handlePasscodeTap(
                            context,
                            passcodeController,
                            passcode.hasPasscode,
                          ),
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuItem(
                          icon: Icons.group_outlined,
                          label: 'Anggota Keluarga',
                          subtitle: 'Kelola profil keluarga terdaftar',
                          onTap: () =>
                              context.push(AppRoutes.familyMembersPath),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Kunci biometrik & PIN lokal ini hanya mengamankan pembukaan aplikasi di ponsel Anda dan tidak tersinkronisasi ke basis data rumah sakit.',
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.35,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    ProfileMenuCard(
                      title: 'Pelayanan',
                      children: [
                        ProfileMenuItem(
                          icon: Icons.assignment_outlined,
                          label: 'Riwayat Medis',
                          subtitle: 'Rekam medis dan hasil pemeriksaan',
                          iconColor: AppColors.clinicalTeal,
                          onTap: () =>
                              context.push(AppRoutes.medicalHistoryPath),
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Pengingat Janji Temu',
                          subtitle: state.appointmentReminder
                              ? 'Aktif: 1 hari sebelum jadwal'
                              : 'Nonaktif',
                          iconColor: AppColors.brandGoldenCaramel,
                          onTap: () => controller.setAppointmentReminder(
                            !state.appointmentReminder,
                          ),
                          trailing: Switch.adaptive(
                            key: const ValueKey('reminder-switch'),
                            value: state.appointmentReminder,
                            activeThumbColor: AppColors.brandGoldenCaramel,
                            onChanged: controller.setAppointmentReminder,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    ProfileMenuCard(
                      title: 'Bantuan',
                      children: [
                        ProfileMenuItem(
                          icon: Icons.info_outline_rounded,
                          label: 'Tentang Sijapin',
                          subtitle: 'Versi 1.0.0',
                          onTap: () => _showAboutDialog(context),
                        ),
                        const ProfileMenuDivider(),
                        ProfileMenuItem(
                          icon: Icons.call_rounded,
                          label: 'Hotline Rumah Sakit',
                          subtitle: AppConstants.emergencyPhoneNumber,
                          iconColor: AppColors.successEmerald,
                          onTap: () => _callHospitalHotline(context),
                        ),
                      ],
                    ),

                    if (user != null) ...[
                      const SizedBox(height: 24),
                      _SignOutButton(
                        onPressed: () => _confirmSignOut(context, controller),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const _ProfileFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTitle extends StatelessWidget {
  const _ProfileTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil Saya',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.01,
              color: AppColors.brandDarkEspresso,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Kelola data diri dan pengaturan akun Anda',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// State tamu: belum memiliki sesi pasien.
class _SignedOutCard extends StatelessWidget {
  const _SignedOutCard();

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandCreamLinen,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.brandSoftSand),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 32,
              color: AppColors.brandWarmBronze,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Masuk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.brandDarkEspresso,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masuk untuk melihat data diri, janji temu, dan riwayat '
            'pemeriksaan Anda di satu tempat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: 'Masuk Sekarang',
            icon: Icons.login_rounded,
            onPressed: () => context.push(AppRoutes.loginPath),
          ),
          const SizedBox(height: 8),
          AppSecondaryButton(
            label: 'Daftar Akun Baru',
            icon: Icons.person_add_alt_1_rounded,
            onPressed: () => context.push(AppRoutes.registerPath),
          ),
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dangerCrimson,
          side: const BorderSide(color: AppColors.dangerCrimson),
          minimumSize: const Size(48, 52),
          shape: const StadiumBorder(),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Keluar dari Akun'),
      ),
    );
  }
}

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Sijapin versi 1.0.0',
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        SizedBox(height: 4),
        Text(
          'RSUP Dr. Sitanala Tangerang • Kemenkes RI',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

void _showComingSoon(BuildContext context, String feature) {
  _showAppSnack(context, '$feature sedang kami kembangkan.');
}

void _showAppSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.brandDarkEspresso,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
}

/// Memproses toggle Kunci Biometrik. Mengaktifkan wajib mengonfirmasi dengan
/// biometrik sistem (dialog native Android/iOS) terlebih dahulu.
Future<void> _handleBiometricToggle(
  BuildContext context,
  BiometricState biometric,
  BiometricController controller,
  bool value,
) async {
  if (value && !biometric.available) {
    _showAppSnack(context, 'Perangkat Anda tidak mendukung biometrik.');
    return;
  }

  final bool ok = value
      ? await controller.enableWithAuthentication()
      : await controller.disable();

  if (!context.mounted) return;

  if (ok) {
    _showAppSnack(
      context,
      value
          ? 'Kunci biometrik aktif. Gunakan Sidik Jari / Face ID saat masuk.'
          : 'Kunci biometrik dinonaktifkan.',
    );
  } else {
    _showAppSnack(
      context,
      'Autentikasi biometrik gagal. Kunci biometrik tetap nonaktif.',
    );
  }
}

/// Membuka pengaturan Kode Kunci (PIN) fallback biometrik.
Future<void> _handlePasscodeTap(
  BuildContext context,
  PasscodeController controller,
  bool hasPasscode,
) async {
  final bool changed = await showPasscodeSetupSheet(
    context,
    controller: controller,
    hasPasscode: hasPasscode,
  );
  if (!changed || !context.mounted) return;
  _showAppSnack(context, 'Pengaturan Kode Kunci disimpan.');
}

/// Membuka aplikasi panggilan dengan nomor hotline rumah sakit sudah terisi.
Future<void> _callHospitalHotline(BuildContext context) async {
  const String hotline = AppConstants.emergencyPhoneNumber;
  final String cleanNumber = hotline.replaceAll(RegExp(r'[^0-9+]'), '');
  final Uri uri = Uri.parse('tel:$cleanNumber');
  try {
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showHotlineFallbackSnack(context, hotline);
    }
  } catch (_) {
    if (context.mounted) {
      _showHotlineFallbackSnack(context, hotline);
    }
  }
}

void _showHotlineFallbackSnack(BuildContext context, String hotline) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Tidak dapat membuka panggilan ke $hotline.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.brandDarkEspresso,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        action: SnackBarAction(
          label: 'Salin Nomor',
          textColor: AppColors.brandGoldenCaramel,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: hotline));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Nomor hotline disalin ke clipboard.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.brandDarkEspresso,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          },
        ),
      ),
    );
}

void _showAboutDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tentang Sijapin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.brandDarkEspresso,
          ),
        ),
        content: const Text(
          'Sijapin adalah aplikasi layanan RSUP Dr. Sitanala Tangerang '
          'yang membantu pasien mencari dokter, memesan jadwal, dan mengelola '
          'riwayat pemeriksaan.\n\nVersi 1.0.0 (prototipe).',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      );
    },
  );
}

Future<void> _confirmSignOut(
  BuildContext context,
  ProfileController controller,
) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Keluar dari aplikasi?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.brandDarkEspresso,
          ),
        ),
        content: const Text(
          'Anda perlu masuk kembali untuk melihat data diri dan janji temu Anda.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerCrimson,
              minimumSize: const Size(110, 48),
              shape: const StadiumBorder(),
            ),
            child: const Text('Keluar'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;
  controller.signOut();
  if (context.mounted) {
    _showAppSnack(context, 'Anda telah keluar dari akun.');
  }
}
