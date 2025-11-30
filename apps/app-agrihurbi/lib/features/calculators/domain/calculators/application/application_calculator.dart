import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Aplicação de Insumos
/// Calcula volume total, número de tanques e cobertura para aplicação de defensivos e fertilizantes
class ApplicationCalculator extends CalculatorEntity {
  const ApplicationCalculator()
      : super(
          id: 'application',
          name: 'Aplicação de Insumos',
          description:
              'Calcula volume total necessário, número de tanques e cobertura para aplicação de defensivos agrícolas e fertilizantes',
          category: CalculatorCategory.management,
          parameters: const [
            CalculatorParameter(
              id: 'area',
              name: 'Área Total',
              description: 'Área total a ser aplicada em hectares',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.1,
              maxValue: 10000.0,
              defaultValue: 10.0,
              validationMessage: 'Área deve estar entre 0.1 e 10.000 ha',
            ),
            CalculatorParameter(
              id: 'dose_per_hectare',
              name: 'Dose por Hectare',
              description: 'Volume de calda a ser aplicado por hectare (L/ha)',
              type: ParameterType.decimal,
              unit: ParameterUnit.litroha,
              minValue: 50.0,
              maxValue: 1000.0,
              defaultValue: 200.0,
              validationMessage: 'Dose deve estar entre 50 e 1000 L/ha',
            ),
            CalculatorParameter(
              id: 'tank_volume',
              name: 'Volume do Tanque',
              description: 'Capacidade do tanque do pulverizador em litros',
              type: ParameterType.decimal,
              unit: ParameterUnit.litro,
              minValue: 100.0,
              maxValue: 10000.0,
              defaultValue: 2000.0,
              validationMessage: 'Volume do tanque deve estar entre 100 e 10.000 L',
            ),
            CalculatorParameter(
              id: 'spray_width',
              name: 'Largura da Faixa',
              description: 'Largura efetiva de aplicação da barra em metros',
              type: ParameterType.decimal,
              unit: ParameterUnit.metro,
              minValue: 3.0,
              maxValue: 50.0,
              defaultValue: 18.0,
              validationMessage: 'Largura deve estar entre 3 e 50 m',
            ),
            CalculatorParameter(
              id: 'work_speed',
              name: 'Velocidade de Trabalho',
              description: 'Velocidade do equipamento durante aplicação (km/h)',
              type: ParameterType.decimal,
              unit: ParameterUnit.kilometro,
              minValue: 3.0,
              maxValue: 30.0,
              defaultValue: 8.0,
              validationMessage: 'Velocidade deve estar entre 3 e 30 km/h',
            ),
            CalculatorParameter(
              id: 'product_concentration',
              name: 'Concentração do Produto',
              description: 'Dose do produto por hectare (mL ou g/ha)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 0.0,
              maxValue: 10000.0,
              defaultValue: 500.0,
              required: false,
              validationMessage: 'Concentração deve estar entre 0 e 10.000',
            ),
            CalculatorParameter(
              id: 'product_unit',
              name: 'Unidade do Produto',
              description: 'Unidade de medida da dose do produto',
              type: ParameterType.selection,
              options: ['mL/ha', 'g/ha', 'L/ha', 'kg/ha'],
              defaultValue: 'mL/ha',
              required: false,
            ),
          ],
          formula: 'Volume Total = Área × Dose/ha; Tanques = Volume Total / Vol. Tanque; Cobertura = Vol. Tanque / Dose/ha',
          references: const [
            'ANDEF - Manual de Aplicação de Defensivos Agrícolas',
            'EMBRAPA - Tecnologia de Aplicação de Agrotóxicos',
            'Matuo et al. (2010) - Tecnologia de Aplicação',
          ],
          tags: const ['aplicação', 'pulverização', 'defensivos', 'insumos'],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double area = double.parse(inputs['area'].toString());
      final double dosePerHectare = double.parse(inputs['dose_per_hectare'].toString());
      final double tankVolume = double.parse(inputs['tank_volume'].toString());
      final double sprayWidth = double.parse(inputs['spray_width'].toString());
      final double workSpeed = double.parse(inputs['work_speed'].toString());
      final double productConcentration = inputs['product_concentration'] != null
          ? double.parse(inputs['product_concentration'].toString())
          : 0.0;
      final String productUnit = inputs['product_unit']?.toString() ?? 'mL/ha';

      // Cálculos principais
      final double totalVolume = area * dosePerHectare;
      final double numberOfTanks = totalVolume / tankVolume;
      final int completeTanks = numberOfTanks.floor();
      final double remainingVolume = (numberOfTanks - completeTanks) * tankVolume;
      final double coveragePerTank = tankVolume / dosePerHectare;

      // Cálculos de rendimento operacional
      final double operationalYield = (sprayWidth * workSpeed * 10) / 10; // ha/h
      final double timeToComplete = area / operationalYield;
      final double distanceToTravel = (area * 10000) / sprayWidth / 1000; // km

      // Cálculo de vazão por bico (assumindo bicos espaçados 0.5m)
      final int numberOfNozzles = (sprayWidth / 0.5).round();
      final double flowPerNozzle = (dosePerHectare * workSpeed) / (600 * sprayWidth);
      final double totalFlowRate = flowPerNozzle * numberOfNozzles;

      // Cálculo do produto por tanque
      final double productPerTank = productConcentration > 0
          ? (productConcentration * coveragePerTank)
          : 0.0;
      final double totalProduct = productConcentration * area;

      // Recomendações
      final List<String> recommendations = _generateRecommendations(
        dosePerHectare,
        workSpeed,
        flowPerNozzle,
        numberOfTanks,
        timeToComplete,
      );

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Volume Total de Calda',
            value: CalculatorMath.roundTo(totalVolume, 1),
            unit: 'L',
            description: 'Volume total necessário para toda a área',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Número de Tanques',
            value: CalculatorMath.roundTo(numberOfTanks, 1),
            unit: 'tanques',
            description: 'Quantidade de tanques cheios necessários',
          ),
          CalculationResultValue(
            label: 'Tanques Completos',
            value: completeTanks,
            unit: 'tanques',
            description: 'Tanques totalmente cheios',
          ),
          CalculationResultValue(
            label: 'Volume do Último Tanque',
            value: CalculatorMath.roundTo(remainingVolume, 1),
            unit: 'L',
            description: 'Volume necessário no último tanque',
          ),
          CalculationResultValue(
            label: 'Cobertura por Tanque',
            value: CalculatorMath.roundTo(coveragePerTank, 2),
            unit: 'ha/tanque',
            description: 'Área coberta com um tanque cheio',
          ),
          CalculationResultValue(
            label: 'Rendimento Operacional',
            value: CalculatorMath.roundTo(operationalYield, 2),
            unit: 'ha/h',
            description: 'Área aplicada por hora de trabalho',
          ),
          CalculationResultValue(
            label: 'Tempo Estimado',
            value: CalculatorMath.roundTo(timeToComplete, 2),
            unit: 'h',
            description: 'Tempo total para completar a aplicação',
          ),
          CalculationResultValue(
            label: 'Distância a Percorrer',
            value: CalculatorMath.roundTo(distanceToTravel, 1),
            unit: 'km',
            description: 'Distância total percorrida',
          ),
          CalculationResultValue(
            label: 'Vazão por Bico',
            value: CalculatorMath.roundTo(flowPerNozzle, 3),
            unit: 'L/min',
            description: 'Vazão necessária por bico',
          ),
          CalculationResultValue(
            label: 'Vazão Total',
            value: CalculatorMath.roundTo(totalFlowRate, 2),
            unit: 'L/min',
            description: 'Vazão total do sistema',
          ),
          if (productConcentration > 0) ...[
            CalculationResultValue(
              label: 'Produto por Tanque',
              value: CalculatorMath.roundTo(productPerTank, 2),
              unit: productUnit.replaceAll('/ha', ''),
              description: 'Quantidade de produto por tanque',
            ),
            CalculationResultValue(
              label: 'Produto Total',
              value: CalculatorMath.roundTo(totalProduct, 2),
              unit: productUnit.replaceAll('/ha', ''),
              description: 'Quantidade total de produto',
            ),
          ],
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
    double dosePerHectare,
    double workSpeed,
    double flowPerNozzle,
    double numberOfTanks,
    double timeToComplete,
  ) {
    final List<String> recommendations = [];

    // Recomendações de volume de calda
    if (dosePerHectare < 100) {
      recommendations.add(
        'Volume de calda baixo (<100 L/ha). Recomendado para aplicações aéreas ou equipamentos específicos.',
      );
    } else if (dosePerHectare >= 100 && dosePerHectare <= 200) {
      recommendations.add(
        'Volume de calda adequado para aplicação de herbicidas e fungicidas sistêmicos.',
      );
    } else if (dosePerHectare > 200 && dosePerHectare <= 400) {
      recommendations.add(
        'Volume de calda ideal para aplicação de inseticidas e fungicidas de contato.',
      );
    } else {
      recommendations.add(
        'Volume de calda alto. Verificar necessidade ou considerar redução com adjuvantes.',
      );
    }

    // Recomendações de velocidade
    if (workSpeed < 5) {
      recommendations.add(
        'Velocidade baixa - adequada para terrenos acidentados ou culturas altas.',
      );
    } else if (workSpeed > 12) {
      recommendations.add(
        'Velocidade alta - verificar se há perda de qualidade na aplicação.',
      );
    }

    // Recomendações de vazão
    if (flowPerNozzle < 0.4) {
      recommendations.add(
        'Vazão por bico baixa. Verificar pressão e tipo de bico utilizado.',
      );
    } else if (flowPerNozzle > 1.2) {
      recommendations.add(
        'Vazão por bico alta. Considerar bicos de menor vazão ou reduzir pressão.',
      );
    }

    // Recomendações gerais
    recommendations.add('Calibre o equipamento antes de iniciar a aplicação.');
    recommendations.add('Aplique nas horas mais frescas do dia (manhã ou final da tarde).');
    recommendations.add('Evite aplicar com ventos acima de 10 km/h.');
    
    if (timeToComplete > 8) {
      recommendations.add(
        'Operação extensa (${timeToComplete.toStringAsFixed(1)}h). Considere divisão em jornadas.',
      );
    }

    return recommendations;
  }
}
