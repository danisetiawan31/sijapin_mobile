import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sijapin_mobile/core/storage/secure_storage_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(mockStorage);
  });

  group('SecureStorageService Test Suite', () {
    const testKey = 'test_token';
    const testValue = 'ci_session_secure_value';

    test('write should call underlying storage write', () async {
      when(() => mockStorage.write(key: testKey, value: testValue))
          .thenAnswer((_) async {});

      await service.write(key: testKey, value: testValue);

      verify(() => mockStorage.write(key: testKey, value: testValue)).called(1);
    });

    test('read should return value from storage', () async {
      when(() => mockStorage.read(key: testKey))
          .thenAnswer((_) async => testValue);

      final result = await service.read(key: testKey);

      expect(result, equals(testValue));
      verify(() => mockStorage.read(key: testKey)).called(1);
    });

    test('delete should call underlying storage delete', () async {
      when(() => mockStorage.delete(key: testKey)).thenAnswer((_) async {});

      await service.delete(key: testKey);

      verify(() => mockStorage.delete(key: testKey)).called(1);
    });

    test('deleteAll should call underlying storage deleteAll', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

      await service.deleteAll();

      verify(() => mockStorage.deleteAll()).called(1);
    });

    test('containsKey should return true when key exists', () async {
      when(() => mockStorage.containsKey(key: testKey))
          .thenAnswer((_) async => true);

      final exists = await service.containsKey(key: testKey);

      expect(exists, isTrue);
      verify(() => mockStorage.containsKey(key: testKey)).called(1);
    });
  });
}
