/// Envelope respons JSON seragam backend SIIJAPIN v2 (SSOT:
/// `.artifacts/PANDUAN_ENDPOINT_FLUTTER.md` §4).
/// Semua endpoint mobile merespons `{status, success, message, data,
/// errors, meta}` dengan `success:false` (HTTP 200) sebagai galat definitif.
class ApiEnvelope {
  final int status;
  final bool success;
  final String message;
  final Object? data;
  final Map<String, String> errors;
  final String version;

  const ApiEnvelope({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
    required this.errors,
    required this.version,
  });

  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    final Object? rawErrors = json['errors'];
    final Map<String, String> errors = <String, String>{};
    if (rawErrors is Map<Object?, Object?>) {
      for (final MapEntry<Object?, Object?> entry in rawErrors.entries) {
        errors[entry.key.toString()] = entry.value?.toString() ?? '';
      }
    }
    final Object? rawMeta = json['meta'];
    String version = '';
    if (rawMeta is Map<Object?, Object?>) {
      version = rawMeta['version']?.toString() ?? '';
    }
    return ApiEnvelope(
      status: (json['status'] as num?)?.toInt() ?? 0,
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'],
      errors: errors,
      version: version,
    );
  }
}

/// Galat definitif dari server REST (`success:false` + `message`).
/// Wajib diteruskan verbatim ke pengguna — tanpa fallback, tanpa retry.
class ApiException implements Exception {
  final String message;
  final int status;
  final Map<String, String> errors;

  const ApiException(
    this.message, {
    this.status = 0,
    this.errors = const <String, String>{},
  });

  @override
  String toString() => message;
}
