import 'package:core/core.dart' show Equatable;

enum ResultType { single, multiple, table, chart, recommendations }

class CalculationResultValue extends Equatable {
  final String label;
  final dynamic value;
  final String unit;
  final String? description;
  final bool isPrimary;

  const CalculationResultValue({
    required this.label,
    required this.value,
    required this.unit,
    this.description,
    this.isPrimary = false,
  });

  String get formattedValue {
    if (value is double) {
      return '${(value as double).toStringAsFixed(2)} $unit';
    } else if (value is int) {
      return '$value $unit';
    } else {
      return '$value $unit';
    }
  }

  @override
  List<Object?> get props => [label, value, unit, description, isPrimary];
}

class CalculationResult extends Equatable {
  final String calculatorId;
  final DateTime calculatedAt;
  final Map<String, dynamic> inputs;
  final ResultType type;
  final List<CalculationResultValue> values;
  final List<String>? recommendations;
  final Map<String, dynamic>? chartData;
  final List<Map<String, dynamic>>? tableData;
  final bool isValid;
  final String? errorMessage;
  final String? interpretation;
  final List<String>? warnings;
  final Map<String, dynamic>? metadata;

  const CalculationResult({
    required this.calculatorId,
    required this.calculatedAt,
    required this.inputs,
    required this.type,
    required this.values,
    this.recommendations,
    this.chartData,
    this.tableData,
    this.isValid = true,
    this.errorMessage,
    this.interpretation,
    this.warnings,
    this.metadata,
  });

  CalculationResult copyWith({
    String? calculatorId,
    DateTime? calculatedAt,
    Map<String, dynamic>? inputs,
    ResultType? type,
    List<CalculationResultValue>? values,
    List<String>? recommendations,
    Map<String, dynamic>? chartData,
    List<Map<String, dynamic>>? tableData,
    bool? isValid,
    String? errorMessage,
    String? interpretation,
    List<String>? warnings,
    Map<String, dynamic>? metadata,
  }) {
    return CalculationResult(
      calculatorId: calculatorId ?? this.calculatorId,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      inputs: inputs ?? this.inputs,
      type: type ?? this.type,
      values: values ?? this.values,
      recommendations: recommendations ?? this.recommendations,
      chartData: chartData ?? this.chartData,
      tableData: tableData ?? this.tableData,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
      interpretation: interpretation ?? this.interpretation,
      warnings: warnings ?? this.warnings,
      metadata: metadata ?? this.metadata,
    );
  }

  CalculationResultValue? getPrimaryResult() {
    return values.where((v) => v.isPrimary).firstOrNull;
  }

  List<CalculationResultValue> getSecondaryResults() {
    return values.where((v) => !v.isPrimary).toList();
  }

  /// Obtém o valor primário do resultado
  dynamic get primaryValue {
    final primary = getPrimaryResult();
    return primary?.value;
  }

  /// Alias para values para compatibilidade
  List<CalculationResultValue> get results => values;

  /// Alias para metadata para compatibilidade
  Map<String, dynamic>? get additionalData => metadata;

  /// Adiciona métodos de serialização
  Map<String, dynamic> toJson() {
    return {
      'calculatorId': calculatorId,
      'calculatedAt': calculatedAt.toIso8601String(),
      'inputs': inputs,
      'type': type.name,
      'values':
          values
              .map(
                (v) => {
                  'label': v.label,
                  'value': v.value,
                  'unit': v.unit,
                  'description': v.description,
                  'isPrimary': v.isPrimary,
                },
              )
              .toList(),
      'recommendations': recommendations,
      'chartData': chartData,
      'tableData': tableData,
      'isValid': isValid,
      'errorMessage': errorMessage,
      'interpretation': interpretation,
      'warnings': warnings,
      'metadata': metadata,
    };
  }

  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      calculatorId: json['calculatorId'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
      inputs: Map<String, dynamic>.from(json['inputs'] as Map),
      type: ResultType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ResultType.single,
      ),
      values:
          (json['values'] as List)
              .map(
                (v) => CalculationResultValue(
                  label: v['label'] as String,
                  value: v['value'],
                  unit: v['unit'] as String,
                  description: v['description'] as String?,
                  isPrimary: v['isPrimary'] as bool? ?? false,
                ),
              )
              .toList(),
      recommendations:
          json['recommendations'] != null
              ? List<String>.from(json['recommendations'] as List)
              : null,
      chartData: json['chartData'] as Map<String, dynamic>?,
      tableData:
          json['tableData'] != null
              ? List<Map<String, dynamic>>.from(json['tableData'] as List)
              : null,
      isValid: json['isValid'] as bool? ?? true,
      errorMessage: json['errorMessage'] as String?,
      interpretation: json['interpretation'] as String?,
      warnings:
          json['warnings'] != null
              ? List<String>.from(json['warnings'] as List)
              : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [
    calculatorId,
    calculatedAt,
    inputs,
    type,
    values,
    recommendations,
    chartData,
    tableData,
    isValid,
    errorMessage,
    interpretation,
    warnings,
    metadata,
  ];
}

class CalculationError extends CalculationResult {
  CalculationError({
    required super.calculatorId,
    required String super.errorMessage,
    required super.inputs,
  }) : super(
         calculatedAt: DateTime.now(),
         type: ResultType.single,
         values: const [],
         isValid: false,
       );
}
