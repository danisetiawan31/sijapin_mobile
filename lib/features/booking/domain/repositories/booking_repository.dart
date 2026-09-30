import '../entities/appointment.dart';
import '../entities/booking_draft.dart';
import '../entities/doctor_schedule.dart';
import '../entities/patient_member.dart';
import '../entities/polyclinic.dart';

/// Kontrak repositori pendaftaran rawat jalan dan janji temu RSUP Dr. Sitanala.
abstract interface class BookingRepository {
  /// Mengambil daftar anggota keluarga / pasien yang terdaftar di akun.
  Future<List<PatientMember>> getPatientMembers();

  /// Mengambil daftar master poliklinik rawat jalan.
  Future<List<Polyclinic>> getPolyclinics();

  /// Mengambil daftar dokter yang berpraktik pada poliklinik dan tanggal tertentu.
  Future<List<DoctorSchedule>> getDoctorsByClinicAndDate({
    required int clinicId,
    required DateTime date,
  });

  /// Mengirimkan formulir pendaftaran rawat jalan ke server CI3
  /// (`insert_daftar_rajal`) dan menerbitkan tiket janji temu.
  Future<Appointment> submitBooking({required BookingDraft draft});

  /// Membatalkan janji temu (maksimal H-1 pukul 23:59 WIB).
  Future<bool> cancelBooking({
    required String bookingCode,
    required String reason,
  });
}
