import 'package:flutter_test/flutter_test.dart';
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
  });
}
