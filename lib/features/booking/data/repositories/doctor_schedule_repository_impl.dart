import 'dart:async';

import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/repositories/doctor_schedule_repository.dart';

/// Implementasi repository jadwal dokter dengan data tiruan (mock data)
/// yang disesuaikan dengan database SIMRS RSUP Dr. Sitanala Tangerang.
class DoctorScheduleRepositoryImpl implements DoctorScheduleRepository {
  const DoctorScheduleRepositoryImpl();

  @override
  Future<List<DoctorSchedule>> getDoctorSchedules({
    String? specialtyFilter,
    String? searchQuery,
    String? dayFilter,
  }) async {
    // Simulasi delay jaringan
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final allSchedules = _getSampleSchedules();

    // Filter berdasarkan poli (poliklinik) & spesialisasi
    var filtered = allSchedules;
    if (specialtyFilter != null && specialtyFilter != 'Semua Poli') {
      final filterLower = specialtyFilter.toLowerCase().trim();
      filtered = filtered.where((d) {
        if (d.poli.isNotEmpty && d.poli.toLowerCase() == filterLower) {
          return true;
        }
        final specLower = d.specialization.toLowerCase();
        if (filterLower.contains('obgyn') ||
            filterLower.contains('kebidanan')) {
          return specLower.contains('obstetri') ||
              specLower.contains('ginekologi') ||
              specLower.contains('obgyn') ||
              specLower.contains('kebidanan');
        }
        return specLower.contains(filterLower);
      }).toList();
    }

    // Filter berdasarkan hari operasional (Senin – Jumat)
    if (dayFilter != null && dayFilter != 'Semua Hari') {
      final dayLower = dayFilter.toLowerCase().trim();
      filtered = filtered.where((d) {
        return d.schedules.any(
          (entry) => entry.day.toLowerCase().trim() == dayLower,
        );
      }).toList();
    }

    // Filter berdasarkan pencarian
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase().trim();
      filtered = filtered.where((d) {
        return d.name.toLowerCase().contains(query) ||
            d.specialization.toLowerCase().contains(query) ||
            d.poli.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Future<DoctorSchedule?> getDoctorScheduleById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final allSchedules = _getSampleSchedules();
    try {
      return allSchedules.firstWhere((d) => d.id == id);
    } on StateError {
      return null;
    }
  }

  /// Data sampel jadwal dokter — sesuai referensi visual & database SIMRS Sitanala.
  List<DoctorSchedule> _getSampleSchedules() {
    return const <DoctorSchedule>[
      // Dokter 1: dr. Era Medina, Sp.PD — Penyakit Dalam (Wanita)
      DoctorSchedule(
        id: 'doc_001',
        name: 'dr. Era Medina, Sp.PD',
        specialization: 'Spesialis Penyakit Dalam',
        poli: 'Penyakit Dalam',
        gender: 'P',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Selasa',
            startTime: '07.30',
            endTime: '12.00',
          ),
          DoctorScheduleEntry(
            day: 'Rabu',
            startTime: '07.30',
            endTime: '12.00',
          ),
        ],
      ),

      // Dokter 2: dr. Hendra, Sp.M — Mata (Pria)
      DoctorSchedule(
        id: 'doc_002',
        name: 'dr. Hendra, Sp.M',
        specialization: 'Spesialis Mata',
        poli: 'Mata',
        gender: 'L',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Kamis',
            startTime: '08.30',
            endTime: '12.00',
          ),
          DoctorScheduleEntry(
            day: 'Jumat',
            startTime: '08.30',
            endTime: '11.30',
          ),
        ],
      ),

      // Dokter 3: dr. Damas Hendriansyah, Sp.OG — Kebidanan & Obgyn (Pria)
      DoctorSchedule(
        id: 'doc_003',
        name: 'dr. Damas Hendriansyah, Sp.OG',
        specialization: 'Spesialis Obstetri & Ginekologi',
        poli: 'Kebidanan & Obgyn',
        gender: 'L',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Senin',
            startTime: '08.00',
            endTime: '13.00',
          ),
          DoctorScheduleEntry(
            day: 'Kamis',
            startTime: '08.00',
            endTime: '13.00',
          ),
        ],
      ),

      // Dokter 4: dr. Rian Pramudita, Sp.THT — THT-KL (Pria)
      DoctorSchedule(
        id: 'doc_004',
        name: 'dr. Rian Pramudita, Sp.THT',
        specialization: 'Spesialis THT-KL',
        poli: 'THT-KL',
        gender: 'L',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Senin',
            startTime: '09.00',
            endTime: '13.00',
          ),
          DoctorScheduleEntry(
            day: 'Rabu',
            startTime: '09.00',
            endTime: '13.00',
          ),
        ],
      ),

      // Dokter 5: dr. Anita Kusuma, Sp.M — Mata (Wanita)
      DoctorSchedule(
        id: 'doc_005',
        name: 'dr. Anita Kusuma, Sp.M',
        specialization: 'Spesialis Mata',
        poli: 'Mata',
        gender: 'P',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Selasa',
            startTime: '08.00',
            endTime: '11.00',
          ),
          DoctorScheduleEntry(
            day: 'Kamis',
            startTime: '08.00',
            endTime: '11.00',
          ),
        ],
      ),

      // Dokter 6: dr. Budi Santoso, Sp.A — Anak (Pria)
      DoctorSchedule(
        id: 'doc_006',
        name: 'dr. Budi Santoso, Sp.A',
        specialization: 'Spesialis Anak',
        poli: 'Anak',
        gender: 'L',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Rabu',
            startTime: '08.30',
            endTime: '12.30',
          ),
          DoctorScheduleEntry(
            day: 'Jumat',
            startTime: '08.30',
            endTime: '12.30',
          ),
        ],
      ),

      // Dokter 7: dr. Citra Dewi, Sp.PD — Penyakit Dalam (Wanita)
      DoctorSchedule(
        id: 'doc_007',
        name: 'dr. Citra Dewi, Sp.PD',
        specialization: 'Spesialis Penyakit Dalam',
        poli: 'Penyakit Dalam',
        gender: 'P',
        photoUrl: null,
        status: DoctorPracticeStatus.libur,
        schedules: <DoctorScheduleEntry>[],
      ),

      // Dokter 8: dr. Eko Wibowo, Sp.OG — Kebidanan & Obgyn (Pria)
      DoctorSchedule(
        id: 'doc_008',
        name: 'dr. Eko Wibowo, Sp.OG',
        specialization: 'Spesialis Obstetri & Ginekologi',
        poli: 'Kebidanan & Obgyn',
        gender: 'L',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Selasa',
            startTime: '13.00',
            endTime: '17.00',
          ),
          DoctorScheduleEntry(
            day: 'Kamis',
            startTime: '13.00',
            endTime: '17.00',
          ),
        ],
      ),

      // Dokter 9: dr. Fitriani, Sp.M — Mata (Wanita)
      DoctorSchedule(
        id: 'doc_009',
        name: 'dr. Fitriani, Sp.M',
        specialization: 'Spesialis Mata',
        poli: 'Mata',
        gender: 'P',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Senin',
            startTime: '07.30',
            endTime: '11.30',
          ),
          DoctorScheduleEntry(
            day: 'Rabu',
            startTime: '07.30',
            endTime: '11.30',
          ),
        ],
      ),

      // Dokter 10: dr. Gunawan, Sp.A — Anak (Pria)
      DoctorSchedule(
        id: 'doc_010',
        name: 'dr. Gunawan, Sp.A',
        specialization: 'Spesialis Anak',
        poli: 'Anak',
        gender: 'L',
        photoUrl: null,
        status: DoctorPracticeStatus.reguler,
        schedules: <DoctorScheduleEntry>[
          DoctorScheduleEntry(
            day: 'Selasa',
            startTime: '13.00',
            endTime: '16.00',
          ),
          DoctorScheduleEntry(
            day: 'Jumat',
            startTime: '13.00',
            endTime: '16.00',
          ),
        ],
      ),
    ];
  }
}
