import 'package:equatable/equatable.dart';

/// Tipos de severidade para alertas e recomendações
enum ResultSeverity {
  info('info', 'Informativo'),
  warning('warning', 'Atenção'),
  danger('danger', 'Crítico'),
  success('success', 'Sucesso');

  const ResultSeverity(this.code, this.displayName);
  
  final String code;
  final String displayName;
}

/// Representa um item de resultado do cálculo
class ResultItem extends Equatable {
  const ResultItem({
    required this.label,
    required this.value,
    this.unit,
    this.severity = ResultSeverity.info,
    this.description,
  });

  /// Label do resultado (ex: "Dosagem recomendada")
  final String label;
  
  /// Valor do resultado
  final dynamic value;
  
  /// Unidade do resultado (ex: "ml", "mg/kg")
  final String? unit;
  
  /// Severidade do resultado
  final ResultSeverity severity;
  
  /// Descrição adicional do resultado
  final String? description;

  /// Retorna o valor formatado com a unidade
  String get formattedValue {
    final valueStr = value.toString();
    return unit != null ? '$valueStr $unit' : valueStr;
  }

  @override
  List<Object?> get props => [label, value, unit, severity, description];
}

/// Representa uma recomendação ou alerta
class Recommendation extends Equatable {
  const Recommendation({
    required this.title,
    required this.message,
    this.severity = ResultSeverity.info,
    this.actionLabel,
    this.actionUrl,
  });

  /// Título da recomendação
  final String title;
  
  /// Mensagem da recomendação
  final String message;
  
  /// Severidade da recomendação
  final ResultSeverity severity;
  
  /// Label de ação (ex: "Consultar veterinário")
  final String? actionLabel;
  
  /// URL de ação (para mais informações)
  final String? actionUrl;

  @override
  List<Object?> get props => [title, message, severity, actionLabel, actionUrl];
}

/// Resultado base de um cálculo de calculadora
abstract class CalculationResult extends Equatable {
  const CalculationResult({
    required this.calculatorId,
    required this.results,
    this.recommendations = const [],
    this.summary,
    this.calculatedAt,
  });

  /// ID da calculadora que gerou este resultado
  final String calculatorId;
  
  /// Lista de resultados do cálculo
  final List<ResultItem> results;
  
  /// Lista de recomendações baseadas no resultado
  final List<Recommendation> recommendations;
  
  /// Resumo textual do resultado
  final String? summary;
  
  /// Data/hora do cálculo
  final DateTime? calculatedAt;

  /// Verifica se há algum resultado com severidade de perigo
  bool get hasCriticalResults => results.any((r) => r.severity == ResultSeverity.danger) ||
      recommendations.any((r) => r.severity == ResultSeverity.danger);

  /// Verifica se há algum resultado com severidade de aviso
  bool get hasWarnings => results.any((r) => r.severity == ResultSeverity.warning) ||
      recommendations.any((r) => r.severity == ResultSeverity.warning);

  /// Retorna o resultado principal (primeiro da lista)
  ResultItem? get primaryResult => results.isNotEmpty ? results.first : null;

  @override
  List<Object?> get props => [calculatorId, results, recommendations, summary, calculatedAt];
}