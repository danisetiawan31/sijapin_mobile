/// Konstanta nama Box Hive dan key penyimpanan lokal
class StorageConstants {
  const StorageConstants._();

  // Nama Box Hive
  static const String ticketsBox = 'tickets_box';
  static const String masterCacheBox = 'master_cache_box';
  static const String preferencesBox = 'preferences_box';
  static const String familyMembersBox = 'family_members_box';

  // Key Secure Storage (UU PDP)
  static const String keyCustomerSession = 'customer_session_token';
  static const String keyCustomerPhoneNumber = 'customer_phone_number';
  static const String keyCustomerId = 'customer_id';
  static const String keyCustomerFullName = 'customer_full_name';
  static const String keyCustomerEmail = 'customer_email';
  static const String keyCustomerGender = 'customer_gender';
  static const String keyCustomerBirthDate = 'customer_birth_date';
  static const String keyBiometricEnabled = 'biometric_auth_enabled';
  static const String keyPasscodeHash = 'app_passcode_hash';
  static const String keyPasscodeSalt = 'app_passcode_salt';
  static const String keyHiddenFamilyMemberIds = 'hidden_family_member_ids';
}
