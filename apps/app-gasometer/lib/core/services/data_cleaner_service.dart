import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:core/core.dart';
import 'database_inspector_service.dart';

/// Serviço para limpeza de dados do GasOMeter
/// Permite limpar boxes Hive e SharedPreferences de forma segura
class DataCleanerService {

  DataCleanerService._internal();
  static DataCleanerService? _instance;
  static DataCleanerService get instance {
    _instance ??= DataCleanerService._internal();
    return _instance!;
  }

  final _inspectorService = GasOMeterDatabaseInspectorService.instance;

  /// Limpa todos os dados da aplicação (HiveBoxes + SharedPreferences)
  Future<Map<String, dynamic>> clearAllData() async {
    if (kDebugMode) {
      debugPrint('🧹 Iniciando limpeza completa de dados...');
    }

    final startTime = DateTime.now();
    final results = <String, dynamic>{
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'startTime': startTime,
    };

    try {
      // 1. Limpar todas as HiveBoxes
      final boxResults = await clearAllHiveBoxes();
      results['clearedBoxes'] = boxResults['clearedBoxes'];
      if (boxResults['errors'] != null) {
        results['errors'].addAll(boxResults['errors']);
      }

      // 2. Limpar SharedPreferences (apenas chaves específicas do app)
      final prefsResults = await clearAppSharedPreferences();
      results['clearedPreferences'] = prefsResults['clearedKeys'];
      if (prefsResults['errors'] != null) {
        results['errors'].addAll(prefsResults['errors']);
      }

      results['success'] = true;
      results['totalClearedBoxes'] = results['clearedBoxes'].length;
      results['totalClearedPreferences'] = results['clearedPreferences'].length;
      
    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ Erro na limpeza completa: $e');
      }
    }

    results['endTime'] = DateTime.now();
    results['duration'] = results['endTime'].difference(startTime).inMilliseconds;

    if (kDebugMode) {
      debugPrint('✅ Limpeza completa finalizada:');
      debugPrint('   Boxes limpos: ${results['totalClearedBoxes'] ?? 0}');
      debugPrint('   Preferências limpas: ${results['totalClearedPreferences'] ?? 0}');
      debugPrint('   Erros: ${(results['errors'] as List).length}');
      debugPrint('   Tempo: ${results['duration']}ms');
    }

    return results;
  }

  /// Limpa todas as HiveBoxes do aplicativo
  Future<Map<String, dynamic>> clearAllHiveBoxes() async {
    final availableBoxes = _inspectorService.getAvailableHiveBoxes();
    final results = <String, dynamic>{
      'clearedBoxes': <String>[],
      'errors': <String>[],
    };

    if (kDebugMode) {
      debugPrint('🧹 Limpando ${availableBoxes.length} HiveBoxes...');
    }

    for (final boxKey in availableBoxes) {
      try {
        final box = Hive.box(boxKey);
        final recordCount = box.keys.length;
        
        await box.clear();
        
        results['clearedBoxes'].add(boxKey);
        
        if (kDebugMode) {
          debugPrint('   ✅ Box "$boxKey" limpo ($recordCount registros)');
        }
      } catch (e) {
        final error = 'Erro ao limpar box "$boxKey": $e';
        results['errors'].add(error);
        
        if (kDebugMode) {
          debugPrint('   ❌ $error');
        }
      }
    }

    return results;
  }

  /// Limpa box específica
  Future<Map<String, dynamic>> clearSpecificBox(String boxKey) async {
    final results = <String, dynamic>{
      'boxKey': boxKey,
      'success': false,
      'recordsCleared': 0,
    };

    try {
      if (!Hive.isBoxOpen(boxKey)) {
        throw Exception('Box "$boxKey" não está aberta');
      }

      final box = Hive.box(boxKey);
      final recordCount = box.keys.length;
      
      await box.clear();
      
      results['success'] = true;
      results['recordsCleared'] = recordCount;

      if (kDebugMode) {
        debugPrint('✅ Box "$boxKey" limpo ($recordCount registros)');
      }
      
    } catch (e) {
      results['error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ Erro ao limpar box "$boxKey": $e');
      }
    }

    return results;
  }

  /// Limpa SharedPreferences específicas do aplicativo
  Future<Map<String, dynamic>> clearAppSharedPreferences() async {
    final results = <String, dynamic>{
      'clearedKeys': <String>[],
      'errors': <String>[],
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      
      // Chaves específicas do app que devem ser limpas
      final appKeys = allKeys.where((key) => 
        key.startsWith('gasometer_') ||
        key.startsWith('theme_') ||
        key.startsWith('user_') ||
        key.startsWith('vehicle_') ||
        key.startsWith('fuel_') ||
        key.startsWith('maintenance_') ||
        key.startsWith('expense_') ||
        key.contains('gasometer') ||
        key == 'theme_mode' // Theme provider key
      ).toList();

      if (kDebugMode) {
        debugPrint('🧹 Limpando ${appKeys.length} preferências do app...');
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
        debugPrint('❌ Erro ao acessar SharedPreferences: $e');
      }
    }

    return results;
  }

  /// Limpa dados por módulo específico
  Future<Map<String, dynamic>> clearModuleData(String moduleName) async {
    final results = <String, dynamic>{
      'module': moduleName,
      'clearedBoxes': <String>[],
      'errors': <String>[],
    };

    // Mapear módulos para suas boxes
    final moduleBoxes = <String, List<String>>{
      'Veículos': [GasOMeterDatabaseInspectorService.vehiclesBoxName],
      'Combustível': [GasOMeterDatabaseInspectorService.fuelRecordsBoxName],
      'Manutenção': [GasOMeterDatabaseInspectorService.maintenanceBoxName],
      'Odômetro': [GasOMeterDatabaseInspectorService.odometerBoxName],
      'Despesas': [GasOMeterDatabaseInspectorService.expensesBoxName],
      'Sincronização': [GasOMeterDatabaseInspectorService.syncQueueBoxName],
      'Categorias': [GasOMeterDatabaseInspectorService.categoriesBoxName],
    };

    final boxesToClear = moduleBoxes[moduleName] ?? [];

    if (boxesToClear.isEmpty) {
      results['errors'].add('Módulo "$moduleName" não encontrado');
      return results;
    }

    if (kDebugMode) {
      debugPrint('🧹 Limpando módulo "$moduleName" (${boxesToClear.length} boxes)...');
    }

    for (final boxKey in boxesToClear) {
      final boxResult = await clearSpecificBox(boxKey);
      
      if (boxResult['success'] == true) {
        results['clearedBoxes'].add(boxKey);
      } else {
        results['errors'].add(boxResult['error'] ?? 'Erro desconhecido');
      }
    }

    return results;
  }

  /// Obtém estatísticas antes da limpeza (para confirmação)
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    try {
      // Estatísticas das boxes
      final availableBoxes = _inspectorService.getAvailableHiveBoxes();
      final boxStats = <String, Map<String, dynamic>>{};
      int totalRecords = 0;

      for (final boxKey in availableBoxes) {
        final stats = _inspectorService.getBoxStats(boxKey);
        boxStats[boxKey] = stats;
        totalRecords += (stats['totalRecords'] as int? ?? 0);
      }

      // Estatísticas SharedPreferences
      final sharedPrefsData = await _inspectorService.loadSharedPreferencesData();
      final appPrefsCount = sharedPrefsData.where((record) => 
        record.key.contains('gasometer') ||
        record.key.startsWith('theme_') ||
        record.key.startsWith('user_') ||
        record.key == 'theme_mode'
      ).length;

      return {
        'totalBoxes': availableBoxes.length,
        'totalRecords': totalRecords,
        'totalSharedPrefs': sharedPrefsData.length,
        'appSpecificPrefs': appPrefsCount,
        'boxStats': boxStats,
        'availableModules': _inspectorService.customBoxes.map((box) => box.module).toSet().toList(),
      };

    } catch (e) {
      return {
        'error': 'Erro ao obter estatísticas: $e',
      };
    }
  }

  /// Verifica se há dados para limpar
  Future<bool> hasDataToClear() async {
    try {
      final stats = await getDataStatsBeforeCleaning();
      return (stats['totalRecords'] as int? ?? 0) > 0 || (stats['appSpecificPrefs'] as int? ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Obtém resumo de limpeza por módulo
  Map<String, String> getModuleSummary() {
    return {
      'Veículos': 'Limpa todos os veículos cadastrados',
      'Combustível': 'Remove registros de abastecimento',
      'Manutenção': 'Apaga histórico de manutenções',
      'Odômetro': 'Remove leituras do odômetro',
      'Despesas': 'Limpa todas as despesas registradas',
      'Sincronização': 'Limpa fila de sincronização',
      'Categorias': 'Remove categorias personalizadas',
    };
  }
}