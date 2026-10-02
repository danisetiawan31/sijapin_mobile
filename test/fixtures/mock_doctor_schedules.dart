import 'package:sijapin_mobile/features/booking/domain/entities/doctor_schedule.dart';
import 'package:sijapin_mobile/features/booking/domain/entities/polyclinic.dart';

/// Test fixture jadwal dokter khusus untuk unit/widget testing.
class MockDoctorSchedulesFixture {
  const MockDoctorSchedulesFixture._();

  static List<DoctorSchedule> getSampleSchedules() {
    return const <DoctorSchedule>[
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
            startTime: '07:30',
            endTime: '12:00',
          ),
          DoctorScheduleEntry(
            day: 'Rabu',
            startTime: '07:30',
            endTime: '12:00',
          ),
        ],
      ),
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
            startTime: '08:30',
            endTime: '12:00',
          ),
          DoctorScheduleEntry(
            day: 'Jumat',
            startTime: '08:30',
            endTime: '11:30',
          ),
        ],
      ),
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
            startTime: '08:00',
            endTime: '13:00',
          ),
          DoctorScheduleEntry(
            day: 'Kamis',
            startTime: '08:00',
            endTime: '13:00',
          ),
        ],
      ),
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
            startTime: '09:00',
            endTime: '13:00',
          ),
          DoctorScheduleEntry(
            day: 'Rabu',
            startTime: '09:00',
            endTime: '13:00',
          ),
        ],
      ),
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
            startTime: '08:00',
            endTime: '11:00',
          ),
          DoctorScheduleEntry(
            day: 'Kamis',
            startTime: '08:00',
            endTime: '11:00',
          ),
        ],
      ),
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
            startTime: '08:30',
            endTime: '12:30',
          ),
          DoctorScheduleEntry(
            day: 'Jumat',
            startTime: '08:30',
            endTime: '12:30',
          ),
        ],
      ),
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
            startTime: '13:00',
            endTime: '17:00',
          ),
          DoctorScheduleEntry(
            day: 'Kamis',
            startTime: '13:00',
            endTime: '17:00',
          ),
        ],
      ),
    ];
  }

  static List<Polyclinic> getSamplePolyclinics() {
    return const <Polyclinic>[
      Polyclinic(
        id: 1,
        name: 'Penyakit Dalam',
        code: 'PDI',
        bpjsCode: 'INT',
        floor: 'Lantai 1',
      ),
      Polyclinic(
        id: 2,
        name: 'Kebidanan & Obgyn',
        code: 'OBG',
        bpjsCode: 'OBG',
        floor: 'Lantai 2',
      ),
      Polyclinic(
        id: 3,
        name: 'Anak',
        code: 'ANA',
        bpjsCode: 'ANA',
        floor: 'Lantai 1',
      ),
      Polyclinic(
        id: 29,
        name: 'Mata',
        code: 'MAT',
        bpjsCode: 'MAT',
        floor: 'Lantai 2',
      ),
    ];
  }
}
