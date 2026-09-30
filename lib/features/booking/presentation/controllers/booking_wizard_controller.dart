import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/booking_repository.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/family_member_controller.dart';

import 'booking_controller.dart';

/// State wizard pendaftaran rawat jalan
class BookingWizardState {
  const BookingWizardState({
    this.draft = const BookingDraft(),
    this.isSubmitting = false,
    this.errorMessage,
    this.completedAppointment,
  });

  final BookingDraft draft;
  final bool isSubmitting;
  final String? errorMessage;
  final Appointment? completedAppointment;

  bool get isCompleted => completedAppointment != null;

  BookingWizardState copyWith({
    BookingDraft? draft,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    Appointment? completedAppointment,
    bool clearAppointment = false,
  }) {
    return BookingWizardState(
      draft: draft ?? this.draft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedAppointment: clearAppointment
          ? null
          : (completedAppointment ?? this.completedAppointment),
    );
  }
}

/// Controller wizard pendaftaran rawat jalan (Epic 05)
class BookingWizardController extends Notifier<BookingWizardState> {
  @override
  BookingWizardState build() {
    return const BookingWizardState();
  }

  BookingRepository get _repository => ref.read(bookingRepositoryProvider);

  /// Mengatur pasien yang dipilih (Step 1)
  void setPatient(PatientMember patient) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        patient: patient,
        // Jika pasien punya nomor BPJS dan saat ini belum ada nomor rujukan, pertahankan atau reset
      ),
      clearError: true,
    );
  }

  /// Mengatur jenis penjaminan (Step 1)
  void setInsuranceType(InsuranceType type) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        insuranceType: type,
        clearBpjsReference: type == InsuranceType.umum,
      ),
      clearError: true,
    );
  }

  /// Mengatur nomor rujukan / surat kontrol BPJS (Step 1)
  void setBpjsReferenceNumber(String refNumber) {
    state = state.copyWith(
      draft: state.draft.copyWith(bpjsReferenceNumber: refNumber),
      clearError: true,
    );
  }

  /// Mengatur poliklinik tujuan (Step 2)
  void setClinic(Polyclinic clinic) {
    // Jika poli berubah, dokter sebelumnya di-reset
    state = state.copyWith(
      draft: state.draft.copyWith(clinic: clinic, clearDoctor: true),
      clearError: true,
    );
  }

  /// Mengatur tanggal rencana kunjungan (Step 2)
  void setBookingDate(DateTime date) {
    state = state.copyWith(
      draft: state.draft.copyWith(bookingDate: date, clearDoctor: true),
      clearError: true,
    );
  }

  /// Mengatur dokter DPJP yang dipilih (Step 3)
  void setDoctor(DoctorSchedule doctor) {
    state = state.copyWith(
      draft: state.draft.copyWith(doctor: doctor),
      clearError: true,
    );
  }

  /// Mengatur persetujuan tata tertib & syarat ketentuan (Step 4)
  void setAgreement(bool agreed) {
    state = state.copyWith(
      draft: state.draft.copyWith(isAgreedToTerms: agreed),
      clearError: true,
    );
  }

  /// Melangkah ke tahap berikutnya jika validasi lolos
  bool nextStep() {
    if (!state.draft.canProceedCurrentStep) {
      state = state.copyWith(
        errorMessage: 'Harap lengkapi seluruh isian wajib pada langkah ini.',
      );
      return false;
    }

    if (state.draft.currentStep < 3) {
      state = state.copyWith(
        draft: state.draft.copyWith(currentStep: state.draft.currentStep + 1),
        clearError: true,
      );
      return true;
    }
    return false;
  }

  /// Kembali ke langkah sebelumnya
  void previousStep() {
    if (state.draft.currentStep > 0) {
      state = state.copyWith(
        draft: state.draft.copyWith(currentStep: state.draft.currentStep - 1),
        clearError: true,
      );
    }
  }

  /// Berpindah langsung ke langkah tertentu
  void goToStep(int step) {
    if (step >= 0 && step <= 3 && step <= state.draft.currentStep) {
      state = state.copyWith(
        draft: state.draft.copyWith(currentStep: step),
        clearError: true,
      );
    }
  }

  /// Inisialisasi awal wizard dengan dokter/poli jika dibuka dari Jadwal Dokter
  Future<void> initializeWithDoctor({
    required DoctorSchedule doctor,
    Polyclinic? clinic,
    DateTime? date,
  }) async {
    // Reset state terlebih dahulu agar sesi pendaftaran dimulai dari awal yang bersih
    reset();

    // Cari poliklinik yang sesuai jika belum disediakan
    Polyclinic? targetClinic = clinic;
    if (targetClinic == null) {
      try {
        final clinics = await _repository.getPolyclinics();
        final docSpec = doctor.specialization.toLowerCase();
        final docPoli = doctor.poli.toLowerCase();
        targetClinic = clinics.firstWhere((c) {
          final cName = c.name.toLowerCase();
          return cName.contains(docPoli) ||
              c.code.toLowerCase() == docPoli ||
              (c.code == 'PDI' && docSpec.contains('penyakit dalam')) ||
              (c.code == 'MAT' && docSpec.contains('mata')) ||
              (c.code == 'THT' && docSpec.contains('tht')) ||
              (c.code == 'OBG' &&
                  (docSpec.contains('kandungan') ||
                      docSpec.contains('obgyn'))) ||
              (c.code == 'ANA' && docSpec.contains('anak')) ||
              (c.code == 'GIG' && docSpec.contains('gigi')) ||
              (c.code == 'JAN' && docSpec.contains('jantung')) ||
              (c.code == 'SAR' && docSpec.contains('saraf'));
        }, orElse: () => clinics.first);
      } catch (_) {
        // Fallback jika pemanggilan gagal
      }
    }

    state = state.copyWith(
      draft: state.draft.copyWith(
        doctor: doctor,
        clinic: targetClinic,
        bookingDate: date,
      ),
    );
  }

  /// Final submit: Mengirim pendaftaran ke server CI3 dan menerbitkan tiket
  Future<Appointment?> submitBooking() async {
    if (!state.draft.isStep4Valid) {
      state = state.copyWith(
        errorMessage:
            'Data formulir belum lengkap atau persetujuan belum dicentang.',
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final appointment = await _repository.submitBooking(draft: state.draft);

      // Simpan appointment ke state wizard
      state = state.copyWith(
        isSubmitting: false,
        completedAppointment: appointment,
      );

      // Integrasikan hasil booking langsung ke Tab Janji Temu rekan!
      ref.read(bookingControllerProvider.notifier).setAppointment(appointment);

      return appointment;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Gagal membuat janji temu: ${e.toString()}',
      );
      return null;
    }
  }

  /// Reset form wizard
  void reset() {
    state = const BookingWizardState();
  }
}

/// Provider wizard controller
final bookingWizardControllerProvider =
    NotifierProvider<BookingWizardController, BookingWizardState>(
      BookingWizardController.new,
    );

/// Provider daftar anggota keluarga / pasien (tersinkronisasi dengan modul profil keluarga)
final patientMembersProvider = FutureProvider<List<PatientMember>>((ref) {
  final familyMembers = ref.watch(familyMembersProvider);
  if (familyMembers.isNotEmpty) {
    return familyMembers.map((FamilyMember m) => m.toPatientMember()).toList();
  }
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getPatientMembers();
});

/// Provider master poliklinik
final polyclinicsProvider = FutureProvider<List<Polyclinic>>((ref) {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getPolyclinics();
});

/// Parameter untuk query dokter berdasarkan poli dan tanggal
typedef ClinicDoctorParams = ({int clinicId, DateTime date});

/// Provider daftar dokter yang berpraktik pada poliklinik & tanggal tertentu
final doctorsByClinicAndDateProvider =
    FutureProvider.family<List<DoctorSchedule>, ClinicDoctorParams>((
      ref,
      params,
    ) {
      final repo = ref.watch(bookingRepositoryProvider);
      return repo.getDoctorsByClinicAndDate(
        clinicId: params.clinicId,
        date: params.date,
      );
    });
