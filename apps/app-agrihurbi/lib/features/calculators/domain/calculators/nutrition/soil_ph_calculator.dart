import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de pH do Solo
/// Calcula a necessidade de calcário para correção do pH do solo
class SoilPHCalculator extends CalculatorEntity {
  const SoilPHCalculator()
      : super(
          id: 'soil_ph_calculator',
          name: 'Correção de pH do Solo',
          description: 'Calcula a necessidade de calcário para correção do pH do solo baseado na análise química',
          category: CalculatorCategory.nutrition,
          parameters: const [
            CalculatorParameter(
              id: 'current_ph',
              name: 'pH Atual do Solo',
              description: 'pH atual do solo medido em água (1:2,5)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 3.5,
              maxValue: 8.5,
              defaultValue: 5.2,
              validationMessage: 'pH deve estar entre 3.5 e 8.5',
            ),
            CalculatorParameter(
              id: 'target_ph',
              name: 'pH Desejado',
              description: 'pH desejado para a cultura',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 5.5,
              maxValue: 7.5,
              defaultValue: 6.5,
              validationMessage: 'pH desejado deve estar entre 5.5 e 7.5',
            ),
            CalculatorParameter(
              id: 'crop_type',
              name: 'Tipo da Cultura',
              description: 'Cultura a ser cultivada',
              type: ParameterType.selection,
              options: ['Milho', 'Soja', 'Trigo', 'Arroz', 'Feijão', 'Café', 'Algodão', 'Cana-de-açúcar', 'Tomate', 'Batata', 'Citros', 'Pastagem'],
              defaultValue: 'Milho',
            ),
            CalculatorParameter(
              id: 'aluminum_saturation',
              name: 'Saturação por Alumínio',
              description: 'Saturação por alumínio (m%) da análise de solo',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.0,
              maxValue: 80.0,
              defaultValue: 15.0,
              validationMessage: 'Saturação Al deve estar entre 0% e 80%',
            ),
            CalculatorParameter(
              id: 'base_saturation',
              name: 'Saturação por Bases',
              description: 'Saturação por bases (V%) da análise de solo',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 10.0,
              maxValue: 95.0,
              defaultValue: 45.0,
              validationMessage: 'Saturação bases deve estar entre 10% e 95%',
            ),
            CalculatorParameter(
              id: 'cec',
              name: 'CTC',
              description: 'Capacidade de troca catiônica efetiva (cmolc/dm³)',
              type: ParameterType.decimal,
              unit: ParameterUnit.cmolcdm3,
              minValue: 2.0,
              maxValue: 30.0,
              defaultValue: 8.5,
              validationMessage: 'CTC deve estar entre 2 e 30 cmolc/dm³',
            ),
            CalculatorParameter(
              id: 'clay_content',
              name: 'Teor de Argila',
              description: 'Porcentagem de argila no solo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 5.0,
              maxValue: 80.0,
              defaultValue: 35.0,
              validationMessage: 'Argila deve estar entre 5% e 80%',
            ),
            CalculatorParameter(
              id: 'area',
              name: 'Área a Corrigir',
              description: 'Área total a receber calcário (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.01,
              maxValue: 10000.0,
              defaultValue: 1.0,
              validationMessage: 'Área deve ser maior que 0.01 ha',
            ),
            CalculatorParameter(
              id: 'application_depth',
              name: 'Profundidade de Aplicação',
              description: 'Profundidade de incorporação do calcário (cm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.centimetro,
              minValue: 15.0,
              maxValue: 40.0,
              defaultValue: 20.0,
              validationMessage: 'Profundidade deve estar entre 15 e 40 cm',
            ),
            CalculatorParameter(
              id: 'limestone_prnt',
              name: 'PRNT do Calcário',
              description: 'Poder Relativo de Neutralização Total do calcário (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 60.0,
              maxValue: 100.0,
              defaultValue: 85.0,
              validationMessage: 'PRNT deve estar entre 60% e 100%',
            ),
          ],
          formula: 'NC = (CTC × (V2 - V1)) / 100 × f  ou  NC = Al × 2 × f',
          references: const [
            'Raij et al. (1997) - Recomendações de calagem para o Estado de São Paulo',
            'CQFS-RS/SC (2016) - Manual de adubação e calagem',
            'Alvarez et al. (1999) - Interpretação dos resultados das análises de solos',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double currentPH = double.parse(inputs['current_ph'].toString());
      final double targetPH = double.parse(inputs['target_ph'].toString());
      final String cropType = inputs['crop_type'].toString();
      final double aluminumSaturation = double.parse(inputs['aluminum_saturation'].toString());
      final double baseSaturation = double.parse(inputs['base_saturation'].toString());
      final double cec = double.parse(inputs['cec'].toString());
      final double clayContent = double.parse(inputs['clay_content'].toString());
      final double area = double.parse(inputs['area'].toString());
      final double applicationDepth = double.parse(inputs['application_depth'].toString());
      final double limestonePRNT = double.parse(inputs['limestone_prnt'].toString());
      if (targetPH <= currentPH) {
        return CalculationError(
          calculatorId: id,
          errorMessage: 'pH desejado deve ser maior que o pH atual',
          inputs: inputs,
        );
      }
      final double idealBaseSaturation = _getIdealBaseSaturation(cropType);
      final double actualTargetV = math.max(idealBaseSaturation, targetPH * 13.5 - 31.5);
      final Map<String, double> calculations = _calculateLimestoneNeed(
        currentPH,
        targetPH,
        aluminumSaturation,
        baseSaturation,
        actualTargetV,
        cec,
        clayContent,
      );
      final double limestoneNeed = _selectBestMethod(
        calculations,
        currentPH,
        aluminumSaturation,
        clayContent,
      );
      final double adjustedLimestoneNeed = limestoneNeed * (100 / limestonePRNT);
      final double depthFactor = applicationDepth / 20.0; // Referência 20 cm
      final double finalLimestoneNeed = adjustedLimestoneNeed * depthFactor;
      final double totalLimestone = finalLimestoneNeed * area;
      final List<Map<String, dynamic>> applicationSchedule = _generateApplicationSchedule(
        finalLimestoneNeed, cropType, currentPH);
      final Map<String, dynamic> costAnalysis = _calculateCostAnalysis(
        totalLimestone, currentPH, targetPH, area);
      final List<String> recommendations = _generateRecommendations(
        currentPH, targetPH, aluminumSaturation, baseSaturation, clayContent, finalLimestoneNeed);
      final Map<String, dynamic> soilChanges = _predictSoilChanges(
        currentPH, baseSaturation, aluminumSaturation, finalLimestoneNeed);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Necessidade de Calcário',
            value: CalculatorMath.roundTo(finalLimestoneNeed, 2),
            unit: 't/ha',
            description: 'Quantidade de calcário necessária por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Total para Área',
            value: CalculatorMath.roundTo(totalLimestone, 1),
            unit: 'toneladas',
            description: 'Quantidade total para $area ha',
          ),
          CalculationResultValue(
            label: 'Calcário PRNT 100%',
            value: CalculatorMath.roundTo(limestoneNeed, 2),
            unit: 't/ha',
            description: 'Equivalente em calcário PRNT 100%',
          ),
          CalculationResultValue(
            label: 'Elevação de pH Prevista',
            value: CalculatorMath.roundTo(soilChanges['ph_increase'] as double, 2),
            unit: 'unidades',
            description: 'Aumento esperado no pH',
          ),
          CalculationResultValue(
            label: 'V% Final Previsto',
            value: CalculatorMath.roundTo(soilChanges['final_v'] as double, 1),
            unit: '%',
            description: 'Saturação por bases após correção',
          ),
          CalculationResultValue(
            label: 'Redução Al Prevista',
            value: CalculatorMath.roundTo(soilChanges['al_reduction'] as double, 1),
            unit: '%',
            description: 'Redução na saturação por alumínio',
          ),
          CalculationResultValue(
            label: 'Método de Cálculo',
            value: calculations['selected_method'] as double,
            unit: '',
            description: _getMethodDescription(calculations['selected_method'] as double),
          ),
          CalculationResultValue(
            label: 'V% Ideal para Cultura',
            value: CalculatorMath.roundTo(idealBaseSaturation, 0),
            unit: '%',
            description: 'Saturação por bases ideal para $cropType',
          ),
          CalculationResultValue(
            label: 'Custo Estimado',
            value: CalculatorMath.roundTo(costAnalysis['total_cost'] as double, 0),
            unit: 'R\$',
            description: 'Custo estimado do calcário',
          ),
          CalculationResultValue(
            label: 'Economia Anual Prevista',
            value: CalculatorMath.roundTo(costAnalysis['annual_savings'] as double, 0),
            unit: 'R\$/ha',
            description: 'Economia com melhoria da fertilidade',
          ),
        ],
        recommendations: recommendations,
        tableData: applicationSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  double _getIdealBaseSaturation(String cropType) {
    final Map<String, double> idealV = {
      'Milho': 70.0,
      'Soja': 70.0,
      'Trigo': 70.0,
      'Arroz': 50.0, // Arroz irrigado tolera menor V%
      'Feijão': 70.0,
      'Café': 60.0,
      'Algodão': 80.0,
      'Cana-de-açúcar': 60.0,
      'Tomate': 80.0,
      'Batata': 75.0,
      'Citros': 70.0,
      'Pastagem': 50.0,
    };

    return idealV[cropType] ?? 70.0;
  }

  Map<String, double> _calculateLimestoneNeed(
    double currentPH,
    double targetPH,
    double alSaturation,
    double baseSaturation,
    double targetV,
    double cec,
    double clayContent,
  ) {
    final double method1 = (cec * (targetV - baseSaturation)) / 100;
    final double alCmolc = (alSaturation / 100) * cec;
    final double method2 = alCmolc * 2; // Fator 2 para neutralização completa
    final double smpBuffer = _estimateSMPBuffer(currentPH, clayContent);
    final double method3 = _smpToLimestone(smpBuffer, targetPH);
    final double deltaH = targetPH - currentPH;
    final double method4 = deltaH * (1.5 + clayContent / 100); // Ajuste por argila

    return {
      'method1': math.max(0, method1),
      'method2': math.max(0, method2),
      'method3': math.max(0, method3),
      'method4': math.max(0, method4),
      'selected_method': 1.0, // Será definido na seleção
    };
  }

  double _selectBestMethod(
    Map<String, double> calculations,
    double currentPH,
    double alSaturation,
    double clayContent,
  ) {
    double selectedValue;
    double selectedMethod;

    if (currentPH < 5.0 && alSaturation > 20) {
      selectedValue = calculations['method2']!;
      selectedMethod = 2.0;
    } else if (clayContent > 50) {
      selectedValue = calculations['method3']!;
      selectedMethod = 3.0;
    } else {
      selectedValue = calculations['method1']!;
      selectedMethod = 1.0;
    }
    final List<double> values = [
      calculations['method1']!,
      calculations['method2']!,
      calculations['method3']!,
      calculations['method4']!,
    ].where((v) => v > 0).toList();

    if (values.isNotEmpty) {
      final double average = values.reduce((a, b) => a + b) / values.length;
      final double maxDiff = values.map((v) => (v - average).abs()).reduce(math.max);
      
      if (maxDiff > average * 0.5) {
        selectedValue = average;
        selectedMethod = 0.0; // Indica método médio
      }
    }

    calculations['selected_method'] = selectedMethod;
    return selectedValue;
  }

  double _estimateSMPBuffer(double pH, double clayContent) {
    return 7.5 - (pH - 4.0) * 0.8 - (clayContent / 100) * 0.5;
  }

  double _smpToLimestone(double smpBuffer, double targetPH) {
    if (smpBuffer > 6.0) return 0.0;
    
    final double limeNeed = (6.0 - smpBuffer) * 2.5;
    return math.min(limeNeed, 8.0); // Máximo 8 t/ha
  }

  List<Map<String, dynamic>> _generateApplicationSchedule(
    double limestoneNeed,
    String cropType,
    double currentPH,
  ) {
    final List<Map<String, dynamic>> schedule = [];

    if (limestoneNeed <= 2.0) {
      schedule.add({
        'periodo': 'Aplicação Única',
        'quantidade': limestoneNeed,
        'percentual': 100,
        'operacao': 'Aplicar e incorporar',
        'observacao': 'Incorporar até 20 cm de profundidade'
      });
    } else if (limestoneNeed <= 4.0) {
      schedule.addAll([
        {
          'periodo': '1ª Aplicação',
          'quantidade': limestoneNeed * 0.6,
          'percentual': 60,
          'operacao': 'Aplicar e incorporar',
          'observacao': 'Aplicação principal antes do plantio'
        },
        {
          'periodo': '2ª Aplicação (6 meses)',
          'quantidade': limestoneNeed * 0.4,
          'percentual': 40,
          'operacao': 'Aplicar superficial',
          'observacao': 'Complemento - pode ser superficial'
        },
      ]);
    } else {
      schedule.addAll([
        {
          'periodo': '1ª Aplicação',
          'quantidade': limestoneNeed * 0.5,
          'percentual': 50,
          'operacao': 'Aplicar e incorporar',
          'observacao': 'Aplicação principal'
        },
        {
          'periodo': '2ª Aplicação (6 meses)',
          'quantidade': limestoneNeed * 0.3,
          'percentual': 30,
          'operacao': 'Aplicar e incorporar',
          'observacao': 'Incorporação leve'
        },
        {
          'periodo': '3ª Aplicação (12 meses)',
          'quantidade': limestoneNeed * 0.2,
          'percentual': 20,
          'operacao': 'Aplicar superficial',
          'observacao': 'Manutenção'
        },
      ]);
    }

    return schedule;
  }

  Map<String, dynamic> _calculateCostAnalysis(
    double totalLimestone,
    double currentPH,
    double targetPH,
    double area,
  ) {
    const double limestonePrice = 120.0; // R\$/t
    const double applicationCost = 50.0; // R\$/ha
    
    final double totalCost = (totalLimestone * limestonePrice) + (area * applicationCost);
    final double phIncrease = targetPH - currentPH;
    final double yieldIncrease = phIncrease * 0.15; // 15% por unidade de pH
    final double annualSavings = yieldIncrease * 2000; // R\$/ha/ano

    return {
      'total_cost': totalCost,
      'cost_per_ha': totalCost / area,
      'annual_savings': annualSavings,
      'payback_period': (totalCost / area) / annualSavings,
    };
  }

  Map<String, dynamic> _predictSoilChanges(
    double currentPH,
    double currentV,
    double currentAl,
    double limestoneNeed,
  ) {
    final double phIncrease = limestoneNeed * 0.3; // Aproximação
    final double finalPH = math.min(currentPH + phIncrease, 7.2);
    
    final double vIncrease = limestoneNeed * 8.0; // Aproximação
    final double finalV = math.min(currentV + vIncrease, 90.0);
    
    final double alReduction = math.min(currentAl, limestoneNeed * 15.0);

    return {
      'ph_increase': phIncrease,
      'final_ph': finalPH,
      'final_v': finalV,
      'al_reduction': alReduction,
    };
  }

  String _getMethodDescription(double method) {
    switch (method.toInt()) {
      case 1:
        return 'Saturação por Bases';
      case 2:
        return 'Neutralização do Alumínio';
      case 3:
        return 'Índice SMP';
      case 4:
        return 'Incubação';
      case 0:
        return 'Média dos Métodos';
      default:
        return 'Método Padrão';
    }
  }

  List<String> _generateRecommendations(
    double currentPH,
    double targetPH,
    double alSaturation,
    double baseSaturation,
    double clayContent,
    double limestoneNeed,
  ) {
    final List<String> recommendations = [];
    if (currentPH < 4.5) {
      recommendations.add('Solo extremamente ácido. Aplicar calcário parceladamente.');
    } else if (currentPH > 6.8) {
      recommendations.add('pH próximo ao neutro. Verificar real necessidade de calagem.');
    }
    if (alSaturation > 30) {
      recommendations.add('Alta saturação por Al. Priorizar neutralização do alumínio.');
    }
    if (limestoneNeed > 4.0) {
      recommendations.add('Dose alta de calcário. Aplicar parceladamente em 2-3 anos.');
    } else if (limestoneNeed < 1.0) {
      recommendations.add('Dose baixa. Aplicação única será suficiente.');
    }
    if (clayContent < 20) {
      recommendations.add('Solo arenoso: usar calcário com maior finura (PRNT >90%).');
    } else if (clayContent > 60) {
      recommendations.add('Solo argiloso: atenção à incorporação uniforme.');
    }
    recommendations.add('Aplicar calcário 60-90 dias antes do plantio.');
    recommendations.add('Incorporar o calcário uniformemente até 20 cm de profundidade.');
    recommendations.add('Verificar qualidade do calcário (PRNT, granulometria).');
    recommendations.add('Reavaliar pH após 12 meses da aplicação.');
    
    if (baseSaturation < 40) {
      recommendations.add('Baixa saturação por bases. Considerar gessagem complementar.');
    }

    return recommendations;
  }
}