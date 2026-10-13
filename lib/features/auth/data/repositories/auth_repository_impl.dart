import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/cookie_manager_service.dart';
import '../../../../core/network/dio_error_handler.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_constants.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_rest_data_source.dart';

/// Implementasi repositori autentikasi nyata yang terhubung ke server CI3
class AuthRepositoryImpl implements AuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final ISecureStorage secureStorage;
  final ICookieManagerService cookieManagerService;

  /// Data source REST v2 opsional: jika ada, login memakai REST primer +
  /// fallback CI3 hanya saat galat transport; jika null, murni CI3
  /// (mempertahankan perilaku lama termasuk seluruh test eksisting).
  final AuthRestDataSource? restDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.cookieManagerService,
    this.restDataSource,
  });

  @override
  Future<AuthResult> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    final AuthRestDataSource? rest = restDataSource;
    if (rest == null) {
      return _loginViaCi3(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );
    }
    try {
      final Map<String, dynamic> payload = await rest.loginRest(
        phoneNumber: identifier,
        password: password,
      );
      await _persistRestSession(identifier.trim(), payload);
      // Endpoint tulis legacy (profil, keluarga, wizard) memakai cookie
      // sesi CI3, bukan Bearer: tanam cookie sekarang selagi kredensial
      // ada di tangan (best-effort; REST sudah sah bila ini gagal).
      try {
        await remoteDataSource.login(
          phoneNumber: identifier.trim(),
          password: password,
        );
      } catch (_) {
        // Cookie tak tertanam: jalur tulis legacy akan 401 jujur.
      }
      Map<String, dynamic>? profile;
      try {
        profile = await rest.fetchRestProfile();
      } catch (_) {
        // Profil gagal dimuat: login tetap sah, controller pakai jalur lama.
        profile = null;
      }
      return AuthResult(
        success: true,
        message: 'Berhasil masuk ke layanan SIIJAPIN.',
        profile: profile,
      );
    } on ApiException catch (e) {
      // Jawaban definitif server: tampilkan verbatim, tanpa fallback.
      return AuthResult(success: false, message: e.message);
    } on DioException catch (e) {
      final failure = DioErrorHandler.handle(e);
      if (failure is NetworkFailure || failure is ServerMaintenanceFailure) {
        return _loginViaCi3(
          identifier: identifier,
          password: password,
          rememberMe: rememberMe,
        );
      }
      return AuthResult(success: false, message: failure.message);
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Gagal terhubung ke server SIMRS. Silakan periksa koneksi internet Anda.',
      );
    }
  }

  /// Menyimpan token Bearer + `expires_at` + nomor telepon REST ke Secure
  /// Storage. Bentuk sukses persis backend: `{token, token_type: "Bearer",
  /// expires_at: "YYYY-MM-DD HH:MM:SS"}` — TIDAK ada `expires_in`/`customer`.
  Future<void> _persistRestSession(
    String identifier,
    Map<String, dynamic> payload,
  ) async {
    final Object? token = payload['token'];
    if (token is String && token.isNotEmpty) {
      await secureStorage.write(
        key: StorageConstants.keyBearerToken,
        value: token,
      );
    }
    final Object? expiresAt = payload['expires_at'];
    if (expiresAt is String && expiresAt.isNotEmpty) {
      await secureStorage.write(
        key: StorageConstants.keyBearerExpiresAt,
        value: expiresAt,
      );
    }
    await secureStorage.write(
      key: StorageConstants.keyCustomerPhoneNumber,
      value: identifier,
    );
  }

  Future<AuthResult> _loginViaCi3({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await remoteDataSource.login(
        phoneNumber: identifier.trim(),
        password: password,
      );

      final dynamic loginCode = response['login'];
      if (loginCode == 1 || loginCode == '1') {
        // Simpan nomor telepon dan status sesi ke Secure Storage (UU PDP)
        await secureStorage.write(
          key: StorageConstants.keyCustomerPhoneNumber,
          value: identifier.trim(),
        );

        // Ambil token ci_session dari CookieManager jika tersedia
        final token = await cookieManagerService.getCiSessionToken(
          Uri.parse(AppConfig.baseUrl),
        );
        if (token != null) {
          await secureStorage.write(
            key: StorageConstants.keyCustomerSession,
            value: token,
          );
        }

        return const AuthResult(
          success: true,
          message: 'Berhasil masuk ke layanan SIIJAPIN.',
        );
      } else if (loginCode == 2 || loginCode == '2') {
        return const AuthResult(
          success: false,
          message: 'Nomor telepon atau kata sandi Anda salah.',
        );
      } else {
        final String msg =
            response['msg']?.toString() ??
            'Gagal melakukan autentikasi ke server rumah sakit.';
        return AuthResult(success: false, message: msg);
      }
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Gagal terhubung ke server SIMRS. Silakan periksa koneksi internet Anda.',
      );
    }
  }

  @override
  Future<AuthResult> register({
    required String fullName,
    required String phone,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.register(
        fullName: fullName.trim(),
        phoneNumber: phone.trim(),
        email: email.trim(),
        birthDate: birthDate,
        gender: gender,
        password: password,
      );

      final String? ret = response['ret']?.toString();
      final String? msg = response['msg']?.toString();

      if (ret == 'success') {
        return AuthResult(
          success: true,
          message:
              msg ?? 'Pendaftaran berhasil. Silakan masuk dengan akun Anda.',
        );
      } else {
        return AuthResult(
          success: false,
          message:
              msg ??
              'Pendaftaran akun gagal. Silakan periksa kembali data Anda.',
        );
      }
    } on ApiException catch (e) {
      // Jawaban definitif server (success:false / ret:fail): verbatim.
      return AuthResult(success: false, message: e.message);
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Terjadi kendala jaringan saat mendaftar. Silakan coba lagi.',
      );
    }
  }

  /// Logout dan bersihkan seluruh sesi
  @override
  Future<void> logout() async {
    try {
      await restDataSource?.logoutRest();
    } catch (_) {
      // Abaikan: pembersihan lokal tetap berjalan.
    }
    await remoteDataSource.logout();
    await cookieManagerService.clearCookies();
    await secureStorage.delete(key: StorageConstants.keyBearerToken);
    await secureStorage.delete(key: StorageConstants.keyBearerExpiresAt);
    await secureStorage.delete(key: StorageConstants.keyCustomerSession);
    await secureStorage.delete(key: StorageConstants.keyCustomerPhoneNumber);
    await secureStorage.delete(key: StorageConstants.keyCustomerId);
    await secureStorage.delete(key: StorageConstants.keyCustomerFullName);
    await secureStorage.delete(key: StorageConstants.keyCustomerEmail);
  }
}
