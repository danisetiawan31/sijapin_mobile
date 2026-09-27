import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'storage_constants.dart';

/// Kontrak abstraksi penyimpanan data lokal berkecepatan tinggi (Hive NoSQL)
abstract class ILocalStorage {
  Future<void> init();
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
  });
  T? get<T>({required String boxName, required String key, T? defaultValue});
  Future<void> delete({required String boxName, required String key});
  Future<void> clearBox({required String boxName});
  bool containsKey({required String boxName, required String key});
  List<T> getAll<T>({required String boxName});
}

/// Implementasi penyimpanan lokal menggunakan Hive CE
class LocalStorageService implements ILocalStorage {
  final Map<String, Box<dynamic>> _openBoxes = {};

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await openRequiredBoxes();
  }

  /// Membuka box inti aplikasi yang sering diakses
  Future<void> openRequiredBoxes() async {
    _openBoxes[StorageConstants.ticketsBox] = await _getBox(
      StorageConstants.ticketsBox,
    );
    _openBoxes[StorageConstants.masterCacheBox] = await _getBox(
      StorageConstants.masterCacheBox,
    );
    _openBoxes[StorageConstants.preferencesBox] = await _getBox(
      StorageConstants.preferencesBox,
    );
  }

  Future<Box<dynamic>> _getBox(String boxName) async {
    final openBox = _getOpenBox(boxName);
    if (openBox != null) {
      return openBox;
    }
    final box = await Hive.openBox<dynamic>(boxName);
    _openBoxes[boxName] = box;
    return box;
  }

  Box<dynamic>? _getOpenBox(String boxName) {
    if (_openBoxes.containsKey(boxName) && _openBoxes[boxName]!.isOpen) {
      return _openBoxes[boxName];
    }
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<dynamic>(boxName);
      _openBoxes[boxName] = box;
      return box;
    }
    return null;
  }

  @override
  Future<void> put<T>({
    required String boxName,
    required String key,
    required T value,
  }) async {
    final box = await _getBox(boxName);
    await box.put(key, value);
  }

  @override
  T? get<T>({required String boxName, required String key, T? defaultValue}) {
    final box = _getOpenBox(boxName);
    if (box == null) {
      return defaultValue;
    }
    final dynamic rawValue = box.get(key, defaultValue: defaultValue);
    if (rawValue is T) {
      return rawValue;
    }
    return defaultValue;
  }

  @override
  Future<void> delete({required String boxName, required String key}) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearBox({required String boxName}) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  @override
  bool containsKey({required String boxName, required String key}) {
    final box = _getOpenBox(boxName);
    if (box == null) {
      return false;
    }
    return box.containsKey(key);
  }

  @override
  List<T> getAll<T>({required String boxName}) {
    final box = _getOpenBox(boxName);
    if (box == null) {
      return <T>[];
    }
    return box.values.whereType<T>().toList();
  }
}

/// Provider Riverpod untuk LocalStorageService
final localStorageServiceProvider = Provider<ILocalStorage>((ref) {
  return LocalStorageService();
});
