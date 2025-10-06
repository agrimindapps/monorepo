import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Dosagem de Fertilizantes
/// Calcula dosagens precisas de fertilizantes líquidos e sólidos para aplicação foliar e fertirrigação
class FertilizerDosingCalculator extends CalculatorEntity {
  const FertilizerDosingCalculator()
      : super(
          id: 'fertilizer_dosing',
          name: 'Dosagem de Fertilizantes',
          description: 'Calcula dosagens precisas de fertilizantes para aplicação foliar, fertirrigação e preparação de soluções nutritivas',
          category: CalculatorCategory.nutrition,
          parameters: const [
            CalculatorParameter(
              id: 'application_type',
              name: 'Tipo de Aplicação',
              description: 'Método de aplicação do fertilizante',
              type: ParameterType.selection,
              options: ['Aplicação Foliar', 'Fertirrigação', 'Solução Nutritiva', 'Pulverização Localizada'],
              defaultValue: 'Aplicação Foliar',
            ),
            CalculatorParameter(
              id: 'fertilizer_type',
              name: 'Tipo de Fertilizante',
              description: 'Tipo do fertilizante a ser utilizado',
              type: ParameterType.selection,
              options: [
                'Ureia (45% N)', 
                'MAP (11-52-0)', 
                'KCl (60% K2O)', 
                'KNO3 (13-0-44)', 
                'Sulfato de Amônio (21% N)',
                'Superfosfato Simples (18% P2O5)',
                'Ácido Fosfórico (54% P2O5)',
                'Sulfato de Potássio (50% K2O)',
                'Cloreto de Cálcio (36% Ca)',
                'Sulfato de Magnésio (16% Mg)',
                'Fertilizante Líquido Personalizado'
              ],
              defaultValue: 'Ureia (45% N)',
            ),
            CalculatorParameter(
              id: 'target_concentration',
              name: 'Concentração Desejada',
              description: 'Concentração desejada do nutriente na solução (ppm ou %)',
              type: ParameterType.decimal,
              unit: ParameterUnit.ppm,
              minValue: 50.0,
              maxValue: 5000.0,
              defaultValue: 1000.0,
              validationMessage: 'Concentração deve estar entre 50 e 5000 ppm',
            ),
            CalculatorParameter(
              id: 'solution_volume',
              name: 'Volume da Solução',
              description: 'Volume total da solução a ser preparada (litros)',
              type: ParameterType.decimal,
              unit: ParameterUnit.litro,
              minValue: 1.0,
              maxValue: 10000.0,
              defaultValue: 100.0,
              validationMessage: 'Volume deve estar entre 1 e 10.000 litros',
            ),
            CalculatorParameter(
              id: 'area_to_cover',
              name: 'Área a Cobrir',
              description: 'Área total a ser tratada (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.01,
              maxValue: 1000.0,
              defaultValue: 1.0,
              validationMessage: 'Área deve estar entre 0.01 e 1000 ha',
            ),
            CalculatorParameter(
              id: 'application_rate',
              name: 'Taxa de Aplicação',
              description: 'Volume de solução por hectare (L/ha)',
              type: ParameterType.decimal,
              unit: ParameterUnit.litroha,
              minValue: 50.0,
              maxValue: 2000.0,
              defaultValue: 200.0,
              validationMessage: 'Taxa deve estar entre 50 e 2000 L/ha',
            ),
            CalculatorParameter(
              id: 'tank_mixing',
              name: 'Mistura de Tanque',
              description: 'Adicionar outros produtos na mistura?',
              type: ParameterType.boolean,
              defaultValue: false,
            ),
            CalculatorParameter(
              id: 'water_quality',
              name: 'Qualidade da Água',
              description: 'Condutividade elétrica da água (dS/m)',
              type: ParameterType.decimal,
              unit: ParameterUnit.dsm,
              minValue: 0.1,
              maxValue: 3.0,
              defaultValue: 0.5,
              validationMessage: 'CE deve estar entre 0.1 e 3.0 dS/m',
            ),
            CalculatorParameter(
              id: 'water_ph',
              name: 'pH da Água',
              description: 'pH da água de irrigação/pulverização',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 4.0,
              maxValue: 9.0,
              defaultValue: 7.0,
              validationMessage: 'pH deve estar entre 4.0 e 9.0',
            ),
            CalculatorParameter(
              id: 'fertilizer_purity',
              name: 'Pureza do Fertilizante',
              description: 'Pureza/concentração do fertilizante (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 80.0,
              maxValue: 100.0,
              defaultValue: 98.0,
              validationMessage: 'Pureza deve estar entre 80% e 100%',
            ),
          ],
          formula: 'Dosagem = (Concentração × Volume × 100) / (Teor do Nutriente × Pureza)',
          references: const [
            'Sonneveld & Voogt (2009) - Plant Nutrition in Future Greenhouse Production',
            'Resh (2013) - Hydroponic Food Production',
            'Casarini et al. (2018) - Fertirrigação em horticultura',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String applicationType = inputs['application_type'].toString();
      final String fertilizerType = inputs['fertilizer_type'].toString();
      final double targetConcentration = double.parse(inputs['target_concentration'].toString());
      final double solutionVolume = double.parse(inputs['solution_volume'].toString());
      final double areaToCover = double.parse(inputs['area_to_cover'].toString());
      final double applicationRate = double.parse(inputs['application_rate'].toString());
      final bool tankMixing = inputs['tank_mixing'] as bool;
      final double waterQuality = double.parse(inputs['water_quality'].toString());
      final double waterPH = double.parse(inputs['water_ph'].toString());
      final double fertilizerPurity = double.parse(inputs['fertilizer_purity'].toString());
      final Map<String, dynamic> fertilizerData = _getFertilizerData(fertilizerType);
      final double nutrientContent = fertilizerData['nutrient_content'] as double;
      final String primaryNutrient = fertilizerData['primary_nutrient'] as String;
      final double solubility = fertilizerData['solubility'] as double;
      final double maxConcentration = solubility * 0.8; // 80% da solubilidade máxima
      if (targetConcentration > maxConcentration) {
        return CalculationError(
          calculatorId: id,
          errorMessage: 'Concentração muito alta. Máximo recomendado: ${maxConcentration.toInt()} ppm',
          inputs: inputs,
        );
      }
      final double basicDosage = _calculateBasicDosage(
        targetConcentration, solutionVolume, nutrientContent, fertilizerPurity);
      final Map<String, dynamic> adjustments = _calculateAdjustments(
        applicationType, basicDosage, waterQuality, waterPH, tankMixing);

      final double adjustedDosage = adjustments['adjusted_dosage'] as double;
      final Map<String, dynamic> calculations = _calculateVolumesAndConcentrations(
        adjustedDosage, solutionVolume, areaToCover, applicationRate, targetConcentration);
      final Map<String, dynamic> compatibility = _analyzeCompatibility(
        fertilizerType, waterPH, waterQuality, tankMixing);
      final List<Map<String, dynamic>> applicationSchedule = _generateApplicationSchedule(
        applicationType, targetConcentration, primaryNutrient);
      final Map<String, dynamic> costAnalysis = _calculateCostAnalysis(
        adjustedDosage, solutionVolume, areaToCover, fertilizerType);
      final List<String> recommendations = _generateRecommendations(
        applicationType, fertilizerType, targetConcentration, waterQuality, waterPH);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Dosagem do Fertilizante',
            value: CalculatorMath.roundTo(adjustedDosage, 2),
            unit: calculations['dosage_unit'] as String,
            description: 'Quantidade a adicionar na solução',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Concentração Final',
            value: CalculatorMath.roundTo(calculations['final_concentration'] as double, 0),
            unit: 'ppm $primaryNutrient',
            description: 'Concentração final do nutriente',
          ),
          CalculationResultValue(
            label: 'Condutividade Estimada',
            value: CalculatorMath.roundTo(calculations['estimated_ec'] as double, 2),
            unit: 'dS/m',
            description: 'CE estimada da solução final',
          ),
          CalculationResultValue(
            label: 'Volume Total Necessário',
            value: CalculatorMath.roundTo(calculations['total_volume_needed'] as double, 0),
            unit: 'litros',
            description: 'Volume total para a área',
          ),
          CalculationResultValue(
            label: 'Fertilizante Total',
            value: CalculatorMath.roundTo(calculations['total_fertilizer'] as double, 2),
            unit: 'kg',
            description: 'Quantidade total de fertilizante',
          ),
          CalculationResultValue(
            label: 'Rendimento da Solução',
            value: CalculatorMath.roundTo(calculations['solution_yield'] as double, 2),
            unit: 'ha',
            description: 'Área que o volume preparado cobrirá',
          ),
          CalculationResultValue(
            label: 'pH Estimado Final',
            value: CalculatorMath.roundTo(compatibility['estimated_ph'] as double, 1),
            unit: '',
            description: 'pH estimado após adição do fertilizante',
          ),
          CalculationResultValue(
            label: 'Fator de Ajuste',
            value: CalculatorMath.roundTo(adjustments['adjustment_factor'] as double, 3),
            unit: '',
            description: 'Fator aplicado para condições específicas',
          ),
          CalculationResultValue(
            label: 'Custo por Hectare',
            value: CalculatorMath.roundTo(costAnalysis['cost_per_ha'] as double, 2),
            unit: 'R\$/ha',
            description: 'Custo do fertilizante por hectare',
          ),
          CalculationResultValue(
            label: 'Custo Total',
            value: CalculatorMath.roundTo(costAnalysis['total_cost'] as double, 2),
            unit: 'R\$',
            description: 'Custo total para a área',
          ),
        ],
        recommendations: recommendations,
        tableData: [
          ...applicationSchedule,
          ...(compatibility['warnings'] as List<Map<String, dynamic>>),
        ],
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _getFertilizerData(String fertilizer) {
    final Map<String, Map<String, dynamic>> fertilizerDatabase = {
      'Ureia (45% N)': {
        'nutrient_content': 45.0,
        'primary_nutrient': 'N',
        'solubility': 1000000.0, // Muito solúvel
        'molecular_weight': 60.06,
        'ph_effect': -0.8, // Acidificante
      },
      'MAP (11-52-0)': {
        'nutrient_content': 52.0, // P2O5
        'primary_nutrient': 'P',
        'solubility': 365000.0, // 365 g/L
        'molecular_weight': 115.03,
        'ph_effect': -1.2,
      },
      'KCl (60% K2O)': {
        'nutrient_content': 60.0,
        'primary_nutrient': 'K',
        'solubility': 350000.0,
        'molecular_weight': 74.55,
        'ph_effect': 0.0, // Neutro
      },
      'KNO3 (13-0-44)': {
        'nutrient_content': 44.0, // K2O
        'primary_nutrient': 'K',
        'solubility': 320000.0,
        'molecular_weight': 101.1,
        'ph_effect': 0.2, // Ligeiramente alcalinizante
      },
      'Sulfato de Amônio (21% N)': {
        'nutrient_content': 21.0,
        'primary_nutrient': 'N',
        'solubility': 750000.0,
        'molecular_weight': 132.14,
        'ph_effect': -1.5, // Muito acidificante
      },
      'Superfosfato Simples (18% P2O5)': {
        'nutrient_content': 18.0,
        'primary_nutrient': 'P',
        'solubility': 20000.0, // Baixa solubilidade
        'molecular_weight': 234.05,
        'ph_effect': -0.3,
      },
      'Ácido Fosfórico (54% P2O5)': {
        'nutrient_content': 54.0,
        'primary_nutrient': 'P',
        'solubility': 1000000.0, // Líquido
        'molecular_weight': 98.0,
        'ph_effect': -2.5, // Muito acidificante
      },
      'Sulfato de Potássio (50% K2O)': {
        'nutrient_content': 50.0,
        'primary_nutrient': 'K',
        'solubility': 120000.0,
        'molecular_weight': 174.26,
        'ph_effect': 0.0,
      },
      'Cloreto de Cálcio (36% Ca)': {
        'nutrient_content': 36.0,
        'primary_nutrient': 'Ca',
        'solubility': 745000.0,
        'molecular_weight': 110.98,
        'ph_effect': 0.3,
      },
      'Sulfato de Magnésio (16% Mg)': {
        'nutrient_content': 16.0,
        'primary_nutrient': 'Mg',
        'solubility': 710000.0,
        'molecular_weight': 246.47,
        'ph_effect': 0.1,
      },
    };

    return fertilizerDatabase[fertilizer] ?? fertilizerDatabase['Ureia (45% N)']!;
  }

  double _calculateBasicDosage(
    double concentration,
    double volume,
    double nutrientContent,
    double purity,
  ) {
    return (concentration * volume) / ((nutrientContent / 100) * (purity / 100));
  }

  Map<String, dynamic> _calculateAdjustments(
    String applicationType,
    double basicDosage,
    double waterQuality,
    double waterPH,
    bool tankMixing,
  ) {
    double adjustmentFactor = 1.0;
    switch (applicationType) {
      case 'Aplicação Foliar':
        adjustmentFactor *= 0.8; // Menor concentração para foliar
        break;
      case 'Fertirrigação':
        adjustmentFactor *= 1.0; // Concentração padrão
        break;
      case 'Solução Nutritiva':
        adjustmentFactor *= 1.1; // Concentração ligeiramente maior
        break;
      case 'Pulverização Localizada':
        adjustmentFactor *= 1.2; // Concentração maior para localizada
        break;
    }
    if (waterQuality > 1.5) {
      adjustmentFactor *= 0.9; // Reduzir em águas salinas
    } else if (waterQuality < 0.3) {
      adjustmentFactor *= 1.05; // Aumentar em águas muito puras
    }
    if (waterPH > 8.0) {
      adjustmentFactor *= 0.95; // Reduzir em águas alcalinas
    } else if (waterPH < 6.0) {
      adjustmentFactor *= 1.05; // Aumentar em águas ácidas
    }
    if (tankMixing) {
      adjustmentFactor *= 0.9; // Reduzir para evitar incompatibilidades
    }

    return {
      'adjusted_dosage': basicDosage * adjustmentFactor,
      'adjustment_factor': adjustmentFactor,
    };
  }

  Map<String, dynamic> _calculateVolumesAndConcentrations(
    double dosage,
    double solutionVolume,
    double area,
    double applicationRate,
    double targetConcentration,
  ) {
    final double totalVolumeNeeded = area * applicationRate;
    final double totalFertilizer = (dosage / solutionVolume) * totalVolumeNeeded / 1000; // kg
    final double solutionYield = solutionVolume / applicationRate;
    final double finalConcentration = targetConcentration;
    final double estimatedEC = (dosage / solutionVolume) * 0.002; // Conversão aproximada
    String dosageUnit = dosage < 1000 ? 'g' : 'kg';
    if (dosageUnit == 'kg') {
      dosage = dosage / 1000;
    }

    return {
      'total_volume_needed': totalVolumeNeeded,
      'total_fertilizer': totalFertilizer,
      'solution_yield': solutionYield,
      'final_concentration': finalConcentration,
      'estimated_ec': estimatedEC,
      'dosage_unit': dosageUnit,
    };
  }

  Map<String, dynamic> _analyzeCompatibility(
    String fertilizer,
    double waterPH,
    double waterQuality,
    bool tankMixing,
  ) {
    final List<Map<String, dynamic>> warnings = [];
    final fertilizerData = _getFertilizerData(fertilizer);
    final double phEffect = fertilizerData['ph_effect'] as double;
    final double estimatedPH = waterPH + phEffect;
    if (estimatedPH < 5.0) {
      warnings.add({
        'tipo': 'pH Baixo',
        'severidade': 'Alta',
        'mensagem': 'pH final muito baixo (${estimatedPH.toStringAsFixed(1)}). Risco de precipitação.',
        'recomendacao': 'Adicionar tampão alcalino ou reduzir dosagem'
      });
    }
    
    if (estimatedPH > 8.5) {
      warnings.add({
        'tipo': 'pH Alto',
        'severidade': 'Média',
        'mensagem': 'pH final alto (${estimatedPH.toStringAsFixed(1)}). Possível precipitação de micronutrientes.',
        'recomendacao': 'Adicionar ácido ou acidificante'
      });
    }

    if (waterQuality > 2.0) {
      warnings.add({
        'tipo': 'Água Salina',
        'severidade': 'Média',
        'mensagem': 'Água com alta condutividade ($waterQuality dS/m).',
        'recomendacao': 'Monitorar CE final e ajustar concentrações'
      });
    }

    if (tankMixing && fertilizer.contains('Fosfórico')) {
      warnings.add({
        'tipo': 'Incompatibilidade',
        'severidade': 'Alta',
        'mensagem': 'Ácido fosfórico pode precipitar com Ca e Mg.',
        'recomendacao': 'Aplicar separadamente ou verificar ordem de mistura'
      });
    }

    return {
      'estimated_ph': estimatedPH,
      'warnings': warnings,
      'compatibility_score': warnings.isEmpty ? 100 : 100 - (warnings.length * 20),
    };
  }

  List<Map<String, dynamic>> _generateApplicationSchedule(
    String applicationType,
    double concentration,
    String nutrient,
  ) {
    final List<Map<String, dynamic>> schedule = [];

    switch (applicationType) {
      case 'Aplicação Foliar':
        schedule.addAll([
          {
            'periodo': 'Manhã (6-9h)',
            'concentracao': concentration,
            'observacao': 'Aplicar com orvalho evaporado, baixa radiação',
          },
          {
            'periodo': 'Final de tarde (16-18h)',
            'concentracao': concentration,
            'observacao': 'Alternativa - menor evaporação',
          },
        ]);
        break;
      case 'Fertirrigação':
        schedule.addAll([
          {
            'periodo': 'Início da irrigação',
            'concentracao': 0,
            'observacao': 'Água pura por 10-15 minutos',
          },
          {
            'periodo': 'Meio da irrigação',
            'concentracao': concentration,
            'observacao': 'Injeção do fertilizante - 70% do tempo',
          },
          {
            'periodo': 'Final da irrigação',
            'concentracao': 0,
            'observacao': 'Água pura para limpeza do sistema',
          },
        ]);
        break;
      case 'Solução Nutritiva':
        schedule.add({
          'periodo': 'Aplicação contínua',
          'concentracao': concentration,
          'observacao': 'Monitorar CE e pH diariamente',
        });
        break;
    }

    return schedule;
  }

  Map<String, dynamic> _calculateCostAnalysis(
    double dosage,
    double volume,
    double area,
    String fertilizer,
  ) {
    final Map<String, double> prices = {
      'Ureia (45% N)': 3.50,
      'MAP (11-52-0)': 4.20,
      'KCl (60% K2O)': 3.80,
      'KNO3 (13-0-44)': 6.50,
      'Sulfato de Amônio (21% N)': 2.90,
      'Superfosfato Simples (18% P2O5)': 2.10,
      'Ácido Fosfórico (54% P2O5)': 5.80,
      'Sulfato de Potássio (50% K2O)': 7.20,
      'Cloreto de Cálcio (36% Ca)': 4.50,
      'Sulfato de Magnésio (16% Mg)': 3.20,
    };

    final double pricePerKg = prices[fertilizer] ?? 4.00;
    final double totalFertilizerKg = (dosage / volume) * area * 200 / 1000; // Assumindo 200L/ha
    final double totalCost = totalFertilizerKg * pricePerKg;
    final double costPerHa = totalCost / area;

    return {
      'total_cost': totalCost,
      'cost_per_ha': costPerHa,
      'fertilizer_amount_kg': totalFertilizerKg,
      'price_per_kg': pricePerKg,
    };
  }

  List<String> _generateRecommendations(
    String applicationType,
    String fertilizer,
    double concentration,
    double waterQuality,
    double waterPH,
  ) {
    final List<String> recommendations = [];
    switch (applicationType) {
      case 'Aplicação Foliar':
        recommendations.add('Aplicar nas horas mais frescas do dia para evitar fitotoxidez.');
        recommendations.add('Adicionar adjuvante para melhor absorção foliar.');
        break;
      case 'Fertirrigação':
        recommendations.add('Manter sistema limpo e calibrado para dosagem uniforme.');
        recommendations.add('Monitorar entupimento de emissores após aplicação.');
        break;
      case 'Solução Nutritiva':
        recommendations.add('Renovar solução a cada 7-14 dias dependendo da cultura.');
        recommendations.add('Oxigenar solução para evitar problemas radiculares.');
        break;
    }
    if (concentration > 2000) {
      recommendations.add('Concentração alta - fazer teste em pequena área primeiro.');
    }
    if (waterQuality > 1.5) {
      recommendations.add('Água salina - reduzir concentrações e monitorar plantas.');
    }

    if (waterPH < 6.0 || waterPH > 8.0) {
      recommendations.add('pH da água fora da faixa ideal - considerar correção.');
    }
    recommendations.add('Usar equipamentos de proteção individual durante preparo.');
    recommendations.add('Preparar apenas a quantidade necessária para o dia.');
    recommendations.add('Armazenar fertilizantes em local seco e arejado.');
    recommendations.add('Não misturar diferentes fertilizantes sem teste prévio.');

    return recommendations;
  }
}