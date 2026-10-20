import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../profile/domain/entities/family_member.dart';
import '../../../profile/presentation/controllers/family_member_controller.dart';
import '../../../profile/presentation/widgets/add_family_member_sheet.dart';
import '../../domain/entities/mcu_patient.dart';
import '../controllers/mcu_patient_controller.dart';
import 'mcu_catalog_screen.dart';

/// Langkah 1 pendaftaran Medical Check-Up (MCU): pemilihan pasien berobat.
///
/// Rute: `/mcu/pasien`. Daftar pasien dimuat dari REST authority
/// `GET /pendaftaran` (Accept: application/json + cookie sesi CI3).
class McuPatientStepScreen extends ConsumerStatefulWidget {
  const McuPatientStepScreen({super.key, this.selectedPackage});

  /// Paket MCU yang dipilih dari katalog; dibawa ke langkah berikutnya.
  final McuPackageItem? selectedPackage;

  @override
  ConsumerState<McuPatientStepScreen> createState() =>
      _McuPatientStepScreenState();
}

class _McuPatientStepScreenState extends ConsumerState<McuPatientStepScreen> {
  String? _selectedMemberId;

  McuPatient _fromFamilyMember(FamilyMember member) {
    return McuPatient(
      idMember: member.id,
      nama: member.fullName.isNotEmpty ? member.fullName : 'Pasien Tanpa Nama',
      nomr: member.medicalRecordNumber ?? '',
      nik: member.nik,
    );
  }

  List<McuPatient> _mergePatients(
    List<McuPatient> fromMcu,
    List<FamilyMember> fromFamily,
  ) {
    final Map<String, McuPatient> map = <String, McuPatient>{};
    for (final McuPatient patient in fromMcu) {
      if (patient.idMember.isEmpty) continue;
      map[patient.idMember] = patient;
    }
    for (final FamilyMember member in fromFamily) {
      final McuPatient converted = _fromFamilyMember(member);
      if (converted.idMember.isEmpty) continue;
      map.putIfAbsent(converted.idMember, () => converted);
    }
    return map.values.toList();
  }

  McuPatient? _resolveSelected(List<McuPatient> patients) {
    final String? id = _selectedMemberId;
    if (id == null) return null;
    for (final McuPatient patient in patients) {
      if (patient.idMember == id) return patient;
    }
    return null;
  }

  void _openAddMemberSheet() {
    AddFamilyMemberSheet.show(
      context,
      onSave: (FamilyMember newMember) {
        ref.read(familyMembersProvider.notifier).addMember(newMember);
        ref.invalidate(mcuPatientsProvider);
        ref.invalidate(familyMembersProvider);
        if (!mounted) return;
        _showSnackBar(
          'Anggota keluarga "${newMember.fullName}" berhasil ditambahkan.',
        );
      },
    );
  }

  void _continue(McuPatient patient) {
    final McuPackageItem? pkg = widget.selectedPackage;
    final String nextStep = pkg == null
        ? 'pilih paket & jadwal MCU'
        : 'pilih jadwal MCU';
    final String forPackage = pkg == null ? '' : ' untuk ${pkg.name}';
    _showSnackBar(
      'Pasien ${patient.nama} dipilih$forPackage. Lanjut ke $nextStep.',
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.brandDarkEspresso,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<McuPatient>> patientsAsync = ref.watch(
      mcuPatientsProvider,
    );
    final List<FamilyMember> familyMembers = ref.watch(familyMembersProvider);

    final List<McuPatient> mcuPatients =
        patientsAsync.value ?? const <McuPatient>[];
    final List<McuPatient> patients = _mergePatients(
      mcuPatients,
      familyMembers,
    );

    final McuPatient? selected = _resolveSelected(patients);

    if (selected == null && patients.isNotEmpty && _selectedMemberId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _selectedMemberId != null) return;
        setState(() => _selectedMemberId = patients.first.idMember);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _McuStepTopBar(
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.mcuCatalogPath);
                }
              },
            ),
            Expanded(child: _buildBody(patientsAsync, patients, selected)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(selected),
    );
  }

  Widget _buildBody(
    AsyncValue<List<McuPatient>> patientsAsync,
    List<McuPatient> patients,
    McuPatient? selected,
  ) {
    final String subtitle = widget.selectedPackage == null
        ? 'Pilih anggota keluarga yang akan mengikuti pemeriksaan MCU '
              'atau daftarkan pasien baru.'
        : 'Pilih anggota keluarga yang akan mengikuti '
              '${widget.selectedPackage!.name} atau daftarkan pasien baru.';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.brandGoldenCaramel, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Pasien Berobat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ..._buildPatientSection(patientsAsync, patients, selected),
        const SizedBox(height: 12),
        _AddPatientCard(onTap: _openAddMemberSheet),
        const SizedBox(height: 16),
        const _SecurityComplianceNotice(),
      ],
    );
  }

  List<Widget> _buildPatientSection(
    AsyncValue<List<McuPatient>> patientsAsync,
    List<McuPatient> patients,
    McuPatient? selected,
  ) {
    if (patientsAsync.isLoading && patients.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (patientsAsync.hasError && patients.isEmpty) {
      final Object error = patientsAsync.error!;
      return [
        AppErrorState(
          title: 'Gagal Memuat Data Pasien',
          message: error.toString(),
          onRetry: () {
            ref.invalidate(mcuPatientsProvider);
            ref.invalidate(familyMembersProvider);
          },
        ),
      ];
    }

    if (patients.isEmpty) {
      return const [
        AppEmptyState(
          title: 'Belum Ada Anggota Pasien',
          message:
              'Belum ada anggota keluarga yang terdaftar untuk akun ini. '
              'Tambahkan pasien terlebih dahulu agar bisa mendaftar MCU.',
          icon: Icons.group_add_outlined,
        ),
      ];
    }

    return [
      for (final McuPatient patient in patients)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _McuPatientCard(
            patient: patient,
            isSelected: selected?.idMember == patient.idMember,
            onTap: () => setState(() => _selectedMemberId = patient.idMember),
          ),
        ),
    ];
  }

  Widget _buildBottomBar(McuPatient? selected) {
    final bool hasSelection = selected != null;
    final String ctaLabel = widget.selectedPackage == null
        ? 'Lanjut: Pilih Paket & Jadwal'
        : 'Lanjut: Pilih Jadwal MCU';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: const Border(top: BorderSide(color: AppColors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandDarkEspresso.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.how_to_reg_rounded,
                    size: 16,
                    color: AppColors.brandGoldenCaramel,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pasien terpilih:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hasSelection ? selected.nama : 'Belum dipilih',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandDarkEspresso,
                      ),
                    ),
                  ),
                  if (hasSelection) _patientBadge(selected),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: AppPrimaryButton(
                  label: ctaLabel,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: hasSelection ? () => _continue(selected) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _patientBadge(McuPatient patient) {
  if (patient.isNewPatient) {
    return const AppBadge.clinical(
      label: 'PASIEN BARU',
      icon: Icons.person_add_alt_1_rounded,
      fontSize: 10,
    );
  }
  return const AppBadge.neutral(
    label: 'PASIEN LAMA',
    icon: Icons.verified_user_outlined,
    fontSize: 10,
  );
}

class _McuStepTopBar extends StatelessWidget {
  const _McuStepTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceBg,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderSubtle.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: AppColors.brandDarkEspresso,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'LANGKAH 1 DARI 3',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.brandGoldenCaramel,
                      ),
                    ),
                    TextSpan(
                      text: '  •  MCU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                        color: AppColors.brandGoldenCaramel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (int index = 0; index < 3; index++) ...[
                    if (index > 0) const SizedBox(width: 6),
                    Container(
                      width: 32,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? AppColors.brandGoldenCaramel
                            : AppColors.borderSubtle,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _McuPatientCard extends StatelessWidget {
  const _McuPatientCard({
    required this.patient,
    required this.isSelected,
    required this.onTap,
  });

  final McuPatient patient;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.brandGoldenCaramel.withValues(alpha: 0.1),
        highlightColor: AppColors.brandCreamLinen.withValues(alpha: 0.4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.brandGoldenCaramel.withValues(alpha: 0.06)
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandGoldenCaramel
                  : AppColors.borderSubtle,
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.brandGoldenCaramel.withValues(
                        alpha: 0.14,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.brandDarkEspresso.withValues(
                        alpha: 0.03,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.brandGoldenCaramel
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.brandGoldenCaramel
                          : AppColors.borderSubtle,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patient.nama.isEmpty
                                ? 'Pasien Tanpa Nama'
                                : patient.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandDarkEspresso,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _patientBadge(patient),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    const SizedBox(height: 10),
                    _PatientField(
                      icon: Icons.folder_open_rounded,
                      label: 'No. RM:',
                      value: patient.maskedNomr,
                    ),
                    const SizedBox(height: 6),
                    _PatientField(
                      icon: Icons.badge_outlined,
                      label: 'NIK:',
                      value: patient.maskedNik,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientField extends StatelessWidget {
  const _PatientField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brandDarkEspresso,
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPatientCard extends StatelessWidget {
  const _AddPatientCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.brandGoldenCaramel.withValues(alpha: 0.45),
            radius: 16,
            strokeWidth: 2,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandGoldenCaramel.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brandGoldenCaramel.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 20,
                    color: AppColors.brandGoldenCaramel,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+ Tambah Pasien / Keluarga',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: AppColors.brandWarmBronze,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Daftarkan pasien baru atau tautkan No. RM lama '
                        'RSUP Dr. Sitanala.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.brandGoldenCaramel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityComplianceNotice extends StatelessWidget {
  const _SecurityComplianceNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.brandCreamLinen.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            size: 16,
            color: AppColors.brandGoldenCaramel,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Data rekam medis terlindungi sesuai standar keamanan ',
                  ),
                  TextSpan(
                    text: 'Kementerian Kesehatan RI',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: ' dan UU Perlindungan Data Pribadi (PDP).'),
                ],
              ),
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    this.radius = 16,
    this.strokeWidth = 2,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    const double dashLength = 6;
    const double gapLength = 4;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
