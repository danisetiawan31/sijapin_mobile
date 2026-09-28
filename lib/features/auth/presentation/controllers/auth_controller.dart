import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/fake_auth_repository.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const FakeAuthRepository();
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

  const AuthControllerState({this.status = AuthSubmissionStatus.idle, this.message});

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
