import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_constants.dart';
import '../../domain/entities/family_member.dart';
import '../../domain/repositories/family_member_repository.dart';
import '../datasources/family_members_mock_data.dart';
import '../datasources/profile_remote_data_source.dart';

/// Implementasi repositori anggota keluarga yang terhubung ke server CI3 SIMRS
/// dengan fallback ke memori/cache lokal (Hive NoSQL) untuk mendukung operasi offline.
class FamilyMemberRepositoryImpl implements FamilyMemberRepository {
  FamilyMemberRepositoryImpl({
    this.remoteDataSource,
    this.localStorage,
    List<FamilyMember>? initialMembers,
  }) : _members = List<FamilyMember>.from(
          initialMembers ?? kMockFamilyMembers,
        );

  final IProfileRemoteDataSource? remoteDataSource;
  final ILocalStorage? localStorage;
  final List<FamilyMember> _members;

  @override
  List<FamilyMember> getCachedFamilyMembers() =>
      List<FamilyMember>.unmodifiable(_members);

  /// Alias getCachedFamilyMembers untuk kompatibilitas.
  List<FamilyMember> getInitialMembers() => getCachedFamilyMembers();

  Set<String> _getHiddenMemberIds() {
    if (localStorage == null) return <String>{};
    try {
      final list = localStorage!.get<List<dynamic>>(
        boxName: StorageConstants.preferencesBox,
        key: StorageConstants.keyHiddenFamilyMemberIds,
      );
      if (list != null) {
        return list.map((e) => e.toString()).toSet();
      }
    } catch (_) {}
    return <String>{};
  }

  Future<void> _recordHiddenMemberId(String id) async {
    if (localStorage == null) return;
    try {
      final hidden = _getHiddenMemberIds()..add(id);
      await localStorage!.put<dynamic>(
        boxName: StorageConstants.preferencesBox,
        key: StorageConstants.keyHiddenFamilyMemberIds,
        value: hidden.toList(),
      );
    } catch (_) {}
  }

  Future<void> _unhideMemberId(String id) async {
    if (localStorage == null) return;
    try {
      final hidden = _getHiddenMemberIds();
      if (hidden.remove(id)) {
        await localStorage!.put<dynamic>(
          boxName: StorageConstants.preferencesBox,
          key: StorageConstants.keyHiddenFamilyMemberIds,
          value: hidden.toList(),
        );
      }
    } catch (_) {}
  }

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    final hiddenIds = _getHiddenMemberIds();
    _members.removeWhere((m) => hiddenIds.contains(m.id));

    // 1. Sinkronisasi dari cache lokal Hive jika tersedia
    if (localStorage != null) {
      try {
        final cached = localStorage!.getAll<dynamic>(
          boxName: StorageConstants.familyMembersBox,
        );
        if (cached.isNotEmpty) {
          for (final raw in cached) {
            if (raw is Map) {
              final member = FamilyMember.fromMap(
                Map<String, dynamic>.from(raw),
              );
              if (hiddenIds.contains(member.id)) continue;
              final idx = _members.indexWhere((m) => m.id == member.id);
              if (idx != -1) {
                _members[idx] = member;
              } else {
                _members.add(member);
              }
            }
          }
        }
      } catch (_) {
        // Abaikan kendala storage
      }
    }

    // 2. Sinkronisasi dari server CI3 RSUP Sitanala jika ada koneksi
    if (remoteDataSource != null) {
      try {
        final remoteList = await remoteDataSource!.fetchFamilyMembers();
        if (remoteList != null && remoteList.isNotEmpty) {
          for (final remote in remoteList) {
            if (hiddenIds.contains(remote.id)) continue;
            final idx = _members.indexWhere((m) => m.id == remote.id);
            if (idx != -1) {
              final existing = _members[idx];
              _members[idx] = existing.copyWith(
                fullName: remote.fullName.isNotEmpty
                    ? remote.fullName
                    : existing.fullName,
                nik: remote.nik.isNotEmpty ? remote.nik : existing.nik,
                birthDate: remote.birthDate ?? existing.birthDate,
                birthPlace: remote.birthPlace.isNotEmpty
                    ? remote.birthPlace
                    : existing.birthPlace,
                motherName: remote.motherName.isNotEmpty
                    ? remote.motherName
                    : existing.motherName,
                address: remote.address.isNotEmpty
                    ? remote.address
                    : existing.address,
                phone: remote.phone.isNotEmpty ? remote.phone : existing.phone,
                religion: remote.religion.isNotEmpty
                    ? remote.religion
                    : existing.religion,
                occupation: remote.occupation.isNotEmpty
                    ? remote.occupation
                    : existing.occupation,
                medicalRecordNumber:
                    remote.medicalRecordNumber ?? existing.medicalRecordNumber,
                rdNomr: remote.rdNomr ?? existing.rdNomr,
              );
            } else {
              _members.add(remote);
            }
            if (localStorage != null) {
              try {
                await localStorage!.put<dynamic>(
                  boxName: StorageConstants.familyMembersBox,
                  key: _members[idx != -1 ? idx : _members.length - 1].id,
                  value: _members[idx != -1 ? idx : _members.length - 1].toMap(),
                );
              } catch (_) {}
            }
          }
        }
      } catch (_) {
        // Fallback ke data cached jika gagal terhubung
      }
    }
    return List<FamilyMember>.unmodifiable(_members);
  }

  @override
  Future<FamilyMember> addFamilyMember(FamilyMember member) async {
    await _unhideMemberId(member.id);
    _members.add(member);
    if (localStorage != null) {
      try {
        await localStorage!.put<dynamic>(
          boxName: StorageConstants.familyMembersBox,
          key: member.id,
          value: member.toMap(),
        );
      } catch (_) {}
    }
    if (remoteDataSource != null) {
      try {
        final res = await remoteDataSource!.saveFamilyMember(member);
        if (res['ret'] == 'success') {
          // Reconcile ID: ambil daftar pasien terbaru dari CI3 untuk menangkap auto-increment ID asli
          final remoteList = await remoteDataSource!.fetchFamilyMembers();
          if (remoteList != null && remoteList.isNotEmpty) {
            final match = remoteList.firstWhere(
              (r) =>
                  r.fullName.trim().toLowerCase() ==
                  member.fullName.trim().toLowerCase(),
              orElse: () => member,
            );
            if (match.id != member.id && match.id.isNotEmpty) {
              final newId = match.id;
              final oldId = member.id;
              await _unhideMemberId(newId);
              final updatedMember = member.copyWith(id: newId);
              final idx = _members.indexWhere((m) => m.id == oldId);
              if (idx != -1) {
                _members[idx] = updatedMember;
              }
              if (localStorage != null) {
                try {
                  await localStorage!.delete(
                    boxName: StorageConstants.familyMembersBox,
                    key: oldId,
                  );
                  await localStorage!.put<dynamic>(
                    boxName: StorageConstants.familyMembersBox,
                    key: newId,
                    value: updatedMember.toMap(),
                  );
                } catch (_) {}
              }
              return updatedMember;
            }
          }
        }
      } catch (_) {
        // Log dan pertahankan data lokal agar UX tidak terhambat
      }
    }
    return member;
  }

  @override
  Future<FamilyMember> updateFamilyMember(FamilyMember member) async {
    final int index = _members.indexWhere((FamilyMember m) => m.id == member.id);
    if (index != -1) {
      _members[index] = member;
    } else {
      _members.add(member);
    }
    if (localStorage != null) {
      try {
        await localStorage!.put<dynamic>(
          boxName: StorageConstants.familyMembersBox,
          key: member.id,
          value: member.toMap(),
        );
      } catch (_) {}
    }
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.saveFamilyMember(member, isUpdate: true);
      } catch (_) {
        // Log dan pertahankan data lokal
      }
    }
    return member;
  }

  @override
  Future<bool> deleteFamilyMember(String id) async {
    final int initialLength = _members.length;
    _members.removeWhere((FamilyMember m) => m.id == id);
    await _recordHiddenMemberId(id);
    if (localStorage != null) {
      try {
        await localStorage!.delete(
          boxName: StorageConstants.familyMembersBox,
          key: id,
        );
      } catch (_) {}
    }
    return _members.length < initialLength;
  }
}

/// Provider instance repositori anggota keluarga.
final familyMemberRepositoryProvider = Provider<FamilyMemberRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final remoteDataSource = ProfileRemoteDataSource(dioClient: dioClient);
  return FamilyMemberRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localStorage: localStorage,
  );
});
