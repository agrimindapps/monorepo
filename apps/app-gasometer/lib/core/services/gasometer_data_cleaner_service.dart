import 'package:flutter/foundation.dart';

import '../../core/logging/repositories/log_repository.dart';
import '../../features/expenses/data/repositories/expenses_repository.dart';
import '../../features/fuel/domain/repositories/fuel_repository.dart';
import '../../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../../features/odometer/data/repositories/odometer_repository.dart';
import '../../features/vehicles/domain/repositories/vehicle_repository.dart';

/// Service responsável por limpeza seletiva de dados específicos do Gasometer
class GasometerDataCleanerService {
  final VehicleRepository vehicleRepository;
  final FuelRepository fuelRepository;
  final MaintenanceRepository maintenanceRepository;
  final ExpensesRepository expensesRepository;
  final OdometerRepository odometerRepository;
  final LogRepository logRepository;

  GasometerDataCleanerService({
    required this.vehicleRepository,
    required this.fuelRepository,
    required this.maintenanceRepository,
    required this.expensesRepository,
    required this.odometerRepository,
    required this.logRepository,
  });

  String get appName => 'Gasometer';
  String get version => '1.0.0';
  String get description => 'Limpeza de veículos, abastecimentos, manutenções e dados relacionados do Gasometer';

  /// Limpa todos os dados do usuário do app
  Future<Map<String, dynamic>> clearAllAppData() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'clearedPreferences': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
      'vehiclesCleaned': 0,
      'fuelRecordsCleaned': 0,
      'maintenanceRecordsCleaned': 0,
      'expensesCleaned': 0,
      'odometerReadingsCleaned': 0,
      'logsCleaned': 0,
    };

    try {
      int totalCleared = 0;

      if (kDebugMode) {
        debugPrint('🧹 GasometerDataCleaner: Iniciando limpeza completa de dados');
      }

      // 1. Limpar logs primeiro (menos crítico)
      try {
        final logsResult = await logRepository.getAllLogs();
        if (logsResult.isRight()) {
          final logs = logsResult.getOrElse(() => []);
          for (final log in logs) {
            try {
              await logRepository.deleteLog(log.id);
            } catch (e) {
              (result['errors'] as List<String>).add('Erro ao deletar log ${log.id}: $e');
            }
          }
          result['logsCleaned'] = logs.length;
          totalCleared += logs.length;
          (result['clearedBoxes'] as List<String>).add('logs_box');

          if (kDebugMode) {
            debugPrint('🧹 GasometerDataCleaner: ${logs.length} logs limpos');
          }
        }
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar logs: $e');
      }

      // 2. Limpar leituras do odômetro
      try {
        final readings = await odometerRepository.getAllOdometerReadings();
        for (final reading in readings) {
          try {
            await odometerRepository.deleteOdometerReading(reading.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar leitura odômetro ${reading.id}: $e');
          }
        }
        result['odometerReadingsCleaned'] = readings.length;
        totalCleared += readings.length;
        (result['clearedBoxes'] as List<String>).add('odometer_readings_box');

        if (kDebugMode) {
          debugPrint('🧹 GasometerDataCleaner: ${readings.length} leituras de odômetro limpas');
        }
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar leituras odômetro: $e');
      }

      // 3. Limpar gastos/despesas
      try {
        final expenses = await expensesRepository.getAllExpenses();
        for (final expense in expenses) {
          try {
            await expensesRepository.deleteExpense(expense.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar despesa ${expense.id}: $e');
          }
        }
        result['expensesCleaned'] = expenses.length;
        totalCleared += expenses.length;
        (result['clearedBoxes'] as List<String>).add('expenses_box');

        if (kDebugMode) {
          debugPrint('🧹 GasometerDataCleaner: ${expenses.length} despesas limpas');
        }
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar despesas: $e');
      }

      // 4. Limpar registros de manutenção
      try {
        final maintenanceResult = await maintenanceRepository.getAllMaintenanceRecords();
        if (maintenanceResult.isRight()) {
          final maintenanceRecords = maintenanceResult.getOrElse(() => []);
          for (final maintenance in maintenanceRecords) {
            try {
              await maintenanceRepository.deleteMaintenanceRecord(maintenance.id);
            } catch (e) {
              (result['errors'] as List<String>).add('Erro ao deletar manutenção ${maintenance.id}: $e');
            }
          }
          result['maintenanceRecordsCleaned'] = maintenanceRecords.length;
          totalCleared += maintenanceRecords.length;
          (result['clearedBoxes'] as List<String>).add('maintenance_records_box');

          if (kDebugMode) {
            debugPrint('🧹 GasometerDataCleaner: ${maintenanceRecords.length} registros de manutenção limpos');
          }
        }
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar manutenções: $e');
      }

      // 5. Limpar registros de combustível/abastecimentos
      try {
        final fuelResult = await fuelRepository.getAllFuelRecords();
        if (fuelResult.isRight()) {
          final fuelRecords = fuelResult.getOrElse(() => []);
          for (final fuel in fuelRecords) {
            try {
              await fuelRepository.deleteFuelRecord(fuel.id);
            } catch (e) {
              (result['errors'] as List<String>).add('Erro ao deletar abastecimento ${fuel.id}: $e');
            }
          }
          result['fuelRecordsCleaned'] = fuelRecords.length;
          totalCleared += fuelRecords.length;
          (result['clearedBoxes'] as List<String>).add('fuel_records_box');

          if (kDebugMode) {
            debugPrint('🧹 GasometerDataCleaner: ${fuelRecords.length} abastecimentos limpos');
          }
        }
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar abastecimentos: $e');
      }

      // 6. Limpar veículos por último (mais crítico)
      try {
        final vehiclesResult = await vehicleRepository.getAllVehicles();
        if (vehiclesResult.isRight()) {
          final vehicles = vehiclesResult.getOrElse(() => []);
          for (final vehicle in vehicles) {
            try {
              await vehicleRepository.deleteVehicle(vehicle.id);
            } catch (e) {
              (result['errors'] as List<String>).add('Erro ao deletar veículo ${vehicle.id}: $e');
            }
          }
          result['vehiclesCleaned'] = vehicles.length;
          totalCleared += vehicles.length;
          (result['clearedBoxes'] as List<String>).add('vehicles_box');

          if (kDebugMode) {
            debugPrint('🧹 GasometerDataCleaner: ${vehicles.length} veículos limpos');
          }
        }
      } catch (e) {
        (result['errors'] as List<String>).add('Erro ao limpar veículos: $e');
      }

      result['totalRecordsCleared'] = totalCleared;
      result['success'] = (result['errors'] as List<String>).isEmpty;

      if (kDebugMode) {
        debugPrint('🧹 GasometerDataCleaner: Limpeza finalizada. Total: $totalCleared registros');
      }

      return result;
    } catch (e) {
      (result['errors'] as List<String>).add('Erro geral: $e');
      if (kDebugMode) {
        debugPrint('❌ GasometerDataCleaner: Erro geral na limpeza: $e');
      }
      return result;
    }
  }

  /// Limpa apenas o conteúdo do usuário mantendo perfil e configurações
  Future<Map<String, dynamic>> clearUserContentOnly() async {
    // Para Gasometer, é equivalente a clearAllAppData
    // pois não temos dados de perfil específicos no repositório
    return clearAllAppData();
  }

  /// Obtém estatísticas dos dados antes da limpeza
  Future<Map<String, dynamic>> getDataStatsBeforeCleaning() async {
    try {
      int vehiclesCount = 0;
      int fuelRecordsCount = 0;
      int maintenanceRecordsCount = 0;
      int expensesCount = 0;
      int odometerReadingsCount = 0;
      int logsCount = 0;

      // Contar veículos
      final vehiclesResult = await vehicleRepository.getAllVehicles();
      if (vehiclesResult.isRight()) {
        vehiclesCount = vehiclesResult.getOrElse(() => []).length;
      }

      // Contar abastecimentos
      final fuelResult = await fuelRepository.getAllFuelRecords();
      if (fuelResult.isRight()) {
        fuelRecordsCount = fuelResult.getOrElse(() => []).length;
      }

      // Contar manutenções
      final maintenanceResult = await maintenanceRepository.getAllMaintenanceRecords();
      if (maintenanceResult.isRight()) {
        maintenanceRecordsCount = maintenanceResult.getOrElse(() => []).length;
      }

      // Contar despesas
      try {
        final expenses = await expensesRepository.getAllExpenses();
        expensesCount = expenses.length;
      } catch (e) {
        // Ignorar erros na contagem
      }

      // Contar leituras do odômetro
      try {
        final readings = await odometerRepository.getAllOdometerReadings();
        odometerReadingsCount = readings.length;
      } catch (e) {
        // Ignorar erros na contagem
      }

      // Contar logs
      final logsResult = await logRepository.getAllLogs();
      if (logsResult.isRight()) {
        logsCount = logsResult.getOrElse(() => []).length;
      }

      final totalRecords = vehiclesCount + fuelRecordsCount + maintenanceRecordsCount +
                          expensesCount + odometerReadingsCount + logsCount;

      return {
        'vehiclesCount': vehiclesCount,
        'fuelRecordsCount': fuelRecordsCount,
        'maintenanceRecordsCount': maintenanceRecordsCount,
        'expensesCount': expensesCount,
        'odometerReadingsCount': odometerReadingsCount,
        'logsCount': logsCount,
        'totalRecords': totalRecords,
        'categories': ['vehicles', 'fuel', 'maintenance', 'expenses', 'odometer', 'logs'],
      };
    } catch (e) {
      return {
        'vehiclesCount': 0,
        'fuelRecordsCount': 0,
        'maintenanceRecordsCount': 0,
        'expensesCount': 0,
        'odometerReadingsCount': 0,
        'logsCount': 0,
        'totalRecords': 0,
        'categories': <String>[],
        'error': e.toString(),
      };
    }
  }

  /// Verifica se há dados para limpar
  Future<bool> hasDataToClear() async {
    final stats = await getDataStatsBeforeCleaning();
    return (stats['totalRecords'] as int) > 0;
  }

  /// Verifica se a limpeza foi bem-sucedida
  Future<bool> verifyDataCleanup() async {
    try {
      final stats = await getDataStatsBeforeCleaning();
      return (stats['totalRecords'] as int) == 0;
    } catch (e) {
      return false;
    }
  }

  /// Lista de categorias disponíveis para limpeza seletiva
  List<String> getAvailableCategories() {
    return ['vehicles', 'fuel', 'maintenance', 'expenses', 'odometer', 'logs', 'all'];
  }

  /// Limpa dados por categoria específica
  Future<Map<String, dynamic>> clearCategoryData(String category) async {
    switch (category) {
      case 'vehicles':
        return _clearVehiclesOnly();
      case 'fuel':
        return _clearFuelRecordsOnly();
      case 'maintenance':
        return _clearMaintenanceRecordsOnly();
      case 'expenses':
        return _clearExpensesOnly();
      case 'odometer':
        return _clearOdometerReadingsOnly();
      case 'logs':
        return _clearLogsOnly();
      case 'all':
      default:
        return clearAllAppData();
    }
  }

  /// Limpa apenas veículos
  Future<Map<String, dynamic>> _clearVehiclesOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final vehiclesResult = await vehicleRepository.getAllVehicles();
      if (vehiclesResult.isRight()) {
        final vehicles = vehiclesResult.getOrElse(() => []);
        for (final vehicle in vehicles) {
          try {
            await vehicleRepository.deleteVehicle(vehicle.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar veículo ${vehicle.id}: $e');
          }
        }
        result['totalRecordsCleared'] = vehicles.length;
        (result['clearedBoxes'] as List<String>).add('vehicles_box');
        result['success'] = (result['errors'] as List<String>).isEmpty;
      }
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }

  /// Limpa apenas registros de combustível
  Future<Map<String, dynamic>> _clearFuelRecordsOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final fuelResult = await fuelRepository.getAllFuelRecords();
      if (fuelResult.isRight()) {
        final fuelRecords = fuelResult.getOrElse(() => []);
        for (final fuel in fuelRecords) {
          try {
            await fuelRepository.deleteFuelRecord(fuel.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar abastecimento ${fuel.id}: $e');
          }
        }
        result['totalRecordsCleared'] = fuelRecords.length;
        (result['clearedBoxes'] as List<String>).add('fuel_records_box');
        result['success'] = (result['errors'] as List<String>).isEmpty;
      }
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }

  /// Limpa apenas registros de manutenção
  Future<Map<String, dynamic>> _clearMaintenanceRecordsOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final maintenanceResult = await maintenanceRepository.getAllMaintenanceRecords();
      if (maintenanceResult.isRight()) {
        final maintenanceRecords = maintenanceResult.getOrElse(() => []);
        for (final maintenance in maintenanceRecords) {
          try {
            await maintenanceRepository.deleteMaintenanceRecord(maintenance.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar manutenção ${maintenance.id}: $e');
          }
        }
        result['totalRecordsCleared'] = maintenanceRecords.length;
        (result['clearedBoxes'] as List<String>).add('maintenance_records_box');
        result['success'] = (result['errors'] as List<String>).isEmpty;
      }
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }

  /// Limpa apenas despesas
  Future<Map<String, dynamic>> _clearExpensesOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final expenses = await expensesRepository.getAllExpenses();
      for (final expense in expenses) {
        try {
          await expensesRepository.deleteExpense(expense.id);
        } catch (e) {
          (result['errors'] as List<String>).add('Erro ao deletar despesa ${expense.id}: $e');
        }
      }
      result['totalRecordsCleared'] = expenses.length;
      (result['clearedBoxes'] as List<String>).add('expenses_box');
      result['success'] = (result['errors'] as List<String>).isEmpty;
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }

  /// Limpa apenas leituras do odômetro
  Future<Map<String, dynamic>> _clearOdometerReadingsOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final readings = await odometerRepository.getAllOdometerReadings();
      for (final reading in readings) {
        try {
          await odometerRepository.deleteOdometerReading(reading.id);
        } catch (e) {
          (result['errors'] as List<String>).add('Erro ao deletar leitura odômetro ${reading.id}: $e');
        }
      }
      result['totalRecordsCleared'] = readings.length;
      (result['clearedBoxes'] as List<String>).add('odometer_readings_box');
      result['success'] = (result['errors'] as List<String>).isEmpty;
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }

  /// Limpa apenas logs
  Future<Map<String, dynamic>> _clearLogsOnly() async {
    final result = <String, dynamic>{
      'success': false,
      'clearedBoxes': <String>[],
      'errors': <String>[],
      'totalRecordsCleared': 0,
    };

    try {
      final logsResult = await logRepository.getAllLogs();
      if (logsResult.isRight()) {
        final logs = logsResult.getOrElse(() => []);
        for (final log in logs) {
          try {
            await logRepository.deleteLog(log.id);
          } catch (e) {
            (result['errors'] as List<String>).add('Erro ao deletar log ${log.id}: $e');
          }
        }
        result['totalRecordsCleared'] = logs.length;
        (result['clearedBoxes'] as List<String>).add('logs_box');
        result['success'] = (result['errors'] as List<String>).isEmpty;
      }
    } catch (e) {
      (result['errors'] as List<String>).add('Erro: $e');
    }

    return result;
  }
}