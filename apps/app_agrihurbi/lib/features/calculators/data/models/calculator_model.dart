import '../../domain/entities/calculator_entity.dart';
import '../../domain/entities/calculator_category.dart';
import '../../domain/entities/calculator_parameter.dart';
import '../../domain/entities/calculation_result.dart';

/// Model para serialização de calculadoras (futuro uso com APIs)
/// 
/// Por enquanto serve como ponte entre datasource e entidades
class CalculatorModel extends CalculatorEntity {
  const CalculatorModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.parameters,
    super.formula,
    super.references,
    super.isActive,
  });

  /// Factory para criar a partir de JSON (futuro uso)
  factory CalculatorModel.fromJson(Map<String, dynamic> json) {
    return CalculatorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: CalculatorCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => CalculatorCategory.irrigation,
      ),
      parameters: (json['parameters'] as List<dynamic>)
          .map((param) => CalculatorParameter.fromJson(param as Map<String, dynamic>))
          .toList(),
      formula: json['formula'] as String?,
      references: json['references'] != null
          ? List<String>.from(json['references'] as List<dynamic>)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Converte para JSON (futuro uso)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.toString(),
      'parameters': parameters.map((param) => param.toJson()).toList(),
      'formula': formula,
      'references': references,
      'isActive': isActive,
    };
  }

  /// Converte para entidade de domínio
  CalculatorEntity toEntity() {
    // Retorna uma instância específica baseada no ID
    // Por ora, retorna uma instância genérica
    return GenericCalculatorEntity(
      id: id,
      name: name,
      description: description,
      category: category,
      parameters: parameters,
      formula: formula,
      references: references,
      isActive: isActive,
    );
  }

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    // Implementação genérica - deve ser sobrescrita pelas calculadoras específicas
    return CalculationError(
      calculatorId: id,
      errorMessage: 'Cálculo não implementado para esta calculadora',
      inputs: inputs,
    );
  }
}

/// Implementação genérica de calculadora (fallback)
class GenericCalculatorEntity extends CalculatorEntity {
  const GenericCalculatorEntity({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.parameters,
    super.formula,
    super.references,
    super.isActive,
  });

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    return CalculationError(
      calculatorId: id,
      errorMessage: 'Calculadora não possui implementação de cálculo específica',
      inputs: inputs,
    );
  }
}