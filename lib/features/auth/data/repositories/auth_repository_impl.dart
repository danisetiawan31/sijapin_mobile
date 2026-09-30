import '../../../../core/config/app_config.dart';
import '../../../../core/network/cookie_manager_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_constants.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementasi repositori autentikasi nyata yang terhubung ke server CI3
class AuthRepositoryImpl implements AuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final ISecureStorage secureStorage;
  final ICookieManagerService cookieManagerService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.cookieManagerService,
  });

  @override
  Future<AuthResult> login({
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
    } catch (_) {
      return const AuthResult(
        success: false,
        message: 'Terjadi kendala jaringan saat mendaftar. Silakan coba lagi.',
      );
    }
  }

  /// Logout dan bersihkan seluruh sesi
  Future<void> logout() async {
    await remoteDataSource.logout();
    await cookieManagerService.clearCookies();
    await secureStorage.delete(key: StorageConstants.keyCustomerSession);
    await secureStorage.delete(key: StorageConstants.keyCustomerId);
    await secureStorage.delete(key: StorageConstants.keyCustomerFullName);
    await secureStorage.delete(key: StorageConstants.keyCustomerEmail);
  }
}
