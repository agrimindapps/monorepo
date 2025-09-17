import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'hive_adapter_registry.dart';

/// Implementação específica do ReceitaAgro para limpeza de dados
/// Implementa IAppDataCleaner do core package
/// Baseado na implementação bem-sucedida do app-gasometer
class ReceitaAgroDataCleaner implements IAppDataCleaner {
  @override
  String get appName => 'ReceitaAgro';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Dados agronômicos (culturas, pragas, defensivos, diagnósticos, favoritos, premium)';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    if (kDebugMode) {
      debugPrint('🧹 ReceitaAgroDataCleaner: Iniciando limpeza completa de dados...');
    }

    final startTime = DateTime.now();
    final results = <String, dynamic>{
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'startTime': startTime,
    };

    try {
      // 1. Limpar todas as HiveBoxes do ReceitaAgro
      final boxResults = await _clearAllHiveBoxes();
      results['clearedBoxes'] = boxResults['clearedBoxes'];
      if (boxResults['errors'] != null) {
        results['errors'].addAll(boxResults['errors']);
      }

      // 2. Limpar SharedPreferences específicas do app
      final prefsResults = await _clearAppSharedPreferences();
      results['clearedPreferences'] = prefsResults['clearedKeys'];
      if (prefsResults['errors'] != null) {
        results['errors'].addAll(prefsResults['errors']);
      }

      results['success'] = true;
      results['totalClearedBoxes'] = results['clearedBoxes'].length;
      results['totalClearedPreferences'] = results['clearedPreferences'].length;
      results['totalRecordsCleared'] = boxResults['totalRecordsCleared'] ?? 0;

    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro na limpeza completa - $e');
      }
    }

    results['endTime'] = DateTime.now();
    results['duration'] = results['endTime'].difference(startTime).inMilliseconds;

    if (kDebugMode) {
      debugPrint('✅ ReceitaAgroDataCleaner: Limpeza completa finalizada:');
      debugPrint('   Boxes limpos: ${results['totalClearedBoxes'] ?? 0}');
      debugPrint('   Preferências limpas: ${results['totalClearedPreferences'] ?? 0}');
      debugPrint('   Registros totais: ${results['totalRecordsCleared'] ?? 0}');
      debugPrint('   Erros: ${(results['errors'] as List).length}');
      debugPrint('   Tempo: ${results['duration']}ms');
    }

    return results;
  }

  @override
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    try {
      final stats = <String, dynamic>{
        'boxStats': <String, Map<String, dynamic>>{},
        'totalBoxes': 0,
        'totalRecords': 0,
        'appSpecificPrefs': 0,
        'availableCategories': getAvailableCategories(),
      };

      int totalRecords = 0;
      final boxStats = <String, Map<String, dynamic>>{};

      // Estatísticas das boxes
      for (final entry in HiveAdapterRegistry.boxNames.entries) {
        final boxName = entry.value;
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final recordCount = box.keys.length;
            totalRecords += recordCount;

            boxStats[entry.key] = {
              'boxName': boxName,
              'totalRecords': recordCount,
              'category': _getCategoryForBox(entry.key),
            };
          }
        } catch (e) {
          boxStats[entry.key] = {
            'boxName': boxName,
            'totalRecords': 0,
            'error': e.toString(),
          };
        }
      }

      stats['boxStats'] = boxStats;
      stats['totalBoxes'] = HiveAdapterRegistry.boxNames.length;
      stats['totalRecords'] = totalRecords;

      // Estatísticas SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();

        final appKeys = allKeys.where((key) =>
          key.startsWith('receituagro_') ||
          key.startsWith('agro_') ||
          key.startsWith('culture_') ||
          key.startsWith('praga_') ||
          key.startsWith('defensivo_') ||
          key.startsWith('diagnostico_') ||
          key.startsWith('favorite_') ||
          key.startsWith('premium_') ||
          key.contains('receituagro') ||
          key == 'theme_mode' // Theme provider key
        ).length;

        stats['appSpecificPrefs'] = appKeys;
      } catch (e) {
        stats['prefsError'] = e.toString();
      }

      return stats;
    } catch (e) {
      return {
        'error': 'Erro ao obter estatísticas: $e',
      };
    }
  }

  @override
  Future<bool> hasDataToClear() async {
    try {
      final stats = await getDataStatsBeforeCleaning();
      return (stats['totalRecords'] as int? ?? 0) > 0 ||
             (stats['appSpecificPrefs'] as int? ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> clearCategoryData(String category) async {
    if (category == 'all') {
      return await clearAllAppData();
    }

    final results = <String, dynamic>{
      'category': category,
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final boxesToClear = _getBoxesForCategory(category);

      if (boxesToClear.isEmpty) {
        results['errors'].add('Categoria "$category" não encontrada');
        results['success'] = false;
        return results;
      }

      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner: Limpando categoria "$category" (${boxesToClear.length} boxes)...');
      }

      int totalRecords = 0;

      for (final boxKey in boxesToClear) {
        final boxName = HiveAdapterRegistry.boxNames[boxKey];
        if (boxName == null) continue;

        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            final recordCount = box.keys.length;

            await box.clear();

            results['clearedBoxes'].add(boxKey);
            totalRecords += recordCount;

            if (kDebugMode) {
              debugPrint('   ✅ Box "$boxKey" limpo ($recordCount registros)');
            }
          }
        } catch (e) {
          final error = 'Erro ao limpar box "$boxKey": $e';
          results['errors'].add(error);

          if (kDebugMode) {
            debugPrint('   ❌ $error');
          }
        }
      }

      results['success'] = results['errors'].isEmpty;
      results['totalRecordsCleared'] = totalRecords;

    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro na limpeza da categoria "$category": $e');
      }
    }

    return results;
  }

  @override
  List<String> getAvailableCategories() {
    return [
      'all',
      'culturas',
      'pragas',
      'defensivos',
      'diagnosticos',
      'favoritos',
      'premium',
      'comentarios',
    ];
  }

  @override
  Future<bool> verifyDataCleanup() async {
    try {
      // Verificar se todas as boxes estão vazias
      for (final boxName in HiveAdapterRegistry.boxNames.values) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          if (box.keys.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('⚠️ ReceitaAgroDataCleaner: Box "$boxName" ainda contém ${box.keys.length} registros');
            }
            return false;
          }
        }
      }

      // Verificar SharedPreferences específicas do app
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      final remainingAppKeys = allKeys.where((key) =>
        key.startsWith('receituagro_') ||
        key.startsWith('agro_') ||
        key.startsWith('culture_') ||
        key.startsWith('praga_') ||
        key.startsWith('defensivo_') ||
        key.startsWith('diagnostico_') ||
        key.startsWith('favorite_') ||
        key.startsWith('premium_') ||
        key.contains('receituagro')
      ).toList();

      if (remainingAppKeys.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ ReceitaAgroDataCleaner: SharedPreferences ainda contêm chaves do app: $remainingAppKeys');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro na verificação: $e');
      }
      return false;
    }
  }

  /// Limpa todas as HiveBoxes do ReceitaAgro
  Future<Map<String, dynamic>> _clearAllHiveBoxes() async {
    final results = <String, dynamic>{
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    if (kDebugMode) {
      debugPrint('🧹 ReceitaAgroDataCleaner: Limpando ${HiveAdapterRegistry.boxNames.length} HiveBoxes...');
    }

    int totalRecords = 0;

    for (final entry in HiveAdapterRegistry.boxNames.entries) {
      final boxKey = entry.key;
      final boxName = entry.value;

      try {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          final recordCount = box.keys.length;

          await box.clear();

          results['clearedBoxes'].add(boxKey);
          totalRecords += recordCount;

          if (kDebugMode) {
            debugPrint('   ✅ Box "$boxKey" limpo ($recordCount registros)');
          }
        } else {
          if (kDebugMode) {
            debugPrint('   ⚠️ Box "$boxKey" não está aberto - pulando');
          }
        }
      } catch (e) {
        final error = 'Erro ao limpar box "$boxKey": $e';
        results['errors'].add(error);

        if (kDebugMode) {
          debugPrint('   ❌ $error');
        }
      }
    }

    results['totalRecordsCleared'] = totalRecords;
    return results;
  }

  /// Limpa SharedPreferences específicas do ReceitaAgro
  Future<Map<String, dynamic>> _clearAppSharedPreferences() async {
    final results = <String, dynamic>{
      'clearedKeys': <String>[],
      'errors': <String>[],
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      // Chaves específicas do app que devem ser limpas
      final appKeys = allKeys.where((key) =>
        key.startsWith('receituagro_') ||
        key.startsWith('agro_') ||
        key.startsWith('culture_') ||
        key.startsWith('praga_') ||
        key.startsWith('defensivo_') ||
        key.startsWith('diagnostico_') ||
        key.startsWith('favorite_') ||
        key.startsWith('premium_') ||
        key.contains('receituagro') ||
        key == 'theme_mode' // Theme provider key
      ).toList();

      if (kDebugMode) {
        debugPrint('🧹 ReceitaAgroDataCleaner: Limpando ${appKeys.length} preferências do app...');
      }

      for (final key in appKeys) {
        try {
          await prefs.remove(key);
          results['clearedKeys'].add(key);

          if (kDebugMode) {
            debugPrint('   ✅ Chave "$key" removida');
          }
        } catch (e) {
          final error = 'Erro ao remover chave "$key": $e';
          results['errors'].add(error);

          if (kDebugMode) {
            debugPrint('   ❌ $error');
          }
        }
      }

      if (appKeys.isEmpty) {
        if (kDebugMode) {
          debugPrint('   ℹ️ Nenhuma preferência específica do app encontrada');
        }
      }

    } catch (e) {
      results['errors'].add('Erro ao acessar SharedPreferences: $e');
      if (kDebugMode) {
        debugPrint('❌ ReceitaAgroDataCleaner: Erro ao acessar SharedPreferences - $e');
      }
    }

    return results;
  }

  /// Mapear categoria para boxes correspondentes
  List<String> _getBoxesForCategory(String category) {
    switch (category) {
      case 'culturas':
        return ['culturas'];
      case 'pragas':
        return ['pragas', 'pragas_inf'];
      case 'defensivos':
        return ['fitossanitarios', 'fitossanitarios_info'];
      case 'diagnosticos':
        return ['diagnosticos', 'diagnosticos_static'];
      case 'favoritos':
        return ['favoritos'];
      case 'premium':
        return ['premium_status'];
      case 'comentarios':
        return ['comentarios'];
      case 'plantas':
        return ['plantas_inf'];
      default:
        return [];
    }
  }

  /// Obter categoria de uma box
  String _getCategoryForBox(String boxKey) {
    switch (boxKey) {
      case 'culturas':
        return 'culturas';
      case 'pragas':
      case 'pragas_inf':
        return 'pragas';
      case 'fitossanitarios':
      case 'fitossanitarios_info':
        return 'defensivos';
      case 'diagnosticos':
      case 'diagnosticos_static':
        return 'diagnosticos';
      case 'favoritos':
        return 'favoritos';
      case 'premium_status':
        return 'premium';
      case 'comentarios':
        return 'comentarios';
      case 'plantas_inf':
        return 'plantas';
      default:
        return 'outros';
    }
  }
}