import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';

import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_local_data_source.dart';
import '../models/ticket_model.dart';

/// Implementasi repositori tiket yang menghubungkan penyimpanan lokal Hive
/// dengan sinkronisasi pembatalan remote ke CodeIgniter 3
class TicketRepositoryImpl implements TicketRepository {
  const TicketRepositoryImpl({
    required this.localDataSource,
    this.dioClient,
    this.secureStorage,
  });

  final ITicketLocalDataSource localDataSource;
  final DioClient? dioClient;
  final ISecureStorage? secureStorage;

  @override
  Future<void> saveTicket(Ticket ticket) async {
    final model = TicketModel.fromEntity(ticket);
    await localDataSource.saveTicket(model);
  }

  @override
  Future<Ticket?> getActiveTicket() async {
    final models = await localDataSource.getAllTickets();
    // Cari tiket yang belum selesai atau belum dibatalkan
    for (final model in models) {
      final entity = model.toEntity();
      if (entity.isUpcoming || entity.isCheckedIn) {
        return entity;
      }
    }
    return null;
  }

  @override
  Future<List<Ticket>> getAllTickets() async {
    final models = await localDataSource.getAllTickets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<bool> cancelTicket({
    required String bookingCode,
    required String reason,
    int? memberId,
    DateTime? scheduledDate,
  }) async {
    bool remoteCancelled = false;

    // 1. Eksekusi pembatalan remote ke backend CI3 jika klien online
    if (dioClient != null) {
      try {
        final customerId =
            await secureStorage?.read(key: StorageConstants.keyCustomerId) ??
            '';
        final targetDate = scheduledDate ?? AppDateTime.now();
        final tgl =
            '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

        final response = await dioClient!.post<dynamic>(
          ApiConstants.bookingBatalAntrian,
          data: FormData.fromMap({
            'customer_id': customerId,
            'member_id': (memberId ?? 0).toString(),
            'tanggal': tgl,
          }),
        );

        if (response.statusCode == 200) {
          remoteCancelled = true;
        }
      } catch (_) {
        // Fallback anggun: Tetap izinkan pembatalan offline di perangkat
      }
    }

    // 2. Perbarui status tiket di penyimpanan lokal Hive
    final existingModel = await localDataSource.getTicketByBookingCode(
      bookingCode,
    );
    if (existingModel != null) {
      final updatedEntity = existingModel.toEntity().copyWith(
        status: TicketStatus.cancelled,
        cancelNote: reason,
        isServerSynced: remoteCancelled,
      );
      await localDataSource.saveTicket(TicketModel.fromEntity(updatedEntity));
    }

    return true;
  }

  @override
  Future<void> checkInTicket(String bookingCode) async {
    final existingModel = await localDataSource.getTicketByBookingCode(
      bookingCode,
    );
    if (existingModel != null) {
      final updatedEntity = existingModel.toEntity().copyWith(
        status: TicketStatus.checkedIn,
        checkInTime: AppDateTime.now(),
      );
      await localDataSource.saveTicket(TicketModel.fromEntity(updatedEntity));
    }
  }
}

/// Provider Riverpod untuk TicketRepository
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final localDataSource = ref.watch(ticketLocalDataSourceProvider);
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);

  return TicketRepositoryImpl(
    localDataSource: localDataSource,
    dioClient: dioClient,
    secureStorage: secureStorage,
  );
});
