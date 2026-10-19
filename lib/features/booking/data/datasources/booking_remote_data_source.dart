import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/network/json_first.dart';
import 'package:sijapin_mobile/core/utils/app_date_time.dart';

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

  /// Polling status panggilan poli (Daftar_Log/cek_status_qrcode)
  Future<Map<String, dynamic>> cekStatusQrcode({
    required String tanggal,
    required String kodeVerifikasi,
  });

  /// Mengambil riwayat antrean rawat jalan dari server (daftar_log)
  Future<List<Map<String, dynamic>>> fetchBookingHistory();

  /// Detail tiket + QR (`Daftar_Log/daftar_detail/{tgl}/{kode}/{daftar}`).
  /// `tanggal8digit` = DDMMYYYY sesuai `substr` backend; null bila tak ada.
  Future<Map<String, dynamic>?> fetchTicketDetail({
    required String tanggal8digit,
    required String kodeVerifikasi,
    String daftarType = '2',
  });
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
        options: jsonAcceptOptions(),
      );

      final data = parseJsonMap(response.data);
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
        options: jsonAcceptOptions(),
      );

      final data = parseJsonMap(response.data);
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
        options: jsonAcceptOptions(),
      );

      final data = parseJsonMap(response.data);
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
      options: jsonAcceptOptions(),
    );

    final resData = parseJsonMap(response.data);
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
      options: jsonAcceptOptions(),
    );

    final resData = parseJsonMap(response.data);
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
      options: jsonAcceptOptions(),
    );

    final resData = parseJsonMap(response.data);
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
      options: jsonAcceptOptions(),
    );

    final resData = parseJsonMap(response.data);
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
      await dioClient.get<dynamic>(
        ApiConstants.bookingFinishDaftar,
        options: jsonAcceptOptions(),
      );
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
        options: jsonAcceptOptions(),
      );

      final resData = parseJsonMap(response.data);
      if (resData != null) {
        return resData['success'] == true || resData['ret'] == 'success';
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> cekStatusQrcode({
    required String tanggal,
    required String kodeVerifikasi,
  }) async {
    try {
      final response = await dioClient.post<dynamic>(
        ApiConstants.checkInCekStatus,
        data: FormData.fromMap({
          'tanggal': tanggal,
          'kode_verifikasi': kodeVerifikasi,
        }),
        options: jsonAcceptOptions(),
      );
      final Map<String, dynamic>? map = parseJsonMap(response.data);
      if (map == null) return const {};
      if (isEnvelopeMap(map)) {
        final Object? payload = unwrapEnvelopeData(map);
        if (payload is Map<String, dynamic>) return payload;
        return <String, dynamic>{'data': payload};
      }
      return map;
    } on DioException catch (e) {
      throw BookingServerException(
        e.message ?? 'Gagal memeriksa status antrean.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchBookingHistory() async {
    // JSON murni (nol HTML): `GET /Daftar_Log` → envelope
    // `data: {riwayat: [...], terakhir: [...]}` (`riwayat_normalize_rows`:
    // baris ternormalisasi lowercase). Diterjemahkan ke kontrakRepo
    // (`rawDate` DDMMYYYY, dst.) agar repository tak berubah.
    final response = await dioClient.get<dynamic>(
      ApiConstants.bookingHistory,
      queryParameters: {'_t': AppDateTime.now().millisecondsSinceEpoch},
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return const [];
    final Object? payload = isEnvelopeMap(map)
        ? unwrapEnvelopeData(map)
        : map['data'] ?? map;
    return _historyFromJson(payload);
  }

  @override
  Future<Map<String, dynamic>?> fetchTicketDetail({
    required String tanggal8digit,
    required String kodeVerifikasi,
    String daftarType = '2',
  }) async {
    // Envelope `data.tiket` (`tiket_rj_normalize` rajal / MCU normalize).
    // 404 = tak ada data, kembalikan null agar pemanggil memakai tiket lokal.
    try {
      final response = await dioClient.get<dynamic>(
        '${ApiConstants.bookingHistoryDetail}/$tanggal8digit/$kodeVerifikasi/$daftarType',
        options: jsonAcceptOptions(),
      );
      final Map<String, dynamic>? map = parseJsonMap(response.data);
      if (map == null) return null;
      final Object? payload = isEnvelopeMap(map)
          ? unwrapEnvelopeData(map)
          : map['data'] ?? map;
      final Object? tiket = payload is Map<String, dynamic>
          ? payload['tiket']
          : null;
      if (tiket is Map<String, dynamic>) return tiket;
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw BookingServerException(
        e.message ?? 'Gagal memuat detail tiket.',
        statusCode: e.response?.statusCode,
      );
    }
  }

  List<Map<String, dynamic>> _historyFromJson(Object? payload) {
    final Map<String, dynamic> root = payload is Map<String, dynamic>
        ? payload
        : const <String, dynamic>{};
    final List<Object?> raw = <Object?>[
      if (root['riwayat'] is List) ...(root['riwayat'] as List),
      if (root['terakhir'] is List) ...(root['terakhir'] as List),
      if (payload is List) ...payload,
    ];
    final List<Map<String, dynamic>> history = [];
    final Set<String> seenCodes = <String>{};
    for (final Object? item in raw) {
      if (item is! Map) continue;
      final Map<String, dynamic> row = item.map(
        (Object? k, Object? v) => MapEntry(k.toString(), v),
      );
      final String code = (row['kode_verifikasi'] ?? '').toString();
      if (code.isNotEmpty && !seenCodes.add(code)) continue;
      final String rawDate = (row['tgl_rencana_kunjungan_raw'] ?? '')
          .toString();
      final String tgl = (row['tgl_rencana_kunjungan'] ?? '').toString();
      history.add(<String, dynamic>{
        'rawDate': rawDate.isNotEmpty
            ? rawDate
            : tgl.replaceAll(RegExp(r'[^0-9]'), ''),
        'verificationCode': code,
        'daftarType': (row['daftar'] ?? '2').toString(),
        'description': <String>[
          (row['tipe_layanan'] ?? '').toString(),
          tgl,
        ].where((String s) => s.isNotEmpty).join(' — '),
        'isCancelled':
            row['is_batal'] == true || row['st_batal']?.toString() == '1',
      });
    }
    return history;
  }
}

/// Provider Riverpod untuk IBookingRemoteDataSource
final bookingRemoteDataSourceProvider = Provider<IBookingRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return BookingRemoteDataSource(dioClient: dioClient);
});
