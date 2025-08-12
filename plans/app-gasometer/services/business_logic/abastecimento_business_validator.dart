// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../database/23_abastecimento_model.dart';

/// Validador especializado para regras de negócio de abastecimentos
/// 
/// Implementa validações matemáticas e business rules para garantir
/// consistência e correção dos dados de abastecimento.
class AbastecimentoBusinessValidator {
  
  // Constantes para validação
  static const double minFuelAmount = 0.1; // Mínimo 0.1L
  static const double maxFuelAmount = 200.0; // Máximo 200L
  static const double minConsumption = 3.0; // Mínimo 3 km/L
  static const double maxConsumption = 30.0; // Máximo 30 km/L
  static const double minDistance = 0.0; // Mínima distância
  static const double maxDistance = 3000.0; // Máxima distância diária (3000km)
  static const double minOdometer = 0.0; // Mínimo odômetro
  static const double maxOdometer = 9999999.0; // Máximo odômetro
  
  /// Resultado de validação com detalhes específicos
  static ValidationResult validateComplete(
    AbastecimentoCar abastecimento, {
    double? odometroAnterior,
    bool isPrimeiroAbastecimento = false,
  }) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validação básica dos campos
    final basicValidation = validateBasicFields(abastecimento);
    if (!basicValidation.isValid) {
      errors.addAll(basicValidation.errors);
    }
    
    // Validação do odômetro
    final odometerValidation = validateOdometer(
      abastecimento.odometro, 
      odometroAnterior,
      isPrimeiroAbastecimento,
    );
    if (!odometerValidation.isValid) {
      errors.addAll(odometerValidation.errors);
    }
    warnings.addAll(odometerValidation.warnings);
    
    // Validação da quantidade de combustível
    final fuelValidation = validateFuelAmount(abastecimento.litros);
    if (!fuelValidation.isValid) {
      errors.addAll(fuelValidation.errors);
    }
    warnings.addAll(fuelValidation.warnings);
    
    // Validação financeira
    final financialValidation = validateFinancialData(
      abastecimento.valorTotal, 
      abastecimento.precoPorLitro, 
      abastecimento.litros,
    );
    if (!financialValidation.isValid) {
      errors.addAll(financialValidation.errors);
    }
    warnings.addAll(financialValidation.warnings);
    
    // Validação de consumo (se não é primeiro abastecimento)
    if (!isPrimeiroAbastecimento && odometroAnterior != null) {
      final consumptionValidation = validateConsumptionCalculation(
        abastecimento.odometro,
        odometroAnterior,
        abastecimento.litros,
      );
      if (!consumptionValidation.isValid) {
        errors.addAll(consumptionValidation.errors);
      }
      warnings.addAll(consumptionValidation.warnings);
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Valida campos básicos obrigatórios
  static ValidationResult validateBasicFields(AbastecimentoCar abastecimento) {
    final errors = <String>[];
    
    if (abastecimento.veiculoId.trim().isEmpty) {
      errors.add('ID do veículo é obrigatório');
    }
    
    if (abastecimento.data <= 0) {
      errors.add('Data do abastecimento é inválida');
    }
    
    // Verifica se data não está no futuro (considerando timezone)
    final dataAbastecimento = DateTime.fromMillisecondsSinceEpoch(abastecimento.data);
    final agora = DateTime.now();
    if (dataAbastecimento.isAfter(agora.add(const Duration(hours: 1)))) {
      errors.add('Data do abastecimento não pode estar no futuro');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Valida dados do odômetro com lógica de negócio
  static ValidationResult validateOdometer(
    double odometroAtual, 
    double? odometroAnterior,
    bool isPrimeiroAbastecimento,
  ) {
    final errors = <String>[];
    final warnings = <String>[];
    
    // Validação de range básico
    if (odometroAtual < minOdometer) {
      errors.add('Odômetro não pode ser negativo');
    }
    
    if (odometroAtual > maxOdometer) {
      errors.add('Odômetro muito alto (máximo: ${maxOdometer.toInt()}km)');
    }
    
    // Validação com odômetro anterior (se não é primeiro abastecimento)
    if (!isPrimeiroAbastecimento && odometroAnterior != null) {
      if (odometroAtual < odometroAnterior) {
        errors.add('Odômetro atual ($odometroAtual km) não pode ser menor que o anterior ($odometroAnterior km)');
      }
      
      final distancia = odometroAtual - odometroAnterior;
      
      if (distancia < minDistance) {
        warnings.add('Distância muito pequena (${distancia.toStringAsFixed(1)} km)');
      }
      
      if (distancia > maxDistance) {
        warnings.add('Distância muito grande (${distancia.toStringAsFixed(1)} km) - verifique se está correto');
      }
      
      // Warning se distância é zero
      if (distancia == 0) {
        warnings.add('Sem distância percorrida - consumo não pode ser calculado');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Valida quantidade de combustível
  static ValidationResult validateFuelAmount(double litros) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (litros <= 0) {
      errors.add('Quantidade de combustível deve ser maior que zero');
    }
    
    if (litros < minFuelAmount) {
      errors.add('Quantidade muito pequena (mínimo: ${minFuelAmount}L)');
    }
    
    if (litros > maxFuelAmount) {
      errors.add('Quantidade muito grande (máximo: ${maxFuelAmount}L)');
    }
    
    // Warnings para valores incomuns mas não inválidos
    if (litros > 100) {
      warnings.add('Quantidade muito alta (${litros.toStringAsFixed(2)}L) - verifique se está correto');
    }
    
    if (litros < 5) {
      warnings.add('Quantidade baixa (${litros.toStringAsFixed(2)}L) - pode afetar precisão do consumo');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Valida dados financeiros e consistência de preços
  static ValidationResult validateFinancialData(
    double valorTotal, 
    double precoPorLitro, 
    double litros,
  ) {
    final errors = <String>[];
    final warnings = <String>[];
    
    if (valorTotal <= 0) {
      errors.add('Valor total deve ser maior que zero');
    }
    
    if (precoPorLitro <= 0) {
      errors.add('Preço por litro deve ser maior que zero');
    }
    
    // Validação de consistência: valor total vs (preço * litros)
    if (valorTotal > 0 && precoPorLitro > 0 && litros > 0) {
      final valorCalculado = precoPorLitro * litros;
      final diferenca = (valorTotal - valorCalculado).abs();
      final percentualDiferenca = (diferenca / valorTotal) * 100;
      
      if (percentualDiferenca > 5) { // Tolerância de 5%
        warnings.add('Inconsistência nos valores: total (R\$ ${valorTotal.toStringAsFixed(2)}) '
            'vs calculado (R\$ ${valorCalculado.toStringAsFixed(2)})');
      }
    }
    
    // Warnings para preços incomuns
    if (precoPorLitro > 10.0) {
      warnings.add('Preço por litro muito alto (R\$ ${precoPorLitro.toStringAsFixed(2)})');
    }
    
    if (precoPorLitro < 3.0) {
      warnings.add('Preço por litro muito baixo (R\$ ${precoPorLitro.toStringAsFixed(2)})');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Valida cálculo de consumo com regras de negócio
  static ValidationResult validateConsumptionCalculation(
    double odometroAtual,
    double odometroAnterior, 
    double litros,
  ) {
    final errors = <String>[];
    final warnings = <String>[];
    
    final distancia = odometroAtual - odometroAnterior;
    
    if (distancia <= 0) {
      errors.add('Distância inválida para cálculo de consumo');
      return ValidationResult(isValid: false, errors: errors);
    }
    
    if (litros <= 0) {
      errors.add('Quantidade de combustível inválida para cálculo de consumo');
      return ValidationResult(isValid: false, errors: errors);
    }
    
    final consumoKmL = distancia / litros;
    final consumoL100km = (litros / distancia) * 100;
    
    // Validação de consumo realista
    if (consumoKmL < minConsumption) {
      warnings.add('Consumo muito baixo (${consumoKmL.toStringAsFixed(2)} km/L) - verifique os dados');
    }
    
    if (consumoKmL > maxConsumption) {
      warnings.add('Consumo muito alto (${consumoKmL.toStringAsFixed(2)} km/L) - verifique os dados');
    }
    
    // Log para debugging em desenvolvimento
    if (kDebugMode) {
      debugPrint('Consumo calculado: ${consumoKmL.toStringAsFixed(2)} km/L '
          '(${consumoL100km.toStringAsFixed(2)} L/100km)');
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
  
  /// Verifica se abastecimento pode ser um "reset" de odômetro
  static bool isPossibleOdometerReset(double odometroAtual, double odometroAnterior) {
    // Se odômetro atual é muito menor que anterior, pode ser reset
    return odometroAtual > 0 && 
           odometroAnterior > 0 && 
           odometroAtual < (odometroAnterior * 0.1);
  }
  
  /// Valida sequência de abastecimentos para detectar inconsistências
  static ValidationResult validateSequence(List<AbastecimentoCar> abastecimentos) {
    if (abastecimentos.length < 2) {
      return const ValidationResult(isValid: true);
    }
    
    // Ordena por data
    final sorted = List<AbastecimentoCar>.from(abastecimentos)
      ..sort((a, b) => a.data.compareTo(b.data));
    
    final errors = <String>[];
    final warnings = <String>[];
    
    for (int i = 1; i < sorted.length; i++) {
      final anterior = sorted[i - 1];
      final atual = sorted[i];
      
      // Verifica progressão do odômetro
      if (atual.odometro < anterior.odometro && 
          !isPossibleOdometerReset(atual.odometro, anterior.odometro)) {
        errors.add('Odômetro regrediu entre ${anterior.data} e ${atual.data}');
      }
      
      // Verifica intervalos de tempo muito pequenos
      final intervaloDias = (atual.data - anterior.data) / (1000 * 60 * 60 * 24);
      if (intervaloDias < 0.5) { // Menos de 12 horas
        warnings.add('Intervalo muito pequeno entre abastecimentos (${intervaloDias.toStringAsFixed(1)} dias)');
      }
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}

/// Resultado de validação com erros e warnings
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
  
  /// Combina múltiplos resultados de validação
  static ValidationResult combine(List<ValidationResult> results) {
    final allErrors = <String>[];
    final allWarnings = <String>[];
    
    for (final result in results) {
      allErrors.addAll(result.errors);
      allWarnings.addAll(result.warnings);
    }
    
    return ValidationResult(
      isValid: allErrors.isEmpty,
      errors: allErrors,
      warnings: allWarnings,
    );
  }
  
  /// Retorna mensagem formatada para o usuário
  String getFormattedMessage() {
    final buffer = StringBuffer();
    
    if (errors.isNotEmpty) {
      buffer.writeln('Erros:');
      for (final error in errors) {
        buffer.writeln('• $error');
      }
    }
    
    if (warnings.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.writeln();
      buffer.writeln('Avisos:');
      for (final warning in warnings) {
        buffer.writeln('• $warning');
      }
    }
    
    return buffer.toString().trim();
  }
  
  @override
  String toString() => 'ValidationResult(valid: $isValid, errors: ${errors.length}, warnings: ${warnings.length})';
}