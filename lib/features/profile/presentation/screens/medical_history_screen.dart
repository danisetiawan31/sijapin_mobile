import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/medical_record.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/medical_record_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/medical_record_card.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/medical_record_detail_sheet.dart';

/// Riwayat rekam medis pasien, dibuka dari menu "Riwayat Medis" di tab Profil.
///
/// Tampilan sementara sesuai DESIGN.md: kartu bertahap berisi linimasa
/// pemeriksaan, bukan tabel datar, dengan aksen `clinical-teal` sebagai
/// penanda klinis dan panel resume melalui bottom sheet.
class MedicalHistoryScreen extends ConsumerWidget {
  const MedicalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProfileState profile = ref.watch(profileControllerProvider);
    final List<MedicalRecord> records = ref.watch(medicalRecordProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(title: const Text('Riwayat Medis'), centerTitle: false),
      body: SafeArea(
        child: !profile.isSignedIn
            ? _SignedOutNotice()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  _HistorySummaryCard(records: records),
                  const SizedBox(height: 20),
                  if (records.isEmpty)
                    const AppEmptyState(
                      title: 'Belum Ada Riwayat Medis',
                      message:
                          'Catatan pemeriksaan, hasil laboratorium, dan resep '
                          'obat akan tampil di sini setelah kunjungan pertama.',
                      icon: Icons.assignment_outlined,
                    )
                  else
                    MedicalRecordTimeline(
                      records: records,
                      onRecordTap: (MedicalRecord record) =>
                          MedicalRecordDetailSheet.show(context, record),
                    ),
                  const SizedBox(height: 20),
                  const _OfficialRecordNotice(),
                ],
              ),
      ),
    );
  }
}

/// Kartu ringkasan jumlah catatan dan pemeriksaan terakhir.
class _HistorySummaryCard extends StatelessWidget {
  const _HistorySummaryCard({required this.records});

  final List<MedicalRecord> records;

  @override
  Widget build(BuildContext context) {
    final MedicalRecord? latest = records.isEmpty ? null : records.first;

    return AppCard.filled(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.clinicalTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.folder_shared_outlined,
              size: 22,
              color: AppColors.clinicalTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${records.length} catatan rekam medis',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  latest == null
                      ? 'Belum ada pemeriksaan tercatat'
                      : 'Pemeriksaan terakhir ${DateFormatter.tanggalPendek(latest.date)}',
                  style: const TextStyle(
                    fontSize: 12,
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
}

/// Catatan cara memperoleh salinan rekam medis resmi.
class _OfficialRecordNotice extends StatelessWidget {
  const _OfficialRecordNotice();

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
              'Rekam medis resmi dapat diminta di Loket 1, Lantai 1 RSUP Dr. '
              'Sitanala dengan identitas dan nomor rekam medis Anda.',
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

/// State tamu: riwayat medis hanya untuk pasien yang sudah masuk.
class _SignedOutNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'Belum Masuk',
      message:
          'Masuk terlebih dahulu untuk melihat riwayat rekam medis Anda di '
          'satu tempat.',
      icon: Icons.lock_outline_rounded,
      actionButton: AppPrimaryButton(
        label: 'Masuk Sekarang',
        icon: Icons.login_rounded,
        width: 200,
        onPressed: () => context.push(AppRoutes.loginPath),
      ),
    );
  }
}
