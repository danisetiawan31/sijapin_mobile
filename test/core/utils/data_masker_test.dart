import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/utils/data_masker.dart';

void main() {
  group('DataMasker Tests (UU PDP No. 27/2022 Compliance)', () {
    test('maskNik masks 16-digit NIK showing first 6 and last 4 digits', () {
      expect(
        DataMasker.maskNik('3671041234560002'),
        equals('367104******0002'),
      );
    });

    test('maskNik handles null, empty, or short strings gracefully', () {
      expect(DataMasker.maskNik(null), equals('-'));
      expect(DataMasker.maskNik(''), equals('-'));
      expect(DataMasker.maskNik('12345'), equals('*****'));
    });

    test(
      'maskBpjs masks 13-digit BPJS card showing first 6 and last 3 digits',
      () {
        expect(DataMasker.maskBpjs('0001234567789'), equals('000123****789'));
      },
    );

    test('maskBpjs handles null, empty, or short strings gracefully', () {
      expect(DataMasker.maskBpjs(null), equals('-'));
      expect(DataMasker.maskBpjs(''), equals('-'));
      expect(DataMasker.maskBpjs('1234'), equals('****'));
    });

    test('maskPhone masks phone number showing first 4 and last 4 digits', () {
      expect(DataMasker.maskPhone('081234568901'), equals('0812****8901'));
      expect(
        DataMasker.maskPhone('081234567890123'),
        equals('0812*******0123'),
      );
    });

    test('maskPhone handles null, empty, or short strings gracefully', () {
      expect(DataMasker.maskPhone(null), equals('-'));
      expect(DataMasker.maskPhone(''), equals('-'));
      expect(DataMasker.maskPhone('08123'), equals('*****'));
    });

    test('maskEmail masks middle letters of email username', () {
      expect(
        DataMasker.maskEmail('pasien@sitanala.go.id'),
        equals('p****n@sitanala.go.id'),
      );
      expect(
        DataMasker.maskEmail('ab@sitanala.go.id'),
        equals('a*@sitanala.go.id'),
      );
      expect(DataMasker.maskEmail(null), equals('-'));
      expect(DataMasker.maskEmail('invalidemail'), equals('***'));
    });
  });
}
