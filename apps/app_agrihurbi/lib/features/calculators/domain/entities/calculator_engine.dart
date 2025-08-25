import 'dart:math' as math;

import 'calculation_result.dart';
import 'calculator_entity.dart';

/// Engine genérico para registro e execução de calculadoras
class CalculatorEngine {
  static final CalculatorEngine _instance = CalculatorEngine._internal();
  factory CalculatorEngine() => _instance;
  CalculatorEngine._internal();

  final Map<String, CalculatorEntity> _calculators = {};

  /// Registra uma calculadora no engine
  void registerCalculator(CalculatorEntity calculator) {
    _calculators[calculator.id] = calculator;
  }

  /// Registra múltiplas calculadoras
  void registerCalculators(List<CalculatorEntity> calculators) {
    for (final calculator in calculators) {
      registerCalculator(calculator);
    }
  }

  /// Obtém uma calculadora pelo ID
  CalculatorEntity? getCalculator(String id) {
    return _calculators[id];
  }

  /// Obtém todas as calculadoras registradas
  List<CalculatorEntity> getAllCalculators() {
    return _calculators.values.where((calc) => calc.isActive).toList();
  }

  /// Executa um cálculo
  CalculationResult executeCalculation(
    String calculatorId,
    Map<String, dynamic> inputs,
  ) {
    final calculator = _calculators[calculatorId];
    
    if (calculator == null) {
      return CalculationError(
        calculatorId: calculatorId,
        errorMessage: 'Calculadora não encontrada: $calculatorId',
        inputs: inputs,
      );
    }

    if (!calculator.isActive) {
      return CalculationError(
        calculatorId: calculatorId,
        errorMessage: 'Calculadora está inativa: ${calculator.name}',
        inputs: inputs,
      );
    }

    return calculator.executeCalculation(inputs);
  }

  /// Limpa todas as calculadoras registradas
  void clearCalculators() {
    _calculators.clear();
  }

  /// Verifica se uma calculadora está registrada
  bool hasCalculator(String id) {
    return _calculators.containsKey(id) && _calculators[id]!.isActive;
  }

  /// Obtém calculadoras por categoria
  List<CalculatorEntity> getCalculatorsByCategory(String category) {
    return _calculators.values
        .where((calc) => calc.category.name == category && calc.isActive)
        .toList();
  }
}

/// Utilitários matemáticos para cálculos
class CalculatorMath {
  /// Converte graus para radianos
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Converte radianos para graus
  static double radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  /// Calcula a hipotenusa
  static double hypotenuse(double a, double b) {
    return math.sqrt(a * a + b * b);
  }

  /// Converte hectare para metros quadrados
  static double hectareToSquareMeters(double hectares) {
    return hectares * 10000;
  }

  /// Converte metros quadrados para hectare
  static double squareMetersToHectare(double squareMeters) {
    return squareMeters / 10000;
  }

  /// Converte litros para metros cúbicos
  static double litersTocubic(double liters) {
    return liters / 1000;
  }

  /// Converte metros cúbicos para litros
  static double cubicToLiters(double cubic) {
    return cubic * 1000;
  }

  /// Arredonda para n casas decimais
  static double roundTo(double value, int decimals) {
    final factor = math.pow(10, decimals);
    return (value * factor).round() / factor;
  }

  /// Calcula percentual
  static double percentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  /// Aplica regra de três simples
  static double ruleOfThree(double a, double b, double c) {
    if (a == 0) return 0;
    return (b * c) / a;
  }

  /// Calcula área de círculo
  static double circleArea(double radius) {
    return math.pi * radius * radius;
  }

  /// Calcula área de retângulo
  static double rectangleArea(double width, double height) {
    return width * height;
  }

  /// Calcula volume de cilindro
  static double cylinderVolume(double radius, double height) {
    return math.pi * radius * radius * height;
  }

  /// Interpola valor linear
  static double linearInterpolation(
    double x,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    if (x2 == x1) return y1;
    return y1 + (y2 - y1) * ((x - x1) / (x2 - x1));
  }

  /// Calcula média aritmética
  static double average(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calcula desvio padrão
  static double standardDeviation(List<double> values) {
    if (values.length < 2) return 0;
    
    final mean = average(values);
    final squaredDiffs = values.map((v) => math.pow(v - mean, 2)).toList();
    final variance = squaredDiffs.reduce((a, b) => a + b) / (values.length - 1);
    
    return math.sqrt(variance);
  }

  /// Verifica se valor está no intervalo
  static bool isInRange(double value, double min, double max) {
    return value >= min && value <= max;
  }

  /// Limita valor ao intervalo
  static double clamp(double value, double min, double max) {
    return math.min(math.max(value, min), max);
  }
}