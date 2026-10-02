import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';
import 'package:sijapin_mobile/features/booking/data/datasources/booking_remote_data_source.dart';

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
    this.bookingRemoteDataSource,
  });

  final ITicketLocalDataSource localDataSource;
  final DioClient? dioClient;
  final ISecureStorage? secureStorage;
  final IBookingRemoteDataSource? bookingRemoteDataSource;

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

    // 1. Eksekusi pembatalan remote ke backend CI3 (Daftar_Log/daftar_batal)
    // SSOT: Format tanggal WAJIB DD-MM-YYYY sesuai STR_TO_DATE("$tanggal", "%d-%m-%Y") di MySQL
    final customerId =
        await secureStorage?.read(key: StorageConstants.keyCustomerId) ?? '';
    final targetDate = scheduledDate ?? AppDateTime.now();
    final tgl =
        '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';

    if (bookingRemoteDataSource != null) {
      try {
        remoteCancelled = await bookingRemoteDataSource!.cancelBooking(
          customerId: customerId,
          memberId: (memberId ?? 0).toString(),
          tanggal: tgl,
          bookingCode: bookingCode,
          reason: reason,
        );
      } catch (_) {
        // Fallback anggun: Tetap izinkan pembatalan offline di perangkat
      }
    } else if (dioClient != null) {
      try {
        final response = await dioClient!.post<dynamic>(
          ApiConstants.bookingBatalAntrian,
          data: FormData.fromMap({
            'customer_id': customerId,
            'member_id': (memberId ?? 0).toString(),
            'tanggal': tgl,
            'kodebooking': bookingCode,
            'alasan': reason,
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

  @override
  Future<int> syncPendingOfflineActions() async {
    if (dioClient == null && bookingRemoteDataSource == null) return 0;
    int syncedCount = 0;
    try {
      final allTickets = await localDataSource.getAllTickets();
      final unsyncedCancelled = allTickets.where(
        (m) => !m.isServerSynced && m.status == TicketStatus.cancelled.name,
      );

      for (final model in unsyncedCancelled) {
        final entity = model.toEntity();
        final customerId =
            await secureStorage?.read(key: StorageConstants.keyCustomerId) ??
            '';
        final targetDate = entity.scheduledDate;
        final tgl =
            '${targetDate.day.toString().padLeft(2, '0')}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.year}';

        bool ok = false;
        if (bookingRemoteDataSource != null) {
          ok = await bookingRemoteDataSource!.cancelBooking(
            customerId: customerId,
            memberId: (entity.memberId ?? 0).toString(),
            tanggal: tgl,
            bookingCode: entity.bookingCode,
            reason:
                entity.cancelNote ??
                'Dibatalkan mandiri oleh pasien (offline sync)',
          );
        } else if (dioClient != null) {
          final response = await dioClient!.post<dynamic>(
            ApiConstants.bookingBatalAntrian,
            data: FormData.fromMap({
              'customer_id': customerId,
              'member_id': (entity.memberId ?? 0).toString(),
              'tanggal': tgl,
              'kodebooking': entity.bookingCode,
              'alasan':
                  entity.cancelNote ??
                  'Dibatalkan mandiri oleh pasien (offline sync)',
            }),
          );
          ok = response.statusCode == 200;
        }

        if (ok) {
          final updated = entity.copyWith(isServerSynced: true);
          await localDataSource.saveTicket(TicketModel.fromEntity(updated));
          syncedCount++;
        }
      }
    } catch (_) {}
    return syncedCount;
  }
}

/// Provider Riverpod untuk TicketRepository
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  final localDataSource = ref.watch(ticketLocalDataSourceProvider);
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final bookingRemote = ref.watch(bookingRemoteDataSourceProvider);

  return TicketRepositoryImpl(
    localDataSource: localDataSource,
    dioClient: dioClient,
    secureStorage: secureStorage,
    bookingRemoteDataSource: bookingRemote,
  );
});
