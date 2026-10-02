import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_constants.dart';
import '../../data/datasources/profile_remote_data_source.dart';
import '../../domain/entities/user_profile.dart';

/// Notifier sesi akun pasien yang sedang aktif di memori/perangkat.
class ActiveSessionUserNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    // Sesi awal bernilai null (tamu/belum login) sampai sesi riil dimuat
    // dari FlutterSecureStorage atau hasil autentikasi live SIMRS.
    return null;
  }

  void setUser(UserProfile? user) {
    state = user;
  }
}

final activeSessionUserProvider =
    NotifierProvider<ActiveSessionUserNotifier, UserProfile?>(
      ActiveSessionUserNotifier.new,
    );

/// Sumber data profil pasien yang sedang login.
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(activeSessionUserProvider);
});

/// State tab profil: identitas pasien + preferensi lokal.
class ProfileState {
  const ProfileState({this.user, this.appointmentReminder = true});

  final UserProfile? user;

  /// Preferensi pengingat janji temu H-1.
  final bool appointmentReminder;

  bool get isSignedIn => user != null;

  ProfileState copyWith({
    UserProfile? user,
    bool clearUser = false,
    bool? appointmentReminder,
  }) {
    return ProfileState(
      user: clearUser ? null : (user ?? this.user),
      appointmentReminder: appointmentReminder ?? this.appointmentReminder,
    );
  }
}

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);

/// Controller tab profil.
class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return ProfileState(user: ref.watch(currentUserProfileProvider));
  }

  /// Mengaktifkan atau mematikan pengingat janji temu.
  void setAppointmentReminder(bool enabled) {
    state = state.copyWith(appointmentReminder: enabled);
  }

  /// Memperbarui informasi akun induk pasien baik di server CI3 SIMRS
  /// maupun sinkronisasi ke FlutterSecureStorage dan Riverpod state.
  Future<bool> updateUserProfile({
    required String fullName,
    required String phone,
    required String email,
    DateTime? birthDate,
    String? gender,
    String? password,
  }) async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    var customerId =
        await secureStorage.read(key: StorageConstants.keyCustomerId) ?? '';
    if (customerId.isEmpty && state.user?.customerId.isNotEmpty == true) {
      customerId = state.user!.customerId;
    }
    final dioClient = ref.read(dioClientProvider);
    final remoteDataSource = ProfileRemoteDataSource(dioClient: dioClient);

    var success = true;
    try {
      final res = await remoteDataSource.updateProfile(
        customerId: customerId,
        fullName: fullName,
        phoneNumber: phone,
        email: email,
        birthDate: birthDate,
        gender: gender,
        password: password,
      );
      if (res['ret'] == 'fail') {
        success = false;
      }
    } catch (_) {
      // Graceful offline fallback
    }

    // Selalu sinkronisasi ke Secure Storage dan in-memory user
    if (customerId.isNotEmpty) {
      await secureStorage.write(
        key: StorageConstants.keyCustomerId,
        value: customerId,
      );
    }
    await secureStorage.write(
      key: StorageConstants.keyCustomerFullName,
      value: fullName,
    );
    await secureStorage.write(
      key: StorageConstants.keyCustomerPhoneNumber,
      value: phone,
    );
    await secureStorage.write(
      key: StorageConstants.keyCustomerEmail,
      value: email,
    );
    if (gender != null) {
      await secureStorage.write(
        key: StorageConstants.keyCustomerGender,
        value: gender,
      );
    }
    if (birthDate != null) {
      await secureStorage.write(
        key: StorageConstants.keyCustomerBirthDate,
        value: birthDate.toIso8601String(),
      );
    }

    final currentUser = state.user;
    final updatedUser =
        (currentUser ??
                UserProfile(
                  customerId: customerId,
                  fullName: fullName,
                  email: email,
                  phone: phone,
                  nik: '',
                  birthDate: birthDate,
                  gender: gender ?? 'L',
                  bloodType: 'O',
                  address: '',
                  memberSince: null,
                ))
            .copyWith(
              customerId: customerId,
              fullName: fullName,
              phone: phone,
              email: email,
              gender: gender,
              birthDate: birthDate,
            );

    ref.read(activeSessionUserProvider.notifier).setUser(updatedUser);
    state = state.copyWith(user: updatedUser);
    return success;
  }

  /// Menghapus sesi pasien dari state lokal.
  void signOut() {
    state = state.copyWith(clearUser: true);
    ref.read(activeSessionUserProvider.notifier).setUser(null);
  }
}
