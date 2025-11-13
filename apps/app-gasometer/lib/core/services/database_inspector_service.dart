/// Serviço de inspeção de database específico do GasOMeter
/// Migrado para usar Drift database
class GasOMeterDatabaseInspectorService {

  GasOMeterDatabaseInspectorService._internal();
  static GasOMeterDatabaseInspectorService? _instance;
  static GasOMeterDatabaseInspectorService get instance {
    _instance ??= GasOMeterDatabaseInspectorService._internal();
    return _instance!;
  }

  /// Database tables do GasOMeter (Drift)
  static const String vehiclesTableName = 'vehicles';
  static const String fuelRecordsTableName = 'fuel_supplies';
  static const String maintenanceTableName = 'maintenances';
  static const String odometerTableName = 'odometer_readings';
  static const String expensesTableName = 'expenses';
  static const String auditTrailTableName = 'audit_trail';

  /// Inicializa o serviço (Drift-based)
  void initialize() {
    print('🔧 GasOMeter Database Inspector initialized (Drift-based)');
  }

  /// Obtém estatísticas específicas do GasOMeter
  Map<String, dynamic> getGasOMeterStats() {
    return {
      'appName': 'GasOMeter',
      'databaseType': 'Drift (SQLite)',
      'tables': [
        vehiclesTableName,
        fuelRecordsTableName,
        maintenanceTableName,
        odometerTableName,
        expensesTableName,
        auditTrailTableName,
      ],
      'totalTables': 6,
    };
  }

  /// Lista todas as tabelas do GasOMeter com suas informações
  List<Map<String, dynamic>> getGasOMeterTablesInfo() {
    return [
      {
        'name': vehiclesTableName,
        'displayName': 'Veículos',
        'description': 'Dados dos veículos cadastrados no app',
        'module': 'Veículos',
      },
      {
        'name': fuelRecordsTableName,
        'displayName': 'Abastecimentos',
        'description': 'Registros de abastecimento de combustível',
        'module': 'Combustível',
      },
      {
        'name': maintenanceTableName,
        'displayName': 'Manutenções',
        'description': 'Registros de manutenção dos veículos',
        'module': 'Manutenção',
      },
      {
        'name': odometerTableName,
        'displayName': 'Odômetro',
        'description': 'Leituras do odômetro dos veículos',
        'module': 'Odômetro',
      },
      {
        'name': expensesTableName,
        'displayName': 'Despesas',
        'description': 'Despesas relacionadas aos veículos',
        'module': 'Despesas',
      },
      {
        'name': auditTrailTableName,
        'displayName': 'Trilha de Auditoria',
        'description': 'Registro de mudanças no sistema',
        'module': 'Auditoria',
      },
    ];
  }

  /// Verifica se uma tabela está disponível
  bool isTableAvailable(String tableName) {
    final tables = [
      vehiclesTableName,
      fuelRecordsTableName,
      maintenanceTableName,
      odometerTableName,
      expensesTableName,
      auditTrailTableName,
    ];
    return tables.contains(tableName);
  }

  /// Obtém resumo rápido de uma tabela
  Map<String, dynamic> getTableSummary(String tableName) {
    final tableInfo = getGasOMeterTablesInfo()
        .firstWhere((t) => t['name'] == tableName, orElse: () => {});
    
    return {
      'name': tableName,
      'displayName': tableInfo['displayName'] ?? tableName,
      'isAvailable': isTableAvailable(tableName),
      'module': tableInfo['module'] ?? 'Outros',
    };
  }
}
