import 'dart:math' as math;

import '../entities/calculation_result.dart';

/// Serviço de formatação de resultados de calculadoras
/// 
/// Implementa formatação contextual, cultural e responsiva para diferentes
/// tipos de resultados agrícolas com precisão adequada
class ResultFormatterService {

  /// Formata resultado principal com precisão adequada
  static String formatPrimaryResult(
    CalculationResultValue result, {
    bool showUnit = true,
    int? forcedDecimals,
  }) {
    final formattedValue = _formatNumber(
      (result.value as num).toDouble(),
      decimals: forcedDecimals ?? _getDecimalPlaces((result.value as num).toDouble(), result.unit),
      useThousandsSeparator: _shouldUseThousandsSeparator((result.value as num).toDouble()),
    );

    if (!showUnit || result.unit.isEmpty) {
      return formattedValue;
    }

    return '$formattedValue ${result.unit}';
  }

  /// Formata múltiplos resultados em formato tabular
  static List<Map<String, String>> formatResultsTable(
    List<CalculationResultValue> results, {
    bool includeDescriptions = false,
  }) {
    return results.map((result) {
      final row = <String, String>{
        'parametro': result.label,
        'valor': formatPrimaryResult(result, showUnit: false),
        'unidade': result.unit,
      };

      if (includeDescriptions && (result.description?.isNotEmpty == true)) {
        row['descricao'] = result.description!;
      }

      return row;
    }).toList();
  }

  /// Formata resultado com contexto científico/técnico
  static String formatScientificResult(
    double value,
    String unit, {
    int significantDigits = 3,
    bool useScientificNotation = false,
  }) {
    String formattedValue;

    if (useScientificNotation || value.abs() < 0.001 || value.abs() >= 1000000) {
      formattedValue = value.toStringAsExponential(significantDigits - 1);
    } else {
      final decimals = _calculateDecimalsForSignificantDigits(value, significantDigits);
      formattedValue = value.toStringAsFixed(decimals);
    }

    return unit.isEmpty ? formattedValue : '$formattedValue $unit';
  }

  /// Formata percentual com contexto
  static String formatPercentage(
    double value, {
    int decimals = 1,
    bool includeSymbol = true,
  }) {
    final formattedValue = value.toStringAsFixed(decimals);
    return includeSymbol ? '$formattedValue%' : formattedValue;
  }

  /// Formata range de valores
  static String formatValueRange(
    double minValue,
    double maxValue,
    String unit, {
    int? decimals,
  }) {
    final defaultDecimals = decimals ?? _getDecimalPlaces(maxValue, unit);
    
    final minFormatted = _formatNumber(minValue, decimals: defaultDecimals);
    final maxFormatted = _formatNumber(maxValue, decimals: defaultDecimals);

    if (unit.isEmpty) {
      return '$minFormatted - $maxFormatted';
    }

    return '$minFormatted - $maxFormatted $unit';
  }

  /// Formata resultado com qualificação (bom, ruim, ótimo)
  static FormattedQualifiedResult formatQualifiedResult(
    double value,
    String unit,
    List<QualityRange> qualityRanges, {
    int? decimals,
  }) {
    final formattedValue = formatPrimaryResult(
      CalculationResultValue(
        label: '',
        value: value,
        unit: unit,
        description: '',
      ),
      forcedDecimals: decimals,
    );

    final quality = _determineQuality(value, qualityRanges);
    final color = _getQualityColor(quality);
    final recommendation = _getQualityRecommendation(quality, qualityRanges);

    return FormattedQualifiedResult(
      formattedValue: formattedValue,
      quality: quality,
      color: color,
      recommendation: recommendation,
    );
  }

  /// Formata resultado de comparação
  static String formatComparisonResult(
    double actualValue,
    double targetValue,
    String unit, {
    bool showPercentageDifference = true,
  }) {
    final actualFormatted = formatPrimaryResult(
      CalculationResultValue(
        label: '',
        value: actualValue,
        unit: unit,
        description: '',
      ),
    );

    final targetFormatted = formatPrimaryResult(
      CalculationResultValue(
        label: '',
        value: targetValue,
        unit: unit,
        description: '',
      ),
    );

    String result = 'Atual: $actualFormatted | Meta: $targetFormatted';

    if (showPercentageDifference) {
      final percentDiff = ((actualValue - targetValue) / targetValue * 100).abs();
      final diffFormatted = formatPercentage(percentDiff);
      final indicator = actualValue > targetValue ? 'acima' : 'abaixo';
      result += ' ($diffFormatted $indicator)';
    }

    return result;
  }

  /// Formata conjunto de resultados relacionados
  static List<String> formatRelatedResults(
    Map<String, CalculationResultValue> results, {
    String separator = ' | ',
  }) {
    return results.entries.map((entry) {
      final label = entry.key;
      final result = entry.value;
      final formattedValue = formatPrimaryResult(result);
      return '$label: $formattedValue';
    }).toList();
  }

  /// Formata resultado para relatório
  static String formatReportResult(
    CalculationResultValue result, {
    bool includeDescription = true,
    bool includeContext = false,
  }) {
    var formatted = '${result.label}: ${formatPrimaryResult(result)}';

    if (includeDescription && (result.description?.isNotEmpty == true)) {
      formatted += ' (${result.description!})';
    }

    return formatted;
  }

  /// Formata lista de recomendações
  static List<String> formatRecommendations(
    List<String> recommendations, {
    bool numbered = true,
    String prefix = '•',
  }) {
    if (numbered) {
      return recommendations.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final recommendation = entry.value;
        return '$index. $recommendation';
      }).toList();
    } else {
      return recommendations.map((rec) => '$prefix $rec').toList();
    }
  }

  /// Formata dados históricos/temporais
  static List<Map<String, String>> formatTimeSeriesData(
    Map<DateTime, double> data,
    String unit, {
    String dateFormat = 'dd/MM/yyyy',
  }) {
    return data.entries.map((entry) {
      final date = entry.key;
      final value = entry.value;

      return {
        'data': _formatDate(date, dateFormat),
        'valor': formatPrimaryResult(
          CalculationResultValue(
            label: '',
            value: value,
            unit: unit,
            description: '',
          ),
        ),
      };
    }).toList();
  }

  /// Métodos auxiliares privados

  static String _formatNumber(
    double value, {
    required int decimals,
    bool useThousandsSeparator = false,
  }) {
    if (value.isNaN || value.isInfinite) {
      return 'N/A';
    }

    String formatted = value.toStringAsFixed(decimals);

    if (useThousandsSeparator && value.abs() >= 1000) {
      formatted = _addThousandsSeparator(formatted);
    }

    return formatted;
  }

  static int _getDecimalPlaces(double value, String unit) {
    // Determinar precisão baseada no valor e contexto
    if (unit.contains('%')) return 1;
    if (unit.contains('ha') || unit.contains('acre')) return 2;
    if (unit.contains('kg') || unit.contains('t')) return 1;
    if (unit.contains('L') || unit.contains('m³')) return 1;
    if (unit.contains('°C')) return 1;
    if (unit.contains('ppm') || unit.contains('mg')) return 2;

    // Baseado no valor
    if (value.abs() >= 1000) return 0;
    if (value.abs() >= 100) return 1;
    if (value.abs() >= 10) return 1;
    if (value.abs() >= 1) return 2;
    if (value.abs() >= 0.1) return 3;
    return 4;
  }

  static bool _shouldUseThousandsSeparator(double value) {
    return value.abs() >= 10000;
  }

  static String _addThousandsSeparator(String number) {
    // Implementação básica para separador de milhares (ponto no BR)
    final parts = number.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return decimalPart.isEmpty ? formattedInteger : '$formattedInteger,$decimalPart';
  }

  static int _calculateDecimalsForSignificantDigits(double value, int significantDigits) {
    if (value == 0) return significantDigits - 1;
    
    final magnitude = math.log(value.abs()) / math.ln10;
    final decimals = (significantDigits - 1 - magnitude.floor()).clamp(0, 10);
    return decimals;
  }

  static QualityLevel _determineQuality(double value, List<QualityRange> ranges) {
    for (final range in ranges) {
      if (value >= range.min && value <= range.max) {
        return range.quality;
      }
    }
    return QualityLevel.unknown;
  }

  static String _getQualityColor(QualityLevel quality) {
    switch (quality) {
      case QualityLevel.excellent:
        return '#4CAF50'; // Verde
      case QualityLevel.good:
        return '#8BC34A'; // Verde claro
      case QualityLevel.fair:
        return '#FF9800'; // Laranja
      case QualityLevel.poor:
        return '#F44336'; // Vermelho
      case QualityLevel.critical:
        return '#B71C1C'; // Vermelho escuro
      case QualityLevel.unknown:
        return '#9E9E9E'; // Cinza
    }
  }

  static String _getQualityRecommendation(
    QualityLevel quality,
    List<QualityRange> ranges,
  ) {
    final range = ranges.firstWhere(
      (r) => r.quality == quality,
      orElse: () => const QualityRange(
        min: 0,
        max: 0,
        quality: QualityLevel.unknown,
        recommendation: 'Valor fora dos parâmetros conhecidos',
      ),
    );
    return range.recommendation;
  }

  static String _formatDate(DateTime date, String format) {
    // Implementação básica de formatação de data
    switch (format) {
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/'
               '${date.month.toString().padLeft(2, '0')}/'
               '${date.year}';
      case 'MM/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy':
        return date.year.toString();
      default:
        return date.toString().split(' ')[0];
    }
  }
}

/// Níveis de qualidade para classificação de resultados
enum QualityLevel {
  excellent,
  good,
  fair,
  poor,
  critical,
  unknown,
}

/// Range de qualidade com recomendação
class QualityRange {
  final double min;
  final double max;
  final QualityLevel quality;
  final String recommendation;

  const QualityRange({
    required this.min,
    required this.max,
    required this.quality,
    required this.recommendation,
  });
}

/// Resultado formatado com qualificação
class FormattedQualifiedResult {
  final String formattedValue;
  final QualityLevel quality;
  final String color;
  final String recommendation;

  const FormattedQualifiedResult({
    required this.formattedValue,
    required this.quality,
    required this.color,
    required this.recommendation,
  });
}