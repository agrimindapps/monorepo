import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_cleaner_service.dart';
import 'database_inspector_service.dart';

/// Implementação específica do GasOMeter para limpeza de dados
/// Implementa IAppDataCleaner do core package
/// Mantém compatibilidade com a implementação existente DataCleanerService
class GasometerDataCleaner implements IAppDataCleaner {
  final DataCleanerService _existingService = DataCleanerService.instance;

  @override
  String get appName => 'GasOMeter';

  @override
  String get version => '1.0.0';

  @override
  String get description => 'Dados de veículos, combustível, manutenção, despesas e configurações';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    if (kDebugMode) {
      debugPrint('🧹 GasometerDataCleaner: Usando DataCleanerService existente para limpeza...');
    }

    // Usar a implementação existente que já está funcionando
    final result = await _existingService.clearAllData();

    // Adaptar resultado para o formato esperado pela interface
    return {
      'success': result['success'] ?? false,
      'clearedBoxes': result['clearedBoxes'] ?? [],
      'clearedPreferences': result['clearedPreferences'] ?? [],
      'errors': result['errors'] ?? [],
      'totalRecordsCleared': _calculateTotalRecords(result),
      'startTime': result['startTime'],
      'endTime': result['endTime'],
      'duration': result['duration'],
    };
  }

  @override
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    try {
      // Usar método existente
      final existingStats = await _existingService.getDataStatsBeforeCleaning();

      // Adaptar para o formato esperado
      return {
        'totalBoxes': existingStats['totalBoxes'] ?? 0,
        'totalRecords': existingStats['totalRecords'] ?? 0,
        'appSpecificPrefs': existingStats['appSpecificPrefs'] ?? 0,
        'availableCategories': getAvailableCategories(),
        'boxStats': existingStats['boxStats'] ?? {},
        'availableModules': existingStats['availableModules'] ?? [],
      };
    } catch (e) {
      return {
        'error': 'Erro ao obter estatísticas: $e',
      };
    }
  }

  @override
  Future<bool> hasDataToClear() async {
    // Usar método existente
    return await _existingService.hasDataToClear();
  }

  @override
  Future<Map<String, dynamic>> clearCategoryData(String category) async {
    if (category == 'all') {
      return await clearAllAppData();
    }

    try {
      // Mapear categoria para módulo do GasOMeter
      final moduleName = _getCategoryModuleName(category);
      if (moduleName == null) {
        return {
          'category': category,
          'success': false,
          'errors': ['Categoria "$category" não encontrada'],
          'clearedBoxes': [],
          'totalRecordsCleared': 0,
        };
      }

      // Usar método existente para limpar por módulo
      final result = await _existingService.clearModuleData(moduleName);

      return {
        'category': category,
        'success': result['errors']?.isEmpty ?? true,
        'clearedBoxes': result['clearedBoxes'] ?? [],
        'errors': result['errors'] ?? [],
        'totalRecordsCleared': result['clearedBoxes']?.length ?? 0,
      };
    } catch (e) {
      return {
        'category': category,
        'success': false,
        'errors': ['Erro ao limpar categoria "$category": $e'],
        'clearedBoxes': [],
        'totalRecordsCleared': 0,
      };
    }
  }

  @override
  List<String> getAvailableCategories() {
    // Mapear módulos do GasOMeter para categorias
    return [
      'all',
      'vehicles', // Veículos
      'fuel', // Combustível
      'maintenance', // Manutenção
      'odometer', // Odômetro
      'expenses', // Despesas
      'sync', // Sincronização
      'categories', // Categorias
    ];
  }

  @override
  Future<bool> verifyDataCleanup() async {
    try {
      // Verificar se todas as boxes estão vazias
      final inspectorService = GasOMeterDatabaseInspectorService.instance;
      final availableBoxes = inspectorService.getAvailableHiveBoxes();

      for (final boxName in availableBoxes) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          if (box.keys.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('⚠️ GasometerDataCleaner: Box "$boxName" ainda contém ${box.keys.length} registros');
            }
            return false;
          }
        }
      }

      // Verificar SharedPreferences específicas do app
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      final remainingAppKeys = allKeys.where((key) =>
        key.startsWith('gasometer_') ||
        key.startsWith('theme_') ||
        key.startsWith('user_') ||
        key.startsWith('vehicle_') ||
        key.startsWith('fuel_') ||
        key.startsWith('maintenance_') ||
        key.startsWith('expense_') ||
        key.contains('gasometer')
      ).toList();

      if (remainingAppKeys.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('⚠️ GasometerDataCleaner: SharedPreferences ainda contêm chaves do app: $remainingAppKeys');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ GasometerDataCleaner: Erro na verificação - $e');
      }
      return false;
    }
  }

  /// Mapear categoria para nome do módulo do GasOMeter
  String? _getCategoryModuleName(String category) {
    switch (category) {
      case 'vehicles':
        return 'Veículos';
      case 'fuel':
        return 'Combustível';
      case 'maintenance':
        return 'Manutenção';
      case 'odometer':
        return 'Odômetro';
      case 'expenses':
        return 'Despesas';
      case 'sync':
        return 'Sincronização';
      case 'categories':
        return 'Categorias';
      default:
        return null;
    }
  }

  /// Calcular total de registros dos resultados
  int _calculateTotalRecords(Map<String, dynamic> result) {
    try {
      final clearedBoxes = result['clearedBoxes'] as List?;
      if (clearedBoxes == null) return 0;

      // Para simplificar, retornar número de boxes limpas
      // O DataCleanerService existente não rastreia registros por box
      return clearedBoxes.length;
    } catch (e) {
      return 0;
    }
  }
}