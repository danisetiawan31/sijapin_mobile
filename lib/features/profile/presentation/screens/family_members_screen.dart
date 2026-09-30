import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/app_card.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/family_member_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_card.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_detail_sheet.dart';

/// Filter hubungan keluarga pada daftar anggota.
enum FamilyMemberFilter { semua, spouse, child, parent, sibling }

extension FamilyMemberFilterLabel on FamilyMemberFilter {
  String get label {
    switch (this) {
      case FamilyMemberFilter.semua:
        return 'Semua';
      case FamilyMemberFilter.spouse:
        return 'Pasangan';
      case FamilyMemberFilter.child:
        return 'Anak';
      case FamilyMemberFilter.parent:
        return 'Orang Tua';
      case FamilyMemberFilter.sibling:
        return 'Saudara';
    }
  }

  FamilyRelation? get relation {
    switch (this) {
      case FamilyMemberFilter.semua:
        return null;
      case FamilyMemberFilter.spouse:
        return FamilyRelation.spouse;
      case FamilyMemberFilter.child:
        return FamilyRelation.child;
      case FamilyMemberFilter.parent:
        return FamilyRelation.parent;
      case FamilyMemberFilter.sibling:
        return FamilyRelation.sibling;
    }
  }
}

/// Daftar anggota keluarga terdaftar, dibuka dari menu "Anggota Keluarga".
///
/// Tampilan sementara sesuai DESIGN.md: kartu squircle bertahap berisi
/// profil tiap anggota, bukan tabel datar, dengan CTA "Tambah Anggota" yang
/// menempel di thumb zone bagian bawah.
class FamilyMembersScreen extends ConsumerStatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  ConsumerState<FamilyMembersScreen> createState() =>
      _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends ConsumerState<FamilyMembersScreen> {
  FamilyMemberFilter _filter = FamilyMemberFilter.semua;

  @override
  Widget build(BuildContext context) {
    final ProfileState profile = ref.watch(profileControllerProvider);
    final List<FamilyMember> members = ref.watch(familyMembersProvider);
    final List<FamilyMember> visible = _filter.relation == null
        ? members
        : members
              .where(
                (FamilyMember member) => member.relation == _filter.relation,
              )
              .toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(title: const Text('Anggota Keluarga'), centerTitle: false),
      body: SafeArea(
        top: false,
        child: !profile.isSignedIn
            ? const _SignedOutNotice()
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        _FamilySummaryCard(members: members),
                        const SizedBox(height: 16),
                        _FamilyFilterBar(
                          selected: _filter,
                          onSelected: (FamilyMemberFilter filter) {
                            setState(() => _filter = filter);
                          },
                        ),
                        const SizedBox(height: 16),
                        if (visible.isEmpty)
                          const AppEmptyState(
                            title: 'Belum Ada Anggota',
                            message:
                                'Belum ada anggota keluarga pada kategori ini. '
                                'Tambahkan anggota agar bisa didaftarkan berobat '
                                'tanpa didampingi langsung.',
                            icon: Icons.group_add_outlined,
                          )
                        else
                          for (int index = 0; index < visible.length; index++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: index == visible.length - 1 ? 0 : 12,
                              ),
                              child: FamilyMemberCard(
                                member: visible[index],
                                onTap: () => FamilyMemberDetailSheet.show(
                                  context,
                                  visible[index],
                                ),
                              ),
                            ),
                        const SizedBox(height: 16),
                        const _FamilyPolicyNotice(),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      border: const Border(
                        top: BorderSide(color: AppColors.borderSubtle),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandDarkEspresso.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: AppPrimaryButton(
                      label: 'Tambah Anggota Keluarga',
                      icon: Icons.person_add_alt_1_rounded,
                      onPressed: () =>
                          _showComingSoon(context, 'Tambah Anggota Keluarga'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Kartu ringkasan jumlah anggota, jaminan BPJS, dan anggota utama.
class _FamilySummaryCard extends StatelessWidget {
  const _FamilySummaryCard({required this.members});

  final List<FamilyMember> members;

  @override
  Widget build(BuildContext context) {
    final List<FamilyMember> bpjsMembers = members
        .where(
          (FamilyMember member) => member.insurance == FamilyInsurance.bpjs,
        )
        .toList();
    FamilyMember? utama;
    for (final FamilyMember member in members) {
      if (member.isPrimary) {
        utama = member;
        break;
      }
    }

    return AppCard.filled(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandGoldenCaramel.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.groups_2_outlined,
              size: 22,
              color: AppColors.brandGoldenCaramel,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${members.length} anggota keluarga',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandDarkEspresso,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${bpjsMembers.length} memakai BPJS • '
                  'Utama: ${utama?.fullName ?? 'Belum ada'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

/// Bilah filter hubungan keluarga: kapsul aktif warna karamel keemasan.
class _FamilyFilterBar extends StatelessWidget {
  const _FamilyFilterBar({required this.selected, required this.onSelected});

  final FamilyMemberFilter selected;
  final ValueChanged<FamilyMemberFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: FamilyMemberFilter.values.length,
        separatorBuilder: (BuildContext _, int _) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final FamilyMemberFilter filter = FamilyMemberFilter.values[index];
          return _FamilyFilterChip(
            label: filter.label,
            isSelected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}

class _FamilyFilterChip extends StatelessWidget {
  const _FamilyFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.brandGoldenCaramel
                  : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(
                color: isSelected
                    ? AppColors.brandGoldenCaramel
                    : AppColors.borderSubtle,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Catatan aturan verifikasi anggota keluarga.
class _FamilyPolicyNotice extends StatelessWidget {
  const _FamilyPolicyNotice();

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

/// State tamu: daftar anggota keluarga hanya untuk pasien yang sudah masuk.
class _SignedOutNotice extends StatelessWidget {
  const _SignedOutNotice();

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: 'Belum Masuk',
      message:
          'Masuk terlebih dahulu untuk mengelola anggota keluarga yang dapat '
          'Anda daftarkan berobat.',
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

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('$feature sedang kami kembangkan.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.brandDarkEspresso,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
}
