import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';

void main() {
  group('BookingDraft Unit Tests (Epic 05 Validations)', () {
    final samplePatient = PatientMember(
      id: 1,
      fullName: 'Ahmad Dhani Setiawan',
      nik: '3671041205950001',
      medicalRecordNumber: '012345',
      relation: 'Diri Sendiri',
      gender: 'L',
      birthDate: DateTime(1995, 5, 12),
      bpjsCardNumber: '0001234567891',
    );

    const sampleClinic = Polyclinic(
      id: 1,
      name: 'Poli Penyakit Dalam',
      code: 'PDI',
      floor: 'Lantai 1',
    );

    const sampleDoctor = DoctorSchedule(
      id: 'doc-1',
      name: 'dr. Era Medina, Sp.PD',
      specialization: 'Spesialis Penyakit Dalam',
      schedules: [
        DoctorScheduleEntry(day: 'Senin', startTime: '08:00', endTime: '12:00'),
      ],
      status: DoctorPracticeStatus.reguler,
    );

    const sampleDoctorCuti = DoctorSchedule(
      id: 'doc-2',
      name: 'dr. Cuti, Sp.PD',
      specialization: 'Spesialis Penyakit Dalam',
      schedules: [],
      status: DoctorPracticeStatus.cuti,
    );

    test('Initial BookingDraft is empty and step 1 is invalid', () {
      const draft = BookingDraft();
      expect(draft.currentStep, equals(0));
      expect(draft.patient, isNull);
      expect(draft.isStep1Valid, isFalse);
      expect(draft.canProceedCurrentStep, isFalse);
    });

    test('Step 1 validation requires BPJS reference number if BPJS chosen', () {
      // Patient selected, but no BPJS reference number
      var draft = BookingDraft(
        patient: samplePatient,
        insuranceType: InsuranceType.bpjs,
        bpjsReferenceNumber: null,
      );
      expect(draft.isStep1Valid, isFalse);

      // BPJS reference filled
      draft = draft.copyWith(bpjsReferenceNumber: '0123B0010926P000123');
      expect(draft.isStep1Valid, isTrue);
      expect(draft.canProceedCurrentStep, isTrue);

      // If Umum chosen, BPJS reference is not required
      draft = draft.copyWith(
        insuranceType: InsuranceType.umum,
        clearBpjsReference: true,
      );
      expect(draft.isStep1Valid, isTrue);
    });

    test('Step 2 validation requires clinic and non-weekend weekday', () {
      // Missing date and clinic
      var draft = const BookingDraft();
      expect(draft.isStep2Valid, isFalse);

      // Saturday (weekend) should be invalid
      draft = draft.copyWith(
        clinic: sampleClinic,
        bookingDate: DateTime(2026, 10, 3), // Sabtu
      );
      expect(draft.isStep2Valid, isFalse);

      // Sunday (weekend) should be invalid
      draft = draft.copyWith(
        clinic: sampleClinic,
        bookingDate: DateTime(2026, 10, 4), // Minggu
      );
      expect(draft.isStep2Valid, isFalse);

      // Wednesday (weekday) should be valid
      draft = draft.copyWith(
        clinic: sampleClinic,
        bookingDate: DateTime(2026, 9, 30), // Rabu
      );
      expect(draft.isStep2Valid, isTrue);
    });

    test('Step 3 validation requires reguler practicing doctor', () {
      // Doctor is null
      var draft = const BookingDraft();
      expect(draft.isStep3Valid, isFalse);

      // Doctor is on leave (cuti)
      draft = draft.copyWith(doctor: sampleDoctorCuti);
      expect(draft.isStep3Valid, isFalse);

      // Doctor is regular
      draft = draft.copyWith(doctor: sampleDoctor);
      expect(draft.isStep3Valid, isTrue);
    });

    test(
      'Step 4 validation requires all previous steps AND terms agreement',
      () {
        var draft = BookingDraft(
          patient: samplePatient,
          insuranceType: InsuranceType.umum,
          clinic: sampleClinic,
          bookingDate: DateTime(2026, 9, 30), // Rabu
          doctor: sampleDoctor,
          isAgreedToTerms: false,
        );

        // Terms not yet agreed
        expect(draft.isStep4Valid, isFalse);

        // Terms agreed
        draft = draft.copyWith(isAgreedToTerms: true);
        expect(draft.isStep4Valid, isTrue);
        expect(draft.canProceedCurrentStep, isTrue);
      },
    );
  });
}
