import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_profile.dart';

/// Sumber data profil pasien yang sedang login.
///
/// STATUS SEMENTARA: sesi pasien belum tersedia di slicing auth
/// (`features/auth` baru menyimpan status submit form), sehingga provider ini
/// masih memakai data contoh untuk kebutuhan slicing UI.
///
/// Saat endpoint sesi CI3 tersedia, ganti isi provider ini dengan pembacaan
/// sesi dari penyimpanan lokal tanpa perlu menyentuh [ProfileScreen] maupun
/// widget presentasi lainnya.
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  return UserProfile(
    fullName: 'Rina Puspita Sari',
    email: 'rina.puspita@warga.go.id',
    phone: '081234567890',
    nik: '3671044508940002',
    birthDate: null,
    gender: 'P',
    bloodType: 'O',
    address: 'Jl. Cileduk Raya No. 24, Tangerang',
    memberSince: DateTime(2024, 3, 17),
  );
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

  /// Menghapus sesi pasien dari state lokal.
  void signOut() {
    state = state.copyWith(clearUser: true);
  }
}
