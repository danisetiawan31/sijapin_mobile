import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

void main() {
  group('FamilyMember Entity Tests', () {
    test('initials menghasilkan inisial yang benar', () {
      const member1 = FamilyMember(
        id: '1',
        fullName: 'Ahmad Fauzi Rahman',
        relation: FamilyRelation.spouse,
        gender: 'L',
        nik: '3671041205860005',
        insurance: FamilyInsurance.bpjs,
      );
      expect(member1.initials, 'AF');

      const member2 = FamilyMember(
        id: '2',
        fullName: 'Nadira',
        relation: FamilyRelation.child,
        gender: 'P',
        nik: '3671047103150008',
        insurance: FamilyInsurance.umum,
      );
      expect(member2.initials, 'N');

      const member3 = FamilyMember(
        id: '3',
        fullName: '   ',
        relation: FamilyRelation.sibling,
        gender: 'L',
        nik: '3671040904790009',
        insurance: FamilyInsurance.selfPay,
      );
      expect(member3.initials, '?');
    });

    test('hasProfileComplete memvalidasi NIK dan tanggal lahir', () {
      final complete = FamilyMember(
        id: '1',
        fullName: 'Ahmad',
        relation: FamilyRelation.spouse,
        gender: 'L',
        nik: '3671041205860005',
        birthDate: DateTime(1986, 5, 12),
        insurance: FamilyInsurance.bpjs,
      );
      expect(complete.hasProfileComplete, isTrue);

      const noBirthDate = FamilyMember(
        id: '2',
        fullName: 'Nadira',
        relation: FamilyRelation.child,
        gender: 'P',
        nik: '3671047103150008',
        insurance: FamilyInsurance.bpjs,
      );
      expect(noBirthDate.hasProfileComplete, isFalse);

      final emptyNik = FamilyMember(
        id: '3',
        fullName: 'Rafi',
        relation: FamilyRelation.child,
        gender: 'L',
        nik: '',
        birthDate: DateTime(2022, 9, 20),
        insurance: FamilyInsurance.umum,
      );
      expect(emptyNik.hasProfileComplete, isFalse);
    });

    test('isNewPatient dan maskedMedicalRecord bekerja sesuai No. RM', () {
      const oldPatient = FamilyMember(
        id: '1',
        fullName: 'Ahmad',
        relation: FamilyRelation.spouse,
        gender: 'L',
        nik: '3671041205860005',
        medicalRecordNumber: '012345',
        insurance: FamilyInsurance.bpjs,
      );
      expect(oldPatient.isNewPatient, isFalse);
      expect(oldPatient.maskedMedicalRecord, '0123**');

      const newPatient = FamilyMember(
        id: '2',
        fullName: 'Rafi',
        relation: FamilyRelation.child,
        gender: 'L',
        nik: '3671042009220011',
        insurance: FamilyInsurance.umum,
      );
      expect(newPatient.isNewPatient, isTrue);
      expect(newPatient.maskedMedicalRecord, 'Pasien Baru');
    });

    test(
      'toPatientMember mengonversi entitas dengan benar ke format booking',
      () {
        final member = FamilyMember(
          id: 'keluarga-10',
          fullName: 'Ahmad Fauzi Rahman',
          relation: FamilyRelation.spouse,
          gender: 'L',
          nik: '3671041205860005',
          medicalRecordNumber: '012345',
          insurance: FamilyInsurance.bpjs,
          insuranceNumber: '0001122334455',
          phone: '081298765432',
          birthDate: DateTime(1986, 5, 12),
          birthPlace: 'Tangerang',
          motherName: 'Maryam',
          address: 'Jl. Dr. Sitanala No. 12',
        );

        final patient = member.toPatientMember();
        expect(patient.id, 10);
        expect(patient.fullName, 'Ahmad Fauzi Rahman');
        expect(patient.nik, '3671041205860005');
        expect(patient.medicalRecordNumber, '012345');
        expect(patient.relation, 'Suami / Istri');
        expect(patient.gender, 'L');
        expect(patient.birthDate, DateTime(1986, 5, 12));
        expect(patient.bpjsCardNumber, '0001122334455');
        expect(patient.phone, '081298765432');
        expect(patient.birthPlace, 'Tangerang');
        expect(patient.motherName, 'Maryam');
        expect(patient.address, 'Jl. Dr. Sitanala No. 12');
        expect(patient.isNewPatient, isFalse);
      },
    );

    test('copyWith dan value equality bekerja dengan presisi', () {
      const member1 = FamilyMember(
        id: '1',
        fullName: 'Ahmad',
        relation: FamilyRelation.spouse,
        gender: 'L',
        nik: '3671041205860005',
        insurance: FamilyInsurance.bpjs,
      );

      final member2 = member1.copyWith(fullName: 'Ahmad Fauzi');
      expect(member2.fullName, 'Ahmad Fauzi');
      expect(member2.id, '1');
      expect(member1 == member2, isFalse);

      final member3 = member1.copyWith();
      expect(member1 == member3, isTrue);
      expect(member1.hashCode, member3.hashCode);
    });

    test(
      'resolvedRdNomr mengembalikan status rekam medis SIMRS yang akurat',
      () {
        const oldMember = FamilyMember(
          id: '1',
          fullName: 'Budi',
          relation: FamilyRelation.spouse,
          gender: 'L',
          nik: '3671041205860005',
          insurance: FamilyInsurance.bpjs,
          medicalRecordNumber: '098877',
        );
        expect(oldMember.resolvedRdNomr, '1');

        const newMember = FamilyMember(
          id: '2',
          fullName: 'Siti',
          relation: FamilyRelation.child,
          gender: 'P',
          nik: '3671047103150008',
          insurance: FamilyInsurance.umum,
        );
        expect(newMember.resolvedRdNomr, '3');

        const explicitMember = FamilyMember(
          id: '3',
          fullName: 'Dewi',
          relation: FamilyRelation.parent,
          gender: 'P',
          nik: '3671045709520003',
          insurance: FamilyInsurance.bpjs,
          rdNomr: '1',
        );
        expect(explicitMember.resolvedRdNomr, '1');
      },
    );

    test('field database SIMRS (TMP_LAHIR, NAMA_IBU, ALAMAT) tersimpan dengan baik', () {
      const member = FamilyMember(
        id: '10',
        fullName: 'Anisa',
        relation: FamilyRelation.child,
        gender: 'P',
        nik: '3671047103150008',
        insurance: FamilyInsurance.bpjs,
        birthPlace: 'Tangerang',
        motherName: 'Siti Aminah',
        address: 'Jl. Dr. Sitanala No. 99',
        religion: '1',
        occupation: 'Pelajar',
      );

      expect(member.birthPlace, 'Tangerang');
      expect(member.motherName, 'Siti Aminah');
      expect(member.address, 'Jl. Dr. Sitanala No. 99');
      expect(member.religion, '1');
      expect(member.occupation, 'Pelajar');

      final updated = member.copyWith(
        motherName: 'Aminah',
        occupation: 'Mahasiswa',
      );
      expect(updated.motherName, 'Aminah');
      expect(updated.occupation, 'Mahasiswa');
      expect(updated.birthPlace, 'Tangerang');
    });
  });
}
