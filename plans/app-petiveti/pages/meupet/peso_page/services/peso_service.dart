// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/17_peso_model.dart';
import '../models/peso_calculation_model.dart';

/// Service for peso business logic and operations
class PesoService {
  
  /// Create a new peso record from form data
  PesoAnimal createPesoFromFormData({
    required String animalId,
    required double peso,
    required int dataPesagem,
    String? observacoes,
    String? id,
    String? objectId,
    int? createdAt,
    int? updatedAt,
    bool? active,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return PesoAnimal(
      id: id ?? _generateId(),
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      isDeleted: !(active ?? true),
      needsSync: true,
      version: 1,
      lastSyncAt: null,
      animalId: animalId,
      peso: peso,
      dataPesagem: dataPesagem,
      observacoes: observacoes?.trim(),
    );
  }

  /// Update existing peso record
  PesoAnimal updatePesoFromFormData({
    required PesoAnimal existingPeso,
    required double peso,
    required int dataPesagem,
    String? observacoes,
  }) {
    return PesoAnimal(
      id: existingPeso.id,
      createdAt: existingPeso.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      isDeleted: existingPeso.isDeleted,
      needsSync: true,
      version: existingPeso.version + 1,
      lastSyncAt: existingPeso.lastSyncAt,
      animalId: existingPeso.animalId,
      peso: peso,
      dataPesagem: dataPesagem,
      observacoes: observacoes?.trim(),
    );
  }

  /// Validate peso data
  Map<String, String?> validatePesoData({
    required double? peso,
    required int? dataPesagem,
    required Animal? animal,
    String? observacoes,
  }) {
    final errors = <String, String?>{};

    // Validate peso
    if (peso == null || peso <= 0) {
      errors['peso'] = 'Peso é obrigatório e deve ser maior que zero';
    } else if (animal != null) {
      final pesoError = PesoCalculationModel.validatePeso(peso, animal);
      if (pesoError != null) {
        errors['peso'] = pesoError;
      }
    }

    // Validate date
    if (dataPesagem == null) {
      errors['dataPesagem'] = 'Data de pesagem é obrigatória';
    } else {
      final date = DateTime.fromMillisecondsSinceEpoch(dataPesagem);
      final now = DateTime.now();
      
      if (date.isAfter(now)) {
        errors['dataPesagem'] = 'Data não pode ser no futuro';
      }
      
      if (date.year < 1900) {
        errors['dataPesagem'] = 'Data muito antiga';
      }
    }

    // Validate observations
    if (observacoes != null && observacoes.length > 500) {
      errors['observacoes'] = 'Observações devem ter no máximo 500 caracteres';
    }

    // Validate animal
    if (animal == null) {
      errors['animal'] = 'Animal deve ser selecionado';
    }

    return errors;
  }

  /// Check if peso data is valid for submission
  bool isPesoDataValid({
    required double? peso,
    required int? dataPesagem,
    required Animal? animal,
    String? observacoes,
  }) {
    final errors = validatePesoData(
      peso: peso,
      dataPesagem: dataPesagem,
      animal: animal,
      observacoes: observacoes,
    );
    
    return errors.isEmpty;
  }

  /// Get error message from exception
  String getErrorMessage(dynamic error) {
    if (error == null) return 'Erro desconhecido';
    
    if (error is SocketException) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    
    if (error is FormatException) {
      return 'Erro no formato dos dados.';
    }
    
    if (error is ArgumentError) {
      return 'Dados inválidos: ${error.message}';
    }
    
    final errorMessage = error.toString();
    
    // Handle common error patterns
    if (errorMessage.contains('permission')) {
      return 'Sem permissão para realizar esta operação';
    }
    
    if (errorMessage.contains('timeout')) {
      return 'Operação expirou. Tente novamente.';
    }
    
    if (errorMessage.contains('not found')) {
      return 'Registro não encontrado';
    }
    
    if (errorMessage.contains('duplicate')) {
      return 'Registro duplicado';
    }
    
    // Return a user-friendly message for unknown errors
    if (kDebugMode) {
      return 'Erro: $errorMessage';
    } else {
      return 'Erro interno. Tente novamente.';
    }
  }

  /// Calculate peso statistics
  PesoStatistics calculateStatistics(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) {
      return PesoStatistics.empty();
    }

    final weights = pesos.map((p) => p.peso).toList();
    weights.sort();

    final sum = weights.reduce((a, b) => a + b);
    final average = sum / weights.length;
    final min = weights.first;
    final max = weights.last;

    // Calculate median
    final median = weights.length.isOdd
        ? weights[weights.length ~/ 2]
        : (weights[weights.length ~/ 2 - 1] + weights[weights.length ~/ 2]) / 2;

    // Calculate trend
    final trend = PesoCalculationModel.getWeightTrend(pesos);

    return PesoStatistics(
      count: pesos.length,
      average: average,
      median: median,
      min: min,
      max: max,
      trend: trend,
    );
  }

  /// Generate suggestions based on peso data
  List<String> generateSuggestions(List<PesoAnimal> pesos, Animal animal) {
    final suggestions = <String>[];
    
    if (pesos.isEmpty) {
      suggestions.add('Registre o primeiro peso do ${animal.nome}');
      return suggestions;
    }

    final statistics = calculateStatistics(pesos);
    final category = PesoCalculationModel.getWeightCategory(statistics.max, animal);
    final daysSince = PesoCalculationModel.daysSinceLastWeighing(pesos);

    // Weight category suggestions
    switch (category) {
      case WeightCategory.underweight:
        suggestions.add('${animal.nome} está abaixo do peso. Consulte um veterinário.');
        break;
      case WeightCategory.overweight:
        suggestions.add('${animal.nome} está acima do peso. Considere exercícios e dieta.');
        break;
      case WeightCategory.obese:
        suggestions.add('${animal.nome} está obeso. Consulte urgentemente um veterinário.');
        break;
      case WeightCategory.normal:
        suggestions.add('Peso do ${animal.nome} está normal. Continue assim!');
        break;
    }

    // Frequency suggestions
    if (daysSince > 30) {
      suggestions.add('Faz tempo que ${animal.nome} não é pesado. Agende uma pesagem.');
    }

    // Trend suggestions
    switch (statistics.trend) {
      case WeightTrend.consistentGaining:
        suggestions.add('${animal.nome} está ganhando peso consistentemente. Monitore a dieta.');
        break;
      case WeightTrend.consistentLosing:
        suggestions.add('${animal.nome} está perdendo peso. Verifique com veterinário.');
        break;
      default:
        break;
    }

    return suggestions;
  }

  /// Check if peso record is recent (within last 30 days)
  bool isRecentPeso(PesoAnimal peso) {
    final pesoDate = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return pesoDate.isAfter(thirtyDaysAgo);
  }

  /// Format peso value for display
  String formatPeso(double peso) {
    return '${peso.toStringAsFixed(1)} kg';
  }

  /// Format peso change for display
  String formatPesoChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
  }

  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Generate unique object ID
  String _generateObjectId() {
    return 'peso_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}

/// Statistics for peso data
class PesoStatistics {
  final int count;
  final double average;
  final double median;
  final double min;
  final double max;
  final WeightTrend trend;

  const PesoStatistics({
    required this.count,
    required this.average,
    required this.median,
    required this.min,
    required this.max,
    required this.trend,
  });

  factory PesoStatistics.empty() {
    return const PesoStatistics(
      count: 0,
      average: 0,
      median: 0,
      min: 0,
      max: 0,
      trend: WeightTrend.stable,
    );
  }

  @override
  String toString() {
    return 'PesoStatistics(count: $count, avg: ${average.toStringAsFixed(1)}, trend: $trend)';
  }
}
