import 'package:equatable/equatable.dart';

import 'calculation_result.dart';
import 'calculator_category.dart';
import 'calculator_parameter.dart';

enum CalculatorComplexity {
  low,
  medium,
  high,
}

abstract class CalculatorEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final CalculatorCategory category;
  final List<CalculatorParameter> parameters;
  final String? formula;
  final List<String>? references;
  final bool isActive;
  final List<String> tags;
  final CalculatorComplexity complexity;

  const CalculatorEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.parameters,
    this.formula,
    this.references,
    this.isActive = true,
    this.tags = const [],
    this.complexity = CalculatorComplexity.medium,
  });

  /// Método abstrato que deve ser implementado por cada calculadora específica
  CalculationResult calculate(Map<String, dynamic> inputs);

  /// Valida os inputs antes de executar o cálculo
  bool validateInputs(Map<String, dynamic> inputs) {
    for (final parameter in parameters) {
      final value = inputs[parameter.id];
      if (!parameter.isValid(value)) {
        return false;
      }
    }
    return true;
  }

  /// Retorna lista de erros de validação
  List<String> getValidationErrors(Map<String, dynamic> inputs) {
    final errors = <String>[];
    
    for (final parameter in parameters) {
      final value = inputs[parameter.id];
      if (!parameter.isValid(value)) {
        if (parameter.required && (value == null || value.toString().isEmpty)) {
          errors.add('${parameter.name} é obrigatório');
        } else if (parameter.validationMessage != null) {
          errors.add(parameter.validationMessage!);
        } else {
          errors.add('${parameter.name} possui valor inválido');
        }
      }
    }
    
    return errors;
  }

  /// Aplica valores padrão para parâmetros não preenchidos
  Map<String, dynamic> applyDefaults(Map<String, dynamic> inputs) {
    final result = Map<String, dynamic>.from(inputs);
    
    for (final parameter in parameters) {
      if (!result.containsKey(parameter.id) && parameter.defaultValue != null) {
        result[parameter.id] = parameter.defaultValue;
      }
    }
    
    return result;
  }

  /// Executa o cálculo com validação
  CalculationResult executeCalculation(Map<String, dynamic> inputs) {
    try {
      // Aplica valores padrão
      final processedInputs = applyDefaults(inputs);
      
      // Valida inputs
      if (!validateInputs(processedInputs)) {
        final errors = getValidationErrors(processedInputs);
        return CalculationError(
          calculatorId: id,
          errorMessage: 'Erro de validação: ${errors.join(', ')}',
          inputs: processedInputs,
        );
      }

      // Executa o cálculo
      final result = calculate(processedInputs);
      
      // Verifica se o resultado é válido
      if (!result.isValid) {
        return result;
      }

      return result;
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        parameters,
        formula,
        references,
        isActive,
        tags,
        complexity,
      ];
}