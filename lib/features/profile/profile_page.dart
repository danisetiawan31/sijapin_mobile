/// Alias kompatibilitas untuk tab Profil.
///
/// Implementasi reside di [ProfileScreen] sesuai struktur clean architecture
/// (`presentation/screens/`), yang dirutekan melalui `core/router/app_router.dart`.
/// File ini dipertahankan agar import lama `features/profile/profile_page.dart`
/// tetap Resolve tanpa menduplikasi UI.
library;

import 'presentation/screens/profile_screen.dart';

/// Nama lama [ProfileScreen], dipertahankan untuk pemanggil sebelumnya.
typedef ProfilePage = ProfileScreen;
