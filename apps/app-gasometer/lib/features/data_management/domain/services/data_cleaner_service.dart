import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../database/gasometer_database.dart';

/// Serviço para limpeza de dados do GasOMeter
/// Permite limpar tabelas Drift e SharedPreferences de forma segura
class DataCleanerService {
  DataCleanerService(this._database);

  final GasometerDatabase _database;

  /// Limpa todos os dados da aplicação (Drift Tables + SharedPreferences)
  Future<Map<String, dynamic>> clearAllData() async {
    if (kDebugMode) {
      debugPrint('🧹 Iniciando limpeza completa de dados...');
    }

    final startTime = DateTime.now();
    final results = <String, dynamic>{
      'clearedTables': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'startTime': startTime,
    };

    try {
      final tableResults = await clearAllDriftTables();
      results['clearedTables'] = tableResults['clearedTables'];
      if (tableResults['errors'] != null) {
        results['errors'].addAll(tableResults['errors']);
      }
      final prefsResults = await clearAppSharedPreferences();
      results['clearedPreferences'] = prefsResults['clearedKeys'];
      if (prefsResults['errors'] != null) {
        results['errors'].addAll(prefsResults['errors']);
      }

      results['success'] = true;
      results['totalClearedTables'] = results['clearedTables'].length;
      results['totalClearedPreferences'] = results['clearedPreferences'].length;
    } catch (e) {
      results['success'] = false;
      results['mainError'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ Erro na limpeza completa: $e');
      }
    }

    results['endTime'] = DateTime.now();
    results['duration'] = results['endTime']
        .difference(startTime)
        .inMilliseconds;

    if (kDebugMode) {
      debugPrint('✅ Limpeza completa finalizada:');
      debugPrint('   Tabelas limpas: ${results['totalClearedTables'] ?? 0}');
      debugPrint(
        '   Preferências limpas: ${results['totalClearedPreferences'] ?? 0}',
      );
      debugPrint('   Erros: ${(results['errors'] as List).length}');
      debugPrint('   Tempo: ${results['duration']}ms');
    }

    return results;
  }

  /// Limpa todas as tabelas Drift do aplicativo
  Future<Map<String, dynamic>> clearAllDriftTables() async {
    final results = <String, dynamic>{
      'clearedTables': <String>[],
      'errors': <String>[],
    };

    if (kDebugMode) {
      debugPrint('🧹 Limpando tabelas Drift...');
    }

    // Limpar cada tabela individualmente
    try {
      // Vehicles
      final vehicleCount =
          (await _database.select(_database.vehicles).get()).length;
      await _database.delete(_database.vehicles).go();
      results['clearedTables'].add('vehicles');
      if (kDebugMode) {
        debugPrint('   ✅ Tabela "vehicles" limpa ($vehicleCount registros)');
      }
    } catch (e) {
      results['errors'].add('Erro ao limpar tabela "vehicles": $e');
      if (kDebugMode) {
        debugPrint('   ❌ Erro ao limpar tabela "vehicles": $e');
      }
    }

    try {
      // Fuel Supplies
      final fuelCount =
          (await _database.select(_database.fuelSupplies).get()).length;
      await _database.delete(_database.fuelSupplies).go();
      results['clearedTables'].add('fuel_supplies');
      if (kDebugMode) {
        debugPrint('   ✅ Tabela "fuel_supplies" limpa ($fuelCount registros)');
      }
    } catch (e) {
      results['errors'].add('Erro ao limpar tabela "fuel_supplies": $e');
      if (kDebugMode) {
        debugPrint('   ❌ Erro ao limpar tabela "fuel_supplies": $e');
      }
    }

    try {
      // Maintenances
      final maintenanceCount =
          (await _database.select(_database.maintenances).get()).length;
      await _database.delete(_database.maintenances).go();
      results['clearedTables'].add('maintenances');
      if (kDebugMode) {
        debugPrint(
          '   ✅ Tabela "maintenances" limpa ($maintenanceCount registros)',
        );
      }
    } catch (e) {
      results['errors'].add('Erro ao limpar tabela "maintenances": $e');
      if (kDebugMode) {
        debugPrint('   ❌ Erro ao limpar tabela "maintenances": $e');
      }
    }

    try {
      // Expenses
      final expenseCount =
          (await _database.select(_database.expenses).get()).length;
      await _database.delete(_database.expenses).go();
      results['clearedTables'].add('expenses');
      if (kDebugMode) {
        debugPrint('   ✅ Tabela "expenses" limpa ($expenseCount registros)');
      }
    } catch (e) {
      results['errors'].add('Erro ao limpar tabela "expenses": $e');
      if (kDebugMode) {
        debugPrint('   ❌ Erro ao limpar tabela "expenses": $e');
      }
    }

    try {
      // Odometer Readings
      final odometerCount =
          (await _database.select(_database.odometerReadings).get()).length;
      await _database.delete(_database.odometerReadings).go();
      results['clearedTables'].add('odometer_readings');
      if (kDebugMode) {
        debugPrint(
          '   ✅ Tabela "odometer_readings" limpa ($odometerCount registros)',
        );
      }
    } catch (e) {
      results['errors'].add('Erro ao limpar tabela "odometer_readings": $e');
      if (kDebugMode) {
        debugPrint('   ❌ Erro ao limpar tabela "odometer_readings": $e');
      }
    }

    try {
      // Audit Trail
      final auditCount =
          (await _database.select(_database.auditTrail).get()).length;
      await _database.delete(_database.auditTrail).go();
      results['clearedTables'].add('audit_trail');
      if (kDebugMode) {
        debugPrint('   ✅ Tabela "audit_trail" limpa ($auditCount registros)');
      }
    } catch (e) {
      results['errors'].add('Erro ao limpar tabela "audit_trail": $e');
      if (kDebugMode) {
        debugPrint('   ❌ Erro ao limpar tabela "audit_trail": $e');
      }
    }

    return results;
  }

  /// Limpa tabela específica
  Future<Map<String, dynamic>> clearSpecificTable(String tableName) async {
    final results = <String, dynamic>{
      'tableName': tableName,
      'success': false,
      'recordsCleared': 0,
    };

    try {
      switch (tableName) {
        case 'vehicles':
          final count =
              (await _database.select(_database.vehicles).get()).length;
          await _database.delete(_database.vehicles).go();
          results['success'] = true;
          results['recordsCleared'] = count;
          break;
        case 'fuel_supplies':
          final count =
              (await _database.select(_database.fuelSupplies).get()).length;
          await _database.delete(_database.fuelSupplies).go();
          results['success'] = true;
          results['recordsCleared'] = count;
          break;
        case 'maintenances':
          final count =
              (await _database.select(_database.maintenances).get()).length;
          await _database.delete(_database.maintenances).go();
          results['success'] = true;
          results['recordsCleared'] = count;
          break;
        case 'expenses':
          final count =
              (await _database.select(_database.expenses).get()).length;
          await _database.delete(_database.expenses).go();
          results['success'] = true;
          results['recordsCleared'] = count;
          break;
        case 'odometer_readings':
          final count =
              (await _database.select(_database.odometerReadings).get()).length;
          await _database.delete(_database.odometerReadings).go();
          results['success'] = true;
          results['recordsCleared'] = count;
          break;
        case 'audit_trail':
          final count =
              (await _database.select(_database.auditTrail).get()).length;
          await _database.delete(_database.auditTrail).go();
          results['success'] = true;
          results['recordsCleared'] = count;
          break;
        default:
          throw Exception('Tabela "$tableName" não encontrada');
      }

      if (kDebugMode && results['success'] == true) {
        debugPrint(
          '✅ Tabela "$tableName" limpa (${results['recordsCleared']} registros)',
        );
      }
    } catch (e) {
      results['error'] = e.toString();
      if (kDebugMode) {
        debugPrint('❌ Erro ao limpar tabela "$tableName": $e');
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
      final appKeys = allKeys
          .where(
            (key) =>
                key.startsWith('gasometer_') ||
                key.startsWith('theme_') ||
                key.startsWith('user_') ||
                key.startsWith('vehicle_') ||
                key.startsWith('fuel_') ||
                key.startsWith('maintenance_') ||
                key.startsWith('expense_') ||
                key.contains('gasometer') ||
                key == 'theme_mode', // Theme provider key
          )
          .toList();

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
      'clearedTables': <String>[],
      'errors': <String>[],
    };

    final moduleTables = <String, List<String>>{
      'Veículos': ['vehicles'],
      'Combustível': ['fuel_supplies'],
      'Manutenção': ['maintenances'],
      'Odômetro': ['odometer_readings'],
      'Despesas': ['expenses'],
      'Auditoria': ['audit_trail'],
    };

    final tablesToClear = moduleTables[moduleName] ?? [];

    if (tablesToClear.isEmpty) {
      results['errors'].add('Módulo "$moduleName" não encontrado');
      return results;
    }

    if (kDebugMode) {
      debugPrint(
        '🧹 Limpando módulo "$moduleName" (${tablesToClear.length} tabelas)...',
      );
    }

    for (final tableName in tablesToClear) {
      final tableResult = await clearSpecificTable(tableName);

      if (tableResult['success'] == true) {
        results['clearedTables'].add(tableName);
      } else {
        results['errors'].add(tableResult['error'] ?? 'Erro desconhecido');
      }
    }

    return results;
  }

  /// Obtém estatísticas antes da limpeza (para confirmação)
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    try {
      final tableStats = <String, Map<String, dynamic>>{};
      int totalRecords = 0;

      // Estatísticas das tabelas
      final vehicleCount =
          (await _database.select(_database.vehicles).get()).length;
      tableStats['vehicles'] = {'totalRecords': vehicleCount};
      totalRecords += vehicleCount;

      final fuelCount =
          (await _database.select(_database.fuelSupplies).get()).length;
      tableStats['fuel_supplies'] = {'totalRecords': fuelCount};
      totalRecords += fuelCount;

      final maintenanceCount =
          (await _database.select(_database.maintenances).get()).length;
      tableStats['maintenances'] = {'totalRecords': maintenanceCount};
      totalRecords += maintenanceCount;

      final expenseCount =
          (await _database.select(_database.expenses).get()).length;
      tableStats['expenses'] = {'totalRecords': expenseCount};
      totalRecords += expenseCount;

      final odometerCount =
          (await _database.select(_database.odometerReadings).get()).length;
      tableStats['odometer_readings'] = {'totalRecords': odometerCount};
      totalRecords += odometerCount;

      final auditCount =
          (await _database.select(_database.auditTrail).get()).length;
      tableStats['audit_trail'] = {'totalRecords': auditCount};
      totalRecords += auditCount;

      // Para SharedPreferences, ainda usamos o método antigo
      final sharedPrefsData = await _loadSharedPreferencesData();
      final appPrefsCount = sharedPrefsData
          .where(
            (SharedPreferencesRecord record) =>
                record.key.contains('gasometer') ||
                record.key.startsWith('theme_') ||
                record.key.startsWith('user_') ||
                record.key == 'theme_mode',
          )
          .length;

      return {
        'totalTables':
            6, // vehicles, fuel_supplies, maintenances, expenses, odometer_readings, audit_trail
        'totalRecords': totalRecords,
        'totalSharedPrefs': sharedPrefsData.length,
        'appSpecificPrefs': appPrefsCount,
        'tableStats': tableStats,
        'availableModules': [
          'Veículos',
          'Combustível',
          'Manutenção',
          'Odômetro',
          'Despesas',
          'Auditoria',
        ],
      };
    } catch (e) {
      return {'error': 'Erro ao obter estatísticas: $e'};
    }
  }

  /// Verifica se há dados para limpar
  Future<bool> hasDataToClear() async {
    try {
      final stats = await getDataStatsBeforeCleaning();
      return (stats['totalRecords'] as int? ?? 0) > 0 ||
          (stats['appSpecificPrefs'] as int? ?? 0) > 0;
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
      'Auditoria': 'Remove histórico de auditoria',
    };
  }

  /// Helper para carregar dados do SharedPreferences (simplificado)
  Future<List<SharedPreferencesRecord>> _loadSharedPreferencesData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final records = <SharedPreferencesRecord>[];

      for (final key in allKeys) {
        try {
          final value = prefs.get(key);
          final type = _getValueType(value);
          records.add(
            SharedPreferencesRecord(key: key, value: value, type: type),
          );
        } catch (e) {
          // Ignora erros individuais
        }
      }

      return records;
    } catch (e) {
      return [];
    }
  }

  /// Helper para determinar o tipo do valor
  String _getValueType(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is bool) return 'bool';
    if (value is double) return 'double';
    if (value is List<String>) return 'List<String>';
    return 'unknown';
  }
}
