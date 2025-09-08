import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Evapotranspiração de Referência (ETo)
/// Calcula ETo pelo método de Penman-Monteith (FAO-56)
class EvapotranspirationCalculator extends CalculatorEntity {
  const EvapotranspirationCalculator()
      : super(
          id: 'evapotranspiration',
          name: 'Evapotranspiração (ETo)',
          description: 'Calcula a evapotranspiração de referência pelo método de Penman-Monteith (FAO-56)',
          category: CalculatorCategory.irrigation,
          parameters: const [
            CalculatorParameter(
              id: 'temp_max',
              name: 'Temperatura Máxima',
              description: 'Temperatura máxima diária (°C)',
              type: ParameterType.decimal,
              unit: ParameterUnit.celsius,
              minValue: 0.0,
              maxValue: 50.0,
              defaultValue: 30.0,
              validationMessage: 'Temperatura máxima deve estar entre 0°C e 50°C',
            ),
            CalculatorParameter(
              id: 'temp_min',
              name: 'Temperatura Mínima',
              description: 'Temperatura mínima diária (°C)',
              type: ParameterType.decimal,
              unit: ParameterUnit.celsius,
              minValue: -10.0,
              maxValue: 40.0,
              defaultValue: 18.0,
              validationMessage: 'Temperatura mínima deve estar entre -10°C e 40°C',
            ),
            CalculatorParameter(
              id: 'humidity',
              name: 'Umidade Relativa',
              description: 'Umidade relativa média (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 10.0,
              maxValue: 100.0,
              defaultValue: 65.0,
              validationMessage: 'Umidade deve estar entre 10% e 100%',
            ),
            CalculatorParameter(
              id: 'wind_speed',
              name: 'Velocidade do Vento',
              description: 'Velocidade média do vento (m/s)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 0.1,
              maxValue: 20.0,
              defaultValue: 2.0,
              validationMessage: 'Velocidade do vento deve estar entre 0.1 e 20.0 m/s',
            ),
            CalculatorParameter(
              id: 'solar_radiation',
              name: 'Radiação Solar',
              description: 'Radiação solar (MJ/m²/dia)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 5.0,
              maxValue: 35.0,
              defaultValue: 20.0,
              validationMessage: 'Radiação solar deve estar entre 5 e 35 MJ/m²/dia',
            ),
            CalculatorParameter(
              id: 'altitude',
              name: 'Altitude',
              description: 'Altitude do local (metros)',
              type: ParameterType.decimal,
              unit: ParameterUnit.metro,
              minValue: 0.0,
              maxValue: 4000.0,
              defaultValue: 500.0,
              validationMessage: 'Altitude deve estar entre 0 e 4000 metros',
            ),
            CalculatorParameter(
              id: 'latitude',
              name: 'Latitude',
              description: 'Latitude do local (graus decimais)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: -90.0,
              maxValue: 90.0,
              defaultValue: -15.0,
              validationMessage: 'Latitude deve estar entre -90° e 90°',
            ),
          ],
          formula: 'ETo = [0.408×Δ×(Rn-G) + γ×900/(T+273)×u2×(es-ea)] / [Δ + γ×(1+0.34×u2)]',
          references: const [
            'Allen et al. (1998) - FAO Irrigation and drainage paper 56',
            'Penman-Monteith equation',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double tempMax = double.parse(inputs['temp_max'].toString());
      final double tempMin = double.parse(inputs['temp_min'].toString());
      final double humidity = double.parse(inputs['humidity'].toString());
      final double windSpeed = double.parse(inputs['wind_speed'].toString());
      final double solarRadiation = double.parse(inputs['solar_radiation'].toString());
      final double altitude = double.parse(inputs['altitude'].toString());
      // ignore: unused_local_variable
      final double latitude = double.parse(inputs['latitude'].toString()); // TODO: Use in solar angle calculations

      // Validação básica
      if (tempMax <= tempMin) {
        return CalculationError(
          calculatorId: id,
          errorMessage: 'Temperatura máxima deve ser maior que a mínima',
          inputs: inputs,
        );
      }

      // Cálculos intermediários
      final double tempMean = (tempMax + tempMin) / 2;
      // ignore: unused_local_variable
      final double deltaTemp = tempMax - tempMin; // TODO: Use in temperature range calculations
      
      // Pressão atmosférica baseada na altitude
      final double atmPressure = 101.3 * math.pow((293 - 0.0065 * altitude) / 293, 5.26);
      
      // Constante psicrométrica
      final double gamma = 0.665 * atmPressure;
      
      // Inclinação da curva de pressão de vapor
      final double delta = 4098 * (0.6108 * math.exp(17.27 * tempMean / (tempMean + 237.3))) /
                          math.pow(tempMean + 237.3, 2);
      
      // Pressão de vapor de saturação
      final double esMax = 0.6108 * math.exp(17.27 * tempMax / (tempMax + 237.3));
      final double esMin = 0.6108 * math.exp(17.27 * tempMin / (tempMin + 237.3));
      final double es = (esMax + esMin) / 2;
      
      // Pressão de vapor atual
      final double ea = es * humidity / 100;
      
      // Déficit de pressão de vapor
      final double vpd = es - ea;
      
      // Radiação líquida (estimativa simplificada)
      final double rn = solarRadiation * 0.77 - 2.45; // MJ/m²/dia
      
      // Fluxo de calor no solo (G ≈ 0 para período diário)
      const double g = 0.0;
      
      // Cálculo da ETo (Penman-Monteith)
      final double numerator = 0.408 * delta * (rn - g) + 
                              gamma * 900 / (tempMean + 273) * windSpeed * vpd;
      final double denominator = delta + gamma * (1 + 0.34 * windSpeed);
      final double eto = numerator / denominator;
      
      // Cálculos adicionais
      final double etoWeekly = eto * 7;
      final double etoMonthly = eto * 30;
      final double radiationMmDay = solarRadiation * 0.408; // Conversão para mm/dia
      
      // Classificação da demanda evaporativa
      final String demandClass = _classifyEvaporativeDemand(eto);
      
      // Recomendações
      final List<String> recommendations = _generateRecommendations(
        eto, vpd, windSpeed, tempMean, humidity);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Evapotranspiração de Referência (ETo)',
            value: CalculatorMath.roundTo(eto, 2),
            unit: 'mm/dia',
            description: 'Evapotranspiração de referência diária',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'ETo Semanal',
            value: CalculatorMath.roundTo(etoWeekly, 1),
            unit: 'mm/semana',
            description: 'Evapotranspiração semanal',
          ),
          CalculationResultValue(
            label: 'ETo Mensal',
            value: CalculatorMath.roundTo(etoMonthly, 1),
            unit: 'mm/mês',
            description: 'Evapotranspiração mensal',
          ),
          CalculationResultValue(
            label: 'Temperatura Média',
            value: CalculatorMath.roundTo(tempMean, 1),
            unit: '°C',
            description: 'Temperatura média do período',
          ),
          CalculationResultValue(
            label: 'Déficit de Pressão de Vapor',
            value: CalculatorMath.roundTo(vpd, 2),
            unit: 'kPa',
            description: 'Diferença entre pressão de saturação e atual',
          ),
          CalculationResultValue(
            label: 'Radiação Equivalente',
            value: CalculatorMath.roundTo(radiationMmDay, 2),
            unit: 'mm/dia',
            description: 'Equivalente em evaporação da radiação solar',
          ),
          CalculationResultValue(
            label: 'Pressão Atmosférica',
            value: CalculatorMath.roundTo(atmPressure, 1),
            unit: 'kPa',
            description: 'Pressão atmosférica no local',
          ),
          CalculationResultValue(
            label: 'Classificação da Demanda',
            value: demandClass,
            unit: '',
            description: 'Classificação da demanda evaporativa',
          ),
        ],
        recommendations: recommendations,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  String _classifyEvaporativeDemand(double eto) {
    if (eto < 2.0) return 'Baixa';
    if (eto < 4.0) return 'Moderada';
    if (eto < 6.0) return 'Alta';
    if (eto < 8.0) return 'Muito Alta';
    return 'Extrema';
  }

  List<String> _generateRecommendations(
    double eto,
    double vpd,
    double windSpeed,
    double tempMean,
    double humidity,
  ) {
    final List<String> recommendations = [];

    // Recomendações baseadas na ETo
    if (eto < 2.0) {
      recommendations.add('Baixa demanda evaporativa. Irrigação menos frequente.');
    } else if (eto > 6.0) {
      recommendations.add('Alta demanda evaporativa. Aumente frequência de irrigação.');
    }

    // Recomendações baseadas na umidade
    if (humidity < 40) {
      recommendations.add('Baixa umidade relativa. Monitore stress hídrico das plantas.');
    } else if (humidity > 80) {
      recommendations.add('Alta umidade. Atenção para doenças fúngicas.');
    }

    // Recomendações baseadas no vento
    if (windSpeed > 4.0) {
      recommendations.add('Vento forte. Pode aumentar evapotranspiração e deriva na aplicação.');
    }

    // Recomendações baseadas na temperatura
    if (tempMean > 30) {
      recommendations.add('Temperaturas elevadas. Considere irrigação nos horários mais frescos.');
    }

    // Recomendações baseadas no déficit de pressão de vapor
    if (vpd > 2.0) {
      recommendations.add('Alto déficit de pressão de vapor. Risco de stress hídrico.');
    }

    return recommendations;
  }
}