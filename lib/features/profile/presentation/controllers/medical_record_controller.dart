import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/medical_record.dart';

/// Daftar riwayat rekam medis pasien aktif.
///
/// STATUS SEMENTARA: endpoint rekam medis belum tersedia, sehingga isi
/// provider ini masih data contoh. Ganti dengan pembacaan API tanpa perlu
/// menyentuh [MedicalHistoryScreen] maupun widget presentasinya.
final medicalRecordProvider = Provider<List<MedicalRecord>>((ref) {
  return <MedicalRecord>[
    MedicalRecord(
      id: 'rm-2026-09-04',
      date: DateTime(2026, 9, 4),
      type: MedicalRecordType.consultation,
      clinic: 'Poli Penyakit Dalam',
      doctorName: 'dr. Era Medina, Sp.PD',
      diagnosis: 'Hipertensi Primer Grade 1',
      summary:
          'Kontrol rutin 3 bulan. Tekanan darah 138/86 mmHg dan terapi '
          'obat antihipertensi dimulai. Diet rendah garam dan olahraga '
          'teratur sesuai anjuran dokter.',
      treatment: <String>[
        'Konsultasi dan edukasi gaya hidup rendah garam',
        'Pemeriksaan tekanan darah ulang 3 bulan',
      ],
      medication: <String>[
        'Amlodipine 10 mg (1x/hari, 30 hari)',
        'Bisoprolol 5 mg (1x/hari, 30 hari)',
      ],
      medicalRecordNumber: '0123***',
    ),
    MedicalRecord(
      id: 'rm-2026-08-12',
      date: DateTime(2026, 8, 12),
      type: MedicalRecordType.laboratory,
      clinic: 'Laboratorium Patologi Klinis',
      doctorName: 'dr. Anita Puspita, Sp.PK',
      diagnosis: 'Panel Darah Lengkap',
      summary:
          'Seluruh parameter berada dalam batas normal. Gula darah '
          'sewaktu 92 mg/dL dan LDL 118 mg/dL.',
      medicalRecordNumber: '0123***',
    ),
    MedicalRecord(
      id: 'rm-2026-07-02',
      date: DateTime(2026, 7, 2),
      type: MedicalRecordType.prescription,
      clinic: 'Poli THT-KL',
      doctorName: 'dr. Reza Mahendra, Sp.THT',
      diagnosis: 'Rinitis Alergi',
      summary:
          'Hidung tersumbat akibat alergi. Disarankan menghindari debu '
          'serta allergen, dan menjaga kelembapan udara.',
      medication: <String>[
        'Cetirizine 10 mg (1x/hari, 10 hari)',
        'Saline nasal spray (2x/hari, 14 hari)',
      ],
      medicalRecordNumber: '0123***',
    ),
    MedicalRecord(
      id: 'rm-2025-11-20',
      date: DateTime(2025, 11, 20),
      type: MedicalRecordType.consultation,
      clinic: 'Poli Mata',
      doctorName: 'dr. Hendra Prasetyo, Sp.M.',
      diagnosis: 'Miopia Ringan',
      summary:
          'Miopia ringan pada kedua mata. Kacamata minus tetap diberikan '
          'dan pemeriksaan ulang tiap 12 bulan.',
      medicalRecordNumber: '0123***',
    ),
  ];
});
