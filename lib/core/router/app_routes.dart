/// Konstanta nama dan path rute terpusat aplikasi SIIJAPIN Mobile.
abstract final class AppRoutes {
  // Rute Global di Luar Shell
  static const String splashPath = '/';
  static const String splashName = 'splash';

  static const String loginPath = '/login';
  static const String loginName = 'login';

  static const String registerPath = '/register';
  static const String registerName = 'register';

  // 4 Tab Utama (Stateful Shell Route)
  static const String homePath = '/home';
  static const String homeName = 'home';

  static const String bookingPath = '/booking';
  static const String bookingName = 'booking';

  static const String doctorsPath = '/doctors';
  static const String doctorsName = 'doctors';

  static const String profilePath = '/profile';
  static const String profileName = 'profile';

  static const String medicalHistoryPath = '/profile/medical-history';
  static const String medicalHistoryName = 'medical_history';

  static const String familyMembersPath = '/profile/family-members';
  static const String familyMembersName = 'family_members';

  // Modul Support & Informasi Publik (Epic 08)
  static const String mcuCatalogPath = '/mcu';
  static const String mcuCatalogName = 'mcu_catalog';

  static const String complaintPath = '/support/complaint';
  static const String complaintName = 'complaint';

  static const String serviceStandardsPath = '/support/service-standards';
  static const String serviceStandardsName = 'service_standards';

  static const String bpjsFlowPath = '/support/bpjs-flow';
  static const String bpjsFlowName = 'bpjs_flow';
}
