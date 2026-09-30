import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijapin_mobile/core/constants/api_constants.dart';
import 'package:sijapin_mobile/core/network/dio_client.dart';
import 'package:sijapin_mobile/core/storage/local_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';
import 'package:sijapin_mobile/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:sijapin_mobile/features/profile/data/repositories/family_member_repository_impl.dart';
import 'package:sijapin_mobile/features/profile/domain/entities/family_member.dart';

class MockLocalStorage implements ILocalStorage {
  final Map<String, Map<String, dynamic>> storage = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {
    storage.putIfAbsent(boxName, () => {})[key] = value;
  }

  @override
  T? get<T>({required String boxName, required String key, T? defaultValue}) {
    return (storage[boxName]?[key] as T?) ?? defaultValue;
  }

  @override
  Future<void> delete({required String boxName, required String key}) async {
    storage[boxName]?.remove(key);
  }

  @override
  Future<void> clearBox({required String boxName}) async {
    storage[boxName]?.clear();
  }

  @override
  bool containsKey({required String boxName, required String key}) {
    return storage[boxName]?.containsKey(key) ?? false;
  }

  @override
  List<T> getAll<T>({required String boxName}) {
    return storage[boxName]?.values.whereType<T>().toList() ?? <T>[];
  }
}

class MockProfileRemoteDataSource implements IProfileRemoteDataSource {
  List<FamilyMember>? mockFetchResult;

  @override
  Future<List<FamilyMember>?> fetchFamilyMembers() async => mockFetchResult;

  @override
  Future<Map<String, dynamic>> saveFamilyMember(
    FamilyMember member, {
    bool isUpdate = false,
  }) async =>
      {'ret': 'success'};

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String customerId,
    required String fullName,
    required String phoneNumber,
    required String email,
    DateTime? birthDate,
    String? gender,
    String? password,
  }) async =>
      {'ret': 'success'};
}

class MockDioClient implements DioClient {
  String? lastPath;
  dynamic lastData;
  dynamic nextResponseData;
  bool shouldThrow = false;

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastPath = path;
    lastData = data;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Network failure',
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: nextResponseData as T?,
      statusCode: 200,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    lastPath = path;
    if (shouldThrow) {
      throw DioException(
        requestOptions: RequestOptions(path: path),
        error: 'Network failure',
      );
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      data: nextResponseData as T?,
      statusCode: 200,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ProfileRemoteDataSource Tests', () {
    late MockDioClient mockDioClient;
    late ProfileRemoteDataSource dataSource;

    setUp(() {
      mockDioClient = MockDioClient();
      dataSource = ProfileRemoteDataSource(dioClient: mockDioClient);
    });

    test('saveFamilyMember mengirim FormData lengkap ke CI3 input_pasien', () async {
      mockDioClient.nextResponseData = {
        'ret': 'success',
        'msg': '',
      };

      final member = FamilyMember(
        id: 'mem-99',
        fullName: 'Siti Rahma',
        relation: FamilyRelation.child,
        nik: '3671045508940003',
        phone: '081299887766',
        gender: 'P',
        insurance: FamilyInsurance.bpjs,
        birthDate: DateTime(2015, 6, 15),
        birthPlace: 'Tangerang',
        motherName: 'Rina Puspita',
        address: 'Jl. Daan Mogot KM 20',
        religion: '1',
        occupation: 'Pelajar',
        medicalRecordNumber: '00112233',
      );

      final result = await dataSource.saveFamilyMember(member, isUpdate: false);

      expect(mockDioClient.lastPath, equals(ApiConstants.inputPasien));
      expect(result['ret'], equals('success'));
      expect(mockDioClient.lastData, isA<FormData>());
      final formData = mockDioClient.lastData as FormData;
      final map = Map.fromEntries(formData.fields);
      expect(map['nama_pasien'], equals('Siti Rahma'));
      expect(map['rd_nomr'], equals('1'));
      expect(map['nomr'], equals('00112233'));
      expect(map['tmp_lahir'], equals('Tangerang'));
      expect(map['tgl_lahir'], equals('15'));
      expect(map['bln_lahir'], equals('06'));
      expect(map['thn_lahir'], equals('2015'));
      expect(map['agama'], equals('1'));
      expect(map['jns_kelamin'], equals('P'));
      expect(map['nama_ibu'], equals('Rina Puspita'));
      expect(map['nik'], equals('3671045508940003'));
      expect(map['alamat'], equals('Jl. Daan Mogot KM 20'));
      expect(map['pekerjaan'], equals('Pelajar'));
      expect(map['id_member'], equals(''));
    });

    test('saveFamilyMember mengirim id_member ketika isUpdate = true', () async {
      mockDioClient.nextResponseData = {'ret': 'success', 'msg': ''};

      const member = FamilyMember(
        id: 'mem-77',
        fullName: 'Budi Santoso',
        relation: FamilyRelation.spouse,
        nik: '3671040101900001',
        phone: '08123456789',
        gender: 'L',
        insurance: FamilyInsurance.umum,
        medicalRecordNumber: '',
      );

      await dataSource.saveFamilyMember(member, isUpdate: true);

      final formData = mockDioClient.lastData as FormData;
      final map = Map.fromEntries(formData.fields);
      expect(map['id_member'], equals('mem-77'));
      expect(map['rd_nomr'], equals('3'));
    });

    test('updateProfile mengirim data profil ke Profile/simpan_akun_pr', () async {
      mockDioClient.nextResponseData = {'ret': 'success', 'msg': 'Profil tersimpan'};

      final result = await dataSource.updateProfile(
        customerId: 'cust-123',
        fullName: 'Rina Puspita Sari',
        phoneNumber: '081234567890',
        email: 'rina@example.com',
        birthDate: DateTime(1994, 8, 20),
        gender: 'P',
      );

      expect(mockDioClient.lastPath, equals(ApiConstants.updateProfile));
      expect(result['ret'], equals('success'));
      final formData = mockDioClient.lastData as FormData;
      final map = Map.fromEntries(formData.fields);
      expect(map['id_customer'], equals('cust-123'));
      expect(map['nomor_telepon'], equals('081234567890'));
      expect(map['nama'], equals('Rina Puspita Sari'));
      expect(map['tgl_lahir'], equals('20'));
      expect(map['bln_lahir'], equals('08'));
      expect(map['thn_lahir'], equals('1994'));
      expect(map['jns_kelamin'], equals('P'));
    });

    test('fetchFamilyMembers mem-parsing kartu HTML dari backend CI3', () async {
      const sampleHtml = '''
      <html>
        <body>
          <div class="row">
            <a class="btn" href="https://rsup-drsitanala.net/siijapin-v2/pasien/form_data/101">
              <div class="card pasien-log-card">
                <div class="card-body">
                  <h5 class="card-title">Ahmad Fauzi Rahman</h5>
                </div>
              </div>
            </a>
            <a class="btn" href="https://rsup-drsitanala.net/siijapin-v2/pasien/form_data/102">
              <div class="card pasien-log-card">
                <div class="card-body">
                  <h5 class="card-title">Nadira Aulia Putri</h5>
                </div>
              </div>
            </a>
          </div>
        </body>
      </html>
      ''';

      mockDioClient.nextResponseData = sampleHtml;

      final members = await dataSource.fetchFamilyMembers();

      expect(members, isNotNull);
      expect(members!.length, equals(2));
      expect(members[0].id, equals('101'));
      expect(members[0].fullName, equals('Ahmad Fauzi Rahman'));
      expect(members[1].id, equals('102'));
      expect(members[1].fullName, equals('Nadira Aulia Putri'));
    });
  });

  group('FamilyMemberRepositoryImpl with Remote Data Source Tests', () {
    late MockDioClient mockDioClient;
    late ProfileRemoteDataSource remoteDataSource;
    late FamilyMemberRepositoryImpl repository;

    setUp(() {
      mockDioClient = MockDioClient();
      remoteDataSource = ProfileRemoteDataSource(dioClient: mockDioClient);
      repository = FamilyMemberRepositoryImpl(
        remoteDataSource: remoteDataSource,
        initialMembers: [],
      );
    });

    test('addFamilyMember menyimpan lokal dan memanggil remote tanpa crash saat gagal', () async {
      mockDioClient.shouldThrow = true;

      const member = FamilyMember(
        id: 'offline-01',
        fullName: 'Pasien Darurat',
        relation: FamilyRelation.child,
        nik: '1234567890123456',
        phone: '08123456789',
        gender: 'L',
        insurance: FamilyInsurance.umum,
      );

      final saved = await repository.addFamilyMember(member);

      expect(saved.fullName, equals('Pasien Darurat'));
      expect(repository.getCachedFamilyMembers().length, equals(1));
    });

    test('updateFamilyMember memperbarui state lokal dan remote', () async {
      mockDioClient.nextResponseData = {'ret': 'success'};

      const member = FamilyMember(
        id: 'mem-01',
        fullName: 'Nama Awal',
        relation: FamilyRelation.child,
        nik: '1234567890123456',
        phone: '08123456789',
        gender: 'L',
        insurance: FamilyInsurance.umum,
      );
      await repository.addFamilyMember(member);

      final updated = member.copyWith(fullName: 'Nama Diperbarui');
      await repository.updateFamilyMember(updated);

      expect(repository.getCachedFamilyMembers().first.fullName, equals('Nama Diperbarui'));
    });

    test('addFamilyMember menyimpan ke Hive LocalStorage untuk mode offline', () async {
      final mockLocalStorage = MockLocalStorage();
      final repoWithStorage = FamilyMemberRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localStorage: mockLocalStorage,
        initialMembers: [],
      );

      const member = FamilyMember(
        id: 'hive-01',
        fullName: 'Dewi Lestari',
        relation: FamilyRelation.spouse,
        nik: '3671040101900005',
        phone: '081233445566',
        gender: 'P',
        insurance: FamilyInsurance.bpjs,
      );

      await repoWithStorage.addFamilyMember(member);

      expect(
        mockLocalStorage.containsKey(
          boxName: StorageConstants.familyMembersBox,
          key: 'hive-01',
        ),
        isTrue,
      );
    });

    test('getFamilyMembers memuat anggota dari Hive LocalStorage', () async {
      final mockLocalStorage = MockLocalStorage();
      const member = FamilyMember(
        id: 'hive-02',
        fullName: 'Bayu Pratama',
        relation: FamilyRelation.child,
        nik: '3671040101900006',
        phone: '081233445577',
        gender: 'L',
        insurance: FamilyInsurance.umum,
      );
      await mockLocalStorage.put(
        boxName: StorageConstants.familyMembersBox,
        key: 'hive-02',
        value: member.toMap(),
      );

      final repoWithStorage = FamilyMemberRepositoryImpl(
        remoteDataSource: null,
        localStorage: mockLocalStorage,
        initialMembers: [],
      );

      final members = await repoWithStorage.getFamilyMembers();
      expect(
        members.any((m) => m.id == 'hive-02' && m.fullName == 'Bayu Pratama'),
        isTrue,
      );
    });

    test('getFamilyMembers mempertahankan atribut lokal saat merge dari scrape HTML remote', () async {
      final mockLocalStorage = MockLocalStorage();
      final mockRemote = MockProfileRemoteDataSource();
      // Remote hanya memiliki nama dan ID (hasil parse kartu HTML /pasien)
      mockRemote.mockFetchResult = [
        const FamilyMember(
          id: 'mem-rich',
          fullName: 'Nama dari Server CI3',
          relation: FamilyRelation.child,
          nik: '',
          gender: 'L',
          insurance: FamilyInsurance.umum,
        ),
      ];

      // Lokal memiliki data lengkap (NIK, alamat, ibu kandung, tanggal lahir)
      final richLocalMember = FamilyMember(
        id: 'mem-rich',
        fullName: 'Nama Lama Lokal',
        relation: FamilyRelation.child,
        nik: '3671040101900099',
        gender: 'P',
        insurance: FamilyInsurance.bpjs,
        birthDate: DateTime(1998, 4, 12),
        birthPlace: 'Tangerang',
        motherName: 'Ibu Maryam',
        address: 'Jl. Daan Mogot No 10',
        phone: '081299887766',
        religion: '1',
      );

      final repo = FamilyMemberRepositoryImpl(
        remoteDataSource: mockRemote,
        localStorage: mockLocalStorage,
        initialMembers: [richLocalMember],
      );

      final result = await repo.getFamilyMembers();
      final merged = result.firstWhere((m) => m.id == 'mem-rich');

      // Nama diupdate dari server
      expect(merged.fullName, equals('Nama dari Server CI3'));
      // Atribut penting lokal tetap aman tidak terhapus menjadi string kosong
      expect(merged.nik, equals('3671040101900099'));
      expect(merged.birthPlace, equals('Tangerang'));
      expect(merged.motherName, equals('Ibu Maryam'));
      expect(merged.address, equals('Jl. Daan Mogot No 10'));
      expect(merged.phone, equals('081299887766'));
      expect(merged.birthDate, equals(DateTime(1998, 4, 12)));
    });

    test('addFamilyMember merekonsiliasi ID lokal menjadi ID server MySQL pasca simpan sukses', () async {
      final mockLocalStorage = MockLocalStorage();
      final mockRemote = MockProfileRemoteDataSource();
      // Server CI3 akan mengembalikan ID asli MySQL (misal: '888')
      mockRemote.mockFetchResult = [
        const FamilyMember(
          id: '888',
          fullName: 'Aisyah Putri',
          relation: FamilyRelation.child,
          nik: '3671040101900888',
          gender: 'P',
          insurance: FamilyInsurance.umum,
        ),
      ];

      final repo = FamilyMemberRepositoryImpl(
        remoteDataSource: mockRemote,
        localStorage: mockLocalStorage,
        initialMembers: [],
      );

      const localMember = FamilyMember(
        id: 'temp-local-01',
        fullName: 'Aisyah Putri',
        relation: FamilyRelation.child,
        nik: '3671040101900888',
        gender: 'P',
        insurance: FamilyInsurance.umum,
      );

      final saved = await repo.addFamilyMember(localMember);

      // ID berhasil direkonsiliasi ke ID server MySQL
      expect(saved.id, equals('888'));
      expect(
        mockLocalStorage.containsKey(
          boxName: StorageConstants.familyMembersBox,
          key: '888',
        ),
        isTrue,
      );
      expect(
        mockLocalStorage.containsKey(
          boxName: StorageConstants.familyMembersBox,
          key: 'temp-local-01',
        ),
        isFalse,
      );
    });

    test('deleteFamilyMember menyembunyikan anggota sehingga tidak dibangkitkan ulang oleh server', () async {
      final mockLocalStorage = MockLocalStorage();
      final mockRemote = MockProfileRemoteDataSource();
      // Server CI3 tetap memiliki pasien ini di database rekam medis
      mockRemote.mockFetchResult = [
        const FamilyMember(
          id: 'server-01',
          fullName: 'Pasien Dihapus di HP',
          relation: FamilyRelation.child,
          nik: '3671040101900111',
          gender: 'L',
          insurance: FamilyInsurance.umum,
        ),
      ];

      const initialMember = FamilyMember(
        id: 'server-01',
        fullName: 'Pasien Dihapus di HP',
        relation: FamilyRelation.child,
        nik: '3671040101900111',
        gender: 'L',
        insurance: FamilyInsurance.umum,
      );

      final repo = FamilyMemberRepositoryImpl(
        remoteDataSource: mockRemote,
        localStorage: mockLocalStorage,
        initialMembers: [initialMember],
      );

      // Pengguna menghapus anggota dari HP
      final deleted = await repo.deleteFamilyMember('server-01');
      expect(deleted, isTrue);

      // Saat refresh dari server dilakukan, anggota yang dihapus tidak bangkit kembali
      final members = await repo.getFamilyMembers();
      expect(members.any((m) => m.id == 'server-01'), isFalse);
    });
  });
}
