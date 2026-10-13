import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';

/// Data source REST API v2 untuk autentikasi (JSON + Bearer; SSOT:
/// `.artifacts/PANDUAN_ENDPOINT_FLUTTER.md` §1).
/// Transport-only: orkestrasi fallback REST → CI3 milik repository.
/// Envelope `success:false` sudah diubah menjadi [ApiException] oleh
/// interceptor sehingga tidak sampai ke sini.
class AuthRestDataSource {
  final ApiClient apiClient;

  AuthRestDataSource({required this.apiClient});

  /// Login modern `POST /api/v1/auth/login` `{nomor_telepon, kunci}`.
  /// WAJIB form-urlencoded: `CI_Input::post()` backend tidak membaca body
  /// JSON (request JSON selalu 401 "wajib diisi"). Mengembalikan peta `data`:
  /// `{token, token_type, expires_in/expires_at}`.
  Future<Map<String, dynamic>> loginRest({
    required String phoneNumber,
    required String password,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'nomor_telepon': phoneNumber.trim(),
      'kunci': password,
    });
    final Response<dynamic> response = await apiClient.post<dynamic>(
      ApiConstants.apiV1Login,
      data: formData,
    );
    final Object? body = response.data;
    if (body is Map<String, dynamic>) {
      final Object? data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    throw const ApiException('Format respons login tidak valid.');
  }

  /// Profil akun `GET /api/v1/profile` (Bearer dilampirkan interceptor).
  /// Bentuk `data`: `{id_customer, nama, nomor_telepon, email,
  /// tanggal_lahir, jenis_kelamin, alamat}` (id bisa int — parse defensif).
  Future<Map<String, dynamic>> fetchRestProfile() async {
    final Response<dynamic> response = await apiClient.get<dynamic>(
      ApiConstants.apiV1Profile,
    );
    final Object? body = response.data;
    if (body is Map<String, dynamic>) {
      final Object? data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    throw const ApiException('Format respons profil tidak valid.');
  }

  /// Revoke token aktif `POST /api/v1/auth/logout`.
  /// Galat diabaikan agar pembersihan sesi lokal tetap berjalan.
  Future<void> logoutRest() async {
    try {
      await apiClient.post<dynamic>(ApiConstants.apiV1Logout);
    } catch (_) {
      // Abaikan: sesi lokal tetap dibersihkan oleh repository.
    }
  }
}
