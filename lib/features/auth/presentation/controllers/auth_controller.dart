import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/app_date_time.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/auth_rest_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_constants.dart';
import '../../../booking/presentation/controllers/booking_wizard_controller.dart';
import '../../../profile/data/repositories/family_member_repository_impl.dart';
import '../../../profile/presentation/controllers/family_member_controller.dart';
import '../../../profile/data/datasources/profile_remote_data_source.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../ticket/presentation/controllers/ticket_controller.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final apiClient = ref.watch(apiClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final cookieManager = ref.watch(cookieManagerServiceProvider);
  final remoteDataSource = AuthRemoteDataSource(dioClient: dioClient);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
    cookieManagerService: cookieManager,
    restDataSource: AuthRestDataSource(apiClient: apiClient),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

enum AuthSubmissionStatus { idle, loading, success, error }

class AuthControllerState {
  final AuthSubmissionStatus status;
  final String? message;

  const AuthControllerState({
    this.status = AuthSubmissionStatus.idle,
    this.message,
  });

  AuthControllerState copyWith({
    AuthSubmissionStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthControllerState(
      status: status ?? this.status,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthControllerState>(AuthController.new);

class AuthController extends Notifier<AuthControllerState> {
  @override
  AuthControllerState build() => const AuthControllerState();

  /// Pengguna darurat jujur bila profil server tak termuat (offline/gagal):
  /// hanya berisi handle login apa adanya — nama TIDAK dikarang, nomor HP
  /// TIDAK diisi email dan sebaliknya. UI menampilkan status
  /// "Data Belum Lengkap" sampai profil asli termuat.
  static UserProfile honestOfflineUser(String identifier) {
    final String trimmed = identifier.trim();
    final bool isEmail = trimmed.contains('@');
    return UserProfile(
      fullName: '',
      phone: isEmail ? '' : trimmed,
      email: isEmail ? trimmed : '',
      nik: '',
      birthDate: null,
      gender: 'L',
      bloodType: '',
      address: '',
      memberSince: AppDateTime.now(),
    );
  }

  Future<AuthResult?> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthSubmissionStatus.loading,
      clearMessage: true,
    );

    try {
      final result = await ref.read(loginUseCaseProvider)(
        identifier: identifier,
        password: password,
      );
      if (result.success) {
        // Profil dari repository (REST Bearer) diutamakan; bila kosong,
        // muat ulang lewat datasource (Bearer-primer + fallback CI3 cookie,
        // sesuai jalur login yang berhasil). Tanpa nama samaran di sini.
        UserProfile? fetchedUser = result.profile == null
            ? null
            : ProfileRemoteDataSource.userFromRestMap(result.profile!);
        if (fetchedUser == null || fetchedUser.fullName.trim().isEmpty) {
          try {
            final dioClient = ref.read(dioClientProvider);
            final apiClient = ref.read(apiClientProvider);
            final refetched = await ProfileRemoteDataSource(
              dioClient: dioClient,
              apiClient: apiClient,
            ).fetchProfile();
            if (refetched != null && refetched.fullName.trim().isNotEmpty) {
              fetchedUser = refetched;
            } else {
              fetchedUser ??= refetched;
            }
          } catch (_) {}
        }

        final user = fetchedUser ?? honestOfflineUser(identifier);

        if (user.customerId.isNotEmpty) {
          final secureStorage = ref.read(secureStorageServiceProvider);
          await secureStorage.write(
            key: StorageConstants.keyCustomerId,
            value: user.customerId,
          );
          await secureStorage.write(
            key: StorageConstants.keyCustomerFullName,
            value: user.fullName,
          );
          if (user.email.isNotEmpty) {
            await secureStorage.write(
              key: StorageConstants.keyCustomerEmail,
              value: user.email,
            );
          }
          if (user.gender.isNotEmpty) {
            await secureStorage.write(
              key: StorageConstants.keyCustomerGender,
              value: user.gender,
            );
          }
          if (user.birthDate != null) {
            await secureStorage.write(
              key: StorageConstants.keyCustomerBirthDate,
              value: user.birthDate!.toIso8601String(),
            );
          }
        }

        ref.read(activeSessionUserProvider.notifier).setUser(user);
      }
      String? displayMessage = result.message;
      if (!result.success) {
        final bool isTransportOrServer =
            displayMessage.contains('koneksi internet') ||
            displayMessage.contains('pemeliharaan') ||
            displayMessage.contains('Format respons server');
        if (!isTransportOrServer) {
          final bool isEmail = identifier.trim().contains('@');
          displayMessage = isEmail
              ? 'E-mail atau password yang anda gunakan salah'
              : 'Nomor Handphone atau password yang anda masukkan salah';
        }
      }
      state = state.copyWith(
        status: result.success
            ? AuthSubmissionStatus.success
            : AuthSubmissionStatus.error,
        message: result.success ? result.message : displayMessage,
      );
      return result;
    } catch (_) {
      const message = 'Terjadi kendala saat memproses permintaan. Coba lagi.';
      state = state.copyWith(
        status: AuthSubmissionStatus.error,
        message: message,
      );
      return null;
    }
  }

  Future<AuthResult?> register({
    required String fullName,
    required String phone,
    required String email,
    required DateTime birthDate,
    required String gender,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthSubmissionStatus.loading,
      clearMessage: true,
    );

    try {
      final result = await ref.read(registerUseCaseProvider)(
        fullName: fullName,
        phone: phone,
        email: email,
        birthDate: birthDate,
        gender: gender,
        password: password,
      );
      if (result.success) {
        ref
            .read(activeSessionUserProvider.notifier)
            .setUser(
              UserProfile(
                fullName: fullName.trim(),
                phone: phone.trim(),
                email: email.trim(),
                nik: '',
                birthDate: birthDate,
                gender: gender,
                bloodType: '',
                address: '',
                memberSince: AppDateTime.now(),
              ),
            );
      }
      state = state.copyWith(
        status: result.success
            ? AuthSubmissionStatus.success
            : AuthSubmissionStatus.error,
        message: result.message,
      );
      return result;
    } catch (_) {
      const message = 'Terjadi kendala saat memproses permintaan. Coba lagi.';
      state = state.copyWith(
        status: AuthSubmissionStatus.error,
        message: message,
      );
      return null;
    }
  }

  /// Keluar penuh: mencabut sesi di server (REST revoke + fallback CI3),
  /// membersihkan cookie + secure keys via repository, lalu mengosongkan
  /// pengguna sesi di memori. Satu-satunya jalur logout aplikasi.
  Future<void> logout() async {
    try {
      await ref.read(authRepositoryProvider).logout();
    } catch (_) {
      // Pembersihan lokal di bawah tetap berjalan.
    }
    // Hapus data user di perangkat: tiket antrean, cache master, dan daftar
    // anggota keluarga Hive. Box preferences dipertahankan: isinya hanya
    // penanda id anggota yang dikeluarkan daftar (ekspel), berlaku juga
    // pada login berikutnya. Passcode/biometrik bukan data akun, tetap ada.
    final ILocalStorage storage = ref.read(localStorageServiceProvider);
    try {
      await storage.clearBox(boxName: StorageConstants.ticketsBox);
      await storage.clearBox(boxName: StorageConstants.masterCacheBox);
      await storage.clearBox(boxName: StorageConstants.familyMembersBox);
    } catch (_) {
      // Pembersihan sesi di Secure Storage dan cookie tetap dibersihkan.
    }
    ref.read(activeSessionUserProvider.notifier).setUser(null);
    // Invalidasi semua provider per-user agar akun berikutnya memuat ulang
    // dari DB SIMRS (bukan mewarisi state memori akun sebelumnya).
    ref.invalidate(familyMemberRepositoryProvider);
    ref.invalidate(familyMembersProvider);
    ref.invalidate(ticketControllerProvider);
    ref.invalidate(bookingWizardControllerProvider);
    state = const AuthControllerState();
  }

  /// Pemulihan sesi saat aplikasi dibuka (spesifikasi §2): token tersimpan +
  /// `expires_at` belum lewat → validasi `GET /api/v1/profile` → isi pengguna
  /// sesi + true (layar home); selain itu false (layar login). Token
  /// kedaluwarsa dihapus agar tidak dipakai ulang.
  Future<bool> restoreSession() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final String token =
        await secureStorage.read(key: StorageConstants.keyBearerToken) ?? '';
    if (token.isEmpty) return false;
    final String expiresRaw =
        await secureStorage.read(key: StorageConstants.keyBearerExpiresAt) ??
        '';
    if (expiresRaw.isNotEmpty) {
      final DateTime? expiry = DateTime.tryParse(expiresRaw);
      if (expiry != null && !expiry.isAfter(AppDateTime.now())) {
        await secureStorage.delete(key: StorageConstants.keyBearerToken);
        await secureStorage.delete(key: StorageConstants.keyBearerExpiresAt);
        return false;
      }
    }
    try {
      final apiClient = ref.read(apiClientProvider);
      final Map<String, dynamic> profile = await AuthRestDataSource(
        apiClient: apiClient,
      ).fetchRestProfile();
      final UserProfile? user = ProfileRemoteDataSource.userFromRestMap(
        profile,
      );
      if (user == null || user.fullName.trim().isEmpty) return false;
      if (user.customerId.isNotEmpty) {
        await secureStorage.write(
          key: StorageConstants.keyCustomerId,
          value: user.customerId,
        );
      }
      if (user.fullName.isNotEmpty) {
        await secureStorage.write(
          key: StorageConstants.keyCustomerFullName,
          value: user.fullName,
        );
      }
      if (user.email.isNotEmpty) {
        await secureStorage.write(
          key: StorageConstants.keyCustomerEmail,
          value: user.email,
        );
      }
      ref.read(activeSessionUserProvider.notifier).setUser(user);
      return true;
    } catch (_) {
      return false;
    }
  }
}
