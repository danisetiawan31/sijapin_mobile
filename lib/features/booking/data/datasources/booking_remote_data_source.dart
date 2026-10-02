import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';

/// Exception khusus untuk kegagalan komunikasi atau validasi booking server CI3
class BookingServerException implements Exception {
  final String message;
  final int? statusCode;

  const BookingServerException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Kontrak Remote Data Source untuk wizard pendaftaran rawat jalan (Daftar_Kunj_Raja)
abstract interface class IBookingRemoteDataSource {
  /// Mengambil daftar dokter jaga untuk poliklinik tertentu (list_dokter_jaga)
  Future<List<Map<String, dynamic>>> fetchDoctorsByUnit(int unitId);

  /// Mengambil jadwal praktik dokter (list_jadwal)
  Future<Map<String, dynamic>> fetchDoctorSchedule({
    required int unitId,
    required int doctorId,
  });

  /// Mengambil jam pelayanan yang dihitung presisi oleh server (get_jam_pelayanan)
  Future<String> fetchJamPelayanan({
    required String tglKunjungan,
    required int unitId,
    required int doctorId,
  });

  /// Step 1: Input identitas pasien ke sesi CI3 (input_pasien)
  Future<void> submitPatientStep(Map<String, dynamic> data);

  /// Step 2: Input unit poliklinik, dokter, dan tanggal ke sesi CI3 (input_kunjungan)
  Future<void> submitVisitStep(Map<String, dynamic> data);

  /// Step 3: Input metode pembayaran ke sesi CI3 (input_pembayaran)
  Future<void> submitPaymentStep(String caraBayar);

  /// Step 4: Final insert transaksi ke tabel t_daftar_rj (insert_daftar_rajal)
  Future<Map<String, dynamic>> insertDaftarRajal(Map<String, dynamic> data);

  /// Step 5: Pembersihan sesi wizard CI3 (finish_daftar)
  Future<void> finishRegistrationSession();

  /// Pembatalan kunjungan (Daftar_Log/daftar_batal)
  Future<bool> cancelBooking({
    required String customerId,
    required String memberId,
    required String tanggal,
    String? bookingCode,
    String? reason,
  });

  /// Mengambil riwayat antrean rawat jalan dari server (daftar_log)
  Future<List<Map<String, dynamic>>> fetchBookingHistory();
}

/// Implementasi Remote Data Source untuk wizard pendaftaran rawat jalan
class BookingRemoteDataSource implements IBookingRemoteDataSource {
  const BookingRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  @override
  Future<List<Map<String, dynamic>>> fetchDoctorsByUnit(int unitId) async {
    try {
      final response = await dioClient.post<dynamic>(
        ApiConstants.bookingListDokter,
        data: FormData.fromMap({'unit': unitId.toString()}),
      );

      final data = _parseJsonMap(response.data);
      if (data == null || data['ret'] != 'success') {
        return const [];
      }

      final List<dynamic> ids = (data['id'] as List<dynamic>?) ?? [];
      final List<dynamic> doctors = (data['dokter'] as List<dynamic>?) ?? [];

      final List<Map<String, dynamic>> result = [];
      final count = ids.length < doctors.length ? ids.length : doctors.length;
      for (var i = 0; i < count; i++) {
        final id = int.tryParse(ids[i].toString()) ?? 0;
        final name = doctors[i].toString().trim();
        if (id > 0 && name.isNotEmpty) {
          result.add({'id': id, 'name': name});
        }
      }
      return result;
    } on DioException catch (e) {
      throw BookingServerException(
        e.message ?? 'Gagal menghubungi server untuk memuat dokter jaga.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDoctorSchedule({
    required int unitId,
    required int doctorId,
  }) async {
    try {
      final response = await dioClient.post<dynamic>(
        ApiConstants.bookingListJadwal,
        data: FormData.fromMap({
          'unit': unitId.toString(),
          'dokter': doctorId.toString(),
        }),
      );

      final data = _parseJsonMap(response.data);
      if (data == null || data['ret'] != 'success') {
        return const {};
      }
      return data;
    } on DioException catch (e) {
      throw BookingServerException(
        e.message ?? 'Gagal memuat jadwal praktik dokter.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> fetchJamPelayanan({
    required String tglKunjungan,
    required int unitId,
    required int doctorId,
  }) async {
    try {
      final response = await dioClient.post<dynamic>(
        ApiConstants.bookingJamPelayanan,
        data: FormData.fromMap({
          'tgl_kunjungan': tglKunjungan,
          'unit': unitId.toString(),
          'dokter': doctorId.toString(),
        }),
      );

      final data = _parseJsonMap(response.data);
      if (data != null && data['ret'] == 'success') {
        final jam = data['jam_layanan']?.toString();
        if (jam != null && jam.isNotEmpty) {
          return jam;
        }
      }
      return '09:00:00';
    } on DioException {
      return '09:00:00';
    }
  }

  @override
  Future<void> submitPatientStep(Map<String, dynamic> data) async {
    final response = await dioClient.post<dynamic>(
      ApiConstants.bookingInputPasien,
      data: FormData.fromMap(data),
    );

    final resData = _parseJsonMap(response.data);
    if (resData != null && resData['ret'] == 'fail') {
      final msg =
          resData['msg']?.toString() ?? 'Gagal memvalidasi data pasien.';
      throw BookingServerException(msg);
    }
  }

  @override
  Future<void> submitVisitStep(Map<String, dynamic> data) async {
    final response = await dioClient.post<dynamic>(
      ApiConstants.bookingInputKunjungan,
      data: FormData.fromMap(data),
    );

    final resData = _parseJsonMap(response.data);
    if (resData != null && resData['ret'] == 'fail') {
      final msg =
          resData['msg']?.toString() ?? 'Gagal memvalidasi pilihan kunjungan.';
      throw BookingServerException(msg);
    }
  }

  @override
  Future<void> submitPaymentStep(String caraBayar) async {
    final response = await dioClient.post<dynamic>(
      ApiConstants.bookingInputPembayaran,
      data: FormData.fromMap({'cara_bayar': caraBayar}),
    );

    final resData = _parseJsonMap(response.data);
    if (resData != null && resData['ret'] == 'fail') {
      final msg =
          resData['msg']?.toString() ?? 'Gagal menetapkan metode penjaminan.';
      throw BookingServerException(msg);
    }
  }

  @override
  Future<Map<String, dynamic>> insertDaftarRajal(
    Map<String, dynamic> data,
  ) async {
    final response = await dioClient.post<dynamic>(
      ApiConstants.bookingInsertRajal,
      data: FormData.fromMap(data),
    );

    final resData = _parseJsonMap(response.data);
    if (resData == null) {
      throw const BookingServerException(
        'Respons server tidak valid saat final transaksi.',
      );
    }

    final success =
        resData['success'] == true ||
        resData['status'] == true ||
        resData['ret'] == 'success';
    if (!success) {
      final msg =
          resData['message']?.toString() ??
          resData['msg']?.toString() ??
          'Gagal menyimpan pendaftaran rawat jalan ke SIMRS.';
      throw BookingServerException(msg);
    }

    return resData;
  }

  @override
  Future<void> finishRegistrationSession() async {
    try {
      await dioClient.get<dynamic>(ApiConstants.bookingFinishDaftar);
    } catch (_) {
      // Abaikan kegagalan non-fatal saat membersihkan sesi
    }
  }

  @override
  Future<bool> cancelBooking({
    required String customerId,
    required String memberId,
    required String tanggal,
    String? bookingCode,
    String? reason,
  }) async {
    try {
      final payload = <String, dynamic>{
        'customer_id': customerId,
        'member_id': memberId,
        'tanggal': tanggal,
      };
      if (bookingCode != null) payload['kodebooking'] = bookingCode;
      if (reason != null) payload['alasan'] = reason;

      final response = await dioClient.post<dynamic>(
        ApiConstants.bookingBatalAntrian,
        data: FormData.fromMap(payload),
      );

      final resData = _parseJsonMap(response.data);
      if (resData != null) {
        return resData['success'] == true || resData['ret'] == 'success';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBookingHistory() async {
    try {
      final response = await dioClient.get<String>(
        ApiConstants.bookingHistory,
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );

      final html = response.data;
      if (html == null || html.isEmpty) return const [];

      final document = html_parser.parse(html);
      final cards = document.querySelectorAll('.riwayat-cards');
      final List<Map<String, dynamic>> history = [];

      for (final card in cards) {
        final btn = card.querySelector('a.btn-select');
        final href = btn?.attributes['href'] ?? '';
        final bodyText = card.querySelector('.card-body')?.text.trim() ?? '';

        final isCanceled =
            card.classes.contains('border-danger') ||
            card.classes.contains('bg-danger');

        // Parse format URL: Daftar_Log/daftar_detail/{TGL_RENCANA_KUNJUNGAN_2}/{KODE_VERIFIKASI}/{DAFTAR}
        final match = RegExp(r'daftar_detail/(\d+)/([^/]+)/(\d+)')
            .firstMatch(href);
        if (match != null) {
          final tglRaw = match.group(1) ?? '';
          final kodeVerifikasi = match.group(2) ?? '';
          final jenisDaftar = match.group(3) ?? '2';

          history.add({
            'rawDate': tglRaw,
            'verificationCode': kodeVerifikasi,
            'daftarType': jenisDaftar,
            'description': bodyText,
            'isCancelled': isCanceled,
          });
        }
      }

      return history;
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic>? _parseJsonMap(dynamic rawData) {
    if (rawData == null) return null;
    if (rawData is Map<String, dynamic>) return rawData;
    if (rawData is Map) {
      return rawData.map((k, v) => MapEntry(k.toString(), v));
    }
    if (rawData is String) {
      try {
        final decoded = json.decode(rawData);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }
    return null;
  }
}

/// Provider Riverpod untuk IBookingRemoteDataSource
final bookingRemoteDataSourceProvider = Provider<IBookingRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingRemoteDataSource(dioClient: dioClient);
});
