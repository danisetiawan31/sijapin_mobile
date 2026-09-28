/// Utility sensor data pribadi pasien sesuai regulasi UU PDP No. 27/2022
class DataMasker {
  const DataMasker._();

  /// Masking NIK 16 digit: Hanya menampilkan 6 digit awal & 4 digit akhir
  /// Contoh: `3671041234560002` -> `367104******0002`
  static String maskNik(String? nik) {
    if (nik == null || nik.isEmpty) return '-';
    final cleaned = nik.trim();
    if (cleaned.length < 10) {
      // Jika panjang di bawah 10, tampilkan masking penuh
      return '*' * cleaned.length;
    }
    final prefix = cleaned.substring(0, 6);
    final suffix = cleaned.substring(cleaned.length - 4);
    final maskLength = cleaned.length - 10;
    return '$prefix${'*' * maskLength}$suffix';
  }

  /// Masking Nomor Kartu BPJS 13 digit: 6 digit awal & 3 digit akhir terlihat
  /// Contoh: `0001234567789` -> `000123****789`
  static String maskBpjs(String? bpjs) {
    if (bpjs == null || bpjs.isEmpty) return '-';
    final cleaned = bpjs.trim();
    if (cleaned.length < 9) {
      return '*' * cleaned.length;
    }
    final prefix = cleaned.substring(0, 6);
    final suffix = cleaned.substring(cleaned.length - 3);
    final maskLength = cleaned.length - 9;
    return '$prefix${'*' * maskLength}$suffix';
  }

  /// Masking Nomor Handphone: 4 digit awal & 4 digit akhir terlihat
  /// Contoh: `081234568901` -> `0812****8901`
  static String maskPhone(String? phone) {
    if (phone == null || phone.isEmpty) return '-';
    final cleaned = phone.trim();
    if (cleaned.length < 8) {
      return '*' * cleaned.length;
    }
    final prefix = cleaned.substring(0, 4);
    final suffix = cleaned.substring(cleaned.length - 4);
    final maskLength = cleaned.length - 8;
    return '$prefix${'*' * maskLength}$suffix';
  }

  /// Masking Alamat Email: menampilkan 1 karakter pertama dan domain
  /// Contoh: `pasien@sitanala.go.id` -> `p***n@sitanala.go.id`
  static String maskEmail(String? email) {
    if (email == null || email.isEmpty) return '-';
    final parts = email.trim().split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) {
      return '${name[0]}*@$domain';
    }
    final firstChar = name[0];
    final lastChar = name[name.length - 1];
    return '$firstChar${'*' * (name.length - 2)}$lastChar@$domain';
  }
}
