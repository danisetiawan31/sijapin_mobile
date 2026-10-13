import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/json_first.dart';

/// Data source REST authority untuk Saran & Pengaduan (PANDUAN §7).
/// JSON-first via [DioClient] + `Accept: application/json`. Jawaban definitif
/// gagal (`success:false` / `ret:fail`) dilempar verbatim; galat transport
/// dilempar sebagai [DioException] agar UI menampilkan status offline.
class FeedbackRemoteDataSource {
  final DioClient dioClient;

  FeedbackRemoteDataSource({required this.dioClient});

  /// `GET /Saran_Pengaduan` → prefill `{nama, alamat, no_contact, email}`
  /// (kunci persis backend; `no_contact` BUKAN `nomor_telepon`).
  Future<Map<String, dynamic>> fetchPrefill() async {
    final response = await dioClient.get<dynamic>(
      ApiConstants.feedbackPrefill,
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

  /// `POST /Saran_Pengaduan/input_saran_pengaduan` (FormData, teks murni —
  /// backend tidak menerima upload gambar). WAJIB `perihal` + `deskripsi`
  /// (`validate_saran_input`: `saran` DITOLAK 422). Identitas diambil server
  /// dari sesi (M13-R1); field identitas terkirim diabaikan backend.
  /// Mengembalikan `{ret, msg}`.
  Future<Map<String, dynamic>> submitFeedback({
    required String name,
    required String phone,
    String email = '',
    String address = '',
    required String subject,
    required String description,
  }) async {
    final response = await dioClient.post<dynamic>(
      ApiConstants.submitFeedback,
      data: FormData.fromMap(<String, dynamic>{
        'nama': name,
        'nomor_telepon': phone,
        'email': email,
        'alamat': address,
        'perihal': subject,
        'deskripsi': description,
      }),
      options: jsonAcceptOptions(),
    );
    final Map<String, dynamic>? map = parseJsonMap(response.data);
    if (map == null) {
      return const <String, dynamic>{
        'ret': 'fail',
        'msg': 'Format respons server tidak valid.',
      };
    }
    throwIfDefinitiveFailure(map);
    return normalizeWriteResult(map);
  }
}

/// Provider Riverpod untuk [FeedbackRemoteDataSource].
final feedbackRemoteDataSourceProvider = Provider<FeedbackRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return FeedbackRemoteDataSource(dioClient: dioClient);
});
