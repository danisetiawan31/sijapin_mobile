import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/patient_member.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';
import 'package:sijapin_mobile/features/booking/presentation/controllers/booking_wizard_controller.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/booking_wizard/booking_wizard_screen.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/booking_wizard/steps/step1_patient_step.dart';
import 'package:sijapin_mobile/features/booking/presentation/screens/booking_wizard/widgets/wizard_progress_bar.dart';

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: BookingWizardScreen()),
  );
}

void main() {
  group('BookingWizardScreen Widget Tests', () {
    final samplePatients = [
      PatientMember(
        id: 1,
        fullName: 'Ahmad Dhani Setiawan',
        nik: '3671041205950001',
        medicalRecordNumber: '012345',
        relation: 'Diri Sendiri',
        gender: 'L',
        birthDate: DateTime(1995, 5, 12),
        bpjsCardNumber: '0001234567891',
      ),
      PatientMember(
        id: 2,
        fullName: 'Rina Puspita Sari',
        nik: '3671044508940002',
        medicalRecordNumber: '045678',
        relation: 'Istri',
        gender: 'P',
        birthDate: DateTime(1994, 8, 25),
        bpjsCardNumber: '0001234567892',
      ),
    ];

    const sampleClinics = [
      Polyclinic(
        id: 1,
        name: 'Poli Penyakit Dalam',
        code: 'PDI',
        floor: 'Lantai 1',
      ),
    ];

    testWidgets(
      'renders AppBar title, progress bar, and Step 1 initial content',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final container = ProviderContainer(
          overrides: [
            patientMembersProvider.overrideWith(
              (ref) => Future.value(samplePatients),
            ),
            polyclinicsProvider.overrideWith(
              (ref) => Future.value(sampleClinics),
            ),
          ],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildApp(container));

        await tester.pumpAndSettle();

        // Verifikasi Header AppBar
        expect(find.text('Pendaftaran Rawat Jalan'), findsOneWidget);
        expect(find.text('Langkah 1 dari 4'), findsOneWidget);

        // Verifikasi WizardProgressBar
        expect(find.byType(WizardProgressBar), findsOneWidget);
        expect(find.text('Pasien'), findsOneWidget);
        expect(find.text('Poli & Tgl'), findsOneWidget);
        expect(find.text('Dokter'), findsOneWidget);
        expect(find.text('Konfirmasi'), findsOneWidget);

        // Verifikasi Step 1 Patient Step
        expect(find.byType(Step1PatientStep), findsOneWidget);
        expect(find.text('Pilih Pasien yang Berobat'), findsOneWidget);
        expect(find.text('Ahmad Dhani Setiawan'), findsOneWidget);
        expect(find.text('Rina Puspita Sari'), findsOneWidget);

        // Verifikasi Pilihan Penjamin
        expect(find.text('BPJS Kesehatan'), findsOneWidget);
        expect(find.text('Pasien Umum / Mandiri'), findsOneWidget);

        // Verifikasi Tombol Lanjutkan
        expect(find.text('Lanjutkan ➔'), findsOneWidget);
      },
    );

    testWidgets('can toggle between BPJS and Pasien Umum on Step 1', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          patientMembersProvider.overrideWith(
            (ref) => Future.value(samplePatients),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(_buildApp(container));

      await tester.pumpAndSettle();

      // Secara default BPJS terpilih dan field rujukan muncul
      expect(
        find.text('Nomor Rujukan FKTP / Surat Kontrol (SPRI) *'),
        findsOneWidget,
      );

      // Klik opsi Pasien Umum / Mandiri
      await tester.tap(find.text('Pasien Umum / Mandiri'));
      await tester.pumpAndSettle();

      // Field nomor rujukan tidak lagi tampil karena memilih jalur umum
      expect(
        find.text('Nomor Rujukan FKTP / Surat Kontrol (SPRI) *'),
        findsNothing,
      );
    });
  });
}
