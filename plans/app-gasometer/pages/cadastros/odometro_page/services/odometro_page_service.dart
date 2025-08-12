// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../../../../database/20_odometro_model.dart';
import '../../../../repository/odometro_repository.dart';
import '../../../../repository/veiculos_repository.dart';
import '../services/error_handler_service.dart';
import '../services/odometro_event_bus.dart';

/// Service responsible for business logic operations in the Odometro module
class OdometroPageService extends GetxController with OdometroEventMixin {
  // Migrated functionality from OdometroListController
  final _repository = OdometroRepository();
  final _veiculosRepository = VeiculosRepository();

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<DateTime, List<OdometroCar>> odometros =
      <DateTime, List<OdometroCar>>{}.obs;
  final Rx<DateTime?> selectedMonth = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();

    // Subscribe to events instead of direct coupling
    subscribeToEvent(OdometroEventType.monthSelected, _handleMonthSelection);
  }

  void _handleMonthSelection(OdometroEvent event) {
    if (event.data is DateTime) {
      updateSelectedMonth(event.data);
    }
  }

  /// Load odometer data with proper error handling and retry mechanism
  Future<Map<DateTime, List<OdometroCar>>> loadOdometroData() async {
    return await ErrorHandlerService.withRetry(() async {
      return await carregarOdometros();
    });
  }

  /// Get months list for navigation
  List<DateTime> getMonthsList() {
    return getMonthsListInternal();
  }

  /// Update selected month in the internal state (via event bus)
  void updateSelectedMonth(DateTime month) {
    // Emit event to maintain decoupling
    emitEvent(OdometroEventType.monthSelected, data: month);

    // Update internal state
    setSelectedMonth(month);
  }

  /// Get odometer readings for a specific month
  List<OdometroCar> getOdometrosForMonth(
    DateTime month,
    Map<DateTime, List<OdometroCar>> odometros,
  ) {
    return odometros[month] ?? [];
  }

  /// Check if there's data for a specific month
  bool hasDataForMonth(
    DateTime month,
    Map<DateTime, List<OdometroCar>> odometros,
  ) {
    return odometros.containsKey(month) && odometros[month]!.isNotEmpty;
  }

  /// Calculate difference between consecutive odometer readings
  double calculateDifference(List<OdometroCar> odometros, int index) {
    if (index < odometros.length - 1) {
      return odometros[index].odometro - odometros[index + 1].odometro;
    }
    return 0.0;
  }

  /// Get statistics for a specific month
  Map<String, dynamic> getStatisticsForMonth(
    DateTime month,
    Map<DateTime, List<OdometroCar>> odometros,
  ) {
    final monthOdometros = getOdometrosForMonth(month, odometros);
    if (monthOdometros.isEmpty) {
      return {
        'totalRecords': 0,
        'totalDistance': 0.0,
        'averagePerDay': 0.0,
        'maxOdometer': 0.0,
        'minOdometer': 0.0,
      };
    }

    final sortedOdometros = List<OdometroCar>.from(monthOdometros)
      ..sort((a, b) => a.odometro.compareTo(b.odometro));

    final totalDistance =
        sortedOdometros.last.odometro - sortedOdometros.first.odometro;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final averagePerDay = totalDistance / daysInMonth;

    return {
      'totalRecords': monthOdometros.length,
      'totalDistance': totalDistance,
      'averagePerDay': averagePerDay,
      'maxOdometer': sortedOdometros.last.odometro,
      'minOdometer': sortedOdometros.first.odometro,
    };
  }

  /// Get overall statistics across all months
  Map<String, dynamic> getOverallStatistics(
    Map<DateTime, List<OdometroCar>> odometros,
  ) {
    if (odometros.isEmpty) {
      return {
        'totalRecords': 0,
        'totalMonths': 0,
        'totalDistance': 0.0,
        'averageRecordsPerMonth': 0.0,
      };
    }

    final allOdometros = odometros.values.expand((list) => list).toList();
    if (allOdometros.isEmpty) {
      return {
        'totalRecords': 0,
        'totalMonths': odometros.length,
        'totalDistance': 0.0,
        'averageRecordsPerMonth': 0.0,
      };
    }

    final sortedOdometros = List<OdometroCar>.from(allOdometros)
      ..sort((a, b) => a.odometro.compareTo(b.odometro));

    final totalDistance =
        sortedOdometros.last.odometro - sortedOdometros.first.odometro;
    final averageRecordsPerMonth = allOdometros.length / odometros.length;

    return {
      'totalRecords': allOdometros.length,
      'totalMonths': odometros.length,
      'totalDistance': totalDistance,
      'averageRecordsPerMonth': averageRecordsPerMonth,
    };
  }

  /// Search odometer readings by query
  List<OdometroCar> searchOdometros(
    String query,
    Map<DateTime, List<OdometroCar>> odometros,
  ) {
    if (query.isEmpty) return [];

    final allOdometros = odometros.values.expand((list) => list).toList();
    return allOdometros.where((odometro) {
      final searchTerm = query.toLowerCase();
      return odometro.descricao.toLowerCase().contains(searchTerm) ||
          odometro.odometro.toString().contains(searchTerm);
    }).toList();
  }

  /// Get odometer readings in a date range
  List<OdometroCar> getOdometrosInRange(
    DateTime start,
    DateTime end,
    Map<DateTime, List<OdometroCar>> odometros,
  ) {
    final result = <OdometroCar>[];
    for (final entry in odometros.entries) {
      if (entry.key.isAfter(start.subtract(const Duration(days: 1))) &&
          entry.key.isBefore(end.add(const Duration(days: 1)))) {
        result.addAll(entry.value);
      }
    }
    return result;
  }

  /// Validate odometer reading against previous readings
  ValidationResult validateOdometerReading(
    double newReading,
    List<OdometroCar> existingReadings, {
    double maxDailyIncrease = 1000.0, // km per day
    double maxReverseAllowed = 50.0, // km reverse allowed (meter rollback)
  }) {
    if (existingReadings.isEmpty) {
      return ValidationResult(isValid: true);
    }

    // Sort by date to get the most recent reading
    final sortedReadings = List<OdometroCar>.from(existingReadings)
      ..sort((a, b) => b.data.compareTo(a.data));

    final lastReading = sortedReadings.first;
    final difference = newReading - lastReading.odometro;
    final daysDifference = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastReading.data))
        .inDays;

    // Check for excessive increase
    if (difference > maxDailyIncrease * (daysDifference + 1)) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Aumento muito alto no odômetro',
        suggestion: 'Verifique se o valor está correto',
      );
    }

    // Check for excessive reverse (allowing some rollback)
    if (difference < -maxReverseAllowed) {
      return ValidationResult(
        isValid: false,
        errorMessage: 'Valor menor que a leitura anterior',
        suggestion: 'O odômetro não pode diminuir significativamente',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// Calculate fuel efficiency if fuel data is available
  Map<String, double> calculateFuelEfficiency(
    List<OdometroCar> odometros,
    Map<DateTime, double> fuelConsumption,
  ) {
    if (odometros.length < 2) {
      return {'efficiency': 0.0, 'totalDistance': 0.0, 'totalFuel': 0.0};
    }

    final sortedOdometros = List<OdometroCar>.from(odometros)
      ..sort((a, b) => a.data.compareTo(b.data));

    final totalDistance =
        sortedOdometros.last.odometro - sortedOdometros.first.odometro;
    final totalFuel =
        fuelConsumption.values.fold(0.0, (sum, fuel) => sum + fuel);

    final efficiency = totalFuel > 0 ? totalDistance / totalFuel : 0.0;

    return {
      'efficiency': efficiency,
      'totalDistance': totalDistance,
      'totalFuel': totalFuel,
    };
  }

  /// Get usage patterns and insights
  Map<String, dynamic> getUsageInsights(
    Map<DateTime, List<OdometroCar>> odometros,
  ) {
    if (odometros.isEmpty) {
      return {'insights': [], 'patterns': {}};
    }

    final insights = <String>[];
    final patterns = <String, dynamic>{};

    // Calculate monthly usage patterns
    final monthlyDistances = <DateTime, double>{};
    for (final entry in odometros.entries) {
      final monthReadings = entry.value;
      if (monthReadings.length >= 2) {
        final sorted = List<OdometroCar>.from(monthReadings)
          ..sort((a, b) => a.odometro.compareTo(b.odometro));
        monthlyDistances[entry.key] =
            sorted.last.odometro - sorted.first.odometro;
      }
    }

    if (monthlyDistances.isNotEmpty) {
      final avgMonthlyDistance =
          monthlyDistances.values.reduce((a, b) => a + b) /
              monthlyDistances.length;
      patterns['averageMonthlyDistance'] = avgMonthlyDistance;

      // Find high usage months
      final highUsageMonths = monthlyDistances.entries
          .where((entry) => entry.value > avgMonthlyDistance * 1.5)
          .map((entry) => entry.key)
          .toList();

      if (highUsageMonths.isNotEmpty) {
        insights.add('Meses de alto uso detectados');
        patterns['highUsageMonths'] = highUsageMonths;
      }

      // Find low usage months
      final lowUsageMonths = monthlyDistances.entries
          .where((entry) => entry.value < avgMonthlyDistance * 0.5)
          .map((entry) => entry.key)
          .toList();

      if (lowUsageMonths.isNotEmpty) {
        insights.add('Meses de baixo uso detectados');
        patterns['lowUsageMonths'] = lowUsageMonths;
      }
    }

    return {
      'insights': insights,
      'patterns': patterns,
    };
  }

  /// Export data for backup or sharing
  Map<String, dynamic> exportData(Map<DateTime, List<OdometroCar>> odometros) {
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'totalMonths': odometros.length,
      'totalRecords':
          odometros.values.fold(0, (sum, list) => sum + list.length),
      'data': odometros.map((key, value) => MapEntry(
            key.millisecondsSinceEpoch.toString(),
            value.map((o) => o.toMap()).toList(),
          )),
    };
  }

  // Migrated methods from OdometroListController
  Future<Map<DateTime, List<OdometroCar>>> carregarOdometros() async {
    isLoading.value = true;
    error.value = '';
    Map<DateTime, List<OdometroCar>> result = {};

    try {
      // Carrega o ID do veículo selecionado do SharedPreferences
      String veiculoId = await _veiculosRepository.getSelectedVeiculoId();
      if (veiculoId.isNotEmpty) {
        result = await _repository.getOdometrosAgrupados(veiculoId);

        odometros.assignAll(result);

        if (result.isNotEmpty && selectedMonth.value == null) {
          selectedMonth.value = result.keys.first;
        }
      } else {
        odometros.clear();
        selectedMonth.value = null;
      }
      return result;
    } catch (e) {
      error.value = 'Erro ao carregar registros de odômetro: $e';
      debugPrint('Erro ao carregar registros de odômetro: $e');
      return {};
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedMonth(DateTime month) {
    selectedMonth.value = month;
  }

  List<DateTime> getMonthsListInternal() {
    if (odometros.isEmpty) return [];
    return odometros.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  Map<String, double> calcularEstatisticasMes(DateTime mes) {
    final odometrosDoMes = odometros[mes] ?? [];

    double kmInicial = 0.0;
    double kmFinal = 0.0;
    double distanciaTotal = 0.0;
    double mediaKmDia = 0.0;

    if (odometrosDoMes.isNotEmpty) {
      kmInicial = odometrosDoMes.last.odometro;
      kmFinal = odometrosDoMes.first.odometro;
      distanciaTotal = kmFinal - kmInicial;

      if (odometrosDoMes.length > 1) {
        mediaKmDia = distanciaTotal / (odometrosDoMes.length - 1);
      }
    }

    return {
      'kmInicial': kmInicial,
      'kmFinal': kmFinal,
      'distanciaTotal': distanciaTotal,
      'mediaKmDia': mediaKmDia,
    };
  }

  Future<OdometroCar?> getOdometroById(String id) async {
    try {
      return await _repository.getOdometroById(id);
    } catch (e) {
      error.value = 'Erro ao buscar registro de odômetro: $e';
      debugPrint('Erro ao buscar registro de odômetro: $e');
      return null;
    }
  }

  Future<Map<String, Map<String, double>>> getEstatisticas() async {
    try {
      // Carrega o ID do veículo selecionado do SharedPreferences
      String veiculoId = await _veiculosRepository.getSelectedVeiculoId();
      if (veiculoId.isEmpty) {
        return {
          'esteMes': {'inicial': 0, 'final': 0, 'diferenca': 0},
          'mesAnterior': {'inicial': 0, 'final': 0, 'diferenca': 0},
          'esteAno': {'inicial': 0, 'final': 0, 'diferenca': 0},
          'anoAnterior': {'inicial': 0, 'final': 0, 'diferenca': 0},
        };
      }

      return await _repository.getOdometroEstatisticas(veiculoId);
    } catch (e) {
      error.value = 'Erro ao carregar estatísticas de odômetro: $e';
      debugPrint('Erro ao carregar estatísticas de odômetro: $e');
      return {
        'esteMes': {'inicial': 0, 'final': 0, 'diferenca': 0},
        'mesAnterior': {'inicial': 0, 'final': 0, 'diferenca': 0},
        'esteAno': {'inicial': 0, 'final': 0, 'diferenca': 0},
        'anoAnterior': {'inicial': 0, 'final': 0, 'diferenca': 0},
      };
    }
  }

  Future<bool> removerOdometro(OdometroCar odometro) async {
    isLoading.value = true;
    error.value = '';

    try {
      final result = await _repository.deleteOdometro(odometro);
      if (result) {
        await carregarOdometros();
      }
      return result;
    } catch (e) {
      error.value = 'Erro ao remover registro de odômetro: $e';
      debugPrint('Erro ao remover registro de odômetro: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> atualizarLista() async {
    await carregarOdometros();
  }
}

/// Validation result class for odometer readings
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? suggestion;

  ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.suggestion,
  });
}
