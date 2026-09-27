/// Konstanta nama Box Hive dan key penyimpanan lokal
class StorageConstants {
  const StorageConstants._();

  // Nama Box Hive
  static const String ticketsBox = 'tickets_box';
  static const String masterCacheBox = 'master_cache_box';
  static const String preferencesBox = 'preferences_box';

  // Key Secure Storage (UU PDP)
  static const String keyCustomerSession = 'customer_session_token';
  static const String keyCustomerPhoneNumber = 'customer_phone_number';
  static const String keyBiometricEnabled = 'biometric_auth_enabled';
}
