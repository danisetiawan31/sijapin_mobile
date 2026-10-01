import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/storage/local_storage_service.dart';
import 'package:sijapin_mobile/features/ticket/data/datasources/ticket_local_data_source.dart';
import 'package:sijapin_mobile/features/ticket/data/models/ticket_model.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';

class FakeLocalStorage implements ILocalStorage {
  final Map<String, Map<String, dynamic>> _boxes = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {
    _boxes.putIfAbsent(boxName, () => {})[key] = value;
  }

  @override
  T? get<T>({required String boxName, required String key, T? defaultValue}) {
    final box = _boxes[boxName];
    if (box == null || !box.containsKey(key)) return defaultValue;
    return box[key] as T?;
  }

  @override
  Future<void> delete({required String boxName, required String key}) async {
    _boxes[boxName]?.remove(key);
  }

  @override
  Future<void> clearBox({required String boxName}) async {
    _boxes[boxName]?.clear();
  }

  @override
  bool containsKey({required String boxName, required String key}) {
    return _boxes[boxName]?.containsKey(key) ?? false;
  }

  @override
  List<T> getAll<T>({required String boxName}) {
    final box = _boxes[boxName];
    if (box == null) return <T>[];
    return box.values.cast<T>().toList();
  }
}

void main() {
  group('TicketLocalDataSourceImpl Tests (Hive NoSQL tickets_box)', () {
    late FakeLocalStorage fakeStorage;
    late TicketLocalDataSourceImpl dataSource;

    final sampleModel = TicketModel(
      bookingCode: '2026101500014',
      queueNumber: 'MAT-014',
      patientName: 'Ahmad Dhani Setiawan',
      doctorName: 'dr. Hendra, Sp.M.',
      specialty: 'Spesialis Mata',
      clinic: 'Poli Mata',
      clinicLocation: 'Lantai 2 - Gedung Rawat Jalan',
      scheduledDate: DateTime(2026, 10, 15, 9, 0),
      scheduledTime: '09:00 WIB',
      estimatedMinutes: 30,
      nowServingNumber: 'MAT-011',
      remainingQueue: 3,
      status: TicketStatus.upcoming.name,
      guarantor: 'BPJS Kesehatan',
      isServerSynced: true,
    );

    setUp(() {
      fakeStorage = FakeLocalStorage();
      dataSource = TicketLocalDataSourceImpl(fakeStorage);
    });

    test('saveTicket stores ticket model in StorageConstants.ticketsBox', () async {
      await dataSource.saveTicket(sampleModel);

      final retrieved = await dataSource.getTicketByBookingCode('2026101500014');
      expect(retrieved, isNotNull);
      expect(retrieved!.bookingCode, equals('2026101500014'));
      expect(retrieved.queueNumber, equals('MAT-014'));
      expect(retrieved.status, equals(TicketStatus.upcoming.name));
    });

    test('getAllTickets returns tickets sorted descending by scheduledDate', () async {
      final olderTicket = TicketModel(
        bookingCode: '2026101000001',
        queueNumber: 'PDI-001',
        patientName: 'Siti Rahmah',
        doctorName: 'dr. Era Medina, Sp.PD.',
        specialty: 'Penyakit Dalam',
        clinic: 'Poli Penyakit Dalam',
        clinicLocation: 'Lantai 1 - Gedung A',
        scheduledDate: DateTime(2026, 10, 10, 8, 0),
        scheduledTime: '08:00 WIB',
        estimatedMinutes: 0,
        nowServingNumber: 'PDI-001',
        remainingQueue: 0,
        status: TicketStatus.completed.name,
        guarantor: 'BPJS Kesehatan',
      );

      await dataSource.saveTicket(sampleModel);
      await dataSource.saveTicket(olderTicket);

      final allTickets = await dataSource.getAllTickets();
      expect(allTickets.length, equals(2));
      // Tiket tanggal 15 Oktober harus berada di urutan pertama dibanding 10 Oktober
      expect(allTickets.first.bookingCode, equals('2026101500014'));
      expect(allTickets.last.bookingCode, equals('2026101000001'));
    });

    test('deleteTicket removes specific ticket by bookingCode', () async {
      await dataSource.saveTicket(sampleModel);
      expect(await dataSource.getTicketByBookingCode('2026101500014'), isNotNull);

      await dataSource.deleteTicket('2026101500014');
      expect(await dataSource.getTicketByBookingCode('2026101500014'), isNull);
    });

    test('clearAllTickets removes all stored tickets in box', () async {
      await dataSource.saveTicket(sampleModel);
      await dataSource.clearAllTickets();

      final list = await dataSource.getAllTickets();
      expect(list, isEmpty);
    });
  });
}
