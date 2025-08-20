import 'package:core/core.dart';

/// Serviço de inspeção de database específico do GasOMeter
/// Integra o DatabaseInspectorService do core package com as boxes do app
class GasOMeterDatabaseInspectorService {
  static GasOMeterDatabaseInspectorService? _instance;
  static GasOMeterDatabaseInspectorService get instance {
    _instance ??= GasOMeterDatabaseInspectorService._internal();
    return _instance!;
  }

  GasOMeterDatabaseInspectorService._internal();

  /// Instance do serviço do core
  final DatabaseInspectorService _coreInspector = DatabaseInspectorService.instance;

  /// Nomes das boxes do GasOMeter
  static const String vehiclesBoxName = 'vehicles';
  static const String fuelRecordsBoxName = 'fuel_records';
  static const String maintenanceBoxName = 'maintenance';
  static const String odometerBoxName = 'odometer';
  static const String expensesBoxName = 'expenses';
  static const String syncQueueBoxName = 'sync_queue';
  static const String categoriesBoxName = 'categories';

  /// Inicializa o serviço e registra as boxes customizadas
  void initialize() {
    final customBoxes = [
      CustomBoxType(
        key: vehiclesBoxName,
        displayName: 'Veículos',
        description: 'Dados dos veículos cadastrados no app',
        module: 'Veículos',
      ),
      CustomBoxType(
        key: fuelRecordsBoxName,
        displayName: 'Abastecimentos',
        description: 'Registros de abastecimento de combustível',
        module: 'Combustível',
      ),
      CustomBoxType(
        key: maintenanceBoxName,
        displayName: 'Manutenções',
        description: 'Registros de manutenção dos veículos',
        module: 'Manutenção',
      ),
      CustomBoxType(
        key: odometerBoxName,
        displayName: 'Odômetro',
        description: 'Leituras do odômetro dos veículos',
        module: 'Odômetro',
      ),
      CustomBoxType(
        key: expensesBoxName,
        displayName: 'Despesas',
        description: 'Despesas relacionadas aos veículos',
        module: 'Despesas',
      ),
      CustomBoxType(
        key: syncQueueBoxName,
        displayName: 'Fila de Sincronização',
        description: 'Fila de itens pendentes para sincronização',
        module: 'Sincronização',
      ),
      CustomBoxType(
        key: categoriesBoxName,
        displayName: 'Categorias',
        description: 'Categorias para classificação de despesas',
        module: 'Categorias',
      ),
    ];

    _coreInspector.registerCustomBoxes(customBoxes);
  }

  /// Delegação dos métodos principais do core service
  Future<List<DatabaseRecord>> loadHiveBoxData(String boxKey) => 
      _coreInspector.loadHiveBoxData(boxKey);

  Future<List<SharedPreferencesRecord>> loadSharedPreferencesData() => 
      _coreInspector.loadSharedPreferencesData();

  Future<bool> removeSharedPreferencesKey(String key) => 
      _coreInspector.removeSharedPreferencesKey(key);

  Set<String> extractUniqueFields(List<DatabaseRecord> records) => 
      _coreInspector.extractUniqueFields(records);

  List<List<String>> convertToTableFormat(List<DatabaseRecord> records) => 
      _coreInspector.convertToTableFormat(records);

  String formatAsJsonString(Map<String, dynamic> data) => 
      _coreInspector.formatAsJsonString(data);

  List<String> getAvailableHiveBoxes() => 
      _coreInspector.getAvailableHiveBoxes();

  Map<String, dynamic> getBoxStats(String boxKey) => 
      _coreInspector.getBoxStats(boxKey);

  Map<String, dynamic> getGeneralStats() => 
      _coreInspector.getGeneralStats();

  String getBoxDisplayName(String key) => 
      _coreInspector.getBoxDisplayName(key);

  String? getBoxDescription(String key) => 
      _coreInspector.getBoxDescription(key);

  /// Obtém as boxes customizadas registradas
  List<CustomBoxType> get customBoxes => _coreInspector.customBoxes;

  /// Obtém estatísticas específicas do GasOMeter
  Map<String, dynamic> getGasOMeterStats() {
    final generalStats = getGeneralStats();
    final availableBoxes = getAvailableHiveBoxes();
    
    // Calcular estatísticas por módulo
    final moduleStats = <String, Map<String, dynamic>>{};
    
    for (final boxKey in availableBoxes) {
      final boxStats = getBoxStats(boxKey);
      final customBox = _coreInspector.customBoxes.where((box) => box.key == boxKey).firstOrNull;
      
      if (customBox != null) {
        final module = customBox.module ?? 'Outros';
        
        if (!moduleStats.containsKey(module)) {
          moduleStats[module] = {
            'totalBoxes': 0,
            'totalRecords': 0,
            'boxes': <String>[],
          };
        }
        
        moduleStats[module]!['totalBoxes'] = (moduleStats[module]!['totalBoxes'] as int) + 1;
        moduleStats[module]!['totalRecords'] = (moduleStats[module]!['totalRecords'] as int) + (boxStats['totalRecords'] as int? ?? 0);
        (moduleStats[module]!['boxes'] as List<String>).add(boxKey);
      }
    }

    return {
      ...generalStats,
      'appName': 'GasOMeter',
      'moduleStats': moduleStats,
      'registeredBoxes': _coreInspector.customBoxes.length,
      'totalModules': moduleStats.keys.length,
    };
  }

  /// Lista todas as boxes do GasOMeter com suas informações
  List<Map<String, dynamic>> getGasOMeterBoxesInfo() {
    final availableBoxes = getAvailableHiveBoxes();
    final boxesInfo = <Map<String, dynamic>>[];

    for (final boxKey in availableBoxes) {
      final stats = getBoxStats(boxKey);
      final customBox = _coreInspector.customBoxes.where((box) => box.key == boxKey).firstOrNull;

      boxesInfo.add({
        'key': boxKey,
        'displayName': getBoxDisplayName(boxKey),
        'description': getBoxDescription(boxKey),
        'module': customBox?.module ?? 'Outros',
        'totalRecords': stats['totalRecords'] ?? 0,
        'isOpen': stats['isOpen'] ?? false,
        'hasError': stats.containsKey('error'),
        'error': stats['error'],
      });
    }

    // Ordenar por módulo e depois por nome
    boxesInfo.sort((a, b) {
      final moduleComparison = (a['module'] as String).compareTo(b['module'] as String);
      if (moduleComparison != 0) return moduleComparison;
      return (a['displayName'] as String).compareTo(b['displayName'] as String);
    });

    return boxesInfo;
  }

  /// Verifica se uma box está disponível e acessível
  bool isBoxAvailable(String boxKey) {
    try {
      final stats = getBoxStats(boxKey);
      return !stats.containsKey('error');
    } catch (e) {
      return false;
    }
  }

  /// Obtém resumo rápido de uma box
  Map<String, dynamic> getBoxSummary(String boxKey) {
    final stats = getBoxStats(boxKey);
    return {
      'key': boxKey,
      'displayName': getBoxDisplayName(boxKey),
      'totalRecords': stats['totalRecords'] ?? 0,
      'isAvailable': !stats.containsKey('error'),
      'module': _coreInspector.customBoxes.where((box) => box.key == boxKey).firstOrNull?.module,
    };
  }
}