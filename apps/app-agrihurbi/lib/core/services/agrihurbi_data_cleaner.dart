import 'package:core/core.dart';

/// Implementação de IAppDataCleaner para app-agrihurbi
/// Gerencia limpeza de farms, fields, crops, activities, harvests e cache local
@LazySingleton(as: IAppDataCleaner)
class AgrihurbiDataCleaner implements IAppDataCleaner {
  final HiveInterface _hive;
  final SharedPreferences _prefs;

  AgrihurbiDataCleaner({
    required HiveInterface hive,
    required SharedPreferences prefs,
  }) : _hive = hive,
       _prefs = prefs;

  @override
  String get appName => 'Agrihurbi';

  @override
  String get version => '1.0.0';

  @override
  String get description =>
      'Limpeza de fazendas, campos, culturas, atividades, colheitas e dados locais do Agrihurbi';

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
        'farms',
        'fields',
        'crops',
        'activities',
        'harvests',
        'settings',
        'farm_cache',
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
      final appSpecificKeys = prefsKeys.where(
        (key) =>
            key.startsWith('agrihurbi_') ||
            key.startsWith('farm_') ||
            key.startsWith('crop_') ||
            key.startsWith('field_'),
      );

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
      'totalFarms': 0,
      'totalFields': 0,
      'totalCrops': 0,
      'totalActivities': 0,
      'totalHarvests': 0,
      'totalPreferences': 0,
      'totalRecords': 0,
    };

    try {
      // Contar farms
      if (await _hive.boxExists('farms')) {
        try {
          final farmsBox = await _hive.openBox<dynamic>('farms');
          stats['totalFarms'] = farmsBox.length;
          await farmsBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar fields
      if (await _hive.boxExists('fields')) {
        try {
          final fieldsBox = await _hive.openBox<dynamic>('fields');
          stats['totalFields'] = fieldsBox.length;
          await fieldsBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar crops
      if (await _hive.boxExists('crops')) {
        try {
          final cropsBox = await _hive.openBox<dynamic>('crops');
          stats['totalCrops'] = cropsBox.length;
          await cropsBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar activities
      if (await _hive.boxExists('activities')) {
        try {
          final activitiesBox = await _hive.openBox<dynamic>('activities');
          stats['totalActivities'] = activitiesBox.length;
          await activitiesBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar harvests
      if (await _hive.boxExists('harvests')) {
        try {
          final harvestsBox = await _hive.openBox<dynamic>('harvests');
          stats['totalHarvests'] = harvestsBox.length;
          await harvestsBox.close();
        } catch (_) {
          // Ignore
        }
      }

      // Contar preferences
      final prefsKeys = _prefs.getKeys();
      stats['totalPreferences'] =
          prefsKeys
              .where(
                (key) =>
                    key.startsWith('agrihurbi_') || key.startsWith('farm_'),
              )
              .length;

      stats['totalRecords'] =
          (stats['totalFarms'] as int) +
          (stats['totalFields'] as int) +
          (stats['totalCrops'] as int) +
          (stats['totalActivities'] as int) +
          (stats['totalHarvests'] as int) +
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
      final boxNames = ['farms', 'fields', 'crops', 'activities', 'harvests'];
      for (final boxName in boxNames) {
        if (await _hive.boxExists(boxName)) {
          return false;
        }
      }

      // Verificar se preferences foram limpas
      final prefsKeys = _prefs.getKeys();
      final remainingAppKeys = prefsKeys.where(
        (key) => key.startsWith('agrihurbi_') || key.startsWith('farm_'),
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
      final boxNames = ['farms', 'fields', 'crops', 'activities', 'harvests'];
      for (final boxName in boxNames) {
        if (await _hive.boxExists(boxName)) {
          return true;
        }
      }

      // Verificar se existem preferences
      final prefsKeys = _prefs.getKeys();
      final hasPrefs = prefsKeys.any(
        (key) => key.startsWith('agrihurbi_') || key.startsWith('farm_'),
      );

      return hasPrefs;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getAvailableCategories() {
    return [
      'Farms',
      'Fields',
      'Crops',
      'Activities',
      'Harvests',
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
        case 'farms':
          await _clearBoxes(['farms'], result);
          break;
        case 'fields':
          await _clearBoxes(['fields'], result);
          break;
        case 'crops':
          await _clearBoxes(['crops'], result);
          break;
        case 'activities':
          await _clearBoxes(['activities'], result);
          break;
        case 'harvests':
          await _clearBoxes(['harvests'], result);
          break;
        case 'settings':
          await _clearBoxes(['settings'], result);
          break;
        case 'cache':
          await _clearBoxes(['farm_cache'], result);
          break;
        case 'preferences':
          await _clearFarmPreferences(result);
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

  Future<void> _clearFarmPreferences(Map<String, dynamic> result) async {
    final prefsKeys = _prefs.getKeys();
    final appKeys = prefsKeys.where(
      (key) => key.startsWith('agrihurbi_') || key.startsWith('farm_'),
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
