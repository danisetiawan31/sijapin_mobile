import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';

/// Item alur langkah pasien BPJS
class BpjsFlowStep {
  const BpjsFlowStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.icon,
    this.badgeLabel,
    this.importantNote,
  });

  final int stepNumber;
  final String title;
  final String description;
  final IconData icon;
  final String? badgeLabel;
  final String? importantNote;
}

/// Layar Panduan & Alur Berobat Pasien BPJS Kesehatan
/// Rute: `/support/bpjs-flow`
class BpjsFlowScreen extends StatelessWidget {
  const BpjsFlowScreen({super.key});

  static const List<BpjsFlowStep> steps = [
    BpjsFlowStep(
      stepNumber: 1,
      title: 'Pemeriksaan di Faskes Tingkat 1 (FKTP)',
      description: 'Kunjungi Puskesmas atau Klinik Pratama tempat Anda terdaftar. Dokter FKTP akan memeriksa dan menerbitkan Surat Rujukan Online jika memerlukan penanganan dokter spesialis.',
      icon: Icons.local_hospital_outlined,
      badgeLabel: 'Faskes Pertama',
    ),
    BpjsFlowStep(
      stepNumber: 2,
      title: 'Pendaftaran Online via Aplikasi (Task 1)',
      description: 'Buka aplikasi SIIJAPIN Mobile, pilih menu Janji Temu / Pendaftaran. Masukkan nomor rujukan BPJS atau Surat Kontrol (SPRI), pilih Poliklinik dan Dokter DPJP.',
      icon: Icons.app_registration_rounded,
      badgeLabel: 'Booking Task 1',
      importantNote:
          'Pendaftaran ditutup H-1 pukul ${AppConfig.registrationCutoffTime} ${AppConfig.timeZoneAbbr}.',
    ),
    BpjsFlowStep(
      stepNumber: 3,
      title: 'Hadir di RS & Check-In Mesin APM Fisik (Task 2)',
      description: 'Hadir di lobi RSUP Dr. Sitanala 30–60 menit sebelum jadwal poli. Arahkan kode QR atau ketik 13 digit Kode Booking Anda pada scanner mesin Anjungan Pendaftaran Mandiri (APM).',
      icon: Icons.qr_code_scanner_rounded,
      badgeLabel: 'Check-In Task 2',
      importantNote: 'SEP BPJS tercetak otomatis dari mesin APM.',
    ),
    BpjsFlowStep(
      stepNumber: 4,
      title: 'Pelayanan Medis di Poliklinik Spesialis (Task 5 & 6)',
      description: 'Menuju ruang tunggu poli tujuan Anda. Dokter DPJP memanggil pasien (Task 5), melakukan pemeriksaan, dan menginput e-Resep/CPPT di SIMRS (Task 6).',
      icon: Icons.medical_services_outlined,
      badgeLabel: 'Poli DPJP',
    ),
    BpjsFlowStep(
      stepNumber: 5,
      title: 'Pengambilan Resep Obat di Farmasi RS (Task 7)',
      description: 'Setelah selesai konsultasi medis, resep digital diteruskan ke Farmasi Rawat Jalan. Pantau nomor antrean obat Anda di loket farmasi untuk penyerahan obat (Task 7).',
      icon: Icons.medication_outlined,
      badgeLabel: 'Farmasi & Selesai',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text('Alur Pasien BPJS Kesehatan'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner Edukasi
            const AppCard.highlighted(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.brandGoldenCaramel,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pastikan status kepesertaan BPJS Kesehatan Anda dalam kondisi aktif dan surat rujukan FKTP masih berlaku sebelum mendaftar.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brandDarkEspresso,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              '5 Langkah Berobat dengan BPJS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Langkah Alur
            // TODO(rekan): Kustomisasi timeline/stepper atau styling tampilan alur di bawah ini
            ...steps.map((step) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AppCard.elevated(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.brandGoldenCaramel.withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${step.stepNumber}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brandDarkEspresso,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandDarkEspresso,
                                  ),
                                ),
                                if (step.badgeLabel != null) ...[
                                  const SizedBox(height: 4),
                                  AppBadge.neutral(label: step.badgeLabel!),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      if (step.importantNote != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warningAmber.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.warningAmber.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AppColors.warningAmber,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  step.importantNote!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brandDarkEspresso,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
