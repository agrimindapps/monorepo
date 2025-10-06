import 'package:core/core.dart' show Equatable;

import 'calculation_result.dart';

class CalculationHistory extends Equatable {
  final String id;
  final String userId;
  final String calculatorId;
  final String calculatorName;
  final DateTime createdAt;
  final CalculationResult result;
  final String? notes;
  final Map<String, String>? tags;

  const CalculationHistory({
    required this.id,
    required this.userId,
    required this.calculatorId,
    required this.calculatorName,
    required this.createdAt,
    required this.result,
    this.notes,
    this.tags,
  });

  CalculationHistory copyWith({
    String? id,
    String? userId,
    String? calculatorId,
    String? calculatorName,
    DateTime? createdAt,
    CalculationResult? result,
    String? notes,
    Map<String, String>? tags,
  }) {
    return CalculationHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      calculatorId: calculatorId ?? this.calculatorId,
      calculatorName: calculatorName ?? this.calculatorName,
      createdAt: createdAt ?? this.createdAt,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    calculatorId,
    calculatorName,
    createdAt,
    result,
    notes,
    tags,
  ];
}
