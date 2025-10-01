import 'package:core/core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementação de IAppDataCleaner para app-taskolist
/// Gerencia limpeza de tasks, categories, settings e cache local
@LazySingleton(as: IAppDataCleaner)
class TaskolistDataCleaner implements IAppDataCleaner {
  final HiveInterface _hive;
  final SharedPreferences _prefs;

  TaskolistDataCleaner({
    required HiveInterface hive,
    required SharedPreferences prefs,
  })  : _hive = hive,
        _prefs = prefs;

  @override
  String get appName => 'Taskolist';

  @override
  String get version => '1.0.0';

  @override
  String get description =>
      'Limpeza de tarefas, categorias, configurações e dados locais do Taskolist';

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
        'tasks',
        'task_box',
        'categories',
        'category_box',
        'settings',
        'user_preferences',
        'task_cache',
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
          key.startsWith('taskolist_') ||
          key.startsWith('task_') ||
          key.startsWith('category_') ||
          key.startsWith('theme_') ||
          key.startsWith('notification_') ||
          key.startsWith('onboarding_') ||
          key.startsWith('last_sync_'));

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
      'totalTasks': 0,
      'totalCategories': 0,
      'totalPreferences': 0,
      'totalRecords': 0,
    };

    try {
      // Contar tasks
      if (await _hive.boxExists('tasks') || await _hive.boxExists('task_box')) {
        try {
          final tasksBox = await _hive.openBox<dynamic>('tasks');
          stats['totalTasks'] = tasksBox.length;
          await tasksBox.close();
        } catch (e) {
          try {
            final tasksBox = await _hive.openBox<dynamic>('task_box');
            stats['totalTasks'] = tasksBox.length;
            await tasksBox.close();
          } catch (_) {
            // Ignore
          }
        }
      }

      // Contar categories
      if (await _hive.boxExists('categories') ||
          await _hive.boxExists('category_box')) {
        try {
          final categoriesBox = await _hive.openBox<dynamic>('categories');
          stats['totalCategories'] = categoriesBox.length;
          await categoriesBox.close();
        } catch (e) {
          try {
            final categoriesBox = await _hive.openBox<dynamic>('category_box');
            stats['totalCategories'] = categoriesBox.length;
            await categoriesBox.close();
          } catch (_) {
            // Ignore
          }
        }
      }

      // Contar preferences
      final prefsKeys = _prefs.getKeys();
      stats['totalPreferences'] = prefsKeys
          .where((key) =>
              key.startsWith('taskolist_') || key.startsWith('task_'))
          .length;

      stats['totalRecords'] = (stats['totalTasks'] as int) +
          (stats['totalCategories'] as int) +
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
      final boxNames = ['tasks', 'task_box', 'categories', 'category_box'];
      for (final boxName in boxNames) {
        if (await _hive.boxExists(boxName)) {
          return false;
        }
      }

      // Verificar se preferences foram limpas
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
      // Verificar se existe alguma box
      final boxNames = ['tasks', 'task_box', 'categories', 'category_box'];
      for (final boxName in boxNames) {
        if (await _hive.boxExists(boxName)) {
          return true;
        }
      }

      // Verificar se existem preferences
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
    return [
      'Tasks',
      'Categories',
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
        case 'tasks':
          await _clearBoxes(['tasks', 'task_box'], result);
          break;
        case 'categories':
          await _clearBoxes(['categories', 'category_box'], result);
          break;
        case 'settings':
          await _clearBoxes(['settings', 'user_preferences'], result);
          break;
        case 'cache':
          await _clearBoxes(['task_cache'], result);
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
