import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';

/// Model tindakan pemeriksaan MCU sesuai tabel database `t_daftar_mcu_tindakan`
class McuTindakanItem {
  const McuTindakanItem({
    required this.tarifId,
    required this.namaTindakan,
    required this.ruang,
  });

  final int tarifId;
  final String namaTindakan;
  final String ruang;
}

/// Model paket MCU sesuai skema database `t_daftar_mcu` & `t_daftar_mcu_billing`
class McuPackageItem {
  const McuPackageItem({
    required this.kodeTarif,
    required this.mcuId,
    required this.name,
    required this.price,
    required this.formattedPrice,
    required this.badgeLabel,
    required this.description,
    required this.examinationItems,
  });

  final String kodeTarif;
  final int mcuId;
  final String name;
  final int price;
  final String formattedPrice;
  final String badgeLabel;
  final String description;
  final List<McuTindakanItem> examinationItems;
}

/// Layar Katalog Paket Medical Check-Up (MCU) — Epic 08 (`US-SUP-01`)
/// Rute: `/mcu`
///
/// Data dan tindakan di bawah ini 100% mencerminkan skema database SIMRS:
/// - `t_daftar_mcu` (KODE_TARIF, MCU_ID)
/// - `t_daftar_mcu_tindakan` (TARIF_ID, NAMA_TINDAKAN, RUANG)
/// - `t_daftar_mcu_billing` (JUMLAH_BAYAR, VIRTUAL_ACCOUNT)
class McuCatalogScreen extends StatelessWidget {
  const McuCatalogScreen({super.key});

  static const List<McuPackageItem> dummyPackages = [
    McuPackageItem(
      kodeTarif: '120050',
      mcuId: 29947,
      name: 'Paket MCU Standar',
      price: 180000,
      formattedPrice: 'Rp 180.000',
      badgeLabel: 'Populer',
      description:
          'Pemeriksaan kesehatan fisik dasar dan uji laboratorium rutin.',
      examinationItems: [
        McuTindakanItem(
          tarifId: 30055,
          namaTindakan: 'Pemeriksaan Fisik Dokter MCU',
          ruang: 'MCU',
        ),
        McuTindakanItem(
          tarifId: 30056,
          namaTindakan: 'Laboratorium Darah Lengkap',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 30061,
          namaTindakan: 'Laboratorium Urin Lengkap',
          ruang: 'Laboratorium',
        ),
      ],
    ),
    McuPackageItem(
      kodeTarif: '120041',
      mcuId: 29938,
      name: 'Paket Bebas Narkoba & MMPI',
      price: 370000,
      formattedPrice: 'Rp 370.000',
      badgeLabel: 'Syarat Kerja',
      description:
          'Skrining bebas narkoba 6 panel dan evaluasi kesehatan jiwa (MMPI).',
      examinationItems: [
        McuTindakanItem(
          tarifId: 29972,
          namaTindakan: 'Pemeriksaan Fisik Dokter MCU',
          ruang: 'MCU',
        ),
        McuTindakanItem(
          tarifId: 29973,
          namaTindakan: 'Laboratorium Tes Narkoba 6 Panel',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 29974,
          namaTindakan: 'MMPI + Dokter Spesialis Jiwa',
          ruang: 'MCU',
        ),
      ],
    ),
    McuPackageItem(
      kodeTarif: '120052',
      mcuId: 29949,
      name: 'Paket MCU Komprehensif',
      price: 501000,
      formattedPrice: 'Rp 501.000',
      badgeLabel: 'Komprehensif',
      description: 'Pemeriksaan skrining organ vital, profil lemak, fungsi ginjal & jantung.',
      examinationItems: [
        McuTindakanItem(
          tarifId: 30055,
          namaTindakan: 'Pemeriksaan Fisik Dokter MCU',
          ruang: 'MCU',
        ),
        McuTindakanItem(
          tarifId: 30056,
          namaTindakan: 'Laboratorium Darah Lengkap',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 30057,
          namaTindakan: 'Laboratorium Gula Darah Sewaktu',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 30058,
          namaTindakan: 'Laboratorium Fungsi Ginjal',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 30059,
          namaTindakan: 'Laboratorium Profil Lemak (Kolesterol/HDL/LDL)',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 30060,
          namaTindakan: 'Laboratorium Fungsi Hati (SGOT/SGPT)',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 30061,
          namaTindakan: 'Laboratorium Urin Lengkap',
          ruang: 'Laboratorium',
        ),
        McuTindakanItem(
          tarifId: 30062,
          namaTindakan: 'Rothgen Thorak',
          ruang: 'Radiologi',
        ),
        McuTindakanItem(
          tarifId: 30063,
          namaTindakan: 'Elektrokardiogram (EKG)',
          ruang: 'R. EKG/EEG',
        ),
      ],
    ),
    McuPackageItem(
      kodeTarif: '120077',
      mcuId: 33771,
      name: 'Paket Psikologi & Konseling',
      price: 290000,
      formattedPrice: 'Rp 290.000',
      badgeLabel: 'Psikologi',
      description:
          'Uji psikologi terpadu (Kecerdasan, Kepribadian, dan Konseling).',
      examinationItems: [
        McuTindakanItem(
          tarifId: 30096,
          namaTindakan: 'Tes Kecerdasan',
          ruang: 'MCU',
        ),
        McuTindakanItem(
          tarifId: 30097,
          namaTindakan: 'Tes Kepribadian',
          ruang: 'MCU',
        ),
        McuTindakanItem(
          tarifId: 30098,
          namaTindakan: 'Pemeriksaan Psikologi Karyawan',
          ruang: 'MCU',
        ),
        McuTindakanItem(
          tarifId: 30099,
          namaTindakan: 'Konseling Psikologi',
          ruang: 'MCU',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: const Text('Katalog Paket MCU'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Banner Panduan Puasa Pasien (US-SUP-01 Scenario 1)
            const AppCard.highlighted(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: AppColors.brandGoldenCaramel,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panduan Persiapan Puasa',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brandDarkEspresso,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Wajib berpuasa 10–12 jam sebelum pengambilan sampel darah. Hanya diperbolehkan minum air putih tanpa gula.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Pilihan Paket Pemeriksaan MCU Sitanala',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.brandDarkEspresso,
              ),
            ),
            const SizedBox(height: 12),

            // Daftar Kartu Paket MCU Sitanala
            // TODO(rekan): Slicing dan kustomisasi tata letak kartu paket di bawah ini
            ...dummyPackages.map((package) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard.elevated(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  package.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brandDarkEspresso,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kode Tarif: ${package.kodeTarif}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppBadge.neutral(label: package.badgeLabel),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        package.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      const SizedBox(height: 12),
                      const Text(
                        'Rincian Tindakan Pemeriksaan:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandDarkEspresso,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...package.examinationItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: AppColors.successEmerald,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.namaTindakan,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.brandCreamLinen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.ruang,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.brandWarmBronze,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tarif Paket (BRIVA)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                package.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brandGoldenCaramel,
                                ),
                              ),
                            ],
                          ),
                          AppPrimaryButton(
                            label: 'Pilih Paket',
                            width: 130,
                            onPressed: () {
                              // TODO(rekan): Hubungkan aksi booking paket MCU
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Paket ${package.name} (Kode: ${package.kodeTarif}) dipilih. Lanjutkan jadwal MCU.',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
