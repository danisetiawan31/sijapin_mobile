import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/storage/local_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';

import '../models/ticket_model.dart';

/// Kontrak data source lokal untuk tiket antrean di Hive NoSQL
abstract class ITicketLocalDataSource {
  /// Menyimpan tiket ke dalam box Hive tickets_box
  Future<void> saveTicket(TicketModel model);

  /// Mengambil tiket berdasarkan kode booking
  Future<TicketModel?> getTicketByBookingCode(String bookingCode);

  /// Mengambil seluruh tiket yang tersimpan di disk lokal
  Future<List<TicketModel>> getAllTickets();

  /// Menghapus tiket tertentu dari disk lokal
  Future<void> deleteTicket(String bookingCode);

  /// Mengosongkan seluruh tiket di disk lokal (misal saat logout)
  Future<void> clearAllTickets();
}

/// Implementasi data source lokal menggunakan ILocalStorage (Hive CE)
class TicketLocalDataSourceImpl implements ITicketLocalDataSource {
  const TicketLocalDataSourceImpl(this._localStorage);

  final ILocalStorage _localStorage;

  @override
  Future<void> saveTicket(TicketModel model) async {
    await _localStorage.put(
      boxName: StorageConstants.ticketsBox,
      key: model.bookingCode,
      value: model.toMap(),
    );
  }

  @override
  Future<TicketModel?> getTicketByBookingCode(String bookingCode) async {
    final raw = _localStorage.get<dynamic>(
      boxName: StorageConstants.ticketsBox,
      key: bookingCode,
    );
    if (raw == null) return null;
    if (raw is Map) {
      return TicketModel.fromMap(raw);
    }
    return null;
  }

  @override
  Future<List<TicketModel>> getAllTickets() async {
    final rawList = _localStorage.getAll<dynamic>(
      boxName: StorageConstants.ticketsBox,
    );
    final List<TicketModel> tickets = [];
    for (final item in rawList) {
      if (item is Map) {
        try {
          tickets.add(TicketModel.fromMap(item));
        } catch (_) {
          // Abaikan item yang rusak
        }
      }
    }
    // Urutkan berdasarkan waktu kunjungan / pembuatan terbaru
    tickets.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
    return tickets;
  }

  @override
  Future<void> deleteTicket(String bookingCode) async {
    await _localStorage.delete(
      boxName: StorageConstants.ticketsBox,
      key: bookingCode,
    );
  }

  @override
  Future<void> clearAllTickets() async {
    await _localStorage.clearBox(boxName: StorageConstants.ticketsBox);
  }
}

/// Provider Riverpod untuk TicketLocalDataSource
final ticketLocalDataSourceProvider = Provider<ITicketLocalDataSource>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return TicketLocalDataSourceImpl(localStorage);
});
