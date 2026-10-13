import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/json_first.dart';

/// Data source REST authority untuk Medical Check-Up (PANDUAN §6).
/// JSON-first via [DioClient] + `Accept: application/json` (endpoint MCU
/// memakai sesi cookie, bukan Bearer). Jawaban definitif gagal
/// (`success:false`) dilempar verbatim; galat transport dilempar sebagai
/// [DioException] agar UI jatuh ke data paket filed-statis.
class McuRemoteDataSource {
  final DioClient dioClient;

  McuRemoteDataSource({required this.dioClient});

  /// `GET /Pendaftaran_MCU_Paket` → envelope
  /// `data: {selected_mcu_id, paket: [...], detail: [...]}` (baris
  /// `mcu_paket_normalize_row`: `{tarif_id, kode_tarif, nama_paket,
  /// nama_tarif, harga}`).
  Future<List<Map<String, dynamic>>> fetchPaketList() async {
    final response = await dioClient.get<dynamic>(
      ApiConstants.mcuPaket,
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return const [];
    final Object? payload = isEnvelopeMap(map)
        ? unwrapEnvelopeData(map)
        : map['data'] ?? map;
    final Object? rows = payload is Map<String, dynamic>
        ? (payload['paket'] ?? payload)
        : payload;
    if (rows is List) {
      return rows
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> m) =>
                m.map((dynamic k, dynamic v) => MapEntry(k.toString(), v)),
          )
          .toList();
    }
    if (rows is Map<String, dynamic>) return <Map<String, dynamic>>[rows];
    return const [];
  }

  /// `GET /Pendaftaran_MCU_Option` → opsi kategori `{tipe_pendaftaran[], ...}`.
  Future<Map<String, dynamic>> fetchOption() async {
    final response = await dioClient.get<dynamic>(
      ApiConstants.mcuOption,
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) return const {};
    final Object? payload = isEnvelopeMap(map)
        ? unwrapEnvelopeData(map)
        : map['data'] ?? map;
    if (payload is Map<String, dynamic>) return payload;
    return const {};
  }

  /// `POST /Pendaftaran/cek_jadwal` → validasi kuota tanggal (FormData).
  /// Tanggal lampau/kuota habis → [ApiException] verbatim.
  Future<Map<String, dynamic>> cekJadwal({
    required String tanggal,
    String? kodeTarif,
  }) async {
    final Map<String, dynamic> body = <String, dynamic>{'tanggal': tanggal};
    if (kodeTarif != null && kodeTarif.isNotEmpty) {
      body['kode_tarif'] = kodeTarif;
    }
    final response = await dioClient.post<dynamic>(
      ApiConstants.mcuCekJadwal,
      data: FormData.fromMap(body),
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) {
      throw const ApiException('Format respons jadwal MCU tidak valid.');
    }
    throwIfDefinitiveFailure(map);
    return normalizeWriteResult(map);
  }
}

/// Provider Riverpod untuk [McuRemoteDataSource].
final mcuRemoteDataSourceProvider = Provider<McuRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return McuRemoteDataSource(dioClient: dioClient);
});
