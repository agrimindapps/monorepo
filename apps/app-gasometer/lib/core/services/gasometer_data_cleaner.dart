import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

/// Implementação de IAppDataCleaner para o app Gasometer
/// Responsável por limpar todos os dados locais do app
@LazySingleton(as: IAppDataCleaner)
class GasometerDataCleaner implements IAppDataCleaner {
  @override
  String get appName => 'Gasometer';

  @override
  String get version => '1.0.0';

  @override
  String get description =>
      'Limpa todos os dados do app Gasometer incluindo veículos, combustível, manutenções e despesas';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    final clearedBoxes = <String>[];
    final errors = <String>[];
    var totalRecordsCleared = 0;

    try {
      // Lista de boxes do Gasometer
      final boxNames = [
        'vehicles',
        'fuel_supplies',
        'odometer',
        'expenses',
        'maintenance',
        'categories',
        'settings',
        'cache',
        'logs',
      ];

      for (final boxName in boxNames) {
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final count = box.length;
            await box.clear();
            clearedBoxes.add(boxName);
            totalRecordsCleared += count;
          }
        } catch (e) {
          errors.add('Erro ao limpar box $boxName: $e');
        }
      }

      return {
        'success': errors.isEmpty,
        'clearedBoxes': clearedBoxes,
        'clearedPreferences': <String>[],
        'errors': errors,
        'totalRecordsCleared': totalRecordsCleared,
      };
    } catch (e) {
      errors.add('Erro geral na limpeza: $e');
      return {
        'success': false,
        'clearedBoxes': clearedBoxes,
        'clearedPreferences': <String>[],
        'errors': errors,
        'totalRecordsCleared': totalRecordsCleared,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    final stats = <String, int>{};
    var totalRecords = 0;

    final boxNames = [
      'vehicles',
      'fuel_supplies',
      'odometer',
      'expenses',
      'maintenance',
      'categories',
      'settings',
      'cache',
      'logs',
    ];

    for (final boxName in boxNames) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          final count = box.length;
          stats[boxName] = count;
          totalRecords += count;
        }
      } catch (e) {
        stats[boxName] = 0;
      }
    }

    return {
      'totalRecords': totalRecords,
      'boxStats': stats,
    };
  }

  @override
  Future<bool> hasDataToClear() async {
    final stats = await getDataStatsBeforeCleaning();
    final totalRecords = stats['totalRecords'] as int? ?? 0;
    return totalRecords > 0;
  }

  @override
  Future<bool> verifyDataCleanup() async {
    final stats = await getDataStatsBeforeCleaning();
    final totalRecords = stats['totalRecords'] as int? ?? 0;
    return totalRecords == 0;
  }

  @override
  List<String> getAvailableCategories() {
    return [
      'all',
      'vehicles',
      'fuel_supplies',
      'odometer',
      'expenses',
      'maintenance',
      'categories',
      'settings',
      'cache',
      'logs',
    ];
  }

  @override
  Future<Map<String, dynamic>> clearCategoryData(String category) async {
    if (category == 'all') {
      return clearAllAppData();
    }

    final errors = <String>[];
    var totalRecordsCleared = 0;

    try {
      if (Hive.isBoxOpen(category)) {
        final box = Hive.box(category);
        final count = box.length;
        await box.clear();
        totalRecordsCleared = count;
      }

      return {
        'success': true,
        'clearedBoxes': [category],
        'clearedPreferences': <String>[],
        'errors': errors,
        'totalRecordsCleared': totalRecordsCleared,
      };
    } catch (e) {
      errors.add('Erro ao limpar categoria $category: $e');
      return {
        'success': false,
        'clearedBoxes': <String>[],
        'clearedPreferences': <String>[],
        'errors': errors,
        'totalRecordsCleared': 0,
      };
    }
  }
}
