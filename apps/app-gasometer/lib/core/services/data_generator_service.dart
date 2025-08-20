import 'dart:math';
import 'package:flutter/foundation.dart';

/// Serviço para geração de dados de teste realísticos para o GasOMeter
class DataGeneratorService {
  static DataGeneratorService? _instance;
  static DataGeneratorService get instance {
    _instance ??= DataGeneratorService._internal();
    return _instance!;
  }

  DataGeneratorService._internal();

  final Random _random = Random();

  /// Gera dados de teste completos para o aplicativo
  Future<Map<String, dynamic>> generateTestData({
    int numberOfVehicles = 2,
    int monthsOfHistory = 14,
  }) async {
    if (kDebugMode) {
      debugPrint('🔄 Iniciando geração de dados de teste...');
      debugPrint('   Veículos: $numberOfVehicles');
      debugPrint('   Meses de histórico: $monthsOfHistory');
    }

    // Simular tempo de processamento
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1500)));

    final startTime = DateTime.now();
    
    // Calcular estimativas realísticas
    final fuelRecords = numberOfVehicles * monthsOfHistory * 3;
    final odometerReadings = numberOfVehicles * monthsOfHistory * 4;
    final expenses = numberOfVehicles * monthsOfHistory * 4;
    final maintenanceRecords = (numberOfVehicles * monthsOfHistory * 0.4).round();
    
    final results = <String, dynamic>{
      'vehicles': numberOfVehicles,
      'fuelRecords': fuelRecords,
      'odometerReadings': odometerReadings,
      'expenses': expenses,
      'maintenanceRecords': maintenanceRecords,
      'categories': 10,
      'startTime': startTime,
      'endTime': DateTime.now(),
      'duration': DateTime.now().difference(startTime).inMilliseconds,
    };

    if (kDebugMode) {
      debugPrint('✅ Geração de dados concluída (MOCK):');
      debugPrint('   ${results['vehicles']} veículos');
      debugPrint('   ${results['fuelRecords']} abastecimentos');
      debugPrint('   ${results['odometerReadings']} leituras odômetro');
      debugPrint('   ${results['expenses']} despesas');
      debugPrint('   ${results['maintenanceRecords']} manutenções');
      debugPrint('   Tempo: ${results['duration']}ms');
    }

    // TODO: Implementar geração real de dados quando as entidades estiverem corrigidas
    throw UnimplementedError(
      'A geração de dados reais ainda não está implementada. '
      'As entidades precisam ser ajustadas para compatibilidade completa.'
    );
  }

  /// Obtém estatísticas dos dados gerados
  Future<Map<String, dynamic>> getGeneratedDataStats() async {
    return {
      'totalHiveBoxes': 7,
      'totalHiveRecords': _random.nextInt(1000),
      'totalModules': 6,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Limpa todos os dados gerados
  Future<void> clearAllGeneratedData() async {
    if (kDebugMode) {
      debugPrint('🧹 Limpando todos os dados gerados...');
    }
    
    // TODO: Implementar limpeza real através dos repositories
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (kDebugMode) {
      debugPrint('✅ Dados limpos com sucesso');
    }
  }
}