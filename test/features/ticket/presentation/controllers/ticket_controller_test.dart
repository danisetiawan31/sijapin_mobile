import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/ticket/data/repositories/ticket_repository_impl.dart';
import 'package:sijapin_mobile/features/ticket/domain/entities/ticket.dart';
import 'package:sijapin_mobile/features/ticket/domain/repositories/ticket_repository.dart';
import 'package:sijapin_mobile/core/network/server_status_controller.dart';
import 'package:sijapin_mobile/features/ticket/presentation/controllers/ticket_controller.dart';

import '../../../../fixtures/mock_ticket.dart';

class FakeTicketRepository implements TicketRepository {
  Ticket? activeTicket;
  final List<Ticket> allTickets = [];
  bool cancelSuccess = true;
  int syncCallCount = 0;
  Map<String, dynamic>? ticketDetail;
  bool qrIssued = false;

  @override
  Future<void> saveTicket(Ticket ticket) async {
    activeTicket = ticket;
    allTickets.add(ticket);
  }

  @override
  Future<Ticket?> getActiveTicket() async {
    return activeTicket;
  }

  @override
  Future<List<Ticket>> getAllTickets() async {
    return allTickets;
  }

  @override
  Future<bool> cancelTicket({
    required String bookingCode,
    required String reason,
    int? memberId,
    DateTime? scheduledDate,
  }) async {
    if (activeTicket != null && activeTicket!.bookingCode == bookingCode) {
      activeTicket = activeTicket!.copyWith(
        status: TicketStatus.cancelled,
        cancelNote: reason,
      );
    }
    return cancelSuccess;
  }

  @override
  Future<void> checkInTicket(String bookingCode) async {
    if (activeTicket != null && activeTicket!.bookingCode == bookingCode) {
      activeTicket = activeTicket!.copyWith(
        status: TicketStatus.checkedIn,
        checkInTime: AppDateTime.now(),
      );
    }
  }

  @override
  Future<int> syncPendingOfflineActions() async {
    syncCallCount++;
    return 0;
  }

  @override
  Future<Map<String, dynamic>?> getTicketDetail({
    required DateTime scheduledDate,
    required String kodeVerifikasi,
    String daftarType = '2',
  }) async {
    return ticketDetail;
  }

  @override
  Future<bool> pollQrStatus({
    required DateTime scheduledDate,
    required String kodeVerifikasi,
  }) async {
    return qrIssued;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TicketController Tests (Offline Engine & State Management)', () {
    late FakeTicketRepository fakeRepo;
    late ProviderContainer container;

    setUp(() {
      fakeRepo = FakeTicketRepository();
      container = ProviderContainer(
        overrides: [
          ticketRepositoryProvider.overrideWithValue(fakeRepo),
          connectivityStreamProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.wifi]),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'initial state has null ticket and is not loading when storage is empty',
      () {
        final state = container.read(ticketControllerProvider);
        expect(state.ticket, isNull);
        expect(state.isLoading, isFalse);
      },
    );

    test(
      'saveNewTicket updates controller state and saves to repository',
      () async {
        final controller = container.read(ticketControllerProvider.notifier);
        final newTicket = kMockActiveTicket.copyWith(
          bookingCode: '2026101500099',
          patientName: 'Ahmad Dhani Setiawan',
        );

        await controller.saveNewTicket(newTicket);

        final state = container.read(ticketControllerProvider);
        expect(state.ticket!.bookingCode, equals('2026101500099'));
        expect(state.ticket!.patientName, equals('Ahmad Dhani Setiawan'));
        expect(fakeRepo.activeTicket!.bookingCode, equals('2026101500099'));
      },
    );

    test(
      'cancelTicket marks ticket cancelled when before cut-off deadline',
      () async {
        final controller = container.read(ticketControllerProvider.notifier);
        final futureDate = AppDateTime.now().add(const Duration(days: 3));
        final cancellableTicket = kMockActiveTicket.copyWith(
          scheduledDate: futureDate,
        );
        await controller.saveNewTicket(cancellableTicket);

        final success = await controller.cancelTicket(
          reason: 'Perubahan jadwal dinas',
        );
        expect(success, isTrue);

        final state = container.read(ticketControllerProvider);
        expect(state.ticket!.isCancelled, isTrue);
        expect(state.ticket!.cancelNote, equals('Perubahan jadwal dinas'));
      },
    );

    test('confirmApmCheckIn updates ticket status to checkedIn', () async {
      final controller = container.read(ticketControllerProvider.notifier);
      await controller.saveNewTicket(kMockActiveTicket);

      await controller.confirmApmCheckIn();

      final state = container.read(ticketControllerProvider);
      expect(state.ticket!.isCheckedIn, isTrue);
      expect(state.ticket!.checkInTime, isNotNull);
    });

    test('setMaxBrightness toggles isMaxBrightness flag', () {
      final controller = container.read(ticketControllerProvider.notifier);
      expect(container.read(ticketControllerProvider).isMaxBrightness, isFalse);

      controller.setMaxBrightness(true);
      expect(container.read(ticketControllerProvider).isMaxBrightness, isTrue);

      controller.setMaxBrightness(false);
      expect(container.read(ticketControllerProvider).isMaxBrightness, isFalse);
    });

    test('refreshQueue decrements remainingQueue safely', () async {
      final controller = container.read(ticketControllerProvider.notifier);
      await controller.saveNewTicket(kMockActiveTicket);

      final initialRemaining = container
          .read(ticketControllerProvider)
          .ticket!
          .remainingQueue;

      await controller.refreshQueue();

      final updatedRemaining = container
          .read(ticketControllerProvider)
          .ticket!
          .remainingQueue;
      expect(updatedRemaining, equals(initialRemaining - 1));
    });

    test(
      'syncPendingTickets calls repository syncPendingOfflineActions',
      () async {
        final controller = container.read(ticketControllerProvider.notifier);
        final count = await controller.syncPendingTickets();
        expect(count, equals(0));
        expect(fakeRepo.syncCallCount, greaterThanOrEqualTo(1));
      },
    );

    test(
      'refreshTicketDetail menggabung kebenaran server ke tiket lokal',
      () async {
        final controller = container.read(ticketControllerProvider.notifier);
        await controller.saveNewTicket(kMockActiveTicket);
        fakeRepo.ticketDetail = <String, dynamic>{
          'nama_klinik': 'Poli Mata Server',
          'nama_dokter': 'dr. Server, Sp.M.',
          'jam_layanan': '08:00 - 12:00',
          'st_batal': '0',
          'is_batal': false,
        };

        final ok = await controller.refreshTicketDetail();

        expect(ok, isTrue);
        final state = container.read(ticketControllerProvider);
        expect(state.ticket!.clinic, equals('Poli Mata Server'));
        expect(state.ticket!.doctorName, equals('dr. Server, Sp.M.'));
        expect(state.ticket!.scheduledTime, equals('08:00 - 12:00'));
        expect(state.ticket!.isCancelled, isFalse);
      },
    );

    test('refreshTicketDetail menandai batal saat server is_batal', () async {
      final controller = container.read(ticketControllerProvider.notifier);
      await controller.saveNewTicket(kMockActiveTicket);
      fakeRepo.ticketDetail = <String, dynamic>{'is_batal': true};

      final ok = await controller.refreshTicketDetail();

      expect(ok, isTrue);
      expect(
        container.read(ticketControllerProvider).ticket!.isCancelled,
        isTrue,
      );
    });

    test(
      'refreshTicketDetail hening saat detail null (lokal dipakai)',
      () async {
        final controller = container.read(ticketControllerProvider.notifier);
        await controller.saveNewTicket(kMockActiveTicket);
        fakeRepo.ticketDetail = null;

        final ok = await controller.refreshTicketDetail();

        expect(ok, isFalse);
        expect(
          container.read(ticketControllerProvider).ticket!.clinic,
          equals(kMockActiveTicket.clinic),
        );
      },
    );

    test('refreshQueue menandai QR terbit saat poll st_qrcode 1', () async {
      final controller = container.read(ticketControllerProvider.notifier);
      await controller.saveNewTicket(kMockActiveTicket);
      fakeRepo.qrIssued = true;

      await controller.refreshQueue();

      expect(container.read(ticketControllerProvider).qrIssuedByServer, isTrue);
    });

    test('detects offline state from connectivity stream', () async {
      final offlineContainer = ProviderContainer(
        overrides: [
          ticketRepositoryProvider.overrideWithValue(fakeRepo),
          connectivityStreamProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.none]),
          ),
        ],
      );
      addTearDown(offlineContainer.dispose);

      offlineContainer.listen(ticketControllerProvider, (prev, next) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = offlineContainer.read(ticketControllerProvider);
      expect(state.isOffline, isTrue);
    });
  });
}
