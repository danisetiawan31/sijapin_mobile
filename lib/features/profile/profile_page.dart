import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/states.dart';
import '../../data/models/app_user.dart';
import '../../data/models/appointment.dart';
import '../../state/appointment_provider.dart';
import '../../state/auth_provider.dart';
import 'about_page.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<AuthProvider>().user;
    final AppointmentProvider appointments = context
        .watch<AppointmentProvider>();
    final AuthProvider auth = context.read<AuthProvider>();
    final TextTheme t = Theme.of(context).textTheme;

    if (user == null) return const Scaffold(body: LoadingView());

    final int total = appointments.items.length;
    final int selesai = appointments.items
        .where((Appointment a) => a.status == 'completed')
        .length;
    final int akanDatang = appointments.upcomingCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: <Widget>[
          AppCard(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    UserAvatar(name: user.fullName, size: 62),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            user.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: <Widget>[
                              SoftChip(
                                label: Fmt.genderLabel(user.gender),
                                icon: user.gender == 'L'
                                    ? Icons.male_rounded
                                    : Icons.female_rounded,
                                dense: true,
                              ),
                              SoftChip(
                                label:
                                    user.bloodType == null ||
                                        user.bloodType!.isEmpty
                                    ? 'Gol. darah -'
                                    : 'Gol. darah ${user.bloodType}',
                                icon: Icons.bloodtype_outlined,
                                color: AppColors.danger,
                                dense: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!user.hasProfileComplete) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warningContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.info_rounded,
                          size: 18,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Lengkapi data NIK dan tanggal lahir untuk '
                            'mempercepat layanan.',
                            style: t.bodySmall?.copyWith(
                              color: const Color(0xFF6B4608),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    _Stat(
                      label: 'Janji temu',
                      value: '$total',
                      icon: Icons.event_note_rounded,
                      color: AppColors.primary,
                    ),
                    _Stat(
                      label: 'Akan datang',
                      value: '$akanDatang',
                      icon: Icons.schedule_rounded,
                      color: AppColors.secondary,
                    ),
                    _Stat(
                      label: 'Selesai',
                      value: '$selesai',
                      icon: Icons.check_circle_rounded,
                      color: AppColors.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: <Widget>[
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profil',
                  subtitle: 'Nama, NIK, alamat, dan data kesehatan',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfilePage(),
                    ),
                  ),
                ),
                const Divider(),
                _MenuTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Ganti Kata Sandi',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
                const Divider(),
                _MenuTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Pengingat Janji Temu',
                  subtitle: 'Diaktifkan',
                  trailing: Switch(
                    value: true,
                    onChanged: (bool v) => AppSnack.show(
                      context,
                      v
                          ? 'Pengingat aktif 1 hari sebelum jadwal.'
                          : 'Pengingat dimatikan.',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Column(
              children: <Widget>[
                _MenuTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Tentang Sijapin',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AboutPage()),
                  ),
                ),
                const Divider(),
                _MenuTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'Hapus Akun',
                  subtitle: 'Menghapus seluruh data di perangkat ini',
                  color: AppColors.danger,
                  onTap: () => _confirmDelete(context, auth),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, auth),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar'),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Sijapin versi 1.0.0',
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rumah Sakit Sijapin • Jl. Kesehatan No. 1',
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Keluar dari aplikasi?'),
        content: Text(
          'Anda perlu masuk kembali untuk melihat janji temu Anda.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true) await auth.logout();
  }

  Future<void> _confirmDelete(BuildContext context, AuthProvider auth) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Hapus akun permanen?'),
        content: Text(
          'Seluruh data profil, janji temu, dan ulasan Anda akan dihapus '
          'dari perangkat ini dan tidak dapat dikembalikan.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(120, 44),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await auth.deleteAccount();
      if (context.mounted) {
        AppSnack.show(context, 'Akun telah dihapus', success: true);
      }
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 19, fontWeight: w800, color: color),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, size: 19, color: c),
      ),
      title: Text(
        label,
        style: TextStyle(fontSize: 14.5, fontWeight: w600, color: c),
      ),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing:
          trailing ??
          Icon(Icons.chevron_right_rounded, color: c.withValues(alpha: 0.4)),
    );
  }
}
