/// Jenis catatan riwayat medis yang ditampilkan di tab Profil.
///
/// Sesuai DESIGN.md §2.C, seluruh catatan memakai aksen `clinical-teal`
/// sebagai penanda klinis agar berbeda dari kartu janji temu di tab lain.
enum MedicalRecordType { consultation, laboratory, prescription, inpatient }

/// Satu catatan rekam medis pasien: kunjungan poli, hasil laboratorium,
/// resep obat, atau riwayat rawat inap.
///
/// Data ini bersifat ringkas dan siap diganti pembacaan API karena hanya
/// dipakai untuk menampilkan bentuk tampilan sementara.
class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.clinic,
    required this.doctorName,
    required this.diagnosis,
    required this.summary,
    this.treatment = const <String>[],
    this.medication = const <String>[],
    this.medicalRecordNumber,
  });

  /// Pengenal catatan agar unik pada daftar.
  final String id;

  /// Tanggal pemeriksaan atau kunjungan.
  final DateTime date;
  final MedicalRecordType type;

  /// Poli, unit, atau layanan tempat catatan dibuat.
  final String clinic;

  /// Dokter pemeriksa atau penanggung jawab klinis.
  final String doctorName;

  /// Diagnosis atau nama pemeriksaan.
  final String diagnosis;

  /// Ringkasan hasil pemeriksaan dalam kalimat pendek.
  final String summary;

  /// Prosedur atau tindakan yang dilakukan.
  final List<String> treatment;

  /// Daftar obat yang dikeluarkan pada catatan resep.
  final List<String> medication;

  /// Nomor rekam medis tersamar, contoh: `0123***`.
  final String? medicalRecordNumber;

  bool get hasMedication => medication.isNotEmpty;
  bool get hasTreatment => treatment.isNotEmpty;
}
