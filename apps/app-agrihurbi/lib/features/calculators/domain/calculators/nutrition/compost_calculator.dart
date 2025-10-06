import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Compostagem
/// Calcula proporções ideais para compostagem e tempo de decomposição
class CompostCalculator extends CalculatorEntity {
  const CompostCalculator()
      : super(
          id: 'compost_calculator',
          name: 'Calculadora de Compostagem',
          description: 'Calcula proporções ideais de materiais para compostagem, tempo de decomposição e qualidade do composto final',
          category: CalculatorCategory.nutrition,
          parameters: const [
            CalculatorParameter(
              id: 'compost_type',
              name: 'Tipo de Compostagem',
              description: 'Método de compostagem a ser utilizado',
              type: ParameterType.selection,
              options: ['Leira Tradicional', 'Compostagem Termofílica', 'Vermicompostagem', 'Compostagem Acelerada', 'Bokashi'],
              defaultValue: 'Leira Tradicional',
            ),
            CalculatorParameter(
              id: 'brown_material_type',
              name: 'Material Marrom (Rico em C)',
              description: 'Tipo do material rico em carbono',
              type: ParameterType.selection,
              options: ['Palha de Arroz', 'Serragem', 'Folhas Secas', 'Papel/Papelão', 'Bagaço de Cana', 'Casca de Café', 'Sabugo de Milho'],
              defaultValue: 'Palha de Arroz',
            ),
            CalculatorParameter(
              id: 'brown_amount',
              name: 'Quantidade Material Marrom',
              description: 'Quantidade disponível do material rico em carbono (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 10.0,
              maxValue: 10000.0,
              defaultValue: 500.0,
              validationMessage: 'Quantidade deve estar entre 10 e 10.000 kg',
            ),
            CalculatorParameter(
              id: 'green_material_type',
              name: 'Material Verde (Rico em N)',
              description: 'Tipo do material rico em nitrogênio',
              type: ParameterType.selection,
              options: ['Esterco Bovino', 'Esterco Suíno', 'Esterco Galinha', 'Restos de Cozinha', 'Grama Cortada', 'Folhas Verdes', 'Resíduos de Poda'],
              defaultValue: 'Esterco Bovino',
            ),
            CalculatorParameter(
              id: 'green_amount',
              name: 'Quantidade Material Verde',
              description: 'Quantidade disponível do material rico em nitrogênio (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 5.0,
              maxValue: 5000.0,
              defaultValue: 200.0,
              validationMessage: 'Quantidade deve estar entre 5 e 5.000 kg',
            ),
            CalculatorParameter(
              id: 'target_cn_ratio',
              name: 'Relação C/N Desejada',
              description: 'Relação carbono/nitrogênio desejada para a compostagem',
              type: ParameterType.decimal,
              unit: ParameterUnit.ratio,
              minValue: 20.0,
              maxValue: 40.0,
              defaultValue: 30.0,
              validationMessage: 'Relação C/N deve estar entre 20:1 e 40:1',
            ),
            CalculatorParameter(
              id: 'moisture_content',
              name: 'Umidade Inicial',
              description: 'Umidade inicial estimada dos materiais (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 30.0,
              maxValue: 80.0,
              defaultValue: 55.0,
              validationMessage: 'Umidade deve estar entre 30% e 80%',
            ),
            CalculatorParameter(
              id: 'pile_size',
              name: 'Tamanho da Leira',
              description: 'Tamanho desejado da leira',
              type: ParameterType.selection,
              options: ['Pequena (1-2 m³)', 'Média (3-5 m³)', 'Grande (6-10 m³)', 'Industrial (>10 m³)'],
              defaultValue: 'Média (3-5 m³)',
            ),
            CalculatorParameter(
              id: 'ambient_temperature',
              name: 'Temperatura Ambiente',
              description: 'Temperatura média ambiente (°C)',
              type: ParameterType.decimal,
              unit: ParameterUnit.celsius,
              minValue: 10.0,
              maxValue: 40.0,
              defaultValue: 25.0,
              validationMessage: 'Temperatura deve estar entre 10°C e 40°C',
            ),
            CalculatorParameter(
              id: 'turning_frequency',
              name: 'Frequência de Reviramento',
              description: 'Frequência planejada de reviramento da leira',
              type: ParameterType.selection,
              options: ['Semanal', 'Quinzenal', 'Mensal', 'Apenas quando necessário'],
              defaultValue: 'Quinzenal',
            ),
            CalculatorParameter(
              id: 'desired_final_amount',
              name: 'Quantidade Final Desejada',
              description: 'Quantidade de composto final desejada (kg)',
              type: ParameterType.decimal,
              unit: ParameterUnit.quilograma,
              minValue: 50.0,
              maxValue: 5000.0,
              defaultValue: 300.0,
              validationMessage: 'Quantidade deve estar entre 50 e 5.000 kg',
            ),
          ],
          formula: 'C/N = (C₁×M₁ + C₂×M₂) / (N₁×M₁ + N₂×M₂)',
          references: const [
            'Kiehl (1985) - Fertilizantes Orgânicos',
            'Epstein (1997) - The Science of Composting',
            'Haug (1993) - The Practical Handbook of Compost Engineering',
            'CQFS-RS/SC (2016) - Manual de compostagem',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String compostType = inputs['compost_type'].toString();
      final String brownMaterialType = inputs['brown_material_type'].toString();
      final double brownAmount = double.parse(inputs['brown_amount'].toString());
      final String greenMaterialType = inputs['green_material_type'].toString();
      final double greenAmount = double.parse(inputs['green_amount'].toString());
      final double targetCNRatio = double.parse(inputs['target_cn_ratio'].toString());
      final double moistureContent = double.parse(inputs['moisture_content'].toString());
      final String pileSize = inputs['pile_size'].toString();
      final double ambientTemperature = double.parse(inputs['ambient_temperature'].toString());
      final String turningFrequency = inputs['turning_frequency'].toString();
      final double desiredFinalAmount = double.parse(inputs['desired_final_amount'].toString());
      final Map<String, dynamic> brownData = _getMaterialData(brownMaterialType, 'brown');
      final Map<String, dynamic> greenData = _getMaterialData(greenMaterialType, 'green');
      final Map<String, dynamic> cnAnalysis = _calculateCNRatio(
        brownAmount, greenAmount, brownData, greenData);
      final Map<String, dynamic> optimalProportions = _calculateOptimalProportions(
        brownData, greenData, targetCNRatio, desiredFinalAmount);
      final Map<String, dynamic> timeEstimate = _estimateCompostingTime(
        compostType, targetCNRatio, moistureContent, ambientTemperature, turningFrequency);
      final Map<String, dynamic> pileDimensions = _calculatePileDimensions(
        optimalProportions['total_material'] as double, pileSize, compostType);
      final List<Map<String, dynamic>> managementSchedule = _generateManagementSchedule(
        timeEstimate['total_time_days'] as int, turningFrequency, compostType);
      final Map<String, dynamic> qualityAnalysis = _analyzeExpectedQuality(
        cnAnalysis, timeEstimate, moistureContent, compostType);
      final Map<String, dynamic> finalNutrients = _calculateFinalNutrients(
        optimalProportions['brown_needed'] as double,
        optimalProportions['green_needed'] as double,
        brownData,
        greenData,
        timeEstimate['decomposition_rate'] as double,
      );
      final Map<String, dynamic> costAnalysis = _calculateCostAnalysis(
        optimalProportions, brownMaterialType, greenMaterialType, timeEstimate);
      final List<String> recommendations = _generateRecommendations(
        compostType, cnAnalysis, moistureContent, ambientTemperature, 
        optimalProportions, qualityAnalysis);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Material Marrom Necessário',
            value: CalculatorMath.roundTo(optimalProportions['brown_needed'] as double, 0),
            unit: 'kg',
            description: 'Quantidade de $brownMaterialType',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Material Verde Necessário',
            value: CalculatorMath.roundTo(optimalProportions['green_needed'] as double, 0),
            unit: 'kg',
            description: 'Quantidade de $greenMaterialType',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Relação C/N Resultante',
            value: CalculatorMath.roundTo(optimalProportions['resulting_cn'] as double, 1),
            unit: ':1',
            description: 'Relação carbono/nitrogênio final',
          ),
          CalculationResultValue(
            label: 'Volume Total da Leira',
            value: CalculatorMath.roundTo(pileDimensions['total_volume'] as double, 1),
            unit: 'm³',
            description: 'Volume inicial da leira',
          ),
          CalculationResultValue(
            label: 'Tempo Total de Compostagem',
            value: CalculatorMath.roundTo((timeEstimate['total_time_days'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Tempo estimado até o composto estar pronto',
          ),
          CalculationResultValue(
            label: 'Fase Termofílica',
            value: CalculatorMath.roundTo((timeEstimate['thermophilic_days'] as int).toDouble(), 0),
            unit: 'dias',
            description: 'Duração da fase ativa (>55°C)',
          ),
          CalculationResultValue(
            label: 'Rendimento Final',
            value: CalculatorMath.roundTo(optimalProportions['final_yield'] as double, 0),
            unit: 'kg',
            description: 'Quantidade estimada de composto final',
          ),
          CalculationResultValue(
            label: 'Taxa de Redução',
            value: CalculatorMath.roundTo(((1 - (optimalProportions['final_yield'] as double) / (optimalProportions['total_material'] as double)) * 100), 1),
            unit: '%',
            description: 'Redução de volume durante o processo',
          ),
          CalculationResultValue(
            label: 'N Total Final',
            value: CalculatorMath.roundTo(finalNutrients['total_n'] as double, 2),
            unit: '%',
            description: 'Nitrogênio total no composto final',
          ),
          CalculationResultValue(
            label: 'P Total Final',
            value: CalculatorMath.roundTo(finalNutrients['total_p'] as double, 2),
            unit: '%',
            description: 'Fósforo total no composto final',
          ),
          CalculationResultValue(
            label: 'K Total Final',
            value: CalculatorMath.roundTo(finalNutrients['total_k'] as double, 2),
            unit: '%',
            description: 'Potássio total no composto final',
          ),
          CalculationResultValue(
            label: 'Matéria Orgânica Final',
            value: CalculatorMath.roundTo(finalNutrients['organic_matter'] as double, 1),
            unit: '%',
            description: 'Teor de matéria orgânica no composto',
          ),
          CalculationResultValue(
            label: 'Custo Total Estimado',
            value: CalculatorMath.roundTo(costAnalysis['total_cost'] as double, 0),
            unit: 'R\$',
            description: 'Custo total do processo',
          ),
          CalculationResultValue(
            label: 'Custo por kg de Composto',
            value: CalculatorMath.roundTo(costAnalysis['cost_per_kg'] as double, 2),
            unit: 'R\$/kg',
            description: 'Custo unitário do composto produzido',
          ),
        ],
        recommendations: recommendations,
        tableData: managementSchedule,
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getMaterialData(String material, String type) {
    final Map<String, Map<String, dynamic>> materialDatabase = {
      'Palha de Arroz': {
        'carbon_content': 40.0,
        'nitrogen_content': 0.6,
        'cn_ratio': 67.0,
        'moisture': 12.0,
        'density': 150.0, // kg/m³
        'decomposition_rate': 0.7,
      },
      'Serragem': {
        'carbon_content': 45.0,
        'nitrogen_content': 0.1,
        'cn_ratio': 450.0,
        'moisture': 15.0,
        'density': 200.0,
        'decomposition_rate': 0.5,
      },
      'Folhas Secas': {
        'carbon_content': 42.0,
        'nitrogen_content': 0.8,
        'cn_ratio': 53.0,
        'moisture': 10.0,
        'density': 180.0,
        'decomposition_rate': 0.8,
      },
      'Papel/Papelão': {
        'carbon_content': 38.0,
        'nitrogen_content': 0.2,
        'cn_ratio': 190.0,
        'moisture': 8.0,
        'density': 250.0,
        'decomposition_rate': 0.6,
      },
      'Bagaço de Cana': {
        'carbon_content': 44.0,
        'nitrogen_content': 0.4,
        'cn_ratio': 110.0,
        'moisture': 50.0,
        'density': 300.0,
        'decomposition_rate': 0.75,
      },
      'Casca de Café': {
        'carbon_content': 48.0,
        'nitrogen_content': 1.2,
        'cn_ratio': 40.0,
        'moisture': 25.0,
        'density': 350.0,
        'decomposition_rate': 0.8,
      },
      'Sabugo de Milho': {
        'carbon_content': 46.0,
        'nitrogen_content': 0.5,
        'cn_ratio': 92.0,
        'moisture': 20.0,
        'density': 280.0,
        'decomposition_rate': 0.65,
      },
      'Esterco Bovino': {
        'carbon_content': 18.0,
        'nitrogen_content': 2.5,
        'cn_ratio': 7.2,
        'moisture': 80.0,
        'density': 800.0,
        'decomposition_rate': 0.9,
        'p_content': 1.0,
        'k_content': 2.0,
      },
      'Esterco Suíno': {
        'carbon_content': 15.0,
        'nitrogen_content': 3.5,
        'cn_ratio': 4.3,
        'moisture': 85.0,
        'density': 850.0,
        'decomposition_rate': 0.95,
        'p_content': 1.8,
        'k_content': 1.5,
      },
      'Esterco Galinha': {
        'carbon_content': 12.0,
        'nitrogen_content': 4.0,
        'cn_ratio': 3.0,
        'moisture': 75.0,
        'density': 750.0,
        'decomposition_rate': 0.9,
        'p_content': 2.5,
        'k_content': 2.0,
      },
      'Restos de Cozinha': {
        'carbon_content': 20.0,
        'nitrogen_content': 2.0,
        'cn_ratio': 10.0,
        'moisture': 80.0,
        'density': 600.0,
        'decomposition_rate': 0.85,
        'p_content': 0.5,
        'k_content': 1.0,
      },
      'Grama Cortada': {
        'carbon_content': 25.0,
        'nitrogen_content': 2.5,
        'cn_ratio': 10.0,
        'moisture': 85.0,
        'density': 400.0,
        'decomposition_rate': 0.9,
        'p_content': 0.3,
        'k_content': 1.5,
      },
      'Folhas Verdes': {
        'carbon_content': 28.0,
        'nitrogen_content': 3.0,
        'cn_ratio': 9.3,
        'moisture': 80.0,
        'density': 350.0,
        'decomposition_rate': 0.85,
        'p_content': 0.4,
        'k_content': 1.2,
      },
      'Resíduos de Poda': {
        'carbon_content': 35.0,
        'nitrogen_content': 1.5,
        'cn_ratio': 23.3,
        'moisture': 60.0,
        'density': 450.0,
        'decomposition_rate': 0.7,
        'p_content': 0.2,
        'k_content': 0.8,
      },
    };

    return materialDatabase[material] ?? (type == 'brown' 
        ? materialDatabase['Palha de Arroz']! 
        : materialDatabase['Esterco Bovino']!);
  }

  Map<String, dynamic> _calculateCNRatio(
    double brownAmount,
    double greenAmount,
    Map<String, dynamic> brownData,
    Map<String, dynamic> greenData,
  ) {
    final double brownCarbon = brownAmount * (brownData['carbon_content'] as double) / 100;
    final double brownNitrogen = brownAmount * (brownData['nitrogen_content'] as double) / 100;
    final double greenCarbon = greenAmount * (greenData['carbon_content'] as double) / 100;
    final double greenNitrogen = greenAmount * (greenData['nitrogen_content'] as double) / 100;

    final double totalCarbon = brownCarbon + greenCarbon;
    final double totalNitrogen = brownNitrogen + greenNitrogen;

    final double currentCNRatio = totalNitrogen > 0 ? totalCarbon / totalNitrogen : 0;

    return {
      'current_cn_ratio': currentCNRatio,
      'total_carbon': totalCarbon,
      'total_nitrogen': totalNitrogen,
      'brown_carbon': brownCarbon,
      'brown_nitrogen': brownNitrogen,
      'green_carbon': greenCarbon,
      'green_nitrogen': greenNitrogen,
    };
  }

  Map<String, dynamic> _calculateOptimalProportions(
    Map<String, dynamic> brownData,
    Map<String, dynamic> greenData,
    double targetCN,
    double desiredFinalAmount,
  ) {
    final double brownCN = brownData['cn_ratio'] as double;
    final double greenCN = greenData['cn_ratio'] as double;
    
    final double brownC = brownData['carbon_content'] as double;
    final double brownN = brownData['nitrogen_content'] as double;
    final double greenC = greenData['carbon_content'] as double;
    final double greenN = greenData['nitrogen_content'] as double;
    final double ratio = (targetCN * greenN - greenC) / (brownC - targetCN * brownN);
    final double totalMaterialNeeded = desiredFinalAmount / 0.4; // Assumindo 40% de rendimento
    
    double brownNeeded, greenNeeded;
    
    if (ratio > 0) {
      brownNeeded = totalMaterialNeeded * ratio / (ratio + 1);
      greenNeeded = totalMaterialNeeded / (ratio + 1);
    } else {
      brownNeeded = totalMaterialNeeded * 0.75;
      greenNeeded = totalMaterialNeeded * 0.25;
    }
    final double resultingC = (brownNeeded * brownC + greenNeeded * greenC) / 100;
    final double resultingN = (brownNeeded * brownN + greenNeeded * greenN) / 100;
    final double resultingCN = resultingN > 0 ? resultingC / resultingN : 0;
    
    return {
      'brown_needed': brownNeeded,
      'green_needed': greenNeeded,
      'total_material': brownNeeded + greenNeeded,
      'resulting_cn': resultingCN,
      'final_yield': totalMaterialNeeded * 0.4,
    };
  }

  Map<String, dynamic> _estimateCompostingTime(
    String compostType,
    double cnRatio,
    double moisture,
    double temperature,
    String turningFrequency,
  ) {
    final Map<String, int> baseTime = {
      'Leira Tradicional': 120,
      'Compostagem Termofílica': 90,
      'Vermicompostagem': 60,
      'Compostagem Acelerada': 45,
      'Bokashi': 30,
    };

    int totalTime = baseTime[compostType] ?? 120;
    if (cnRatio > 35) {
      totalTime = (totalTime * 1.2).round(); // C/N alto demora mais
    } else if (cnRatio < 25) {
      totalTime = (totalTime * 1.1).round(); // C/N baixo pode ter problemas
    }
    if (moisture < 45 || moisture > 65) {
      totalTime = (totalTime * 1.15).round();
    }
    if (temperature < 15) {
      totalTime = (totalTime * 1.4).round();
    } else if (temperature > 30) {
      totalTime = (totalTime * 0.85).round();
    }
    final Map<String, double> turningFactors = {
      'Semanal': 0.8,
      'Quinzenal': 1.0,
      'Mensal': 1.3,
      'Apenas quando necessário': 1.5,
    };
    
    totalTime = (totalTime * (turningFactors[turningFrequency] ?? 1.0)).round();
    int thermophilicDays = (totalTime * 0.3).round(); // 30% em fase termofílica
    int mesophilicDays = (totalTime * 0.4).round(); // 40% em fase mesofílica
    int maturationDays = totalTime - thermophilicDays - mesophilicDays; // Resto em maturação
    
    return {
      'total_time_days': totalTime,
      'thermophilic_days': thermophilicDays,
      'mesophilic_days': mesophilicDays,
      'maturation_days': maturationDays,
      'decomposition_rate': math.max(0.3, 1.0 - (totalTime / 365.0)), // Taxa de decomposição
    };
  }

  Map<String, dynamic> _calculatePileDimensions(
    double totalMaterial,
    String pileSize,
    String compostType,
  ) {
    const double averageDensity = 400.0;
    final double initialVolume = totalMaterial / averageDensity;
    Map<String, double> dimensions;
    
    switch (pileSize) {
      case 'Pequena (1-2 m³)':
        dimensions = {'width': 1.5, 'height': 1.0, 'length': initialVolume / 1.5};
        break;
      case 'Média (3-5 m³)':
        dimensions = {'width': 2.0, 'height': 1.2, 'length': initialVolume / 2.4};
        break;
      case 'Grande (6-10 m³)':
        dimensions = {'width': 2.5, 'height': 1.5, 'length': initialVolume / 3.75};
        break;
      case 'Industrial (>10 m³)':
        dimensions = {'width': 3.0, 'height': 1.8, 'length': initialVolume / 5.4};
        break;
      default:
        dimensions = {'width': 2.0, 'height': 1.2, 'length': initialVolume / 2.4};
    }
    
    return {
      'total_volume': initialVolume,
      'width': dimensions['width'],
      'height': dimensions['height'],
      'length': dimensions['length'],
      'surface_area': dimensions['width']! * dimensions['length']!,
    };
  }

  List<Map<String, dynamic>> _generateManagementSchedule(
    int totalDays,
    String turningFrequency,
    String compostType,
  ) {
    final List<Map<String, dynamic>> schedule = [];
    final Map<String, int> turningDays = {
      'Semanal': 7,
      'Quinzenal': 15,
      'Mensal': 30,
      'Apenas quando necessário': 45,
    };
    
    final int interval = turningDays[turningFrequency] ?? 15;
    final int thermophilicEnd = (totalDays * 0.3).round();
    final int mesophilicEnd = (totalDays * 0.7).round();
    
    for (int day = 0; day <= totalDays; day += interval) {
      String phase;
      String activity;
      String monitoring;
      
      if (day <= thermophilicEnd) {
        phase = 'Termofílica';
        activity = 'Reviramento completo';
        monitoring = 'Temperatura (55-65°C), umidade (50-60%)';
      } else if (day <= mesophilicEnd) {
        phase = 'Mesofílica';
        activity = 'Reviramento moderado';
        monitoring = 'Temperatura (40-55°C), umidade (45-55%)';
      } else {
        phase = 'Maturação';
        activity = 'Reviramento leve ou aeração';
        monitoring = 'Estabilidade, cheiro, cor';
      }
      
      schedule.add({
        'dia': day,
        'fase': phase,
        'atividade': activity,
        'monitoramento': monitoring,
      });
    }
    
    return schedule;
  }

  Map<String, dynamic> _analyzeExpectedQuality(
    Map<String, dynamic> cnAnalysis,
    Map<String, dynamic> timeEstimate,
    double moisture,
    String compostType,
  ) {
    double qualityScore = 100.0;
    final List<String> qualityIssues = [];
    final double cnRatio = cnAnalysis['current_cn_ratio'] as double;
    if (cnRatio < 20 || cnRatio > 40) {
      qualityScore -= 20;
      qualityIssues.add('Relação C/N fora da faixa ideal');
    }
    if (moisture < 45 || moisture > 65) {
      qualityScore -= 15;
      qualityIssues.add('Umidade inadequada');
    }
    final int totalTime = timeEstimate['total_time_days'] as int;
    if (totalTime < 60) {
      qualityScore -= 10;
      qualityIssues.add('Tempo pode ser insuficiente para estabilização');
    }
    String classification;
    if (qualityScore >= 90) {
      classification = 'Excelente';
    } else if (qualityScore >= 70) {
      classification = 'Boa';
    } else if (qualityScore >= 50) {
      classification = 'Regular';
    } else {
      classification = 'Ruim';
    }
    
    return {
      'quality_score': qualityScore,
      'classification': classification,
      'issues': qualityIssues,
    };
  }

  Map<String, dynamic> _calculateFinalNutrients(
    double brownAmount,
    double greenAmount,
    Map<String, dynamic> brownData,
    Map<String, dynamic> greenData,
    double decompositionRate,
  ) {
    final double initialN = (brownAmount * (brownData['nitrogen_content'] as double) + 
                           greenAmount * (greenData['nitrogen_content'] as double)) / 100;
    final double initialP = (greenAmount * ((greenData['p_content'] as double?) ?? 0.5)) / 100;
    final double initialK = (greenAmount * ((greenData['k_content'] as double?) ?? 1.0)) / 100;
    final double massReduction = decompositionRate;
    final double finalMass = (brownAmount + greenAmount) * (1 - massReduction);
    
    return {
      'total_n': (initialN * 0.9 / finalMass) * 100, // 90% de retenção de N
      'total_p': (initialP * 0.95 / finalMass) * 100, // 95% de retenção de P
      'total_k': (initialK * 0.85 / finalMass) * 100, // 85% de retenção de K
      'organic_matter': 65.0, // Composto maduro típico
    };
  }

  Map<String, dynamic> _calculateCostAnalysis(
    Map<String, dynamic> proportions,
    String brownMaterial,
    String greenMaterial,
    Map<String, dynamic> timeEstimate,
  ) {
    final Map<String, double> materialCosts = {
      'Palha de Arroz': 0.15,
      'Serragem': 0.10,
      'Folhas Secas': 0.05,
      'Papel/Papelão': 0.20,
      'Bagaço de Cana': 0.12,
      'Casca de Café': 0.18,
      'Sabugo de Milho': 0.08,
      'Esterco Bovino': 0.25,
      'Esterco Suíno': 0.30,
      'Esterco Galinha': 0.40,
      'Restos de Cozinha': 0.00,
      'Grama Cortada': 0.00,
      'Folhas Verdes': 0.00,
      'Resíduos de Poda': 0.00,
    };
    
    final double brownCost = (proportions['brown_needed'] as double) * 
                           (materialCosts[brownMaterial] ?? 0.10);
    final double greenCost = (proportions['green_needed'] as double) * 
                           (materialCosts[greenMaterial] ?? 0.20);
    final int totalDays = timeEstimate['total_time_days'] as int;
    final double laborHours = totalDays * 0.5; // 30 min/dia em média
    final double laborCost = laborHours * 25.0; // R\$ 25/hora
    
    final double totalCost = brownCost + greenCost + laborCost;
    final double finalYield = proportions['final_yield'] as double;
    
    return {
      'material_cost': brownCost + greenCost,
      'labor_cost': laborCost,
      'total_cost': totalCost,
      'cost_per_kg': finalYield > 0 ? totalCost / finalYield : 0,
    };
  }

  List<String> _generateRecommendations(
    String compostType,
    Map<String, dynamic> cnAnalysis,
    double moisture,
    double temperature,
    Map<String, dynamic> proportions,
    Map<String, dynamic> qualityAnalysis,
  ) {
    final List<String> recommendations = [];
    final double cnRatio = cnAnalysis['current_cn_ratio'] as double;
    if (cnRatio > 35) {
      recommendations.add('Relação C/N alta: adicionar mais material verde (rico em N).');
    } else if (cnRatio < 25) {
      recommendations.add('Relação C/N baixa: adicionar mais material marrom (rico em C).');
    }
    if (moisture < 45) {
      recommendations.add('Umidade baixa: adicionar água durante o reviramento.');
    } else if (moisture > 65) {
      recommendations.add('Umidade alta: adicionar material seco e aumentar aeração.');
    }
    if (temperature < 15) {
      recommendations.add('Temperatura baixa: considerar cobertura da leira e local protegido.');
    } else if (temperature > 35) {
      recommendations.add('Temperatura alta: proteger leira do sol direto.');
    }
    switch (compostType) {
      case 'Vermicompostagem':
        recommendations.add('Vermicompostagem: manter temperatura abaixo de 35°C.');
        recommendations.add('Evitar materiais ácidos que prejudicam as minhocas.');
        break;
      case 'Compostagem Termofílica':
        recommendations.add('Termofílica: monitorar temperatura diariamente na fase ativa.');
        break;
      case 'Bokashi':
        recommendations.add('Bokashi: manter sistema anaeróbico durante fermentação.');
        break;
    }
    recommendations.add('Triturar materiais grandes para acelerar decomposição.');
    recommendations.add('Manter leira protegida de chuva excessiva.');
    recommendations.add('Revolver sempre que temperatura exceder 70°C.');
    recommendations.add('Composto pronto: cor escura, cheiro de terra, não esquenta.');
    final double qualityScore = qualityAnalysis['quality_score'] as double;
    if (qualityScore < 70) {
      recommendations.add('Atenção: condições podem afetar qualidade final.');
    }
    
    return recommendations;
  }
}
