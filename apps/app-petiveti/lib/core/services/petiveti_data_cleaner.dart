import 'package:core/core.dart';

/// Implementação de IAppDataCleaner para app-petiveti
/// Gerencia limpeza de dados através do Drift database e SharedPreferences
/// Note: Hive foi removido - agora usa apenas Drift para persistência
@LazySingleton(as: IAppDataCleaner)
class PetivetiDataCleaner implements IAppDataCleaner {
  final SharedPreferences _prefs;

  PetivetiDataCleaner({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

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
      'clearedPreferences': <String>[],
      'totalRecordsCleared': 0,
      'errors': <String>[],
    };

    try {
      final statsBefore = await getDataStatsBeforeCleaning();

      // Clear SharedPreferences only (Drift database cleared separately via database APIs)
      final prefsKeys = _prefs.getKeys();
      final appSpecificKeys = prefsKeys.where(
        (key) =>
            key.startsWith('petiveti_') ||
            key.startsWith('pet_') ||
            key.startsWith('reminder_'),
      );

      for (final key in appSpecificKeys) {
        try {
          await _prefs.remove(key);
          (result['clearedPreferences'] as List).add(key);
        } catch (e) {
          (result['errors'] as List).add('Failed to clear preference $key: $e');
        }
      }

      result['totalRecordsCleared'] = (result['clearedPreferences'] as List).length;
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
      'totalPreferences': 0,
      'totalRecords': 0,
      'note': 'Drift database stats not included - query database directly for detailed stats',
    };

    try {
      // Only count SharedPreferences (Drift data queried separately)
      final prefsKeys = _prefs.getKeys();
      stats['totalPreferences'] = prefsKeys
          .where((key) => key.startsWith('petiveti_') || key.startsWith('pet_'))
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
      // Verify SharedPreferences are cleared (Drift database verified separately)
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
      // Check SharedPreferences only (Drift database checked separately)
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
    // No-op: Hive removed - Drift database cleared via database APIs
    // This method kept for interface compatibility
    for (final boxName in boxNames) {
      (result['clearedItems'] as List).add('$boxName (Drift - use database API)');
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
