import 'package:injectable/injectable.dart';
import 'dart:math' as math;
import '../entities/calculation_result.dart';
import '../interfaces/calculator_strategy.dart';

/// Service especializado em formatação de resultados de cálculos
/// 
/// Implementa Single Responsibility Principle (SRP) - foca apenas na formatação.
/// Separado do Calculator Engine para maior modularidade e personalização.
@injectable
class CalculatorFormattingService {

  /// Formata resultado de cálculo com base na estratégia
  Future<FormattedCalculationResult> formatResult(
    CalculationResult result,
    ICalculatorStrategy strategy, {
    FormattingOptions? options,
  }) async {
    final opts = options ?? const FormattingOptions();

    final formattedValues = await _formatResultValues(result.values, opts);
    final formattedRecommendations = _formatRecommendations(result.recommendations ?? [], opts);
    final formattedTableData = await _formatTableData(result.tableData ?? [], opts);

    return FormattedCalculationResult(
      calculatorId: result.calculatorId,
      strategyId: strategy.strategyId,
      strategyName: strategy.strategyName,
      title: _generateResultTitle(strategy, result),
      subtitle: _generateResultSubtitle(result),
      formattedValues: formattedValues,
      formattedRecommendations: formattedRecommendations,
      formattedTableData: formattedTableData,
      summary: await _generateSummary(result, strategy, opts),
      metadata: FormattingMetadata(
        formattedAt: DateTime.now(),
        locale: opts.locale,
        precision: opts.decimalPlaces,
        currency: opts.currency,
      ),
      originalResult: opts.includeOriginal ? result : null,
    );
  }

  /// Formata valor único para exibição
  String formatValue(
    double value, {
    int decimalPlaces = 2,
    String unit = '',
    bool useThousandsSeparator = true,
    String? prefix,
    String? suffix,
  }) {
    // Arredondamento
    final factor = math.pow(10, decimalPlaces);
    final rounded = (value * factor).round() / factor;

    // Formatação básica
    String formatted = rounded.toStringAsFixed(decimalPlaces);

    // Separador de milhares
    if (useThousandsSeparator && rounded >= 1000) {
      formatted = _addThousandsSeparator(formatted);
    }

    // Adicionar prefixo e sufixo
    if (prefix != null) formatted = '$prefix$formatted';
    if (unit.isNotEmpty) formatted = '$formatted $unit';
    if (suffix != null) formatted = '$formatted$suffix';

    return formatted;
  }

  /// Formata porcentagem
  String formatPercentage(
    double value, {
    int decimalPlaces = 1,
    bool includeSymbol = true,
  }) {
    final formatted = (value * 100).toStringAsFixed(decimalPlaces);
    return includeSymbol ? '$formatted%' : formatted;
  }

  /// Formata moeda brasileira
  String formatCurrency(
    double value, {
    int decimalPlaces = 2,
    bool includeSymbol = true,
    String symbol = 'R\$',
  }) {
    return formatValue(
      value,
      decimalPlaces: decimalPlaces,
      prefix: includeSymbol ? '$symbol ' : null,
      useThousandsSeparator: true,
    );
  }

  /// Formata área
  String formatArea(
    double value, {
    String unit = 'ha',
    int decimalPlaces = 2,
  }) {
    return formatValue(value, decimalPlaces: decimalPlaces, unit: unit);
  }

  /// Formata peso
  String formatWeight(
    double value, {
    String unit = 'kg',
    int decimalPlaces = 1,
  }) {
    // Auto-conversão para toneladas se muito grande
    if (value >= 1000 && unit == 'kg') {
      return formatValue(value / 1000, decimalPlaces: decimalPlaces, unit: 't');
    }
    return formatValue(value, decimalPlaces: decimalPlaces, unit: unit);
  }

  /// Formata volume
  String formatVolume(
    double value, {
    String unit = 'L',
    int decimalPlaces = 1,
  }) {
    // Auto-conversão para m³ se muito grande
    if (value >= 1000 && unit == 'L') {
      return formatValue(value / 1000, decimalPlaces: decimalPlaces, unit: 'm³');
    }
    return formatValue(value, decimalPlaces: decimalPlaces, unit: unit);
  }

  /// Formata lista de resultados para tabela
  List<FormattedTableRow> formatTableData(
    List<Map<String, dynamic>> tableData, {
    FormattingOptions? options,
  }) {
    final opts = options ?? const FormattingOptions();
    
    return tableData.map((row) {
      final formattedCells = <String, String>{};
      
      for (final entry in row.entries) {
        formattedCells[entry.key] = _formatCellValue(entry.value, opts);
      }
      
      return FormattedTableRow(
        originalData: row,
        formattedCells: formattedCells,
      );
    }).toList();
  }

  /// Gera resumo executivo dos resultados
  Future<ResultSummary> generateExecutiveSummary(
    CalculationResult result,
    ICalculatorStrategy strategy,
  ) async {
    final primaryValues = result.values.where((v) => v.isPrimary).toList();
    final keyInsights = _extractKeyInsights(result);
    
    return ResultSummary(
      title: 'Resumo - ${strategy.strategyName}',
      primaryResults: primaryValues.map((v) => 
        '${v.label}: ${formatValue(v.value, unit: v.unit)}'
      ).toList(),
      keyInsights: keyInsights,
      totalRecommendations: result.recommendations?.length ?? 0,
      confidence: _calculateConfidence(result),
    );
  }

  // ============= MÉTODOS PRIVADOS =============

  Future<List<FormattedResultValue>> _formatResultValues(
    List<CalculationResultValue> values,
    FormattingOptions options,
  ) async {
    return values.map((value) {
      final formatted = _formatByUnit(value.value, value.unit, options);
      
      return FormattedResultValue(
        label: value.label,
        formattedValue: formatted,
        originalValue: value.value,
        unit: value.unit,
        description: value.description ?? '',
        isPrimary: value.isPrimary,
        category: _categorizeValue(value),
      );
    }).toList();
  }

  List<FormattedRecommendation> _formatRecommendations(
    List<String> recommendations,
    FormattingOptions options,
  ) {
    return recommendations.asMap().entries.map((entry) {
      final index = entry.key;
      final recommendation = entry.value;
      
      return FormattedRecommendation(
        id: 'rec_$index',
        text: recommendation,
        priority: _extractPriority(recommendation),
        category: _categorizeRecommendation(recommendation),
        actionable: _isActionable(recommendation),
      );
    }).toList();
  }

  Future<List<FormattedTableRow>> _formatTableData(
    List<Map<String, dynamic>> tableData,
    FormattingOptions options,
  ) async {
    return formatTableData(tableData, options: options);
  }

  String _formatByUnit(double value, String unit, FormattingOptions options) {
    switch (unit.toLowerCase()) {
      case 'kg':
      case 'kg/ha':
        return formatWeight(value, decimalPlaces: options.decimalPlaces);
      case 't':
      case 't/ha':
        return formatWeight(value, unit: 't', decimalPlaces: options.decimalPlaces);
      case 'ha':
        return formatArea(value, decimalPlaces: options.decimalPlaces);
      case 'r\$':
        return formatCurrency(value, decimalPlaces: options.decimalPlaces);
      case '%':
        return formatPercentage(value / 100, decimalPlaces: options.decimalPlaces);
      case 'l':
        return formatVolume(value, decimalPlaces: options.decimalPlaces);
      default:
        return formatValue(value, decimalPlaces: options.decimalPlaces, unit: unit);
    }
  }

  String _formatCellValue(dynamic value, FormattingOptions options) {
    if (value is num) {
      return formatValue(value.toDouble(), decimalPlaces: options.decimalPlaces);
    }
    return value.toString();
  }

  String _addThousandsSeparator(String number) {
    // Separar parte decimal
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';
    
    // Adicionar separadores a cada 3 dígitos
    final regex = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    final formattedInteger = integerPart.replaceAll(regex, r'$1.');
    
    return formattedInteger + decimalPart;
  }

  String _generateResultTitle(ICalculatorStrategy strategy, CalculationResult result) {
    return 'Resultado - ${strategy.strategyName}';
  }

  String _generateResultSubtitle(CalculationResult result) {
    final primaryCount = result.values.where((v) => v.isPrimary).length;
    final recommendationCount = result.recommendations?.length ?? 0;
    return '$primaryCount resultados principais • $recommendationCount recomendações';
  }

  Future<String> _generateSummary(
    CalculationResult result, 
    ICalculatorStrategy strategy,
    FormattingOptions options,
  ) async {
    final primaryValues = result.values.where((v) => v.isPrimary).take(3);
    final summaryParts = <String>[];
    
    for (final value in primaryValues) {
      final formatted = _formatByUnit(value.value, value.unit, options);
      summaryParts.add('${value.label}: $formatted');
    }
    
    if (result.recommendations?.isNotEmpty == true) {
      summaryParts.add('${result.recommendations!.length} recomendações geradas');
    }
    
    return summaryParts.join(' • ');
  }

  ValueCategory _categorizeValue(CalculationResultValue value) {
    if (value.isPrimary) return ValueCategory.primary;
    if (value.unit.toLowerCase().contains('r\$')) return ValueCategory.financial;
    if (value.label.toLowerCase().contains('total')) return ValueCategory.total;
    return ValueCategory.supporting;
  }

  RecommendationPriority _extractPriority(String recommendation) {
    final lower = recommendation.toLowerCase();
    if (lower.contains('importante') || lower.contains('crítico') || lower.contains('essencial')) {
      return RecommendationPriority.high;
    }
    if (lower.contains('recomenda') || lower.contains('considera')) {
      return RecommendationPriority.medium;
    }
    return RecommendationPriority.low;
  }

  RecommendationCategory _categorizeRecommendation(String recommendation) {
    final lower = recommendation.toLowerCase();
    if (lower.contains('aplicação') || lower.contains('aplicar')) {
      return RecommendationCategory.application;
    }
    if (lower.contains('análise') || lower.contains('monitorar')) {
      return RecommendationCategory.monitoring;
    }
    if (lower.contains('solo') || lower.contains('ph')) {
      return RecommendationCategory.soil;
    }
    if (lower.contains('nutriente') || lower.contains('fertilizante')) {
      return RecommendationCategory.nutrition;
    }
    return RecommendationCategory.general;
  }

  bool _isActionable(String recommendation) {
    final actionWords = ['aplicar', 'realizar', 'considerar', 'adequar', 'implementar'];
    final lower = recommendation.toLowerCase();
    return actionWords.any((word) => lower.contains(word));
  }

  List<String> _extractKeyInsights(CalculationResult result) {
    final insights = <String>[];
    
    // Insights baseados nos valores primários
    final primaryValues = result.values.where((v) => v.isPrimary).toList();
    
    if (primaryValues.length >= 3) {
      final maxValue = primaryValues.reduce((a, b) => a.value > b.value ? a : b);
      insights.add('${maxValue.label} é o maior valor calculado');
    }
    
    // Insights baseados em recomendações
    if ((result.recommendations?.length ?? 0) > 5) {
      insights.add('Múltiplas recomendações indicam necessidade de atenção especial');
    }
    
    return insights;
  }

  double _calculateConfidence(CalculationResult result) {
    // Algoritmo simples para calcular confiança baseado na completude dos dados
    double confidence = 0.8; // Base
    
    if (result.values.isNotEmpty) confidence += 0.1;
    if (result.recommendations?.isNotEmpty == true) confidence += 0.1;
    if (result.tableData?.isNotEmpty == true) confidence += 0.1;
    
    return math.min(confidence, 1.0);
  }
}

// ============= DATA CLASSES =============

class FormattingOptions {
  final int decimalPlaces;
  final String locale;
  final String currency;
  final bool useThousandsSeparator;
  final bool includeOriginal;

  const FormattingOptions({
    this.decimalPlaces = 2,
    this.locale = 'pt_BR',
    this.currency = 'BRL',
    this.useThousandsSeparator = true,
    this.includeOriginal = false,
  });
}

class FormattedCalculationResult {
  final String calculatorId;
  final String strategyId;
  final String strategyName;
  final String title;
  final String subtitle;
  final List<FormattedResultValue> formattedValues;
  final List<FormattedRecommendation> formattedRecommendations;
  final List<FormattedTableRow> formattedTableData;
  final String summary;
  final FormattingMetadata metadata;
  final CalculationResult? originalResult;

  const FormattedCalculationResult({
    required this.calculatorId,
    required this.strategyId,
    required this.strategyName,
    required this.title,
    required this.subtitle,
    required this.formattedValues,
    required this.formattedRecommendations,
    required this.formattedTableData,
    required this.summary,
    required this.metadata,
    this.originalResult,
  });
}

class FormattedResultValue {
  final String label;
  final String formattedValue;
  final double originalValue;
  final String unit;
  final String description;
  final bool isPrimary;
  final ValueCategory category;

  const FormattedResultValue({
    required this.label,
    required this.formattedValue,
    required this.originalValue,
    required this.unit,
    required this.description,
    required this.isPrimary,
    required this.category,
  });
}

class FormattedRecommendation {
  final String id;
  final String text;
  final RecommendationPriority priority;
  final RecommendationCategory category;
  final bool actionable;

  const FormattedRecommendation({
    required this.id,
    required this.text,
    required this.priority,
    required this.category,
    required this.actionable,
  });
}

class FormattedTableRow {
  final Map<String, dynamic> originalData;
  final Map<String, String> formattedCells;

  const FormattedTableRow({
    required this.originalData,
    required this.formattedCells,
  });
}

class FormattingMetadata {
  final DateTime formattedAt;
  final String locale;
  final int precision;
  final String currency;

  const FormattingMetadata({
    required this.formattedAt,
    required this.locale,
    required this.precision,
    required this.currency,
  });
}

class ResultSummary {
  final String title;
  final List<String> primaryResults;
  final List<String> keyInsights;
  final int totalRecommendations;
  final double confidence;

  const ResultSummary({
    required this.title,
    required this.primaryResults,
    required this.keyInsights,
    required this.totalRecommendations,
    required this.confidence,
  });
}

enum ValueCategory {
  primary,
  supporting,
  financial,
  total,
}

enum RecommendationPriority {
  high,
  medium,
  low,
}

enum RecommendationCategory {
  application,
  monitoring,
  soil,
  nutrition,
  general,
}