import 'package:core/core.dart' show Equatable;

import 'calculation_result.dart';

/// Representa um histórico de cálculo salvo
class CalculationHistory extends Equatable {
  const CalculationHistory({
    required this.id,
    required this.calculatorId,
    required this.calculatorName,
    required this.inputs,
    required this.result,
    required this.createdAt,
    this.animalId,
    this.notes,
  });

  /// ID único do histórico
  final String id;

  /// ID da calculadora usada
  final String calculatorId;

  /// Nome da calculadora (para exibição)
  final String calculatorName;

  /// Inputs utilizados no cálculo
  final Map<String, dynamic> inputs;

  /// Resultado do cálculo
  final CalculationResult result;

  /// Data/hora da criação
  final DateTime createdAt;

  /// ID do animal associado (opcional)
  final String? animalId;

  /// Notas adicionais do usuário
  final String? notes;

  /// Cria uma cópia com alterações
  CalculationHistory copyWith({
    String? id,
    String? calculatorId,
    String? calculatorName,
    Map<String, dynamic>? inputs,
    CalculationResult? result,
    DateTime? createdAt,
    String? animalId,
    String? notes,
  }) {
    return CalculationHistory(
      id: id ?? this.id,
      calculatorId: calculatorId ?? this.calculatorId,
      calculatorName: calculatorName ?? this.calculatorName,
      inputs: inputs ?? this.inputs,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      animalId: animalId ?? this.animalId,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    calculatorId,
    calculatorName,
    inputs,
    result,
    createdAt,
    animalId,
    notes,
  ];
}
