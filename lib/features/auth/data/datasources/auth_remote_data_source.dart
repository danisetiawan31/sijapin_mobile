import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

/// Kontrak interface remote data source autentikasi CodeIgniter 3 RSUP Dr. Sitanala
abstract interface class IAuthRemoteDataSource {
  /// Mengirim permintaan verifikasi kredensial ke `POST /Login/cek_login`
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  });

  /// Mengirim data registrasi akun baru ke `POST /Login/simpan_akun_pr`
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  });

  /// Mengakhiri sesi akun di server RSUP Dr. Sitanala
  Future<void> logout();
}

/// Implementasi pemanggilan HTTP API CodeIgniter 3 via Dio
class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSource({required this.dioClient});

  @override
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final formData = FormData.fromMap({
      'nomor_telepon': phoneNumber,
      'kunci': password,
    });

    final response = await dioClient.post<dynamic>(
      ApiConstants.login,
      data: formData,
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{
      'ret': 'error',
      'msg': 'Format respons server tidak valid',
    };
  }

  @override
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) async {
    final String genderCode = gender.toUpperCase().startsWith('P') ? 'P' : 'L';

    final formData = FormData.fromMap({
      'id_customer': '',
      'nomor_telepon': phoneNumber,
      'nama': fullName,
      'tgl_lahir': birthDate.day.toString().padLeft(2, '0'),
      'bln_lahir': birthDate.month.toString().padLeft(2, '0'),
      'thn_lahir': birthDate.year.toString(),
      'jns_kelamin': genderCode,
      'email': email,
      'kunci': password,
      'kunci_conf': password,
    });

    final response = await dioClient.post<dynamic>(
      ApiConstants.register,
      data: formData,
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return <String, dynamic>{
      'ret': 'error',
      'msg': 'Format respons server tidak valid',
    };
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.get<dynamic>(ApiConstants.logout);
    } catch (_) {
      // Abaikan kendala koneksi agar pembersihan sesi lokal tetap berjalan
    }
  }
}
