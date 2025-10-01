import 'package:core/core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementação de IAppDataCleaner para app-petiveti
/// Gerencia limpeza de pets, reminders, schedules, health_records e cache local
@LazySingleton(as: IAppDataCleaner)
class PetivetiDataCleaner implements IAppDataCleaner {
  final HiveInterface _hive;
  final SharedPreferences _prefs;

  PetivetiDataCleaner({
    required HiveInterface hive,
    required SharedPreferences prefs,
  })  : _hive = hive,
        _prefs = prefs;

  @override
  String get appName => 'Petiveti';

  @override
  String get version => '1.0.0';

  @override
  String get description =>
      'Limpeza de pets, lembretes, agendamentos, registros de saúde e dados locais do Petiveti';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    final result = <String, dynamic>{
      'success': true,
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'totalRecordsCleared': 0,
      'errors': <String>[],
    };

    try {
      // Obter estatísticas antes da limpeza
      final statsBefore = await getDataStatsBeforeCleaning();

      // 1. Limpar Hive boxes
      final boxNames = [
        'pets',
        'pet_box',
        'reminders',
        'schedules',
        'health_records',
        'settings',
        'pet_cache',
      ];

      for (final boxName in boxNames) {
        try {
          if (await _hive.boxExists(boxName)) {
            await _hive.deleteBoxFromDisk(boxName);
            (result['clearedBoxes'] as List).add(boxName);
          }
        } catch (e) {
          (result['errors'] as List).add('Failed to clear $boxName: $e');
          result['success'] = false;
        }
      }

      // 2. Limpar SharedPreferences (apenas chaves do app)
      final prefsKeys = _prefs.getKeys();
      final appSpecificKeys = prefsKeys.where((key) =>
          key.startsWith('petiveti_') ||
          key.startsWith('pet_') ||
          key.startsWith('reminder_'));

      for (final key in appSpecificKeys) {
        try {
          await _prefs.remove(key);
          (result['clearedPreferences'] as List).add(key);
        } catch (e) {
          (result['errors'] as List).add('Failed to clear preference $key: $e');
        }
      }

      result['totalRecordsCleared'] =
          (result['clearedBoxes'] as List).length +
              (result['clearedPreferences'] as List).length;

      result['statsBefore'] = statsBefore;
    } catch (e) {
      result['success'] = false;
      (result['errors'] as List).add('Unexpected error: $e');
    }

    return result;
  }

  @override
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    final stats = <String, dynamic>{
      'totalPets': 0,
      'totalReminders': 0,
      'totalSchedules': 0,
      'totalHealthRecords': 0,
      'totalPreferences': 0,
      'totalRecords': 0,
    };

    try {
      // Contar pets
      if (await _hive.boxExists('pets') || await _hive.boxExists('pet_box')) {
        try {
          final petsBox = await _hive.openBox('pets');
          stats['totalPets'] = petsBox.length;
          await petsBox.close();
        } catch (e) {
          try {
            final petsBox = await _hive.openBox('pet_box');
            stats['totalPets'] = petsBox.length;
            await petsBox.close();
          } catch (_) {
            // Ignore
          }
        }
      }

      // Contar reminders
      if (await _hive.boxExists('reminders')) {
        try {
          final remindersBox = await _hive.openBox('reminders');
          stats['totalReminders'] = remindersBox.length;
          await remindersBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar schedules
      if (await _hive.boxExists('schedules')) {
        try {
          final schedulesBox = await _hive.openBox('schedules');
          stats['totalSchedules'] = schedulesBox.length;
          await schedulesBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar health_records
      if (await _hive.boxExists('health_records')) {
        try {
          final healthRecordsBox = await _hive.openBox('health_records');
          stats['totalHealthRecords'] = healthRecordsBox.length;
          await healthRecordsBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar preferences
      final prefsKeys = _prefs.getKeys();
      stats['totalPreferences'] = prefsKeys
          .where((key) =>
              key.startsWith('petiveti_') || key.startsWith('pet_'))
          .length;

      stats['totalRecords'] = (stats['totalPets'] as int) +
          (stats['totalReminders'] as int) +
          (stats['totalSchedules'] as int) +
          (stats['totalHealthRecords'] as int) +
          (stats['totalPreferences'] as int);
    } catch (e) {
      stats['error'] = e.toString();
    }

    return stats;
  }

  @override
  Future<bool> verifyDataCleanup() async {
    try {
      // Verificar se boxes foram deletadas
      final boxNames = ['pets', 'pet_box', 'reminders', 'schedules', 'health_records'];
      for (final boxName in boxNames) {
        if (await _hive.boxExists(boxName)) {
          return false;
        }
      }

      // Verificar se preferences foram limpas
      final prefsKeys = _prefs.getKeys();
      final remainingAppKeys = prefsKeys.where(
        (key) => key.startsWith('petiveti_') || key.startsWith('pet_'),
      );

      return remainingAppKeys.isEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasDataToClear() async {
    try {
      // Verificar se existe alguma box
      final boxNames = ['pets', 'pet_box', 'reminders', 'schedules', 'health_records'];
      for (final boxName in boxNames) {
        if (await _hive.boxExists(boxName)) {
          return true;
        }
      }

      // Verificar se existem preferences
      final prefsKeys = _prefs.getKeys();
      final hasPrefs = prefsKeys.any(
        (key) => key.startsWith('petiveti_') || key.startsWith('pet_'),
      );

      return hasPrefs;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getAvailableCategories() {
    return [
      'Pets',
      'Reminders',
      'Schedules',
      'HealthRecords',
      'Settings',
      'Cache',
      'Preferences',
    ];
  }

  @override
  Future<Map<String, dynamic>> clearCategoryData(String category) async {
    final result = <String, dynamic>{
      'success': true,
      'category': category,
      'clearedItems': <String>[],
      'errors': <String>[],
    };

    try {
      switch (category.toLowerCase()) {
        case 'pets':
          await _clearBoxes(['pets', 'pet_box'], result);
          break;
        case 'reminders':
          await _clearBoxes(['reminders'], result);
          break;
        case 'schedules':
          await _clearBoxes(['schedules'], result);
          break;
        case 'healthrecords':
          await _clearBoxes(['health_records'], result);
          break;
        case 'settings':
          await _clearBoxes(['settings'], result);
          break;
        case 'cache':
          await _clearBoxes(['pet_cache'], result);
          break;
        case 'preferences':
          await _clearPetPreferences(result);
          break;
        default:
          result['success'] = false;
          (result['errors'] as List).add('Unknown category: $category');
      }
    } catch (e) {
      result['success'] = false;
      (result['errors'] as List).add('Error clearing category: $e');
    }

    return result;
  }

  Future<void> _clearBoxes(
    List<String> boxNames,
    Map<String, dynamic> result,
  ) async {
    for (final boxName in boxNames) {
      try {
        if (await _hive.boxExists(boxName)) {
          await _hive.deleteBoxFromDisk(boxName);
          (result['clearedItems'] as List).add(boxName);
        }
      } catch (e) {
        (result['errors'] as List).add('Failed to clear $boxName: $e');
        result['success'] = false;
      }
    }
  }

  Future<void> _clearPetPreferences(Map<String, dynamic> result) async {
    final prefsKeys = _prefs.getKeys();
    final appKeys = prefsKeys.where(
      (key) => key.startsWith('petiveti_') || key.startsWith('pet_'),
    );

    for (final key in appKeys) {
      try {
        await _prefs.remove(key);
        (result['clearedItems'] as List).add(key);
      } catch (e) {
        (result['errors'] as List).add('Failed to clear preference $key: $e');
      }
    }
  }
}
