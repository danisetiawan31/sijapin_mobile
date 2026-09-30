import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/app_vectors.dart';

void main() {
  group('AppVectors Asset Existence Tests', () {
    final allVectors = [
      AppVectors.emptyAppointment,
      AppVectors.doctorSearchEmpty,
      AppVectors.networkOffline,
      AppVectors.bookingSuccess,
      AppVectors.bpjsCard,
      AppVectors.outpatientRegistration,
      AppVectors.icHospitalBed,
      AppVectors.icDoctorStethoscope,
    ];

    for (final assetPath in allVectors) {
      test('Vector asset file exists: $assetPath', () {
        final file = File(assetPath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'File $assetPath should exist on filesystem',
        );
      });
    }
  });
}
