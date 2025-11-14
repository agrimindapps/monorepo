import 'package:core/core.dart' hide Column;

import '../../domain/entities/calculation_history.dart';
import '../../domain/entities/calculation_result.dart';

part 'calculation_history_model.g.dart';

/// Model para persistência do histórico de cálculos
@JsonSerializable()
class CalculationHistoryModel {
  final int? id;

  final String calculatorId;

  final String calculatorName;

  final Map<String, dynamic> inputs;

  final Map<String, dynamic> resultData;

  final DateTime createdAt;

  final String? animalId;

  final String? notes;

  final String? userId;

  final bool isDeleted;

  CalculationHistoryModel({
    this.id,
    required this.calculatorId,
    required this.calculatorName,
    required this.inputs,
    required this.resultData,
    required this.createdAt,
    this.animalId,
    this.notes,
    this.userId,
    this.isDeleted = false,
  });

  /// Converte de entity para model
  factory CalculationHistoryModel.fromEntity(CalculationHistory entity) {
    return CalculationHistoryModel(
      id: entity.id.isNotEmpty ? int.tryParse(entity.id) : null,
      calculatorId: entity.calculatorId,
      calculatorName: entity.calculatorName,
      inputs: Map<String, dynamic>.from(entity.inputs),
      resultData: _resultToMap(entity.result),
      createdAt: entity.createdAt,
      animalId: entity.animalId,
      notes: entity.notes,
    );
  }

  /// Converte de model para entity
  CalculationHistory toEntity() {
    return CalculationHistory(
      id: id?.toString() ?? '',
      calculatorId: calculatorId,
      calculatorName: calculatorName,
      inputs: Map<String, dynamic>.from(inputs),
      result: _mapToResult(resultData),
      createdAt: createdAt,
      animalId: animalId,
      notes: notes,
    );
  }

  factory CalculationHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$CalculationHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CalculationHistoryModelToJson(this);

  /// Converte CalculationResult para Map
  static Map<String, dynamic> _resultToMap(CalculationResult result) {
    return {
      'calculator_id': result.calculatorId,
      'results':
          result.results
              .map(
                (item) => {
                  'label': item.label,
                  'value': item.value,
                  'unit': item.unit,
                  'severity': item.severity.code,
                  'description': item.description,
                },
              )
              .toList(),
      'recommendations':
          result.recommendations
              .map(
                (rec) => {
                  'title': rec.title,
                  'message': rec.message,
                  'severity': rec.severity.code,
                  'action_label': rec.actionLabel,
                  'action_url': rec.actionUrl,
                },
              )
              .toList(),
      'summary': result.summary,
      'calculated_at': result.calculatedAt?.toIso8601String(),
    };
  }

  /// Converte Map para CalculationResult
  static CalculationResult _mapToResult(Map<String, dynamic> data) {
    final results =
        (data['results'] as List<dynamic>?)
            ?.map(
              (item) => ResultItem(
                label: item['label'] as String,
                value: item['value'],
                unit: item['unit'] as String?,
                severity: _parseSeverity(item['severity'] as String?),
                description: item['description'] as String?,
              ),
            )
            .toList() ??
        [];

    final recommendations =
        (data['recommendations'] as List<dynamic>?)
            ?.map(
              (item) => Recommendation(
                title: item['title'] as String,
                message: item['message'] as String,
                severity: _parseSeverity(item['severity'] as String?),
                actionLabel: item['action_label'] as String?,
                actionUrl: item['action_url'] as String?,
              ),
            )
            .toList() ??
        [];

    return _GenericCalculationResult(
      calculatorId: data['calculator_id'] as String,
      results: results,
      recommendations: recommendations,
      summary: data['summary'] as String?,
      calculatedAt:
          data['calculated_at'] != null
              ? DateTime.parse(data['calculated_at'] as String)
              : null,
    );
  }

  static ResultSeverity _parseSeverity(String? severityCode) {
    switch (severityCode) {
      case 'warning':
        return ResultSeverity.warning;
      case 'danger':
        return ResultSeverity.danger;
      case 'success':
        return ResultSeverity.success;
      default:
        return ResultSeverity.info;
    }
  }
}

/// Implementação genérica de CalculationResult para deserialização
class _GenericCalculationResult extends CalculationResult {
  const _GenericCalculationResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}
