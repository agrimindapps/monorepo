// Package imports:
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../../models/17_peso_model.dart';
import '../../../../repository/peso_repository.dart';
import '../config/peso_config.dart';

class PesoCadastroService {
  final PesoRepository _repository;

  PesoCadastroService({PesoRepository? repository})
      : _repository = repository ?? PesoRepository();

  static Future<PesoCadastroService> initialize() async {
    await PesoRepository.initialize();
    return PesoCadastroService();
  }

  Future<bool> savePeso({
    required String animalId,
    required double peso,
    required int dataPesagem,
    String? observacoes,
    PesoAnimal? existingPeso,
  }) async {
    try {
      final newPeso = PesoAnimal(
        id: existingPeso?.id ?? const Uuid().v4(),
        createdAt: existingPeso?.createdAt ?? DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        isDeleted: false,
        needsSync: existingPeso?.needsSync ?? true,
        version: existingPeso == null ? 1 : existingPeso.version + 1,
        lastSyncAt: existingPeso?.lastSyncAt,
        animalId: animalId,
        peso: peso,
        dataPesagem: dataPesagem,
        observacoes: observacoes?.isEmpty == true ? null : observacoes,
      );

      if (existingPeso == null) {
        return await _repository.addPeso(newPeso);
      } else {
        return await _repository.updatePeso(newPeso);
      }
    } catch (e) {
      throw Exception('Erro ao salvar peso: ${e.toString()}');
    }
  }

  Future<bool> deletePeso(String pesoId) async {
    try {
      final peso = await _repository.getPesoById(pesoId);
      if (peso != null) {
        return await _repository.deletePeso(peso);
      }
      return false;
    } catch (e) {
      throw Exception('Erro ao deletar peso: ${e.toString()}');
    }
  }

  Future<List<PesoAnimal>> getPesosByAnimal(String animalId) async {
    try {
      return await _repository.getPesos(animalId);
    } catch (e) {
      throw Exception('Erro ao buscar pesos: ${e.toString()}');
    }
  }

  // ========== BUSINESS VALIDATION METHODS ==========

  /// Validates business rules before saving peso
  Future<Map<String, String?>> validateBusinessRules({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
    String? animalType,
    bool isFilhote = false,
  }) async {
    final errors = <String, String?>{};

    // Basic field validation
    final basicValidation = PesoConfig.validateAllFields(
      animalId: animalId,
      peso: peso,
      dataPesagem: dataPesagem,
      observacoes: observacoes,
      animalType: animalType,
      isFilhote: isFilhote,
    );
    errors.addAll(basicValidation);

    // Check for duplicate weight on same date
    final existingPesos = await getPesosByAnimal(animalId);
    final sameDate = existingPesos.where((p) => 
      DateTime.fromMillisecondsSinceEpoch(p.dataPesagem).day == dataPesagem.day &&
      DateTime.fromMillisecondsSinceEpoch(p.dataPesagem).month == dataPesagem.month &&
      DateTime.fromMillisecondsSinceEpoch(p.dataPesagem).year == dataPesagem.year
    ).toList();

    if (sameDate.isNotEmpty) {
      errors['dataPesagem'] = 'Já existe um peso registrado para esta data';
    }

    // Check for sudden weight changes (>20% change in short period)
    if (existingPesos.isNotEmpty) {
      final lastPeso = existingPesos.first;
      final daysDifference = dataPesagem.difference(
        DateTime.fromMillisecondsSinceEpoch(lastPeso.dataPesagem)
      ).inDays;

      if (daysDifference < 7) {
        final weightChange = ((peso - lastPeso.peso) / lastPeso.peso).abs();
        if (weightChange > 0.20) {
          errors['peso'] = 'Mudança de peso muito abrupta (>20% em menos de 7 dias)';
        }
      }
    }

    return errors;
  }

  /// Creates peso with business validation
  Future<bool> createPesoWithValidation({
    required String animalId,
    required double peso,
    required DateTime dataPesagem,
    String? observacoes,
    String? animalType,
    bool isFilhote = false,
  }) async {
    final validationErrors = await validateBusinessRules(
      animalId: animalId,
      peso: peso,
      dataPesagem: dataPesagem,
      observacoes: observacoes,
      animalType: animalType,
      isFilhote: isFilhote,
    );

    final hasErrors = validationErrors.values.any((error) => error != null);
    if (hasErrors) {
      throw Exception('Validation failed: ${validationErrors.values.where((e) => e != null).join(', ')}');
    }

    return await savePeso(
      animalId: animalId,
      peso: peso,
      dataPesagem: dataPesagem.millisecondsSinceEpoch,
      observacoes: observacoes,
    );
  }

  /// Gets creation statistics for an animal
  Future<Map<String, dynamic>> getCreationStatistics(String animalId) async {
    final pesos = await getPesosByAnimal(animalId);
    
    if (pesos.isEmpty) {
      return {
        'totalRecords': 0,
        'averageWeight': 0.0,
        'weightRange': {'min': 0.0, 'max': 0.0},
        'lastWeighing': null,
        'trend': 'none',
      };
    }

    final weights = pesos.map((p) => p.peso).toList();
    final totalWeight = weights.reduce((a, b) => a + b);
    final averageWeight = totalWeight / weights.length;
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);

    final lastPeso = pesos.first;
    String trend = 'stable';
    if (pesos.length > 1) {
      final secondLast = pesos[1];
      if (lastPeso.peso > secondLast.peso) {
        trend = 'increasing';
      } else if (lastPeso.peso < secondLast.peso) {
        trend = 'decreasing';
      }
    }

    return {
      'totalRecords': pesos.length,
      'averageWeight': averageWeight,
      'weightRange': {'min': minWeight, 'max': maxWeight},
      'lastWeighing': DateTime.fromMillisecondsSinceEpoch(lastPeso.dataPesagem),
      'trend': trend,
    };
  }

  /// Analyzes weight against ideal ranges
  Future<Map<String, dynamic>> analyzeWeightForAnimal({
    required double peso,
    required String animalType,
    bool isFilhote = false,
  }) async {
    final category = PesoConfig.getWeightCategory(peso, _getIdealWeight(animalType, isFilhote));
    final ranges = PesoConfig.pesosPorEspecie[animalType];
    
    return {
      'category': category,
      'isHealthy': category == 'Peso ideal',
      'needsAttention': ['Obesidade grau I', 'Obesidade grau II', 'Abaixo do peso'].contains(category),
      'ranges': ranges,
      'recommendations': _getWeightRecommendations(category),
    };
  }

  /// Gets weight trend analysis
  Future<Map<String, dynamic>> getWeightTrend(String animalId, {int days = 30}) async {
    final pesos = await getPesosByAnimal(animalId);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    
    final recentPesos = pesos.where((p) => 
      DateTime.fromMillisecondsSinceEpoch(p.dataPesagem).isAfter(cutoffDate)
    ).toList();

    if (recentPesos.length < 2) {
      return {
        'trend': 'insufficient_data',
        'description': 'Dados insuficientes para análise de tendência',
        'weightChange': 0.0,
        'percentage': 0.0,
      };
    }

    final firstWeight = recentPesos.last.peso;
    final lastWeight = recentPesos.first.peso;
    final weightChange = lastWeight - firstWeight;
    final percentage = (weightChange / firstWeight) * 100;

    String trend;
    String description;
    
    if (percentage > 5) {
      trend = 'significant_gain';
      description = 'Ganho significativo de peso (${percentage.toStringAsFixed(1)}%)';
    } else if (percentage < -5) {
      trend = 'significant_loss';
      description = 'Perda significativa de peso (${percentage.abs().toStringAsFixed(1)}%)';
    } else if (percentage > 2) {
      trend = 'moderate_gain';
      description = 'Ganho moderado de peso (${percentage.toStringAsFixed(1)}%)';
    } else if (percentage < -2) {
      trend = 'moderate_loss';
      description = 'Perda moderada de peso (${percentage.abs().toStringAsFixed(1)}%)';
    } else {
      trend = 'stable';
      description = 'Peso estável nos últimos $days dias';
    }

    return {
      'trend': trend,
      'description': description,
      'weightChange': weightChange,
      'percentage': percentage,
      'period': days,
      'recordsAnalyzed': recentPesos.length,
    };
  }

  /// Exports weight data to CSV format
  Future<String> exportWeightDataToCSV(String animalId) async {
    final pesos = await getPesosByAnimal(animalId);
    
    final csvLines = <String>[
      'Data,Peso (kg),Observações', // Header
    ];

    for (final peso in pesos.reversed) {
      final date = DateTime.fromMillisecondsSinceEpoch(peso.dataPesagem);
      final dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      final observations = peso.observacoes?.replaceAll(',', ';') ?? '';
      
      csvLines.add('$dateStr,${peso.peso},"$observations"');
    }

    return csvLines.join('\n');
  }

  /// Gets batch operations summary
  Future<Map<String, dynamic>> getBatchOperationsSummary(List<String> animalIds) async {
    int totalRecords = 0;
    double totalWeight = 0.0;
    final animalStats = <String, Map<String, dynamic>>{};

    for (final animalId in animalIds) {
      final pesos = await getPesosByAnimal(animalId);
      final weights = pesos.map((p) => p.peso).toList();
      
      if (weights.isNotEmpty) {
        final animalTotal = weights.reduce((a, b) => a + b);
        totalRecords += pesos.length;
        totalWeight += animalTotal;
        
        animalStats[animalId] = {
          'recordCount': pesos.length,
          'averageWeight': animalTotal / weights.length,
          'lastWeight': weights.first,
        };
      }
    }

    return {
      'totalAnimals': animalIds.length,
      'totalRecords': totalRecords,
      'averageWeightAcrossAll': totalRecords > 0 ? totalWeight / totalRecords : 0.0,
      'animalStats': animalStats,
    };
  }

  /// Validates weight against previous entries for consistency
  Future<List<String>> validateWeightConsistency({
    required String animalId,
    required double newWeight,
    required DateTime newDate,
  }) async {
    final warnings = <String>[];
    final existingPesos = await getPesosByAnimal(animalId);
    
    if (existingPesos.isEmpty) return warnings;

    // Check for unrealistic weight jumps
    final sortedPesos = existingPesos..sort((a, b) => b.dataPesagem.compareTo(a.dataPesagem));
    final lastPeso = sortedPesos.first;
    final lastWeight = lastPeso.peso;
    final daysDiff = newDate.difference(DateTime.fromMillisecondsSinceEpoch(lastPeso.dataPesagem)).inDays;

    if (daysDiff > 0) {
      final dailyChange = (newWeight - lastWeight).abs() / daysDiff;
      
      if (dailyChange > 0.5) { // More than 500g per day
        warnings.add('Mudança de peso muito rápida: ${dailyChange.toStringAsFixed(2)}kg por dia');
      }
    }

    // Check for weight going below minimum historical
    final minHistoricalWeight = sortedPesos.map((p) => p.peso).reduce((a, b) => a < b ? a : b);
    if (newWeight < minHistoricalWeight * 0.8) {
      warnings.add('Peso está 20% abaixo do mínimo histórico');
    }

    // Check for weight going above maximum historical
    final maxHistoricalWeight = sortedPesos.map((p) => p.peso).reduce((a, b) => a > b ? a : b);
    if (newWeight > maxHistoricalWeight * 1.3) {
      warnings.add('Peso está 30% acima do máximo histórico');
    }

    return warnings;
  }

  // ========== PRIVATE HELPER METHODS ==========

  double _getIdealWeight(String animalType, bool isFilhote) {
    final ranges = PesoConfig.pesosPorEspecie[animalType];
    if (ranges == null) return 5.0; // Default fallback
    
    final min = ranges[isFilhote ? 'filhote_min' : 'min'] ?? 1.0;
    final max = ranges[isFilhote ? 'filhote_max' : 'max'] ?? 10.0;
    
    return (min + max) / 2; // Average as ideal weight
  }

  List<String> _getWeightRecommendations(String category) {
    switch (category) {
      case 'Abaixo do peso':
        return [
          'Consulte um veterinário para avaliar a causa',
          'Considere aumentar a frequência das refeições',
          'Monitore o peso semanalmente',
        ];
      case 'Sobrepeso':
        return [
          'Reduza a quantidade de ração gradualmente',
          'Aumente a atividade física',
          'Evite petiscos extras',
        ];
      case 'Obesidade grau I':
      case 'Obesidade grau II':
        return [
          'Consulta veterinária urgente necessária',
          'Dieta restritiva supervisionada',
          'Programa de exercícios gradual',
          'Monitoramento semanal obrigatório',
        ];
      default:
        return [
          'Mantenha a rotina atual',
          'Continue o monitoramento regular',
        ];
    }
  }
}
