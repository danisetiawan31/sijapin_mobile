import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/mcu_remote_data_source.dart';
import '../../domain/entities/mcu_patient.dart';

/// Daftar anggota pasien untuk pendaftaran MCU (`GET /pendaftaran`).
final mcuPatientsProvider = FutureProvider<List<McuPatient>>((ref) {
  return ref.watch(mcuRemoteDataSourceProvider).fetchPatientList();
});
