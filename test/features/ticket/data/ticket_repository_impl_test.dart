import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:sijapin_mobile/features/ticket/data/datasources/ticket_local_data_source.dart';
import 'package:sijapin_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:sijapin_mobile/features/ticket/data/repositories/ticket_repository_impl.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';

class FakeTicketLocalDataSource implements ITicketLocalDataSource {
  final Map<String, TicketModel> _storage = {};

  @override
  Future<void> saveTicket(TicketModel model) async {
    _storage[model.bookingCode] = model;
  }

  @override
  Future<TicketModel?> getTicketByBookingCode(String bookingCode) async {
    return _storage[bookingCode];
  }

  @override
  Future<List<TicketModel>> getAllTickets() async {
    final list = _storage.values.toList();
    list.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return list;
  }

  @override
  Future<void> deleteTicket(String bookingCode) async {
    _storage.remove(bookingCode);
  }

  @override
  Future<void> clearAllTickets() async {
    _storage.clear();
  }
}

class StubBookingRemoteDataSource implements IBookingRemoteDataSource {
  String? lastDetailArgs;
  Map<String, dynamic>? detailResult;
  bool throwOnDetail = false;
  Map<String, dynamic> qrResult = const {'success': true, 'st_qrcode': '0'};
  bool throwOnQr = false;
  String? lastQrTanggal;

  @override
  Future<Map<String, dynamic>?> fetchTicketDetail({
    required String tanggal8digit,
    required String kodeVerifikasi,
    String daftarType = '2',
  }) async {
    lastDetailArgs = '$tanggal8digit/$kodeVerifikasi/$daftarType';
    if (throwOnDetail) {
      throw const BookingServerException('Transport putus.');
    }
    return detailResult;
  }

  @override
  Future<Map<String, dynamic>> cekStatusQrcode({
    required String tanggal,
    required String kodeVerifikasi,
  }) async {
    lastQrTanggal = tanggal;
    if (throwOnQr) {
      throw const BookingServerException('Transport putus.');
    }
    return qrResult;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchDoctorsByUnit(int unitId) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> fetchDoctorSchedule({
    required int unitId,
    required int doctorId,
  }) => throw UnimplementedError();

  @override
  Future<String> fetchJamPelayanan({
    required String tglKunjungan,
    required int unitId,
    required int doctorId,
  }) => throw UnimplementedError();

  @override
  Future<void> submitPatientStep(Map<String, dynamic> data) =>
      throw UnimplementedError();

  @override
  Future<void> submitVisitStep(Map<String, dynamic> data) =>
      throw UnimplementedError();

  @override
  Future<void> submitPaymentStep(String caraBayar) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>> insertDaftarRajal(Map<String, dynamic> data) =>
      throw UnimplementedError();

  @override
  Future<void> finishRegistrationSession() => throw UnimplementedError();

  @override
  Future<bool> cancelBooking({
    required String customerId,
    required String memberId,
    required String tanggal,
    String? bookingCode,
    String? reason,
  }) => throw UnimplementedError();

  @override
  Future<List<Map<String, dynamic>>> fetchBookingHistory() =>
      throw UnimplementedError();
}

void main() {
  group('TicketRepositoryImpl Tests (Domain-Data Coordination)', () {
    late FakeTicketLocalDataSource fakeDataSource;
    late TicketRepositoryImpl repository;

    final sampleTicket = Ticket(
      bookingCode: '2026101500014',
      queueNumber: 'MAT-014',
      patientName: 'Ahmad Dhani Setiawan',
      medicalRecord: '01-••-45',
      doctorName: 'dr. Hendra, Sp.M.',
      specialty: 'Spesialis Mata',
      clinic: 'Poli Mata',
      clinicLocation: 'Lantai 2 - Gedung Rawat Jalan',
      scheduledDate: DateTime(2026, 10, 15, 9, 0),
      scheduledTime: '09:00 WIB',
      estimatedMinutes: 30,
      nowServingNumber: 'MAT-011',
      remainingQueue: 3,
      status: TicketStatus.upcoming,
      guarantor: 'BPJS Kesehatan',
      isServerSynced: true,
    );

    setUp(() {
      fakeDataSource = FakeTicketLocalDataSource();
      repository = TicketRepositoryImpl(localDataSource: fakeDataSource);
    });

    test('saveTicket saves entity to local data source', () async {
      await repository.saveTicket(sampleTicket);

      final active = await repository.getActiveTicket();
      expect(active, isNotNull);
      expect(active!.bookingCode, equals('2026101500014'));
      expect(active.patientName, equals('Ahmad Dhani Setiawan'));
    });

    test('getActiveTicket ignores completed and cancelled tickets', () async {
      final completedTicket = sampleTicket.copyWith(
        bookingCode: '2026101000001',
        status: TicketStatus.completed,
      );
      final cancelledTicket = sampleTicket.copyWith(
        bookingCode: '2026101200002',
        status: TicketStatus.cancelled,
      );

      await repository.saveTicket(completedTicket);
      await repository.saveTicket(cancelledTicket);

      final active = await repository.getActiveTicket();
      expect(active, isNull);

      // Tambahkan tiket upcoming
      await repository.saveTicket(sampleTicket);
      final newActive = await repository.getActiveTicket();
      expect(newActive, isNotNull);
      expect(newActive!.bookingCode, equals(sampleTicket.bookingCode));
    });

    test('cancelTicket updates local status to cancelled with note', () async {
      await repository.saveTicket(sampleTicket);

      final result = await repository.cancelTicket(
        bookingCode: sampleTicket.bookingCode,
        reason: 'Ada urusan dinas mendadak',
      );

      expect(result, isTrue);

      final all = await repository.getAllTickets();
      expect(all.first.isCancelled, isTrue);
      expect(all.first.cancelNote, equals('Ada urusan dinas mendadak'));
    });

    test(
      'checkInTicket updates status to checkedIn and records timestamp',
      () async {
        await repository.saveTicket(sampleTicket);

        await repository.checkInTicket(sampleTicket.bookingCode);

        final all = await repository.getAllTickets();
        expect(all.first.isCheckedIn, isTrue);
        expect(all.first.checkInTime, isNotNull);
      },
    );

    test('getTicketDetail memakai segmen DDMMYYYY + kode + daftar', () async {
      final stub = StubBookingRemoteDataSource()
        ..detailResult = {'nama_klinik': 'Poli Mata'};
      final remoteRepo = TicketRepositoryImpl(
        localDataSource: fakeDataSource,
        bookingRemoteDataSource: stub,
      );
      final detail = await remoteRepo.getTicketDetail(
        scheduledDate: DateTime(2026, 10, 15),
        kodeVerifikasi: 'A1B2C3',
      );
      expect(stub.lastDetailArgs, equals('15102026/A1B2C3/2'));
      expect(detail?['nama_klinik'], equals('Poli Mata'));
    });

    test('getTicketDetail null tanpa remote (murni lokal)', () async {
      final detail = await repository.getTicketDetail(
        scheduledDate: DateTime(2026, 10, 15),
        kodeVerifikasi: 'A1B2C3',
      );
      expect(detail, isNull);
    });

    test('pollQrStatus true hanya saat st_qrcode 1', () async {
      final stub = StubBookingRemoteDataSource()
        ..qrResult = const {'success': true, 'st_qrcode': '1'};
      final remoteRepo = TicketRepositoryImpl(
        localDataSource: fakeDataSource,
        bookingRemoteDataSource: stub,
      );
      final issued = await remoteRepo.pollQrStatus(
        scheduledDate: DateTime(2026, 10, 15),
        kodeVerifikasi: 'A1B2C3',
      );
      expect(issued, isTrue);
      expect(stub.lastQrTanggal, equals('2026-10-15'));
    });

    test(
      'pollQrStatus false saat belum terbit, galat, atau tanpa remote',
      () async {
        final stub = StubBookingRemoteDataSource();
        final remoteRepo = TicketRepositoryImpl(
          localDataSource: fakeDataSource,
          bookingRemoteDataSource: stub,
        );
        expect(
          await remoteRepo.pollQrStatus(
            scheduledDate: DateTime(2026, 10, 15),
            kodeVerifikasi: 'A1B2C3',
          ),
          isFalse,
        );
        stub.throwOnQr = true;
        expect(
          await remoteRepo.pollQrStatus(
            scheduledDate: DateTime(2026, 10, 15),
            kodeVerifikasi: 'A1B2C3',
          ),
          isFalse,
        );
        expect(
          await repository.pollQrStatus(
            scheduledDate: DateTime(2026, 10, 15),
            kodeVerifikasi: 'A1B2C3',
          ),
          isFalse,
        );
      },
    );
  });
}
