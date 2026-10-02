import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_controller.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';

import 'package:sijapin_mobile/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/doctor_schedule_repository_impl.dart';

void main() {
  group('BookingWizardController Tests', () {
    late ProviderContainer container;

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

    setUp(() {
      final doctorScheduleRepo = DoctorScheduleRepositoryImpl();
      final repository = BookingRepositoryImpl(
        doctorScheduleRepository: doctorScheduleRepo,
        bookingRemoteDataSource: null,
        initialPolyclinics: [sampleClinic],
      );
      container = ProviderContainer(
        overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial wizard state is step 0 and empty', () {
      final state = container.read(bookingWizardControllerProvider);
      expect(state.draft.currentStep, equals(0));
      expect(state.draft.patient, isNull);
      expect(state.isSubmitting, isFalse);
      expect(state.completedAppointment, isNull);
    });

    test(
      'nextStep fails if current step is incomplete and sets error message',
      () {
        final controller = container.read(
          bookingWizardControllerProvider.notifier,
        );

        final result = controller.nextStep();
        expect(result, isFalse);
        expect(
          container.read(bookingWizardControllerProvider).errorMessage,
          isNotNull,
        );
        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(0),
        );
      },
    );

    test(
      'Complete wizard flow from Step 1 to Step 4 and submitBooking',
      () async {
        final controller = container.read(
          bookingWizardControllerProvider.notifier,
        );

        // Step 1: Pasien & Penjamin Umum
        controller.setPatient(samplePatient);
        controller.setInsuranceType(InsuranceType.umum);
        expect(
          container.read(bookingWizardControllerProvider).draft.isStep1Valid,
          isTrue,
        );

        var nextOk = controller.nextStep();
        expect(nextOk, isTrue);
        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(1),
        );

        // Step 2: Poli & Tanggal Kunjungan (Rabu - Hari Kerja)
        controller.setClinic(sampleClinic);
        controller.setBookingDate(DateTime(2026, 9, 30));
        expect(
          container.read(bookingWizardControllerProvider).draft.isStep2Valid,
          isTrue,
        );

        nextOk = controller.nextStep();
        expect(nextOk, isTrue);
        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(2),
        );

        // Step 3: Dokter DPJP
        controller.setDoctor(sampleDoctor);
        expect(
          container.read(bookingWizardControllerProvider).draft.isStep3Valid,
          isTrue,
        );

        nextOk = controller.nextStep();
        expect(nextOk, isTrue);
        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(3),
        );

        // Step 4: Persetujuan & Submit
        controller.setAgreement(true);
        expect(
          container.read(bookingWizardControllerProvider).draft.isStep4Valid,
          isTrue,
        );

        // Eksekusi Submit Booking
        final appointment = await controller.submitBooking();
        expect(appointment, isNotNull);
        expect(appointment!.patientName, equals('Ahmad Dhani Setiawan'));
        expect(appointment.doctorName, equals('dr. Era Medina, Sp.PD'));
        expect(appointment.bookingCode.length, equals(13)); // 13 digit numerik
        expect(appointment.queueNumber, startsWith('PDI-'));

        // Verifikasi integrasi ke BookingController Tab Janji Temu rekan!
        final activeBooking = container
            .read(bookingControllerProvider)
            .appointment;
        expect(activeBooking, isNotNull);
        expect(activeBooking!.bookingCode, equals(appointment.bookingCode));
        expect(activeBooking.queueNumber, equals(appointment.queueNumber));
      },
    );

    test(
      'previousStep moves backward and goToStep navigates to visited step',
      () {
        final controller = container.read(
          bookingWizardControllerProvider.notifier,
        );
        controller.setPatient(samplePatient);
        controller.setInsuranceType(InsuranceType.umum);
        controller.nextStep(); // to Step 1

        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(1),
        );

        controller.previousStep();
        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(0),
        );

        controller.nextStep();
        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(1),
        );

        controller.goToStep(0);
        expect(
          container.read(bookingWizardControllerProvider).draft.currentStep,
          equals(0),
        );
      },
    );

    test('setClinic and setBookingDate reset previously selected doctor', () {
      final controller = container.read(
        bookingWizardControllerProvider.notifier,
      );

      controller.setClinic(sampleClinic);
      controller.setDoctor(sampleDoctor);
      expect(
        container.read(bookingWizardControllerProvider).draft.doctor,
        isNotNull,
      );

      // Mengganti poli harus mereset dokter
      const otherClinic = Polyclinic(
        id: 2,
        name: 'Poli Mata',
        code: 'MAT',
        floor: 'Lantai 2',
      );
      controller.setClinic(otherClinic);
      expect(
        container.read(bookingWizardControllerProvider).draft.doctor,
        isNull,
      );

      // Set dokter lagi lalu ganti tanggal
      controller.setDoctor(sampleDoctor);
      expect(
        container.read(bookingWizardControllerProvider).draft.doctor,
        isNotNull,
      );

      controller.setBookingDate(DateTime(2026, 10, 1));
      expect(
        container.read(bookingWizardControllerProvider).draft.doctor,
        isNull,
      );
    });

    test(
      'initializeWithDoctor resets state and auto-resolves matching clinic',
      () async {
        final controller = container.read(
          bookingWizardControllerProvider.notifier,
        );

        await controller.initializeWithDoctor(doctor: sampleDoctor);

        final state = container.read(bookingWizardControllerProvider);
        expect(state.draft.doctor, equals(sampleDoctor));
        expect(state.draft.clinic, isNotNull);
        expect(state.draft.clinic!.code, equals('PDI'));
      },
    );

    test('reset clears draft back to pristine state', () {
      final controller = container.read(
        bookingWizardControllerProvider.notifier,
      );

      controller.setPatient(samplePatient);
      controller.setInsuranceType(InsuranceType.umum);
      controller.nextStep();

      expect(
        container.read(bookingWizardControllerProvider).draft.currentStep,
        equals(1),
      );

      controller.reset();

      final state = container.read(bookingWizardControllerProvider);
      expect(state.draft.currentStep, equals(0));
      expect(state.draft.patient, isNull);
    });
  });
}
