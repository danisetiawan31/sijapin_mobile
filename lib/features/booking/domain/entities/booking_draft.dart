import 'doctor_schedule.dart';
import 'patient_member.dart';
import 'polyclinic.dart';

/// Jenis penjaminan / pembiayaan pendaftaran pasien rawat jalan.
enum InsuranceType {
  bpjs('BPJS Kesehatan', 'Memerlukan Nomor Rujukan / Surat Kontrol'),
  umum('Pasien Umum / Mandiri', 'Pembayaran mandiri di kasir rumah sakit');

  const InsuranceType(this.label, this.description);
  final String label;
  final String description;

  bool get isBpjs => this == InsuranceType.bpjs;
  bool get isUmum => this == InsuranceType.umum;
}

/// Model draft data wizard pendaftaran rawat jalan (Epic 05).
///
/// Menyimpan state akumulatif dari Step 1 hingga Step 4 sebelum dikirim
/// ke controller CodeIgniter 3 `Daftar_Kunj_Raja/insert_daftar_rajal`.
class BookingDraft {
  const BookingDraft({
    this.currentStep = 0,
    this.patient,
    this.insuranceType = InsuranceType.bpjs,
    this.bpjsReferenceNumber,
    this.clinic,
    this.bookingDate,
    this.doctor,
    this.isAgreedToTerms = false,
  });

  /// Indeks langkah saat ini (0 = Pasien, 1 = Poli & Tanggal, 2 = Dokter, 3 = Konfirmasi)
  final int currentStep;

  /// Pasien / anggota keluarga yang berobat (Step 1)
  final PatientMember? patient;

  /// Jalur penjaminan (Step 1)
  final InsuranceType insuranceType;

  /// Nomor Rujukan FKTP atau Surat Kontrol (SPRI) jika BPJS (Step 1)
  final String? bpjsReferenceNumber;

  /// Poliklinik tujuan (Step 2)
  final Polyclinic? clinic;

  /// Tanggal rencana berobat (Step 2)
  final DateTime? bookingDate;

  /// Dokter DPJP yang dipilih (Step 3)
  final DoctorSchedule? doctor;

  /// Apakah pasien telah menyetujui tata tertib & syarat ketentuan (Step 4)
  final bool isAgreedToTerms;

  /// Validasi Langkah 1 (Pasien & Penjamin)
  bool get isStep1Valid {
    if (patient == null) return false;
    if (insuranceType == InsuranceType.bpjs) {
      return bpjsReferenceNumber != null &&
          bpjsReferenceNumber!.trim().isNotEmpty;
    }
    return true;
  }

  /// Validasi Langkah 2 (Poliklinik & Tanggal)
  bool get isStep2Valid {
    if (clinic == null || bookingDate == null) return false;
    // Hanya hari Senin s/d Jumat yang sah
    final weekday = bookingDate!.weekday;
    return weekday != DateTime.saturday && weekday != DateTime.sunday;
  }

  /// Validasi Langkah 3 (Dokter DPJP)
  bool get isStep3Valid {
    if (doctor == null) return false;
    return doctor!.status == DoctorPracticeStatus.reguler;
  }

  /// Validasi Langkah 4 (Konfirmasi & Kesepakatan)
  bool get isStep4Valid {
    return isStep1Valid && isStep2Valid && isStep3Valid && isAgreedToTerms;
  }

  /// Mengecek apakah langkah saat ini valid dan boleh lanjut ke langkah berikutnya
  bool get canProceedCurrentStep {
    switch (currentStep) {
      case 0:
        return isStep1Valid;
      case 1:
        return isStep2Valid;
      case 2:
        return isStep3Valid;
      case 3:
        return isStep4Valid;
      default:
        return false;
    }
  }

  BookingDraft copyWith({
    int? currentStep,
    PatientMember? patient,
    InsuranceType? insuranceType,
    String? bpjsReferenceNumber,
    Polyclinic? clinic,
    DateTime? bookingDate,
    DoctorSchedule? doctor,
    bool? isAgreedToTerms,
    bool clearBpjsReference = false,
    bool clearDoctor = false,
  }) {
    return BookingDraft(
      currentStep: currentStep ?? this.currentStep,
      patient: patient ?? this.patient,
      insuranceType: insuranceType ?? this.insuranceType,
      bpjsReferenceNumber: clearBpjsReference
          ? null
          : (bpjsReferenceNumber ?? this.bpjsReferenceNumber),
      clinic: clinic ?? this.clinic,
      bookingDate: bookingDate ?? this.bookingDate,
      doctor: clearDoctor ? null : (doctor ?? this.doctor),
      isAgreedToTerms: isAgreedToTerms ?? this.isAgreedToTerms,
    );
  }
}
