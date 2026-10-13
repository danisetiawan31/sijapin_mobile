import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/features/profile/data/datasources/profile_remote_data_source.dart';

void main() {
  group('ProfileRemoteDataSource.userFromRestMap (bentuk backend nyata)', () {
    test('peta api/v1/profile: nama, telepon, lahir DD-MM-YYYY', () {
      final user = ProfileRemoteDataSource.userFromRestMap(<String, dynamic>{
        'id_customer': 163958,
        'nama': 'Ahmad Dani',
        'nomor_telepon': '0812000000',
        'email': 'ahmad@example.com',
        'tanggal_lahir': '17-05-1990',
        'jenis_kelamin': 'L',
        'alamat': 'Tangerang',
      });
      expect(user, isNotNull);
      expect(user!.fullName, equals('Ahmad Dani'));
      expect(user.phone, equals('0812000000'));
      expect(user.birthDate, equals(DateTime(1990, 5, 17)));
      expect(user.customerId, equals('163958'));
    });

    test('peta GET /Profile tersarang di kunci profil terurai', () {
      final user = ProfileRemoteDataSource.userFromRestMap(<String, dynamic>{
        'profil': <String, dynamic>{
          'id_customer': 44,
          'nama': 'Siti Rahma',
          'nomor_telepon': '081299887766',
          'email': '',
          'tanggal_lahir': '05-08-1988',
          'tgl_lahir': '05',
          'bln_lahir': '08',
          'thn_lahir': '1988',
          'jenis_kelamin': 'P',
          'alamat': '',
        },
      });
      expect(user, isNotNull);
      expect(user!.fullName, equals('Siti Rahma'));
      expect(user.birthDate, equals(DateTime(1988, 8, 5)));
      expect(user.gender, equals('P'));
    });

    test('komponen tgl/bln/thn merakit lahir bila format kosong', () {
      final user = ProfileRemoteDataSource.userFromRestMap(<String, dynamic>{
        'nama': 'Budi Santoso',
        'nomor_telepon': '08123456789',
        'tanggal_lahir': '',
        'tgl_lahir': '3',
        'bln_lahir': '4',
        'thn_lahir': '2001',
      });
      expect(user?.birthDate, equals(DateTime(2001, 4, 3)));
    });

    test('payload hampa (nama+telepon kosong) menjadi null', () {
      expect(
        ProfileRemoteDataSource.userFromRestMap(<String, dynamic>{
          'nama': '',
          'nomor_telepon': '',
        }),
        isNull,
      );
    });

    test('nama kosong + telepon ada: jujur kosong, tanpa nama samaran', () {
      final user = ProfileRemoteDataSource.userFromRestMap(<String, dynamic>{
        'nama': '',
        'nomor_telepon': '0812000000',
      });
      expect(user, isNotNull);
      expect(user!.fullName, isEmpty);
      expect(user.phone, equals('0812000000'));
    });
  });
}
