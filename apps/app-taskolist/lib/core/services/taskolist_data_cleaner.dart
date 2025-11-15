import 'package:core/core.dart';

import '../../database/taskolist_database.dart';

/// Implementação de IAppDataCleaner para app-taskolist
/// Gerencia limpeza de tasks e dados locais
@LazySingleton(as: IAppDataCleaner)
class TaskolistDataCleaner implements IAppDataCleaner {
  final TaskolistDatabase _database;
  final SharedPreferences _prefs;

  TaskolistDataCleaner({
    required TaskolistDatabase database,
    required SharedPreferences prefs,
  })  : _database = database,
        _prefs = prefs;

  @override
  String get appName => 'Taskolist';

  @override
  String get version => '1.0.0';

  @override
  String get description =>
      'Limpeza de tarefas e dados locais do Taskolist';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    final result = <String, dynamic>{
      'success': true,
      'clearedTables': <String>[],
      'clearedPreferences': <String>[],
      'totalRecordsCleared': 0,
      'errors': <String>[],
    };

    try {
      final statsBefore = await getDataStatsBeforeCleaning();

      // Clear Drift database tables
      try {
        await _database.taskDao.clearAllTasks();
        (result['clearedTables'] as List).add('tasks');
      } catch (e) {
        (result['errors'] as List).add('Failed to clear tasks: $e');
        result['success'] = false;
      }

      try {
        await _database.userDao.clearCache();
        (result['clearedTables'] as List).add('users');
      } catch (e) {
        (result['errors'] as List).add('Failed to clear users: $e');
        result['success'] = false;
      }

      // Clear SharedPreferences
      final prefsKeys = _prefs.getKeys();
      final appSpecificKeys = prefsKeys.where(
        (key) =>
            key.startsWith('taskolist_') ||
            key.startsWith('task_') ||
            key.startsWith('theme_') ||
            key.startsWith('notification_'),
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
          (result['clearedTables'] as List).length +
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
      'totalTasks': 0,
      'totalUsers': 0,
      'totalPreferences': 0,
      'totalRecords': 0,
    };

    try {
      stats['totalTasks'] = await _database.taskDao.getTaskCount();
      
      final user = await _database.userDao.getCachedUser();
      stats['totalUsers'] = user != null ? 1 : 0;

      final prefsKeys = _prefs.getKeys();
      stats['totalPreferences'] = prefsKeys
          .where(
            (key) => key.startsWith('taskolist_') || key.startsWith('task_'),
          )
          .length;

      stats['totalRecords'] = (stats['totalTasks'] as int) +
          (stats['totalUsers'] as int) +
          (stats['totalPreferences'] as int);
    } catch (e) {
      stats['error'] = e.toString();
    }

    return stats;
  }

  @override
  Future<bool> verifyDataCleanup() async {
    try {
      final taskCount = await _database.taskDao.getTaskCount();
      if (taskCount > 0) return false;

      final user = await _database.userDao.getCachedUser();
      if (user != null) return false;

      final prefsKeys = _prefs.getKeys();
      final remainingAppKeys = prefsKeys.where(
        (key) => key.startsWith('taskolist_') || key.startsWith('task_'),
      );

      return remainingAppKeys.isEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasDataToClear() async {
    try {
      final taskCount = await _database.taskDao.getTaskCount();
      if (taskCount > 0) return true;

      final user = await _database.userDao.getCachedUser();
      if (user != null) return true;

      final prefsKeys = _prefs.getKeys();
      final hasPrefs = prefsKeys.any(
        (key) => key.startsWith('taskolist_') || key.startsWith('task_'),
      );

      return hasPrefs;
    } catch (e) {
      return false;
    }
  }

  @override
  List<String> getAvailableCategories() {
    return ['Tasks', 'Users', 'Preferences'];
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
        case 'tasks':
          await _database.taskDao.clearAllTasks();
          (result['clearedItems'] as List).add('tasks');
          break;
        case 'users':
          await _database.userDao.clearCache();
          (result['clearedItems'] as List).add('users');
          break;
        case 'preferences':
          await _clearTaskPreferences(result);
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

  Future<void> _clearTaskPreferences(Map<String, dynamic> result) async {
    final prefsKeys = _prefs.getKeys();
    final appKeys = prefsKeys.where(
      (key) => key.startsWith('taskolist_') || key.startsWith('task_'),
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
