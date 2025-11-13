import 'package:core/core.dart';

/// Implementação de IAppDataCleaner para app-agrihurbi
/// Gerencia limpeza de farms, fields, crops, activities, harvests e cache local
@LazySingleton(as: IAppDataCleaner)
class AgrihurbiDataCleaner implements IAppDataCleaner {
  final IDriftManager _driftManager;
  final SharedPreferences _prefs;

  AgrihurbiDataCleaner({
    required IDriftManager driftManager,
    required SharedPreferences prefs,
  }) : _driftManager = driftManager,
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
      // Clear all Drift databases
      final clearResult = await _driftManager.clearAllData();
      if (clearResult.isFailure) {
        result['success'] = false;
        (result['errors'] as List).add('Failed to clear Drift data: ${clearResult.error}');
      } else {
        (result['clearedBoxes'] as List).addAll(['drift_databases']);
      }

      // Clear SharedPreferences
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
      // For now, we only track SharedPreferences since we're migrating to Drift
      // Drift data stats would require database queries which are app-specific
      final prefsKeys = _prefs.getKeys();
      stats['totalPreferences'] =
          prefsKeys
              .where(
                (key) =>
                    key.startsWith('agrihurbi_') || key.startsWith('farm_'),
              )
              .length;

      stats['totalRecords'] = stats['totalPreferences'] as int;
    } catch (e) {
      stats['error'] = e.toString();
    }

    return stats;
  }

  @override
  Future<bool> verifyDataCleanup() async {
    try {
      // Check if Drift databases are cleared
      if (_driftManager.openDatabaseNames.isNotEmpty) {
        return false;
      }

      // Check if SharedPreferences are cleared
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
      // Check if Drift has any databases
      if (_driftManager.openDatabaseNames.isNotEmpty) {
        return true;
      }

      // Check SharedPreferences
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
    // Since we're migrating to Drift, boxes are now databases
    // For now, we'll clear all Drift data for any category request
    try {
      final clearResult = await _driftManager.clearAllData();
      if (clearResult.isFailure) {
        result['success'] = false;
        (result['errors'] as List).add('Failed to clear Drift data: ${clearResult.error}');
      } else {
        (result['clearedItems'] as List).addAll(boxNames);
      }
    } catch (e) {
      (result['errors'] as List).add('Failed to clear data: $e');
      result['success'] = false;
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
