import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

/// Layar Maklumat & Standar Pelayanan Publik RSUP Dr. Sitanala Tangerang
/// Rute: `/support/service-standards`
///
/// Transformasi Mobile Native:
/// Menggantikan iframe flipbook pihak ketiga yang berat dengan kartu informasi terstruktur.
class ServiceStandardsScreen extends StatelessWidget {
  const ServiceStandardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text('Standar Pelayanan Publik'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Kartu Maklumat Pelayanan
            const AppCard.highlighted(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.brandGoldenCaramel,
                        size: 26,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Maklumat Pelayanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '“Dengan ini kami pimpinan dan segenap pegawai RSUP Dr. Sitanala Tangerang menyatakan sanggup menyelenggarakan pelayanan sesuai standar pelayanan yang telah ditetapkan, dan apabila tidak menepati janji ini, kami siap menerima sanksi sesuai peraturan perundang-undangan yang berlaku.”',
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.brandDarkEspresso,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— Direksi RSUP Dr. Sitanala',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandGoldenCaramel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Jam Operasional Loket & Poliklinik
            const Text(
              'Jam Operasional Pelayanan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 12),

            AppCard.elevated(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildScheduleRow(
                    title: 'Pendaftaran Loket Rawat Jalan',
                    days: 'Senin – Kamis',
                    hours: '07.30 – 12.00 WIB',
                    badge: const AppBadge.neutral(label: 'Hari Kerja'),
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  _buildScheduleRow(
                    title: 'Pendaftaran Loket Rawat Jalan',
                    days: 'Jumat',
                    hours: '07.30 – 11.00 WIB',
                    badge: const AppBadge.neutral(label: 'Jumat'),
                  ),
                  const Divider(height: 20, color: AppColors.borderSubtle),
                  _buildScheduleRow(
                    title: 'Instalasi Gawat Darurat (IGD)',
                    days: 'Setiap Hari',
                    hours: '24 Jam Non-Stop',
                    badge: const AppBadge.danger(label: 'Siaga 24 Jam'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hak dan Kewajiban Pasien
            const Text(
              'Hak & Kewajiban Pasien',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 12),

            // TODO(rekan): Slicing dan kustomisasi konten hak & kewajiban di bawah ini
            AppCard.elevated(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.brandWarmBronze,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ringkasan Hak Pasien',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    'Memperoleh informasi mengenai tata tertib dan peraturan yang berlaku di RS.',
                  ),
                  _buildBulletPoint(
                    'Memperoleh layanan medis yang manusiawi, adil, jujur, dan tanpa diskriminasi.',
                  ),
                  _buildBulletPoint(
                    'Memperoleh layanan kesehatan yang bermutu sesuai standar profesi dan SOP.',
                  ),
                  _buildBulletPoint(
                    'Memberikan persetujuan atau menolak tindakan medis (Informed Consent).',
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.borderSubtle),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        color: AppColors.brandWarmBronze,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ringkasan Kewajiban Pasien',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    'Menaati segala peraturan dan tata tertib yang berlaku di rumah sakit.',
                  ),
                  _buildBulletPoint(
                    'Memberikan informasi medis yang jujur, lengkap, dan akurat kepada tenaga kesehatan.',
                  ),
                  _buildBulletPoint(
                    'Mematuhi rencana pengobatan yang telah disepakati bersama dokter penanggung jawab.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow({
    required String title,
    required String days,
    required String hours,
    required Widget badge,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$days • $hours',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        badge,
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.brandGoldenCaramel,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
