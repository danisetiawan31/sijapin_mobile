import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final cookieManager = ref.watch(cookieManagerServiceProvider);
  final remoteDataSource = AuthRemoteDataSource(dioClient: dioClient);

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
    cookieManagerService: cookieManager,
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

  Future<AuthResult?> login({
    required String identifier,
    required String password,
    required bool rememberMe,
  }) async {
    state = state.copyWith(
      status: AuthSubmissionStatus.loading,
      clearMessage: true,
    );

    try {
      final result = await ref.read(loginUseCaseProvider)(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );
      if (result.success) {
        ref.read(activeSessionUserProvider.notifier).setUser(
              UserProfile(
                fullName: 'Pasien Terdaftar',
                phone: identifier.trim(),
                email: identifier.contains('@') ? identifier.trim() : '',
                nik: '',
                birthDate: null,
                gender: 'L',
                bloodType: '',
                address: '',
                memberSince: DateTime.now(),
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
        ref.read(activeSessionUserProvider.notifier).setUser(
              UserProfile(
                fullName: fullName.trim(),
                phone: phone.trim(),
                email: email.trim(),
                nik: '',
                birthDate: birthDate,
                gender: gender,
                bloodType: '',
                address: '',
                memberSince: DateTime.now(),
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
}
