import 'package:core/core.dart';

import '../../../../database/gasometer_database.dart';

/// Implementação de IAppDataCleaner para o app Gasometer
/// Responsável por limpar todos os dados locais do app usando Drift
class GasometerDataCleaner implements IAppDataCleaner {

  GasometerDataCleaner(this._database);
  final GasometerDatabase _database;

  @override
  String get appName => 'Gasometer';

  @override
  String get version => '1.0.0';

  @override
  String get description =>
      'Limpa todos os dados do app Gasometer incluindo veículos, combustível, manutenções e despesas';

  @override
  Future<Map<String, dynamic>> clearAllAppData() async {
    final clearedTables = <String>[];
    final errors = <String>[];
    var totalRecordsCleared = 0;

    try {
      // Limpar todas as tabelas Drift
      final tablesToClear = [
        'vehicles',
        'fuel_supplies',
        'odometer_readings',
        'expenses',
        'maintenances',
        'audit_trail',
      ];

      for (final tableName in tablesToClear) {
        try {
          int count = 0;

          switch (tableName) {
            case 'vehicles':
              count = await _database
                  .select(_database.vehicles)
                  .get()
                  .then((list) => list.length);
              await (_database.delete(
                _database.vehicles,
              )..where((tbl) => tbl.id.isNotNull())).go();
              break;
            case 'fuel_supplies':
              count = await _database
                  .select(_database.fuelSupplies)
                  .get()
                  .then((list) => list.length);
              await (_database.delete(
                _database.fuelSupplies,
              )..where((tbl) => tbl.id.isNotNull())).go();
              break;
            case 'odometer_readings':
              count = await _database
                  .select(_database.odometerReadings)
                  .get()
                  .then((list) => list.length);
              await (_database.delete(
                _database.odometerReadings,
              )..where((tbl) => tbl.id.isNotNull())).go();
              break;
            case 'expenses':
              count = await _database
                  .select(_database.expenses)
                  .get()
                  .then((list) => list.length);
              await (_database.delete(
                _database.expenses,
              )..where((tbl) => tbl.id.isNotNull())).go();
              break;
            case 'maintenances':
              count = await _database
                  .select(_database.maintenances)
                  .get()
                  .then((list) => list.length);
              await (_database.delete(
                _database.maintenances,
              )..where((tbl) => tbl.id.isNotNull())).go();
              break;
            case 'audit_trail':
              count = await _database
                  .select(_database.auditTrail)
                  .get()
                  .then((list) => list.length);
              await (_database.delete(
                _database.auditTrail,
              )..where((tbl) => tbl.id.isNotNull())).go();
              break;
          }

          clearedTables.add(tableName);
          totalRecordsCleared += count;
        } catch (e) {
          errors.add('Erro ao limpar tabela $tableName: $e');
        }
      }

      return {
        'success': errors.isEmpty,
        'clearedBoxes':
            clearedTables, // Mantém nome do campo para compatibilidade
        'clearedPreferences': <String>[],
        'errors': errors,
        'totalRecordsCleared': totalRecordsCleared,
      };
    } catch (e) {
      errors.add('Erro geral na limpeza: $e');
      return {
        'success': false,
        'clearedBoxes': clearedTables,
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

    try {
      // Contar registros em cada tabela Drift
      final vehiclesCount = await _database
          .select(_database.vehicles)
          .get()
          .then((list) => list.length);
      stats['vehicles'] = vehiclesCount;
      totalRecords += vehiclesCount;

      final fuelCount = await _database
          .select(_database.fuelSupplies)
          .get()
          .then((list) => list.length);
      stats['fuel_supplies'] = fuelCount;
      totalRecords += fuelCount;

      final odometerCount = await _database
          .select(_database.odometerReadings)
          .get()
          .then((list) => list.length);
      stats['odometer_readings'] = odometerCount;
      totalRecords += odometerCount;

      final expensesCount = await _database
          .select(_database.expenses)
          .get()
          .then((list) => list.length);
      stats['expenses'] = expensesCount;
      totalRecords += expensesCount;

      final maintenanceCount = await _database
          .select(_database.maintenances)
          .get()
          .then((list) => list.length);
      stats['maintenances'] = maintenanceCount;
      totalRecords += maintenanceCount;

      final auditCount = await _database
          .select(_database.auditTrail)
          .get()
          .then((list) => list.length);
      stats['audit_trail'] = auditCount;
      totalRecords += auditCount;
    } catch (e) {
      // Em caso de erro, retorna valores zerados
      return {'totalRecords': 0, 'boxStats': stats};
    }

    return {'totalRecords': totalRecords, 'boxStats': stats};
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
      'odometer_readings',
      'expenses',
      'maintenances',
      'audit_trail',
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
      switch (category) {
        case 'vehicles':
          totalRecordsCleared = await _database
              .select(_database.vehicles)
              .get()
              .then((list) => list.length);
          await (_database.delete(
            _database.vehicles,
          )..where((tbl) => tbl.id.isNotNull())).go();
          break;
        case 'fuel_supplies':
          totalRecordsCleared = await _database
              .select(_database.fuelSupplies)
              .get()
              .then((list) => list.length);
          await (_database.delete(
            _database.fuelSupplies,
          )..where((tbl) => tbl.id.isNotNull())).go();
          break;
        case 'odometer_readings':
          totalRecordsCleared = await _database
              .select(_database.odometerReadings)
              .get()
              .then((list) => list.length);
          await (_database.delete(
            _database.odometerReadings,
          )..where((tbl) => tbl.id.isNotNull())).go();
          break;
        case 'expenses':
          totalRecordsCleared = await _database
              .select(_database.expenses)
              .get()
              .then((list) => list.length);
          await (_database.delete(
            _database.expenses,
          )..where((tbl) => tbl.id.isNotNull())).go();
          break;
        case 'maintenances':
          totalRecordsCleared = await _database
              .select(_database.maintenances)
              .get()
              .then((list) => list.length);
          await (_database.delete(
            _database.maintenances,
          )..where((tbl) => tbl.id.isNotNull())).go();
          break;
        case 'audit_trail':
          totalRecordsCleared = await _database
              .select(_database.auditTrail)
              .get()
              .then((list) => list.length);
          await (_database.delete(
            _database.auditTrail,
          )..where((tbl) => tbl.id.isNotNull())).go();
          break;
        default:
          errors.add('Categoria desconhecida: $category');
      }

      return {
        'success': errors.isEmpty,
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
