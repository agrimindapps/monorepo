import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Necessidade Hídrica das Culturas
/// Calcula a necessidade de água baseada na evapotranspiração e características da cultura
class WaterNeedCalculator extends CalculatorEntity {
  const WaterNeedCalculator()
      : super(
          id: 'water_need',
          name: 'Necessidade Hídrica',
          description: 'Calcula a necessidade de água das culturas baseada na evapotranspiração de referência e coeficiente da cultura',
          category: CalculatorCategory.irrigation,
          parameters: const [
            CalculatorParameter(
              id: 'eto',
              name: 'Evapotranspiração de Referência (ETo)',
              description: 'Evapotranspiração de referência em mm/dia',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 0.1,
              maxValue: 15.0,
              defaultValue: 5.0,
              validationMessage: 'ETo deve estar entre 0.1 e 15.0 mm/dia',
            ),
            CalculatorParameter(
              id: 'kc',
              name: 'Coeficiente da Cultura (Kc)',
              description: 'Coeficiente da cultura para o estádio fenológico atual',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 0.1,
              maxValue: 2.0,
              defaultValue: 1.0,
              validationMessage: 'Kc deve estar entre 0.1 e 2.0',
            ),
            CalculatorParameter(
              id: 'area',
              name: 'Área da Cultura',
              description: 'Área total da cultura em hectares',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.01,
              maxValue: 10000.0,
              defaultValue: 1.0,
              validationMessage: 'Área deve ser maior que 0.01 ha',
            ),
            CalculatorParameter(
              id: 'efficiency',
              name: 'Eficiência do Sistema',
              description: 'Eficiência do sistema de irrigação (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 30.0,
              maxValue: 98.0,
              defaultValue: 80.0,
              validationMessage: 'Eficiência deve estar entre 30% e 98%',
            ),
            CalculatorParameter(
              id: 'crop_stage',
              name: 'Estádio da Cultura',
              description: 'Estádio fenológico atual da cultura',
              type: ParameterType.selection,
              options: ['Inicial', 'Desenvolvimento', 'Médio', 'Final'],
              defaultValue: 'Médio',
            ),
          ],
          formula: 'ETc = ETo × Kc; Volume = (ETc × Área) / Eficiência',
          references: const [
            'FAO 56 - Crop evapotranspiration',
            'Allen et al. (1998)',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double eto = double.parse(inputs['eto'].toString());
      final double kc = double.parse(inputs['kc'].toString());
      final double area = double.parse(inputs['area'].toString());
      final double efficiency = double.parse(inputs['efficiency'].toString()) / 100;
      final String cropStage = inputs['crop_stage'].toString();
      final double etc = eto * kc;
      final double dailyVolumeM3 = (etc / 1000) * CalculatorMath.hectareToSquareMeters(area);
      final double dailyVolumeLiters = CalculatorMath.cubicToLiters(dailyVolumeM3);
      final double realVolumeLiters = dailyVolumeLiters / efficiency;
      final double realVolumeM3 = CalculatorMath.litersTocubic(realVolumeLiters);
      final double weeklyVolumeLiters = realVolumeLiters * 7;
      final double monthlyVolumeLiters = realVolumeLiters * 30;
      final double literPerHectarePerDay = realVolumeLiters / area;
      final List<String> recommendations = _generateRecommendations(
        etc,
        cropStage,
        efficiency,
      );

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Evapotranspiração da Cultura (ETc)',
            value: CalculatorMath.roundTo(etc, 2),
            unit: 'mm/dia',
            description: 'Necessidade hídrica teórica da cultura',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Volume Diário Necessário',
            value: CalculatorMath.roundTo(realVolumeLiters, 1),
            unit: 'L/dia',
            description: 'Volume real considerando eficiência do sistema',
          ),
          CalculationResultValue(
            label: 'Volume Diário (m³)',
            value: CalculatorMath.roundTo(realVolumeM3, 2),
            unit: 'm³/dia',
            description: 'Volume em metros cúbicos por dia',
          ),
          CalculationResultValue(
            label: 'Volume Semanal',
            value: CalculatorMath.roundTo(weeklyVolumeLiters, 1),
            unit: 'L/semana',
            description: 'Volume necessário por semana',
          ),
          CalculationResultValue(
            label: 'Volume Mensal',
            value: CalculatorMath.roundTo(monthlyVolumeLiters, 1),
            unit: 'L/mês',
            description: 'Volume necessário por mês',
          ),
          CalculationResultValue(
            label: 'Lâmina por Hectare',
            value: CalculatorMath.roundTo(literPerHectarePerDay, 1),
            unit: 'L/ha/dia',
            description: 'Volume por hectare por dia',
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

  List<String> _generateRecommendations(
    double etc,
    String cropStage,
    double efficiency,
  ) {
    final List<String> recommendations = [];
    if (etc < 2.0) {
      recommendations.add('Baixa demanda hídrica. Monitore a umidade do solo.');
    } else if (etc > 7.0) {
      recommendations.add('Alta demanda hídrica. Aumente a frequência de irrigação.');
    }
    switch (cropStage) {
      case 'Inicial':
        recommendations.add('Estádio inicial: mantenha solo úmido mas evite encharcamento.');
        break;
      case 'Desenvolvimento':
        recommendations.add('Estádio de desenvolvimento: aumente gradualmente a irrigação.');
        break;
      case 'Médio':
        recommendations.add('Estádio médio: período de maior demanda hídrica.');
        break;
      case 'Final':
        recommendations.add('Estádio final: reduza a irrigação próximo à colheita.');
        break;
    }
    if (efficiency < 0.6) {
      recommendations.add('Eficiência baixa. Considere melhorias no sistema de irrigação.');
    } else if (efficiency > 0.9) {
      recommendations.add('Excelente eficiência do sistema de irrigação.');
    }

    return recommendations;
  }
}