import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

/// Daftar anggota keluarga yang terdaftar atas nama pasien aktif.
///
/// STATUS SEMENTARA: endpoint anggota keluarga belum tersedia, sehingga isi
/// provider ini masih data contoh. Ganti dengan pembacaan API tanpa perlu
/// menyentuh [FamilyMembersScreen] maupun widget presentasinya.
final familyMembersProvider = Provider<List<FamilyMember>>((ref) {
  return <FamilyMember>[
    FamilyMember(
      id: 'keluarga-1',
      fullName: 'Ahmad Fauzi Rahman',
      relation: FamilyRelation.spouse,
      gender: 'L',
      nik: '3671041205860005',
      birthDate: DateTime(1986, 5, 12),
      bloodType: 'A',
      phone: '081298765432',
      insurance: FamilyInsurance.bpjs,
      insuranceNumber: '0001122334455',
      lastServiceDate: DateTime(2026, 8, 19),
      healthNote: 'Hipertensi ringan, rutin kontrol setiap 3 bulan.',
      isPrimary: true,
    ),
    FamilyMember(
      id: 'keluarga-2',
      fullName: 'Nadira Aulia Putri',
      relation: FamilyRelation.child,
      gender: 'P',
      nik: '3671047103150008',
      birthDate: DateTime(2015, 3, 15),
      bloodType: 'O',
      phone: '',
      insurance: FamilyInsurance.bpjs,
      insuranceNumber: '0001122334456',
      lastServiceDate: DateTime(2026, 7, 22),
      healthNote: 'Asma ringan, hindari debu dan asap rokok.',
    ),
    FamilyMember(
      id: 'keluarga-3',
      fullName: 'Rafi Aulia Pratama',
      relation: FamilyRelation.child,
      gender: 'L',
      nik: '3671042009220011',
      birthDate: DateTime(2022, 9, 20),
      bloodType: 'B',
      phone: '',
      insurance: FamilyInsurance.umum,
      lastServiceDate: DateTime(2026, 5, 8),
      healthNote: 'Imunisasi lengkap, pemeriksaan rutin anak setiap tahun.',
    ),
    FamilyMember(
      id: 'keluarga-4',
      fullName: 'Siti Aminah',
      relation: FamilyRelation.parent,
      gender: 'P',
      nik: '3671045709520003',
      birthDate: DateTime(1952, 9, 27),
      bloodType: 'AB',
      phone: '081377778888',
      insurance: FamilyInsurance.bpjs,
      insuranceNumber: '0001122334457',
      lastServiceDate: DateTime(2026, 9, 1),
      healthNote:
          'Diabetes melitus tipe 2, kaki mudah lecet. Memerlukan kursi roda '
          'saat mobilitas menurun.',
    ),
    FamilyMember(
      id: 'keluarga-5',
      fullName: 'Hendra Wijaya',
      relation: FamilyRelation.sibling,
      gender: 'L',
      nik: '3671040904790009',
      birthDate: DateTime(1979, 4, 9),
      bloodType: 'O',
      phone: '081355553333',
      insurance: FamilyInsurance.umum,
      healthNote: 'Belum pernah berobat di Sitanala, data belum lengkap.',
    ),
  ];
});
