import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sijapin_mobile/core/storage/local_storage_service.dart';
import 'package:sijapin_mobile/core/storage/storage_constants.dart';

void main() {
  late Directory tempDir;
  late LocalStorageService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);
    service = LocalStorageService();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('LocalStorageService Hive Suite', () {
    test('openRequiredBoxes should open standard boxes successfully', () async {
      await service.openRequiredBoxes();

      expect(Hive.isBoxOpen(StorageConstants.ticketsBox), isTrue);
      expect(Hive.isBoxOpen(StorageConstants.masterCacheBox), isTrue);
      expect(Hive.isBoxOpen(StorageConstants.preferencesBox), isTrue);
    });

    test('put and get should store and retrieve data correctly', () async {
      await service.put<String>(
        boxName: StorageConstants.preferencesBox,
        key: 'app_language',
        value: 'id',
      );

      final result = service.get<String>(
        boxName: StorageConstants.preferencesBox,
        key: 'app_language',
      );

      expect(result, equals('id'));
    });

    test('get should return defaultValue when key does not exist', () {
      final result = service.get<String>(
        boxName: StorageConstants.preferencesBox,
        key: 'non_existent_key',
        defaultValue: 'default_val',
      );

      expect(result, equals('default_val'));
    });

    test('containsKey should return correct presence state', () async {
      await service.put<String>(
        boxName: StorageConstants.preferencesBox,
        key: 'active_user',
        value: 'user_123',
      );

      expect(
        service.containsKey(
          boxName: StorageConstants.preferencesBox,
          key: 'active_user',
        ),
        isTrue,
      );
      expect(
        service.containsKey(
          boxName: StorageConstants.preferencesBox,
          key: 'unknown_key',
        ),
        isFalse,
      );
    });

    test('delete should remove key from box', () async {
      await service.put<String>(
        boxName: StorageConstants.preferencesBox,
        key: 'temp_key',
        value: 'temp_val',
      );

      await service.delete(
        boxName: StorageConstants.preferencesBox,
        key: 'temp_key',
      );

      expect(
        service.get<String>(
          boxName: StorageConstants.preferencesBox,
          key: 'temp_key',
        ),
        isNull,
      );
    });

    test('clearBox should remove all entries in the box', () async {
      await service.put<String>(
        boxName: StorageConstants.masterCacheBox,
        key: 'poli_1',
        value: 'Penyakit Dalam',
      );
      await service.put<String>(
        boxName: StorageConstants.masterCacheBox,
        key: 'poli_2',
        value: 'Mata',
      );

      await service.clearBox(boxName: StorageConstants.masterCacheBox);

      final all = service.getAll<String>(
        boxName: StorageConstants.masterCacheBox,
      );
      expect(all, isEmpty);
    });
  });
}
