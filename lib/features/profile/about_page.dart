import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/common.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Sijapin')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                const AppLogo(size: 82),
                const SizedBox(height: AppSpacing.lg),
                const AppWordmark(size: 26),
                const SizedBox(height: AppSpacing.xs),
                Text('Versi 1.0.0 (prototipe)', style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Tentang aplikasi', style: t.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sijapin adalah aplikasi layanan rumah sakit yang '
                  'memudahkan pasien mencari dokter, memesan jadwal, dan '
                  'mengelola riwayat pemeriksaan. Versi ini masih '
                  'menyimpan seluruh data secara lokal di perangkat '
                  'menggunakan SQLite sebagai temporarily.',
                  style: t.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Fitur saat ini', style: t.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                const _Feature(
                  icon: Icons.search_rounded,
                  text: 'Cari dokter berdasarkan layanan dan nama',
                ),
                const _Feature(
                  icon: Icons.event_available_rounded,
                  text: 'Pilih tanggal dan jam yang tersedia',
                ),
                const _Feature(
                  icon: Icons.confirmation_number_rounded,
                  text: 'Kode pemesanan dan nomor antrean digital',
                ),
                const _Feature(
                  icon: Icons.history_rounded,
                  text: 'Riwayat janji temu, diagnosis, dan resep',
                ),
                const _Feature(
                  icon: Icons.rate_review_rounded,
                  text: 'Beri ulasan pada dokter',
                ),
                const _Feature(
                  icon: Icons.article_rounded,
                  text: 'Bacaan edukasi kesehatan',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Kontak', style: t.titleSmall),
                const Divider(height: AppSpacing.xxl),
                const InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: 'Jl. Kesehatan No. 1, Jakarta 12950',
                ),
                const InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: '021-555-0119',
                ),
                const InfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Layanan',
                  value: 'IGD 24 jam, klinik 08.00-17.00',
                ),
                const InfoRow(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'info@sijapin.co.id',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Aplikasi ini untuk keperluan demonstrasi dan pembelajaran. '
            'Data pasien yang ditampilkan merupakan data fiktif.',
            textAlign: TextAlign.center,
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
