import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/network/api_response.dart';

void main() {
  group('ApiEnvelope', () {
    test('parses full success envelope', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'status': 200,
        'success': true,
        'message': 'Autentikasi Bearer berhasil',
        'data': <String, dynamic>{'token': 'abc123'},
        'errors': null,
        'meta': <String, dynamic>{'version': '2.0'},
      };

      final ApiEnvelope envelope = ApiEnvelope.fromJson(json);

      expect(envelope.status, 200);
      expect(envelope.success, isTrue);
      expect(envelope.message, 'Autentikasi Bearer berhasil');
      expect(envelope.data, <String, dynamic>{'token': 'abc123'});
      expect(envelope.errors, isEmpty);
      expect(envelope.version, '2.0');
    });

    test('parses success:false with message and validation errors map', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'status': 422,
        'success': false,
        'message': 'Validasi gagal',
        'data': null,
        'errors': <String, dynamic>{
          'nomor_telepon': 'Nomor telepon wajib diisi',
          'kunci': 'Kunci minimal 8 karakter',
        },
        'meta': null,
      };

      final ApiEnvelope envelope = ApiEnvelope.fromJson(json);

      expect(envelope.success, isFalse);
      expect(envelope.message, 'Validasi gagal');
      expect(envelope.data, isNull);
      expect(envelope.errors, <String, String>{
        'nomor_telepon': 'Nomor telepon wajib diisi',
        'kunci': 'Kunci minimal 8 karakter',
      });
      expect(envelope.version, isEmpty);
    });

    test('tolerates missing keys and non-string scalars', () {
      final ApiEnvelope envelope = ApiEnvelope.fromJson(<String, dynamic>{});

      expect(envelope.status, 0);
      expect(envelope.success, isFalse);
      expect(envelope.message, isEmpty);
      expect(envelope.data, isNull);
      expect(envelope.errors, isEmpty);
      expect(envelope.version, isEmpty);
    });

    test('stringifies non-string error values', () {
      final Map<String, dynamic> json = <String, dynamic>{
        'status': 400,
        'success': false,
        'message': 'Buruk',
        'data': null,
        'errors': <String, dynamic>{'kode': 101, 'aktif': false},
        'meta': <String, dynamic>{},
      };

      final ApiEnvelope envelope = ApiEnvelope.fromJson(json);

      expect(envelope.errors, <String, String>{
        'kode': '101',
        'aktif': 'false',
      });
    });
  });

  group('ApiException', () {
    test('toString returns message verbatim', () {
      const ApiException exception = ApiException(
        'Nomor telepon atau kata sandi salah.',
        status: 401,
      );

      expect(exception.toString(), 'Nomor telepon atau kata sandi salah.');
      expect(exception.status, 401);
      expect(exception.errors, isEmpty);
    });
  });
}
