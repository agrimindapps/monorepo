import 'dart:math' as math;
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_parameter.dart';
import '../../entities/calculation_result.dart';
import '../../entities/calculator_engine.dart';

/// Calculadora de NPK
/// Calcula a necessidade de fertilizantes NPK baseado na análise do solo e exigência da cultura
class NPKCalculator extends CalculatorEntity {
  NPKCalculator()
      : super(
          id: 'npk_calculator',
          name: 'Calculadora NPK',
          description: 'Calcula a necessidade de fertilizantes NPK baseado na análise de solo e exigência da cultura',
          category: CalculatorCategory.nutrition,
          parameters: const [
            CalculatorParameter(
              id: 'crop_type',
              name: 'Tipo da Cultura',
              description: 'Cultura a ser cultivada',
              type: ParameterType.selection,
              options: ['Milho', 'Soja', 'Trigo', 'Arroz', 'Feijão', 'Café', 'Algodão', 'Cana-de-açúcar', 'Tomate', 'Batata'],
              defaultValue: 'Milho',
            ),
            CalculatorParameter(
              id: 'expected_yield',
              name: 'Produtividade Esperada',
              description: 'Produtividade esperada da cultura (t/ha)',
              type: ParameterType.decimal,
              unit: ParameterUnit.tonelada,
              minValue: 0.5,
              maxValue: 50.0,
              defaultValue: 10.0,
              validationMessage: 'Produtividade deve estar entre 0.5 e 50 t/ha',
            ),
            CalculatorParameter(
              id: 'soil_n',
              name: 'Nitrogênio no Solo',
              description: 'Teor de nitrogênio disponível no solo (mg/dm³)',
              type: ParameterType.decimal,
              unit: ParameterUnit.mgdm3,
              minValue: 0.0,
              maxValue: 200.0,
              defaultValue: 20.0,
              validationMessage: 'N no solo deve estar entre 0 e 200 mg/dm³',
            ),
            CalculatorParameter(
              id: 'soil_p',
              name: 'Fósforo no Solo',
              description: 'Teor de fósforo disponível no solo (mg/dm³)',
              type: ParameterType.decimal,
              unit: ParameterUnit.mgdm3,
              minValue: 0.0,
              maxValue: 100.0,
              defaultValue: 10.0,
              validationMessage: 'P no solo deve estar entre 0 e 100 mg/dm³',
            ),
            CalculatorParameter(
              id: 'soil_k',
              name: 'Potássio no Solo',
              description: 'Teor de potássio disponível no solo (mg/dm³)',
              type: ParameterType.decimal,
              unit: ParameterUnit.mgdm3,
              minValue: 0.0,
              maxValue: 500.0,
              defaultValue: 80.0,
              validationMessage: 'K no solo deve estar entre 0 e 500 mg/dm³',
            ),
            CalculatorParameter(
              id: 'area',
              name: 'Área de Cultivo',
              description: 'Área total a ser cultivada (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.01,
              maxValue: 10000.0,
              defaultValue: 1.0,
              validationMessage: 'Área deve ser maior que 0.01 ha',
            ),
            CalculatorParameter(
              id: 'soil_texture',
              name: 'Textura do Solo',
              description: 'Classe textural do solo',
              type: ParameterType.selection,
              options: ['Arenoso', 'Franco-arenoso', 'Franco', 'Franco-argiloso', 'Argiloso'],
              defaultValue: 'Franco',
            ),
            CalculatorParameter(
              id: 'organic_matter',
              name: 'Matéria Orgânica',
              description: 'Teor de matéria orgânica do solo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.5,
              maxValue: 15.0,
              defaultValue: 3.0,
              validationMessage: 'MO deve estar entre 0.5% e 15%',
            ),
            CalculatorParameter(
              id: 'previous_crop',
              name: 'Cultura Anterior',
              description: 'Cultura cultivada anteriormente na área',
              type: ParameterType.selection,
              options: ['Nenhuma', 'Leguminosa', 'Gramínea', 'Pousio', 'Adubação Verde'],
              defaultValue: 'Nenhuma',
            ),
          ],
          formula: 'Necessidade = (Exigência da Cultura - Fornecimento do Solo) × Fator de Eficiência',
          references: const [
            'Raij et al. (1997) - Recomendações de adubação para o Estado de São Paulo',
            'CQFS-RS/SC (2016) - Manual de adubação e calagem',
            'Cantarella et al. (2007) - Adubação nitrogenada em sistemas intensivos',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String cropType = inputs['crop_type'].toString();
      final double expectedYield = double.parse(inputs['expected_yield'].toString());
      final double soilN = double.parse(inputs['soil_n'].toString());
      final double soilP = double.parse(inputs['soil_p'].toString());
      final double soilK = double.parse(inputs['soil_k'].toString());
      final double area = double.parse(inputs['area'].toString());
      final String soilTexture = inputs['soil_texture'].toString();
      final double organicMatter = double.parse(inputs['organic_matter'].toString());
      final String previousCrop = inputs['previous_crop'].toString();

      // Obter exigências nutricionais da cultura
      final Map<String, dynamic> cropRequirements = _getCropRequirements(cropType, expectedYield);
      final double nRequirement = cropRequirements['n'] as double;
      final double pRequirement = cropRequirements['p'] as double;
      final double kRequirement = cropRequirements['k'] as double;

      // Calcular fornecimento do solo
      final Map<String, double> soilSupply = _calculateSoilSupply(
        soilN, soilP, soilK, soilTexture, organicMatter, previousCrop);

      // Calcular fatores de eficiência
      final Map<String, double> efficiencyFactors = _getEfficiencyFactors(soilTexture, organicMatter);

      // Calcular necessidades líquidas
      double nNeed = math.max(0, (nRequirement - soilSupply['n']!) / efficiencyFactors['n']!);
      double pNeed = math.max(0, (pRequirement - soilSupply['p']!) / efficiencyFactors['p']!);
      double kNeed = math.max(0, (kRequirement - soilSupply['k']!) / efficiencyFactors['k']!);

      // Calcular para a área total
      final double totalN = nNeed * area;
      final double totalP = pNeed * area;
      final double totalK = kNeed * area;

      // Recomendações de fertilizantes
      final Map<String, dynamic> fertilizerRecommendations = _calculateFertilizerRecommendations(
        nNeed, pNeed, kNeed, soilTexture);

      // Cronograma de aplicação
      final List<Map<String, dynamic>> applicationSchedule = _generateApplicationSchedule(
        cropType, nNeed, pNeed, kNeed);

      // Custo estimado
      final double estimatedCost = _calculateCost(totalN, totalP, totalK);

      // Recomendações agronômicas
      final List<String> recommendations = _generateRecommendations(
        cropType, nNeed, pNeed, kNeed, soilTexture, organicMatter);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Nitrogênio (N)',
            value: CalculatorMath.roundTo(nNeed, 1),
            unit: 'kg/ha',
            description: 'Necessidade de nitrogênio por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Fósforo (P₂O₅)',
            value: CalculatorMath.roundTo(pNeed, 1),
            unit: 'kg/ha',
            description: 'Necessidade de fósforo por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Potássio (K₂O)',
            value: CalculatorMath.roundTo(kNeed, 1),
            unit: 'kg/ha',
            description: 'Necessidade de potássio por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Total N para Área',
            value: CalculatorMath.roundTo(totalN, 0),
            unit: 'kg',
            description: 'Nitrogênio total para ${area} ha',
          ),
          CalculationResultValue(
            label: 'Total P₂O₅ para Área',
            value: CalculatorMath.roundTo(totalP, 0),
            unit: 'kg',
            description: 'Fósforo total para ${area} ha',
          ),
          CalculationResultValue(
            label: 'Total K₂O para Área',
            value: CalculatorMath.roundTo(totalK, 0),
            unit: 'kg',
            description: 'Potássio total para ${area} ha',
          ),
          CalculationResultValue(
            label: 'Fornecimento Solo N',
            value: CalculatorMath.roundTo(soilSupply['n']!, 1),
            unit: 'kg/ha',
            description: 'Nitrogênio fornecido pelo solo',
          ),
          CalculationResultValue(
            label: 'Fornecimento Solo P',
            value: CalculatorMath.roundTo(soilSupply['p']!, 1),
            unit: 'kg/ha',
            description: 'Fósforo fornecido pelo solo',
          ),
          CalculationResultValue(
            label: 'Fornecimento Solo K',
            value: CalculatorMath.roundTo(soilSupply['k']!, 1),
            unit: 'kg/ha',
            description: 'Potássio fornecido pelo solo',
          ),
          CalculationResultValue(
            label: 'Custo Estimado',
            value: CalculatorMath.roundTo(estimatedCost, 0),
            unit: 'R\$',
            description: 'Custo estimado dos fertilizantes',
          ),
        ],
        recommendations: recommendations,
        tableData: [
          ...applicationSchedule,
          ...fertilizerRecommendations['products'] as List<Map<String, dynamic>>,
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

  Map<String, dynamic> _getCropRequirements(String crop, double yield) {
    // Exigências nutricionais por tonelada de produção (kg/t)
    final Map<String, Map<String, double>> cropData = {
      'Milho': {'n': 25.0, 'p': 8.0, 'k': 18.0},
      'Soja': {'n': 80.0, 'p': 15.0, 'k': 37.0}, // N da FBN
      'Trigo': {'n': 30.0, 'p': 12.0, 'k': 25.0},
      'Arroz': {'n': 22.0, 'p': 10.0, 'k': 30.0},
      'Feijão': {'n': 35.0, 'p': 8.0, 'k': 25.0},
      'Café': {'n': 45.0, 'p': 7.0, 'k': 40.0},
      'Algodão': {'n': 60.0, 'p': 25.0, 'k': 45.0},
      'Cana-de-açúcar': {'n': 1.8, 'p': 0.8, 'k': 2.5}, // por tonelada
      'Tomate': {'n': 3.0, 'p': 1.2, 'k': 4.5},
      'Batata': {'n': 4.5, 'p': 1.8, 'k': 7.0},
    };

    final requirements = cropData[crop] ?? cropData['Milho']!;
    
    return {
      'n': requirements['n']! * yield,
      'p': requirements['p']! * yield,
      'k': requirements['k']! * yield,
    };
  }

  Map<String, double> _calculateSoilSupply(
    double soilN,
    double soilP,
    double soilK,
    String texture,
    double organicMatter,
    String previousCrop,
  ) {
    // Fatores de conversão mg/dm³ para kg/ha (considerando 20 cm de profundidade)
    const double conversionFactor = 2.0;

    // Fornecimento base do solo
    double nSupply = soilN * conversionFactor;
    double pSupply = soilP * conversionFactor * 2.29; // Conversão P para P₂O₅
    double kSupply = soilK * conversionFactor * 1.20; // Conversão K para K₂O

    // Ajuste por matéria orgânica (mineralização de N)
    final double omBonus = (organicMatter - 2.0) * 10.0; // kg N/ha por % de MO acima de 2%
    nSupply += math.max(0, omBonus);

    // Ajuste por cultura anterior
    switch (previousCrop) {
      case 'Leguminosa':
        nSupply += 40.0; // Contribuição da FBN residual
        break;
      case 'Adubação Verde':
        nSupply += 30.0;
        break;
      case 'Pousio':
        nSupply += 15.0; // Mineralização durante pousio
        break;
    }

    // Ajuste por textura (capacidade de retenção)
    final Map<String, double> textureFactors = {
      'Arenoso': 0.7,
      'Franco-arenoso': 0.8,
      'Franco': 1.0,
      'Franco-argiloso': 1.1,
      'Argiloso': 1.2,
    };

    final double textureFactor = textureFactors[texture] ?? 1.0;
    pSupply *= textureFactor;
    kSupply *= textureFactor;

    return {
      'n': nSupply,
      'p': pSupply,
      'k': kSupply,
    };
  }

  Map<String, double> _getEfficiencyFactors(String texture, double organicMatter) {
    // Eficiência de aproveitamento dos fertilizantes
    final Map<String, Map<String, double>> efficiencyByTexture = {
      'Arenoso': {'n': 0.6, 'p': 0.15, 'k': 0.8},
      'Franco-arenoso': {'n': 0.7, 'p': 0.20, 'k': 0.85},
      'Franco': {'n': 0.8, 'p': 0.25, 'k': 0.9},
      'Franco-argiloso': {'n': 0.75, 'p': 0.30, 'k': 0.85},
      'Argiloso': {'n': 0.7, 'p': 0.20, 'k': 0.8},
    };

    final efficiency = efficiencyByTexture[texture] ?? efficiencyByTexture['Franco']!;
    
    // Ajuste por matéria orgânica
    final double omFactor = 1.0 + (organicMatter - 3.0) * 0.05;
    
    return {
      'n': efficiency['n']! * omFactor,
      'p': efficiency['p']!,
      'k': efficiency['k']!,
    };
  }

  Map<String, dynamic> _calculateFertilizerRecommendations(
    double nNeed,
    double pNeed,
    double kNeed,
    String soilTexture,
  ) {
    final List<Map<String, dynamic>> products = [];

    // Fonte de Nitrogênio
    if (nNeed > 0) {
      final double ureaQuantity = nNeed / 0.45; // Ureia 45% N
      products.add({
        'produto': 'Ureia',
        'quantidade': CalculatorMath.roundTo(ureaQuantity, 1),
        'unidade': 'kg/ha',
        'nutriente': 'N',
        'teor': '45%',
        'observacao': 'Aplicação parcelada recomendada'
      });
    }

    // Fonte de Fósforo
    if (pNeed > 0) {
      final double mapQuantity = pNeed / 0.52; // MAP 52% P₂O₅
      products.add({
        'produto': 'MAP (Fosfato Monoamônico)',
        'quantidade': CalculatorMath.roundTo(mapQuantity, 1),
        'unidade': 'kg/ha',
        'nutriente': 'P₂O₅',
        'teor': '52%',
        'observacao': 'Aplicação no plantio'
      });
    }

    // Fonte de Potássio
    if (kNeed > 0) {
      final double kclQuantity = kNeed / 0.60; // KCl 60% K₂O
      products.add({
        'produto': 'Cloreto de Potássio',
        'quantidade': CalculatorMath.roundTo(kclQuantity, 1),
        'unidade': 'kg/ha',
        'nutriente': 'K₂O',
        'teor': '60%',
        'observacao': 'Aplicação parcelada em solos arenosos'
      });
    }

    // Formulação NPK alternativa
    if (nNeed > 0 && pNeed > 0 && kNeed > 0) {
      final double ratio1 = nNeed / math.min(nNeed, math.min(pNeed, kNeed));
      final double ratio2 = pNeed / math.min(nNeed, math.min(pNeed, kNeed));
      final double ratio3 = kNeed / math.min(nNeed, math.min(pNeed, kNeed));
      
      products.add({
        'produto': 'Formulação NPK Sugerida',
        'quantidade': '${ratio1.round()}-${ratio2.round()}-${ratio3.round()}',
        'unidade': 'formulação',
        'nutriente': 'NPK',
        'teor': 'variável',
        'observacao': 'Buscar formulação comercial próxima'
      });
    }

    return {
      'products': products,
      'totalProducts': products.length,
    };
  }

  List<Map<String, dynamic>> _generateApplicationSchedule(
    String cropType,
    double nNeed,
    double pNeed,
    double kNeed,
  ) {
    final List<Map<String, dynamic>> schedule = [];

    // Cronograma baseado na cultura
    switch (cropType) {
      case 'Milho':
        schedule.addAll([
          {
            'periodo': 'Plantio',
            'n': CalculatorMath.roundTo(nNeed * 0.3, 1),
            'p': CalculatorMath.roundTo(pNeed * 1.0, 1),
            'k': CalculatorMath.roundTo(kNeed * 0.5, 1),
            'observacao': '30% N, 100% P, 50% K'
          },
          {
            'periodo': 'V6 (6 folhas)',
            'n': CalculatorMath.roundTo(nNeed * 0.7, 1),
            'p': 0.0,
            'k': CalculatorMath.roundTo(kNeed * 0.5, 1),
            'observacao': '70% N restante, 50% K restante'
          },
        ]);
        break;
      case 'Soja':
        schedule.add({
          'periodo': 'Plantio',
          'n': CalculatorMath.roundTo(nNeed * 1.0, 1),
          'p': CalculatorMath.roundTo(pNeed * 1.0, 1),
          'k': CalculatorMath.roundTo(kNeed * 1.0, 1),
          'observacao': 'Aplicação única no plantio'
        });
        break;
      default:
        schedule.addAll([
          {
            'periodo': 'Plantio',
            'n': CalculatorMath.roundTo(nNeed * 0.4, 1),
            'p': CalculatorMath.roundTo(pNeed * 1.0, 1),
            'k': CalculatorMath.roundTo(kNeed * 0.6, 1),
            'observacao': '40% N, 100% P, 60% K'
          },
          {
            'periodo': 'Cobertura',
            'n': CalculatorMath.roundTo(nNeed * 0.6, 1),
            'p': 0.0,
            'k': CalculatorMath.roundTo(kNeed * 0.4, 1),
            'observacao': '60% N restante, 40% K restante'
          },
        ]);
    }

    return schedule;
  }

  double _calculateCost(double totalN, double totalP, double totalK) {
    // Preços estimados por kg de nutriente (R\$/kg)
    const double nPrice = 4.50; // Ureia
    const double pPrice = 8.00; // MAP
    const double kPrice = 5.50; // KCl

    return (totalN * nPrice) + (totalP * pPrice) + (totalK * kPrice);
  }

  List<String> _generateRecommendations(
    String cropType,
    double nNeed,
    double pNeed,
    double kNeed,
    String soilTexture,
    double organicMatter,
  ) {
    final List<String> recommendations = [];

    // Recomendações por nutriente
    if (nNeed > 150) {
      recommendations.add('Alto requerimento de N. Considere aplicação parcelada em 3 vezes.');
    } else if (nNeed < 50) {
      recommendations.add('Baixo requerimento de N. Solo bem suprido ou cultura fixadora.');
    }

    if (pNeed > 80) {
      recommendations.add('Alto requerimento de P. Verifique pH do solo para melhor aproveitamento.');
    }

    if (kNeed > 120) {
      recommendations.add('Alto requerimento de K. Em solos arenosos, aplique parceladamente.');
    }

    // Recomendações por textura
    if (soilTexture == 'Arenoso') {
      recommendations.add('Solo arenoso: parcelar N e K para evitar perdas por lixiviação.');
    } else if (soilTexture == 'Argiloso') {
      recommendations.add('Solo argiloso: atenção ao parcelamento de P em cultivos sucessivos.');
    }

    // Recomendações por matéria orgânica
    if (organicMatter < 2.0) {
      recommendations.add('Baixo teor de MO. Considere adubação orgânica complementar.');
    } else if (organicMatter > 5.0) {
      recommendations.add('Alto teor de MO. Monitore disponibilidade de micronutrientes.');
    }

    // Recomendações específicas por cultura
    switch (cropType) {
      case 'Milho':
        recommendations.add('Milho: aplicar N em V6 para máxima eficiência.');
        break;
      case 'Soja':
        recommendations.add('Soja: priorizar P e K. Inoculação com Bradyrhizobium é essencial.');
        break;
      case 'Café':
        recommendations.add('Café: dividir adubação em 3-4 aplicações ao longo do ano.');
        break;
    }

    // Recomendações gerais
    recommendations.add('Realizar análise foliar para acompanhamento nutricional.');
    recommendations.add('Considerar aplicação de micronutrientes conforme análise de solo.');
    recommendations.add('Adequar pH do solo para melhor aproveitamento dos nutrientes.');

    return recommendations;
  }
}