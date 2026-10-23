import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/appointment.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/booking_draft.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';
import 'package:sijapin_mobile/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/booking_repository.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/booking_wizard/steps/step1_patient_step.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:sijapin_mobile/features/profile/presentation/controllers/profile_controller.dart';

const testUser = UserProfile(
  customerId: '4',
  fullName: 'Rina Puspita Sari',
  email: 'rina.puspita@warga.go.id',
  phone: '081234567890',
);

/// Repositori booking tidak dipakai pada kasus daftar kosong selain
/// fallback pasien: cukup kembalikan hasil kosong/nilai minimal.
class EmptyBookingRepository implements BookingRepository {
  @override
  Future<List<PatientMember>> getPatientMembers() async => <PatientMember>[];

  @override
  Future<List<Polyclinic>> getPolyclinics() async => <Polyclinic>[];

  @override
  Future<List<DoctorSchedule>> getDoctorsByClinicAndDate({
    required int clinicId,
    required DateTime date,
  }) async => <DoctorSchedule>[];

  @override
  Future<Appointment> submitBooking({required BookingDraft draft}) async =>
      throw UnimplementedError();

  @override
  Future<bool> cancelBooking({
    required String bookingCode,
    required String reason,
    int? memberId,
    DateTime? scheduledDate,
  }) async => false;

  @override
  Future<List<Appointment>> getBookingHistory() async => <Appointment>[];
}

void main() {
  group('Step1PatientStep: daftar pasien kosong', () {
    testWidgets(
      'menampilkan tombol Tambahkan Diri Sendiri dan catatan jalur pegawai KEMENKES',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserProfileProvider.overrideWithValue(testUser),
              familyMemberRepositoryProvider.overrideWith(
                (ref) => FamilyMemberRepositoryImpl(remoteDataSource: null),
              ),
              bookingRepositoryProvider.overrideWith(
                (ref) => EmptyBookingRepository(),
              ),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: const Scaffold(body: Step1PatientStep()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Keadaan kosong: alasan + satu tindakan efisien langsung terlihat.
        expect(
          find.text('Belum ada data anggota keluarga terdaftar.'),
          findsOneWidget,
        );
        expect(find.text('Tambahkan Diri Sendiri'), findsOneWidget);
        expect(find.textContaining('bawa kartu kepegawaian'), findsOneWidget);
      },
    );
  });
}
