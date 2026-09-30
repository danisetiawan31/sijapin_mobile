import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/presentation/widgets/doctor_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleDoctor = DoctorSchedule(
    id: 'doc-001',
    name: 'dr. Era Medina, Sp.PD',
    specialization: 'Spesialis Penyakit Dalam',
    gender: 'P',
    status: DoctorPracticeStatus.reguler,
    schedules: [
      DoctorScheduleEntry(day: 'Senin', startTime: '08:00', endTime: '12:00'),
      DoctorScheduleEntry(day: 'Rabu', startTime: '13:00', endTime: '16:00'),
    ],
  );

  const sampleDoctorLibur = DoctorSchedule(
    id: 'doc-002',
    name: 'dr. Hendra, Sp.M',
    specialization: 'Spesialis Mata',
    gender: 'L',
    status: DoctorPracticeStatus.libur,
    schedules: [
      DoctorScheduleEntry(day: 'Kamis', startTime: '09:00', endTime: '12:00'),
    ],
  );

  Widget buildTestableDoctorCard({
    required DoctorSchedule schedule,
    VoidCallback? onActionPressed,
    String? actionLabel,
    IconData? actionIcon,
    String? activeDay,
    bool isSelected = false,
    VoidCallback? onTapCard,
  }) {
    return ProviderScope(
      child: MaterialApp(
        themeMode: ThemeMode.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: DoctorCard(
              schedule: schedule,
              onActionPressed: onActionPressed,
              actionLabel: actionLabel,
              actionIcon: actionIcon ?? Icons.arrow_forward_rounded,
              activeDay: activeDay,
              isSelected: isSelected,
              onTapCard: onTapCard,
            ),
          ),
        ),
      ),
    );
  }

  group('DoctorCard Widget Tests', () {
    testWidgets(
      'renders doctor name, specialization, badge, avatar, and schedules',
      (tester) async {
        await tester.pumpWidget(
          buildTestableDoctorCard(schedule: sampleDoctor),
        );

        // Verifikasi nama dan spesialisasi
        expect(find.text('dr. Era Medina, Sp.PD'), findsOneWidget);
        expect(find.text('Spesialis Penyakit Dalam'), findsOneWidget);

        // Verifikasi specialty badge
        expect(find.text('Penyakit Dalam'), findsOneWidget);

        // Verifikasi avatar inisial EM dan gender P (Female icon)
        expect(find.text('EM'), findsOneWidget);
        expect(find.byIcon(Icons.female_rounded), findsOneWidget);

        // Verifikasi jadwal
        expect(find.text('Senin'), findsOneWidget);
        expect(find.text('Rabu'), findsOneWidget);
        expect(find.text('08:00 – 12:00 WIB'), findsOneWidget);
        expect(find.text('13:00 – 16:00 WIB'), findsOneWidget);

        // Verifikasi status reguler & tombol pendaftaran
        expect(find.text('Praktik Reguler'), findsOneWidget);
        expect(find.text('Daftar Janji Temu'), findsOneWidget);
      },
    );

    testWidgets('highlights schedule entry when activeDay matches', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestableDoctorCard(schedule: sampleDoctor, activeDay: 'Senin'),
      );

      // Ikon penanda hari aktif muncul
      expect(find.byIcon(Icons.event_available_rounded), findsOneWidget);
    });

    testWidgets(
      'handles DoctorPracticeStatus.libur with warning badge and disabled button',
      (tester) async {
        bool actionTriggered = false;

        await tester.pumpWidget(
          buildTestableDoctorCard(
            schedule: sampleDoctorLibur,
            onActionPressed: () => actionTriggered = true,
          ),
        );

        // Verifikasi badge Libur / Cuti
        expect(find.text('Libur / Cuti'), findsOneWidget);

        // Verifikasi tombol berlabel Dokter Cuti dan tidak bisa ditekan
        expect(find.text('Dokter Cuti'), findsOneWidget);
        await tester.tap(find.text('Dokter Cuti'));
        await tester.pumpAndSettle();

        expect(actionTriggered, isFalse);
      },
    );

    testWidgets('triggers onActionPressed when regular doctor CTA is tapped', (
      tester,
    ) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        buildTestableDoctorCard(
          schedule: sampleDoctor,
          onActionPressed: () => actionTriggered = true,
        ),
      );

      await tester.tap(find.text('Daftar Janji Temu'));
      await tester.pumpAndSettle();

      expect(actionTriggered, isTrue);
    });

    testWidgets(
      'supports custom actionLabel and selection highlight for DPJP selection',
      (tester) async {
        await tester.pumpWidget(
          buildTestableDoctorCard(
            schedule: sampleDoctor,
            actionLabel: 'Pilih Dokter DPJP',
            isSelected: true,
          ),
        );

        expect(find.text('Pilih Dokter DPJP'), findsOneWidget);
      },
    );

    testWidgets('triggers onTapCard when entire card is tapped', (
      tester,
    ) async {
      bool cardTapped = false;

      await tester.pumpWidget(
        buildTestableDoctorCard(
          schedule: sampleDoctor,
          onTapCard: () => cardTapped = true,
        ),
      );

      await tester.tap(find.text('dr. Era Medina, Sp.PD'));
      await tester.pumpAndSettle();

      expect(cardTapped, isTrue);
    });
  });
}
