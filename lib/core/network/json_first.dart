/// Fondasi JSON-first untuk endpoint legacy (SSOT:
/// `.artifacts/PANDUAN_ENDPOINT_FLUTTER.md` aturan emas 1–2).
/// Backend CI3 memakai content negotiation: header
/// `Accept: application/json` menjamin envelope JSON seragam alih-alih HTML.
/// Nol HTML parsing: respons non-JSON berarti gagal (null), bukan fallback
/// scrape. Galat definitif (`success:false`, `ret:fail`) tampil verbatim.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors/failures.dart';
import 'api_response.dart';
import 'dio_error_handler.dart';

/// Options per-request yang menimpa Accept default DioClient menjadi JSON murni.
Options jsonAcceptOptions([Options? base]) {
  final Map<String, dynamic> headers = <String, dynamic>{
    if (base?.headers != null) ...base!.headers!,
    'Accept': 'application/json',
  };
  return (base ?? Options()).copyWith(headers: headers);
}

/// True bila galat layak fallback ke jalur legacy (timeout, putus koneksi,
/// 5xx). Jawaban definitif server (4xx validasi, `success:false`) → false.
bool isTransportFailure(Object error) {
  if (error is DioException) {
    if (error.error is ApiException) return false;
    final Failure failure = DioErrorHandler.handle(error);
    return failure is NetworkFailure || failure is ServerMaintenanceFailure;
  }
  return false;
}

/// Mengurai body Dio menjadi peta JSON; null bila HTML/string non-JSON
/// sehingga pemanggil dapat jatuh ke scraper legacy.
Map<String, dynamic>? parseJsonMap(dynamic raw) {
  if (raw == null) return null;
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) {
    return raw.map((Object? k, Object? v) => MapEntry(k.toString(), v));
  }
  if (raw is String) {
    final String trimmed = raw.trimLeft();
    if (!trimmed.startsWith('{')) return null;
    try {
      final Object? decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((Object? k, Object? v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      return null;
    }
  }
  return null;
}

/// True bila peta adalah envelope seragam `{status, success, message, ...}`.
bool isEnvelopeMap(Map<String, dynamic> map) =>
    map['success'] is bool && map.containsKey('message');

/// Mengurai envelope: mengembalikan `data` (Map/List/null) atau melempar
/// [ApiException] verbatim bila `success:false`. Bukan envelope → null.
Object? unwrapEnvelopeData(Map<String, dynamic> map) {
  if (!isEnvelopeMap(map)) return null;
  final ApiEnvelope envelope = ApiEnvelope.fromJson(map);
  if (!envelope.success) {
    throw ApiException(
      envelope.message.isEmpty
          ? 'Permintaan gagal diproses.'
          : envelope.message,
      status: envelope.status,
      errors: envelope.errors,
    );
  }
  return envelope.data;
}

/// Normalisasi respons tulis legacy `{ret,msg}` maupun envelope menjadi
/// `{ret: success|fail, msg}` agar kontrak datasource lama tetap berlaku.
Map<String, dynamic> normalizeWriteResult(Map<String, dynamic> map) {
  if (isEnvelopeMap(map)) {
    final Object? data = unwrapEnvelopeData(map);
    final ApiEnvelope envelope = ApiEnvelope.fromJson(map);
    final Map<String, dynamic> out = <String, dynamic>{
      'ret': 'success',
      'msg': envelope.message,
    };
    if (data != null) out['data'] = data;
    return out;
  }
  if (map.containsKey('ret')) {
    final String ret = map['ret']?.toString() ?? 'fail';
    final String msg =
        map['msg']?.toString() ?? map['message']?.toString() ?? '';
    final Map<String, dynamic> out = <String, dynamic>{'ret': ret, 'msg': msg};
    if (map.containsKey('data')) out['data'] = map['data'];
    return out;
  }
  if (map['success'] is bool) {
    final bool ok = map['success'] as bool;
    final String msg = map['message']?.toString() ?? '';
    return <String, dynamic>{
      'ret': ok ? 'success' : 'fail',
      'msg': msg,
      'data': map,
    };
  }
  return map;
}

/// Melempar [ApiException] bila peta adalah jawaban definitif gagal
/// (`success:false` atau `ret:fail`); selain itu tidak melakukan apa-apa.
void throwIfDefinitiveFailure(Map<String, dynamic> map) {
  if (isEnvelopeMap(map)) {
    unwrapEnvelopeData(map);
    return;
  }
  if (map['ret']?.toString() == 'fail') {
    final String msg =
        map['msg']?.toString() ?? map['message']?.toString() ?? '';
    throw ApiException(msg.isEmpty ? 'Permintaan gagal diproses.' : msg);
  }
  if (map['success'] == false) {
    final String msg = map['message']?.toString() ?? '';
    throw ApiException(msg.isEmpty ? 'Permintaan gagal diproses.' : msg);
  }
}
