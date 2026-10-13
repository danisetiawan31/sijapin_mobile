import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.parseTanggalLahir (bentuk backend SIMRS)', () {
    test('DD-MM-YYYY backend (DATE_FORMAT M_customer) terurai', () {
      expect(
        DateFormatter.parseTanggalLahir('17-05-1990'),
        equals(DateTime(1990, 5, 17)),
      );
    });

    test('ISO-8601 tetap terurai', () {
      expect(
        DateFormatter.parseTanggalLahir('1990-05-17'),
        equals(DateTime(1990, 5, 17)),
      );
    });

    test('varian garis miring terurai', () {
      expect(
        DateFormatter.parseTanggalLahir('17/05/1990'),
        equals(DateTime(1990, 5, 17)),
      );
    });

    test('kosong dan sampah menjadi null (jujur kosong)', () {
      expect(DateFormatter.parseTanggalLahir(null), isNull);
      expect(DateFormatter.parseTanggalLahir(''), isNull);
      expect(DateFormatter.parseTanggalLahir('  '), isNull);
      expect(DateFormatter.parseTanggalLahir('belum diisi'), isNull);
      expect(DateFormatter.parseTanggalLahir('17-13-1990'), isNull);
    });

    test('DateTime diteruskan apa adanya', () {
      final date = DateTime(2000, 1, 2);
      expect(DateFormatter.parseTanggalLahir(date), same(date));
    });
  });
}
