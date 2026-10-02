import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sijapin_mobile/core/router/app_routes.dart';
import 'package:sijapin_mobile/core/theme/app_colors.dart';
import 'package:sijapin_mobile/core/widgets/app_button.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/family_member_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/add_family_member_sheet.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_filter_bar.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_card.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_member_detail_sheet.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_policy_notice.dart';
import 'package:sijapin_mobile/features/profile/presentation/widgets/family_summary_card.dart';

export 'package:sijapin_mobile/features/profile/presentation/widgets/add_family_member_sheet.dart';
export 'package:sijapin_mobile/features/profile/presentation/widgets/family_filter_bar.dart';
export 'package:sijapin_mobile/features/profile/presentation/widgets/family_policy_notice.dart';
export 'package:sijapin_mobile/features/profile/presentation/widgets/family_summary_card.dart';

/// Daftar anggota keluarga terdaftar, dibuka dari menu "Anggota Keluarga".
class FamilyMembersScreen extends ConsumerStatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  ConsumerState<FamilyMembersScreen> createState() =>
      _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends ConsumerState<FamilyMembersScreen> {
  FamilyMemberFilter _filter = FamilyMemberFilter.semua;

  void _openAddMemberSheet() {
    AddFamilyMemberSheet.show(
      context,
      onSave: (FamilyMember newMember) {
        ref.read(familyMembersProvider.notifier).addMember(newMember);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Anggota keluarga "${newMember.fullName}" berhasil ditambahkan.',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.brandDarkEspresso,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
      },
    );
  }

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
                    child: RefreshIndicator(
                      onRefresh: () => ref
                          .read(familyMembersProvider.notifier)
                          .loadMembers(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: [
                          FamilySummaryCard(members: members),
                          const SizedBox(height: 16),
                          FamilyFilterBar(
                            selected: _filter,
                            onSelected: (FamilyMemberFilter filter) {
                              setState(() => _filter = filter);
                            },
                          ),
                          const SizedBox(height: 16),
                          if (visible.isEmpty)
                            AppEmptyState(
                              title: 'Belum Ada Anggota',
                              message:
                                  'Belum ada anggota keluarga pada kategori ini. '
                                  'Tambahkan anggota agar bisa didaftarkan berobat '
                                  'tanpa didampingi langsung.',
                              icon: Icons.group_add_outlined,
                              actionButton: _filter != FamilyMemberFilter.semua
                                  ? AppSecondaryButton(
                                      label: 'Tampilkan Semua',
                                      width: 180,
                                      onPressed: () {
                                        setState(
                                          () => _filter =
                                              FamilyMemberFilter.semua,
                                        );
                                      },
                                    )
                                  : null,
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
                          const FamilyPolicyNotice(),
                        ],
                      ),
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
                      onPressed: _openAddMemberSheet,
                    ),
                  ),
                ],
              ),
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
