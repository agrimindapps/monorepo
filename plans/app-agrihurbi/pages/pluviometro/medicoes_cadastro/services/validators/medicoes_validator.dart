// Project imports:
import '../error_handling/medicoes_exceptions.dart';

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const {},
    this.warnings = const [],
  });

  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.invalid(Map<String, String> errors) {
    return ValidationResult(isValid: false, errors: errors);
  }

  factory ValidationResult.withWarnings(List<String> warnings) {
    return ValidationResult(isValid: true, warnings: warnings);
  }
}

/// Validador para dados de medições
class MedicoesValidator {
  static const double _maxQuantidadeNormal = 200.0; // mm/dia
  static const double _maxQuantidadeExtrema = 500.0; // mm/dia
  static const int _maxDaysBack = 365; // dias no passado

  /// Valida todos os dados de uma medição
  static ValidationResult validateMedicao({
    required double quantidade,
    required int dtMedicao,
    String? id,
    String? fkPluviometro,
  }) {
    final errors = <String, String>{};
    final warnings = <String>[];

    // Validação da quantidade
    final quantidadeResult = validateQuantidade(quantidade);
    if (!quantidadeResult.isValid) {
      errors.addAll(quantidadeResult.errors);
    }
    warnings.addAll(quantidadeResult.warnings);

    // Validação da data
    final dataResult = validateData(dtMedicao);
    if (!dataResult.isValid) {
      errors.addAll(dataResult.errors);
    }
    warnings.addAll(dataResult.warnings);

    // Validação do id
    if (id != null && id.isNotEmpty) {
      final idResult = validateId(id);
      if (!idResult.isValid) {
        errors.addAll(idResult.errors);
      }
    }

    // Validação do pluviômetro
    if (fkPluviometro != null && fkPluviometro.isNotEmpty) {
      final pluviometroResult = validatePluviometro(fkPluviometro);
      if (!pluviometroResult.isValid) {
        errors.addAll(pluviometroResult.errors);
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Valida quantidade de precipitação
  static ValidationResult validateQuantidade(double quantidade) {
    final errors = <String, String>{};
    final warnings = <String>[];

    // Validação básica
    if (quantidade < 0) {
      errors['quantidade'] = 'Quantidade não pode ser negativa';
      return ValidationResult.invalid(errors);
    }

    // Validação de valores extremos
    if (quantidade > _maxQuantidadeExtrema) {
      errors['quantidade'] =
          'Quantidade muito alta (>${_maxQuantidadeExtrema}mm). Verifique o valor.';
      return ValidationResult.invalid(errors);
    }

    // Warnings para valores atípicos
    if (quantidade > _maxQuantidadeNormal) {
      warnings.add(
          'Quantidade muito alta (${quantidade.toStringAsFixed(1)}mm). Confirme se está correto.');
    }

    if (quantidade > 0 && quantidade < 0.1) {
      warnings.add(
          'Quantidade muito baixa (${quantidade.toStringAsFixed(2)}mm). Confirme se está correto.');
    }

    return ValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  /// Valida data da medição
  static ValidationResult validateData(int dtMedicao) {
    final errors = <String, String>{};
    final warnings = <String>[];

    final now = DateTime.now();
    final medicaoDate = DateTime.fromMillisecondsSinceEpoch(dtMedicao);

    // Validação básica
    if (dtMedicao <= 0) {
      errors['dtMedicao'] = 'Data da medição é obrigatória';
      return ValidationResult.invalid(errors);
    }

    // Não pode ser futuro
    if (medicaoDate.isAfter(now)) {
      errors['dtMedicao'] = 'Data da medição não pode ser futura';
      return ValidationResult.invalid(errors);
    }

    // Não pode ser muito antiga
    final maxPastDate = now.subtract(const Duration(days: _maxDaysBack));
    if (medicaoDate.isBefore(maxPastDate)) {
      errors['dtMedicao'] =
          'Data da medição muito antiga (>$_maxDaysBack dias)';
      return ValidationResult.invalid(errors);
    }

    // Warnings para datas suspeitas
    final oneDayAgo = now.subtract(const Duration(days: 1));
    if (medicaoDate.isBefore(oneDayAgo)) {
      final daysAgo = now.difference(medicaoDate).inDays;
      if (daysAgo > 7) {
        warnings.add(
            'Medição antiga ($daysAgo dias atrás). Confirme se está correto.');
      }
    }

    return ValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  /// Valida id
  static ValidationResult validateId(String id) {
    final errors = <String, String>{};

    if (id.isEmpty) {
      errors['id'] = 'ID não pode estar vazio';
      return ValidationResult.invalid(errors);
    }

    // Verifica formato UUID ou similar
    if (id.length < 8) {
      errors['id'] = 'ID deve ter pelo menos 8 caracteres';
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }

  /// Valida ID do pluviômetro
  static ValidationResult validatePluviometro(String fkPluviometro) {
    final errors = <String, String>{};

    if (fkPluviometro.isEmpty) {
      errors['fkPluviometro'] = 'Pluviômetro é obrigatório';
      return ValidationResult.invalid(errors);
    }

    // Verifica formato UUID
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (!uuidRegex.hasMatch(fkPluviometro)) {
      errors['fkPluviometro'] = 'ID do pluviômetro deve ser um UUID válido';
      return ValidationResult.invalid(errors);
    }

    return ValidationResult.valid();
  }

  /// Valida contexto de medição (regras de negócio)
  static ValidationResult validateContext({
    required double quantidade,
    required int dtMedicao,
    List<double>? historicoQuantidades,
    String? observacoes,
  }) {
    final warnings = <String>[];

    // Validação contextual com histórico
    if (historicoQuantidades != null && historicoQuantidades.isNotEmpty) {
      final media = historicoQuantidades.reduce((a, b) => a + b) /
          historicoQuantidades.length;

      if (quantidade > media * 3) {
        warnings.add(
            'Quantidade muito acima da média histórica (${media.toStringAsFixed(1)}mm)');
      }
    }

    // Validação temporal
    final medicaoDate = DateTime.fromMillisecondsSinceEpoch(dtMedicao);
    final now = DateTime.now();

    // Verifica se é medição de hoje em horário muito cedo
    if (medicaoDate.year == now.year &&
        medicaoDate.month == now.month &&
        medicaoDate.day == now.day &&
        medicaoDate.hour < 6) {
      warnings.add(
          'Medição registrada muito cedo (${medicaoDate.hour}:${medicaoDate.minute.toString().padLeft(2, '0')})');
    }

    // Validação de observações
    if (observacoes != null && observacoes.length > 500) {
      warnings.add('Observação muito longa (${observacoes.length} caracteres)');
    }

    return ValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  /// Converte resultado de validação em exceção
  static void throwIfInvalid(ValidationResult result, {String? context}) {
    if (!result.isValid) {
      throw ValidationException(
        message: context != null
            ? 'Validação falhou para $context'
            : 'Dados inválidos fornecidos',
        fieldErrors: result.errors,
      );
    }
  }
}
