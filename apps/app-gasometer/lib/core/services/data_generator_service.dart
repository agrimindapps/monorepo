import 'dart:math';
import 'package:flutter/foundation.dart';

/// Serviço para geração de dados de teste realísticos para o GasOMeter
///
/// ⚠️ DEVELOPMENT MODE:
/// Este serviço atualmente retorna MOCK data apenas para demonstração.
/// O UnimplementedError é INTENCIONAL e capturado pelo GenerateDataDialog.
/// Não causa crash - mostra mensagem amigável ao usuário.
class DataGeneratorService {
  DataGeneratorService._internal();
  static DataGeneratorService? _instance;
  static DataGeneratorService get instance {
    _instance ??= DataGeneratorService._internal();
    return _instance!;
  }

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
    await Future<void>.delayed(
      Duration(milliseconds: 500 + _random.nextInt(1500)),
    );

    final startTime = DateTime.now();
    final fuelRecords = numberOfVehicles * monthsOfHistory * 3;
    final odometerReadings = numberOfVehicles * monthsOfHistory * 4;
    final expenses = numberOfVehicles * monthsOfHistory * 4;
    final maintenanceRecords =
        (numberOfVehicles * monthsOfHistory * 0.4).round();

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
    // INTENTIONAL: Exception is caught by GenerateDataDialog (line 105)
    // Shows user-friendly message instead of crashing
    throw UnimplementedError(
      'DataGeneratorService: Geração de dados reais ainda não implementada. '
      'Este serviço atualmente apenas simula estatísticas. '
      'Para implementação completa, ajustar entidades para compatibilidade com geração de dados realistas.',
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
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (kDebugMode) {
      debugPrint('✅ Dados limpos com sucesso');
    }
  }
}
