import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';

/// Avatar dokter dengan ilustrasi medis berbasis jenis kelamin & inisial nama.
///
/// Memenuhi mandat PRD FR-08.3 & Audit SIMRS Sitanala:
/// Tabel `m_pegawai` database SIMRS Sitanala tidak menyimpan foto profil dokter,
/// sehingga antarmuka menyajikan ilustrasi medis berbasis gender ('L' / 'P')
/// dan inisial dokter berlatar palet warna resmi RSUP Dr. Sitanala.
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.name,
    this.gender = 'L',
    this.photoUrl,
    this.radius = 28,
  });

  final String name;
  final String gender;
  final String? photoUrl;
  final double radius;

  bool get _isFemale => gender.toUpperCase() == 'P';

  String _getInitials(String name) {
    final cleaned = name
        .replaceAll(RegExp(r'^(dr\.|drg\.|dr\s+|drg\s+)', caseSensitive: false), '')
        .trim();
    final parts = cleaned.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'DR';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final size = radius * 2;

    // Jika memiliki URL foto valid
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.brandCreamLinen,
        backgroundImage: NetworkImage(photoUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    // Tampilan Avatar Medis Berbasis Gender Sesuai SSOT Sitanala
    final primaryColor = _isFemale
        ? AppColors.brandWarmBronze
        : AppColors.brandDarkEspresso;
    final badgeBgColor = AppColors.brandCreamLinen;
    final badgeIconColor = _isFemale
        ? AppColors.brandGoldenCaramel
        : AppColors.clinicalTeal;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Lingkaran utama dengan inisial dan border elegan
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brandCreamLinen,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // Badge kecil indikator gender dokter medis di pojok kanan bawah
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: radius * 0.75,
            height: radius * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeBgColor,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                _isFemale ? Icons.female_rounded : Icons.male_rounded,
                size: radius * 0.5,
                color: badgeIconColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
