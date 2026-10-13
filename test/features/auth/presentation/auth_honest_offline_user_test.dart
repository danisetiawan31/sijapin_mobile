import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/auth/presentation/controllers/auth_controller.dart';

void main() {
  group('AuthController.honestOfflineUser (tanpa data karangan)', () {
    test('login email: telepon kosong, email terisi', () {
      final user = AuthController.honestOfflineUser('pasien@domain.com');
      expect(user.fullName, isEmpty);
      expect(user.phone, isEmpty);
      expect(user.email, equals('pasien@domain.com'));
      expect(user.birthDate, isNull);
    });

    test('login nomor HP: email kosong, telepon terisi', () {
      final user = AuthController.honestOfflineUser('081234567890');
      expect(user.fullName, isEmpty);
      expect(user.phone, equals('081234567890'));
      expect(user.email, isEmpty);
    });

    test('tidak pernah bernama samaran', () {
      expect(
        AuthController.honestOfflineUser('081234567890').fullName,
        isNot('Pasien Terdaftar'),
      );
    });
  });
}
