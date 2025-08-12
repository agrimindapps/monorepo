// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../database/23_abastecimento_model.dart';
import '../../repository/abastecimentos_repository.dart';
import 'abastecimento_business_validator.dart';
import 'consumption_calculator_service.dart';

/// Service principal para business logic de abastecimentos
/// 
/// Centraliza todas as operações de negócio relacionadas a abastecimentos,
/// incluindo validações, cálculos e análises estatísticas.
class AbastecimentoBusinessService {
  final AbastecimentosRepository _repository;
  
  AbastecimentoBusinessService(this._repository);
  
  /// Valida um abastecimento antes da criação/atualização
  /// 
  /// Retorna resultado completo com erros e warnings
  Future<ValidationResult> validateAbastecimento(
    AbastecimentoCar abastecimento,
    {String? veiculoId}
  ) async {
    try {
      // Se veiculoId não foi fornecido, usa o do abastecimento
      final veiculo = veiculoId ?? abastecimento.veiculoId;
      
      // Busca abastecimento anterior para validação contextual
      final abastecimentoAnterior = await _getAbastecimentoAnterior(veiculo, abastecimento.data);
      
      // Determina se é primeiro abastecimento
      final isPrimeiro = abastecimentoAnterior == null;
      
      // Validação completa
      final validation = AbastecimentoBusinessValidator.validateComplete(
        abastecimento,
        odometroAnterior: abastecimentoAnterior?.odometro,
        isPrimeiroAbastecimento: isPrimeiro,
      );
      
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Validação ${validation.isValid ? "OK" : "FALHOU"}');
        if (!validation.isValid) {
          debugPrint('Erros: ${validation.errors.join(", ")}');
        }
        if (validation.warnings.isNotEmpty) {
          debugPrint('Avisos: ${validation.warnings.join(", ")}');
        }
      }
      
      return validation;
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Erro na validação - $e');
      }
      
      return ValidationResult(
        isValid: false,
        errors: ['Erro interno na validação: ${e.toString()}'],
      );
    }
  }
  
  /// Calcula consumo de um abastecimento específico
  Future<ConsumptionResult> calculateConsumption(
    AbastecimentoCar abastecimento,
    {String? veiculoId}
  ) async {
    try {
      final veiculo = veiculoId ?? abastecimento.veiculoId;
      final abastecimentoAnterior = await _getAbastecimentoAnterior(veiculo, abastecimento.data);
      
      if (abastecimentoAnterior == null) {
        return const ConsumptionResult(
          isValid: false,
          message: 'Primeiro abastecimento - consumo não pode ser calculado',
          isPrimeiroAbastecimento: true,
        );
      }
      
      final consumoKmL = ConsumptionCalculatorService.calculateConsumptionKmL(
        abastecimento.odometro,
        abastecimentoAnterior.odometro,
        abastecimento.litros,
      );
      
      if (consumoKmL == null) {
        return const ConsumptionResult(
          isValid: false,
          message: 'Dados insuficientes para calcular consumo',
        );
      }
      
      final consumoL100km = ConsumptionCalculatorService.calculateConsumptionL100km(
        abastecimento.odometro,
        abastecimentoAnterior.odometro,
        abastecimento.litros,
      );
      
      final distancia = abastecimento.odometro - abastecimentoAnterior.odometro;
      final custoporKm = ConsumptionCalculatorService.calculateCostPerKm(
        distancia,
        abastecimento.valorTotal,
      );
      
      final isRealistic = ConsumptionCalculatorService.isConsumptionRealistic(consumoKmL);
      
      return ConsumptionResult(
        isValid: true,
        consumptionKmL: consumoKmL,
        consumptionL100km: consumoL100km,
        distanceKm: distancia,
        costPerKm: custoporKm,
        isRealistic: isRealistic,
        message: isRealistic 
            ? 'Consumo calculado com sucesso'
            : 'Consumo calculado mas fora da faixa típica',
      );
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Erro no cálculo de consumo - $e');
      }
      
      return ConsumptionResult(
        isValid: false,
        message: 'Erro no cálculo: ${e.toString()}',
      );
    }
  }
  
  /// Calcula estatísticas de consumo para um veículo
  Future<ConsumptionSummary> calculateVehicleConsumptionSummary(String veiculoId) async {
    try {
      final abastecimentos = await _repository.getAbastecimentos(veiculoId);
      
      if (abastecimentos.length < 2) {
        return ConsumptionSummary.empty();
      }
      
      return ConsumptionCalculatorService.calculateAverageConsumption(abastecimentos);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Erro no cálculo de estatísticas - $e');
      }
      return ConsumptionSummary.empty();
    }
  }
  
  /// Detecta anomalias nos abastecimentos de um veículo
  Future<List<ConsumptionAnomaly>> detectVehicleAnomalies(
    String veiculoId,
    {double tolerancePercentage = 30.0}
  ) async {
    try {
      final abastecimentos = await _repository.getAbastecimentos(veiculoId);
      
      return ConsumptionCalculatorService.detectConsumptionAnomalies(
        abastecimentos,
        tolerancePercentage: tolerancePercentage,
      );
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Erro na detecção de anomalias - $e');
      }
      return [];
    }
  }
  
  /// Projeta consumo para uma viagem
  Future<FuelConsumptionProjection> projectTripConsumption(
    String veiculoId,
    double distanciaKm,
    {double? precoCustomizado}
  ) async {
    try {
      // Calcula consumo médio do veículo
      final summary = await calculateVehicleConsumptionSummary(veiculoId);
      if (!summary.isValid) {
        return FuelConsumptionProjection.invalid();
      }
      
      // Usa preço customizado ou calcula média dos últimos abastecimentos
      double precoMedio = precoCustomizado ?? 0;
      if (precoMedio == 0) {
        precoMedio = await _calculateAverageFuelPrice(veiculoId);
      }
      
      if (precoMedio <= 0) {
        return FuelConsumptionProjection.invalid();
      }
      
      return ConsumptionCalculatorService.projectFuelConsumption(
        summary.averageKmL,
        distanciaKm,
        precoMedio,
      );
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Erro na projeção - $e');
      }
      return FuelConsumptionProjection.invalid();
    }
  }
  
  /// Valida sequência de abastecimentos para detectar inconsistências
  Future<ValidationResult> validateAbastecimentoSequence(String veiculoId) async {
    try {
      final abastecimentos = await _repository.getAbastecimentos(veiculoId);
      
      return AbastecimentoBusinessValidator.validateSequence(abastecimentos);
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Erro na validação de sequência - $e');
      }
      
      return ValidationResult(
        isValid: false,
        errors: ['Erro na validação da sequência: ${e.toString()}'],
      );
    }
  }
  
  /// Gera relatório de análise completa do veículo
  Future<VehicleAnalysisReport> generateVehicleAnalysisReport(String veiculoId) async {
    try {
      // Executa todas as análises em paralelo
      final futures = await Future.wait([
        calculateVehicleConsumptionSummary(veiculoId),
        detectVehicleAnomalies(veiculoId),
        validateAbastecimentoSequence(veiculoId),
      ]);
      
      final summary = futures[0] as ConsumptionSummary;
      final anomalies = futures[1] as List<ConsumptionAnomaly>;
      final sequenceValidation = futures[2] as ValidationResult;
      
      // Calcula score de saúde dos dados
      final healthScore = _calculateDataHealthScore(summary, anomalies, sequenceValidation);
      
      return VehicleAnalysisReport(
        veiculoId: veiculoId,
        consumptionSummary: summary,
        anomalies: anomalies,
        sequenceValidation: sequenceValidation,
        dataHealthScore: healthScore,
        generatedAt: DateTime.now(),
      );
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AbastecimentoBusinessService: Erro no relatório - $e');
      }
      
      return VehicleAnalysisReport.empty(veiculoId);
    }
  }
  
  // ========================================
  // MÉTODOS PRIVADOS AUXILIARES
  // ========================================
  
  /// Busca o abastecimento anterior a uma data específica
  Future<AbastecimentoCar?> _getAbastecimentoAnterior(String veiculoId, int dataLimite) async {
    final abastecimentos = await _repository.getAbastecimentos(veiculoId);
    
    // Filtra abastecimentos anteriores e ordena por data decrescente
    final anteriores = abastecimentos
        .where((a) => a.data < dataLimite)
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
    
    return anteriores.isEmpty ? null : anteriores.first;
  }
  
  /// Calcula preço médio de combustível dos últimos abastecimentos
  Future<double> _calculateAverageFuelPrice(String veiculoId, {int ultimosAbastecimentos = 5}) async {
    final abastecimentos = await _repository.getAbastecimentos(veiculoId);
    
    if (abastecimentos.isEmpty) return 0;
    
    // Ordena por data decrescente e pega os últimos N
    final recentes = abastecimentos
      ..sort((a, b) => b.data.compareTo(a.data));
    
    final ultimos = recentes.take(ultimosAbastecimentos).toList();
    
    if (ultimos.isEmpty) return 0;
    
    final somaPrecos = ultimos.fold<double>(0, (sum, a) => sum + a.precoPorLitro);
    return somaPrecos / ultimos.length;
  }
  
  /// Calcula score de saúde dos dados (0-100)
  double _calculateDataHealthScore(
    ConsumptionSummary summary,
    List<ConsumptionAnomaly> anomalies,
    ValidationResult sequenceValidation,
  ) {
    double score = 100.0;
    
    // Penaliza por dados insuficientes
    if (!summary.isValid) {
      score -= 50;
    } else {
      // Penaliza por baixa porcentagem de cálculos válidos
      score -= (100 - summary.validCalculationPercentage) * 0.3;
    }
    
    // Penaliza por anomalias
    score -= anomalies.length * 5;
    
    // Penaliza por erros de sequência
    if (!sequenceValidation.isValid) {
      score -= sequenceValidation.errors.length * 10;
    }
    
    // Penaliza por warnings de sequência
    score -= sequenceValidation.warnings.length * 2;
    
    return (score < 0) ? 0 : score;
  }
}

/// Resultado do cálculo de consumo
class ConsumptionResult {
  final bool isValid;
  final double? consumptionKmL;
  final double? consumptionL100km;
  final double? distanceKm;
  final double? costPerKm;
  final bool? isRealistic;
  final bool isPrimeiroAbastecimento;
  final String message;
  
  const ConsumptionResult({
    required this.isValid,
    this.consumptionKmL,
    this.consumptionL100km,
    this.distanceKm,
    this.costPerKm,
    this.isRealistic,
    this.isPrimeiroAbastecimento = false,
    required this.message,
  });
  
  @override
  String toString() => 'ConsumptionResult(valid: $isValid, consumption: $consumptionKmL km/L)';
}

/// Relatório completo de análise do veículo
class VehicleAnalysisReport {
  final String veiculoId;
  final ConsumptionSummary consumptionSummary;
  final List<ConsumptionAnomaly> anomalies;
  final ValidationResult sequenceValidation;
  final double dataHealthScore;
  final DateTime generatedAt;
  
  const VehicleAnalysisReport({
    required this.veiculoId,
    required this.consumptionSummary,
    required this.anomalies,
    required this.sequenceValidation,
    required this.dataHealthScore,
    required this.generatedAt,
  });
  
  factory VehicleAnalysisReport.empty(String veiculoId) {
    return VehicleAnalysisReport(
      veiculoId: veiculoId,
      consumptionSummary: ConsumptionSummary.empty(),
      anomalies: const [],
      sequenceValidation: const ValidationResult(isValid: true),
      dataHealthScore: 0,
      generatedAt: DateTime.now(),
    );
  }
  
  /// Classificação da qualidade dos dados
  String get dataQualityRating {
    if (dataHealthScore >= 90) return 'Excelente';
    if (dataHealthScore >= 70) return 'Bom';
    if (dataHealthScore >= 50) return 'Regular';
    return 'Ruim';
  }
  
  /// Resumo executivo do relatório
  String get executiveSummary {
    if (!consumptionSummary.isValid) {
      return 'Dados insuficientes para análise completa.';
    }
    
    final buffer = StringBuffer();
    buffer.write('Consumo médio: ${consumptionSummary.averageKmL.toStringAsFixed(2)} km/L. ');
    
    if (anomalies.isNotEmpty) {
      buffer.write('${anomalies.length} anomalia(s) detectada(s). ');
    }
    
    buffer.write('Qualidade dos dados: $dataQualityRating.');
    
    return buffer.toString();
  }
  
  @override
  String toString() => 'VehicleAnalysisReport($veiculoId, score: $dataHealthScore)';
}