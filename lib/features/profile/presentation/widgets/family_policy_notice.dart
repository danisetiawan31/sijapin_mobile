import 'package:flutter/material.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';

/// Catatan aturan verifikasi anggota keluarga saat pendaftaran di loket.
class FamilyPolicyNotice extends StatelessWidget {
  const FamilyPolicyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard.outlined(
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Anggota keluarga dapat didaftarkan berobat dengan melampirkan '
              'kartu identitas asli dan bukti hubungan keluarga saat '
              'pendaftaran di loket.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
