import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';
import 'package:sijapin_mobile/core/theme/app_theme.dart';
import 'package:sijapin_mobile/core/widgets/state_widgets.dart';
import 'package:sijapin_mobile/features/support/domain/entities/mcu_patient.dart';
import 'package:sijapin_mobile/features/support/presentation/controllers/mcu_patient_controller.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/mcu_catalog_screen.dart';
import 'package:sijapin_mobile/features/support/presentation/screens/mcu_patient_step_screen.dart';

const _bambang = McuPatient(
  idMember: '1',
  nama: 'Bambang Sutrisno',
  nomr: '00123456',
  nik: '3671010101900001',
);

const _siti = McuPatient(
  idMember: '2',
  nama: 'Siti Aminah',
  nik: '3671044508940002',
);

Widget _wrap(McuPatientStepScreen screen, List<McuPatient> patients) {
  return ProviderScope(
    overrides: [
      mcuPatientsProvider.overrideWith((ref) => Future.value(patients)),
    ],
    child: MaterialApp(theme: AppTheme.lightTheme, home: screen),
  );
}

void main() {
  group('McuPatientStepScreen Widget Tests', () {
    testWidgets(
      'memuat pasien dari GET /pendaftaran dan menampilkan langkah 1 MCU',
      (tester) async {
        tester.view.physicalSize = const Size(800, 2000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(const McuPatientStepScreen(), const [_bambang, _siti]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pilih Pasien Berobat'), findsOneWidget);
        expect(find.textContaining('LANGKAH 1 DARI 3'), findsOneWidget);
        expect(find.textContaining('MCU'), findsWidgets);
        expect(find.text('+ Tambah Pasien / Keluarga'), findsOneWidget);
        expect(find.textContaining('Kementerian Kesehatan RI'), findsOneWidget);

        expect(find.text('Bambang Sutrisno'), findsWidgets);
        expect(find.text('Siti Aminah'), findsOneWidget);
        expect(find.text('No. RM:'), findsNWidgets(2));
        expect(find.text('NIK:'), findsNWidgets(2));
        expect(find.text('001234**'), findsOneWidget);
        expect(find.text('367101******0001'), findsOneWidget);
        expect(find.text('Belum ada No. RM'), findsOneWidget);
        expect(find.text('367104******0002'), findsOneWidget);

        expect(find.text('PASIEN LAMA'), findsNWidgets(2));
        expect(find.text('PASIEN BARU'), findsOneWidget);

        expect(find.text('Lanjut: Pilih Paket & Jadwal'), findsOneWidget);
      },
    );

    testWidgets('memilih pasien lain memperbarui ringkasan bawah dan CTA', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(const McuPatientStepScreen(), const [_bambang, _siti]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bambang Sutrisno'), findsNWidgets(2));

      await tester.tap(find.text('Siti Aminah'));
      await tester.pumpAndSettle();

      expect(find.text('Siti Aminah'), findsNWidgets(2));
      expect(find.text('Bambang Sutrisno'), findsOneWidget);

      await tester.tap(find.text('Lanjut: Pilih Paket & Jadwal'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Pasien Siti Aminah dipilih. Lanjut ke pilih paket & jadwal MCU.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('membawa paket terpilih ke label CTA dan subjudul', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const McuPackageItem paket = McuPackageItem(
        kodeTarif: '120050',
        mcuId: 29947,
        name: 'Paket MCU Standar',
        price: 180000,
        formattedPrice: 'Rp 180.000',
        badgeLabel: 'Populer',
        description: 'Pemeriksaan dasar.',
        examinationItems: <McuTindakanItem>[],
      );

      await tester.pumpWidget(
        _wrap(const McuPatientStepScreen(selectedPackage: paket), const [
          _bambang,
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Paket MCU Standar'), findsWidgets);
      expect(find.text('Lanjut: Pilih Jadwal MCU'), findsOneWidget);
    });

    testWidgets('menampilkan galat verbatim saat envelope success:false', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mcuPatientsProvider.overrideWith(
              (ref) => Future<List<McuPatient>>.error(
                const ApiException(
                  'Pasien tidak ditemukan atau bukan milik akun Anda',
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const McuPatientStepScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsOneWidget);
      expect(
        find.text('Pasien tidak ditemukan atau bukan milik akun Anda'),
        findsOneWidget,
      );
      expect(find.text('Coba Lagi'), findsOneWidget);
    });
  });
}
