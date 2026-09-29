import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Bento Status Duo: Ketersediaan Kamar & Jadwal Dokter di Beranda.
///
/// Mengadopsi desain seimbang & presisi:
/// - Ukuran layout kedua kartu identik dan sejajar sempurna
/// - Slot judul konsisten 42dp agar kartu Jadwal Dokter dan Ketersediaan Kamar setara
/// - Latar belakang fotografis lembut (hospital bed & doctor portrait)
/// - Squircle container untuk ikon medis utama
/// - Tombol pill full-width "Lihat Ketersediaan >" & "Lihat Jadwal >"
class HomeBentoStatusCards extends StatelessWidget {
  const HomeBentoStatusCards({
    super.key,
    required this.onBedAvailabilityTap,
    required this.onDoctorScheduleTap,
    this.availableBedsCount = AppConstants.defaultAvailableBeds,
    this.activeDoctorsCount = AppConstants.defaultActiveDoctors,
  });

  final VoidCallback onBedAvailabilityTap;
  final VoidCallback onDoctorScheduleTap;
  final int availableBedsCount;
  final int activeDoctorsCount;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kartu Kiri: Ketersediaan Kamar
          Expanded(
            child: _PhotoBentoCard(
              onTap: onBedAvailabilityTap,
              semanticLabel:
                  'Ketersediaan Kamar, Rawat inap & ICU, $availableBedsCount Bed Kosong',
              icon: Icons.bed_rounded,
              iconColor: AppColors.clinicalTeal,
              iconBgColor: AppColors.clinicalContainer,
              title: 'Ketersediaan\nKamar',
              subtitle: 'Rawat inap & ICU',
              backgroundImagePath: 'assets/images/bento_bed.png',
              bgImageWidth: 115,
              bgImageHeight: 110,
              buttonLabel: 'Lihat Ketersediaan',
              buttonBgColor: AppColors.clinicalContainer,
              buttonTextColor: AppColors.clinicalTealDeep,
            ),
          ),
          const SizedBox(width: 12),

          // Kartu Kanan: Jadwal Dokter (Ukuran & Layout diselaraskan penuh)
          Expanded(
            child: _PhotoBentoCard(
              onTap: onDoctorScheduleTap,
              semanticLabel:
                  'Jadwal Dokter, Cari spesialis & jam praktik, $activeDoctorsCount Dokter Aktif',
              icon: Icons.person_rounded,
              iconColor: AppColors.brandGoldenCaramel,
              iconBgColor: AppColors.goldenSoftLinen,
              title: 'Jadwal Dokter',
              subtitle: 'Cari spesialis & jam praktik',
              backgroundImagePath: 'assets/images/bento_doctor.png',
              bgImageWidth: 85,
              bgImageHeight: 110,
              buttonLabel: 'Lihat Jadwal',
              buttonBgColor: AppColors.brandCreamLinen,
              buttonTextColor: AppColors.brandDeepChocolate,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoBentoCard extends StatelessWidget {
  const _PhotoBentoCard({
    required this.onTap,
    required this.semanticLabel,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.backgroundImagePath,
    required this.bgImageWidth,
    required this.bgImageHeight,
    required this.buttonLabel,
    required this.buttonBgColor,
    required this.buttonTextColor,
  });

  final VoidCallback onTap;
  final String semanticLabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String backgroundImagePath;
  final double bgImageWidth;
  final double bgImageHeight;
  final String buttonLabel;
  final Color buttonBgColor;
  final Color buttonTextColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: iconColor.withValues(alpha: 0.08),
          highlightColor: iconBgColor.withValues(alpha: 0.3),
          child: Ink(
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.borderSubtle.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandDarkEspresso.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Gambar Fotografis Halus di Sudut Kanan Atas
                  Positioned(
                    top: 0,
                    right: 0,
                    width: bgImageWidth,
                    height: bgImageHeight,
                    child: IgnorePointer(
                      child: Image.asset(
                        backgroundImagePath,
                        fit: BoxFit.contain,
                        alignment: Alignment.topRight,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // Konten Utama Bento Card
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ikon Squircle
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: iconBgColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Icon(icon, color: iconColor, size: 24),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Judul Kartu (Konsisten 42dp agar tinggi kedua kartu identik dan rata)
                            SizedBox(
                              height: 42,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.brandDarkEspresso,
                                    height: 1.25,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Subjudul
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Tombol Aksi Full-Width Pill
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 7.5,
                          ),
                          decoration: BoxDecoration(
                            color: buttonBgColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  buttonLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: buttonTextColor,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 15,
                                color: buttonTextColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
