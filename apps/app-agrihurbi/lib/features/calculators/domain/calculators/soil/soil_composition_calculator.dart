import 'dart:math' as math;

import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Composição do Solo
/// Analisa composição física e química do solo
class SoilCompositionCalculator extends CalculatorEntity {
  const SoilCompositionCalculator()
      : super(
          id: 'soil_composition_calculator',
          name: 'Composição do Solo',
          description: 'Analisa composição física e química do solo, classificação textural e características',
          category: CalculatorCategory.crops, // Ajustado para crops pois não temos categoria soil
          parameters: const [
            CalculatorParameter(
              id: 'sand_percentage',
              name: 'Percentual de Areia',
              description: 'Porcentagem de areia no solo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.0,
              maxValue: 100.0,
              defaultValue: 45.0,
              validationMessage: 'Areia deve estar entre 0% e 100%',
            ),
            CalculatorParameter(
              id: 'silt_percentage',
              name: 'Percentual de Silte',
              description: 'Porcentagem de silte no solo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.0,
              maxValue: 100.0,
              defaultValue: 30.0,
              validationMessage: 'Silte deve estar entre 0% e 100%',
            ),
            CalculatorParameter(
              id: 'clay_percentage',
              name: 'Percentual de Argila',
              description: 'Porcentagem de argila no solo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.0,
              maxValue: 100.0,
              defaultValue: 25.0,
              validationMessage: 'Argila deve estar entre 0% e 100%',
            ),
            CalculatorParameter(
              id: 'organic_matter',
              name: 'Matéria Orgânica',
              description: 'Teor de matéria orgânica (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.1,
              maxValue: 15.0,
              defaultValue: 3.5,
              validationMessage: 'MO deve estar entre 0.1% e 15%',
            ),
            CalculatorParameter(
              id: 'soil_ph',
              name: 'pH do Solo',
              description: 'pH medido em água (1:2,5)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 3.5,
              maxValue: 9.0,
              defaultValue: 6.2,
              validationMessage: 'pH deve estar entre 3.5 e 9.0',
            ),
            CalculatorParameter(
              id: 'bulk_density',
              name: 'Densidade Aparente',
              description: 'Densidade aparente do solo (g/cm³)',
              type: ParameterType.decimal,
              unit: ParameterUnit.gcm3,
              minValue: 0.8,
              maxValue: 2.0,
              defaultValue: 1.3,
              validationMessage: 'Densidade deve estar entre 0.8 e 2.0 g/cm³',
            ),
            CalculatorParameter(
              id: 'cec',
              name: 'CTC',
              description: 'Capacidade de Troca Catiônica (cmolc/dm³)',
              type: ParameterType.decimal,
              unit: ParameterUnit.cmolcdm3,
              minValue: 1.0,
              maxValue: 30.0,
              defaultValue: 8.5,
              validationMessage: 'CTC deve estar entre 1 e 30 cmolc/dm³',
            ),
            CalculatorParameter(
              id: 'base_saturation',
              name: 'Saturação por Bases',
              description: 'Saturação por bases (V%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 5.0,
              maxValue: 95.0,
              defaultValue: 65.0,
              validationMessage: 'V% deve estar entre 5% e 95%',
            ),
          ],
          formula: 'Análise integrada de propriedades físicas e químicas',
          references: const [
            'Brady & Weil (2013) - Elementos da Natureza e Propriedades dos Solos',
            'Embrapa (2009) - Manual de análises químicas de solos',
            'USDA (2014) - Soil taxonomy',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double sandPercentage = double.parse(inputs['sand_percentage'].toString());
      final double siltPercentage = double.parse(inputs['silt_percentage'].toString());
      final double clayPercentage = double.parse(inputs['clay_percentage'].toString());
      final double organicMatter = double.parse(inputs['organic_matter'].toString());
      final double soilPH = double.parse(inputs['soil_ph'].toString());
      final double bulkDensity = double.parse(inputs['bulk_density'].toString());
      final double cec = double.parse(inputs['cec'].toString());
      final double baseSaturation = double.parse(inputs['base_saturation'].toString());

      // Validar soma das frações
      final double totalFractions = sandPercentage + siltPercentage + clayPercentage;
      final double totalDiff = totalFractions - 100.0;
      if ((totalDiff < 0 ? -totalDiff : totalDiff) > 2.0) {
        return CalculationError(
          calculatorId: id,
          errorMessage: 'A soma de areia, silte e argila deve ser próxima a 100%',
          inputs: inputs,
        );
      }

      // Classificação textural
      final Map<String, dynamic> textureAnalysis = _classifyTexture(
        sandPercentage, siltPercentage, clayPercentage);

      // Análise de propriedades físicas
      final Map<String, dynamic> physicalProperties = _analyzePhysicalProperties(
        textureAnalysis, bulkDensity, organicMatter);

      // Análise de propriedades químicas
      final Map<String, dynamic> chemicalProperties = _analyzeChemicalProperties(
        soilPH, cec, baseSaturation, organicMatter);

      // Qualidade do solo
      final Map<String, dynamic> soilQuality = _assessSoilQuality(
        physicalProperties, chemicalProperties, textureAnalysis);

      // Recomendações de manejo
      final List<String> recommendations = _generateManagementRecommendations(
        textureAnalysis, physicalProperties, chemicalProperties, soilQuality);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Classe Textural',
            value: 1.0,
            unit: '',
            description: textureAnalysis['texture_class'].toString(),
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Porosidade Total',
            value: CalculatorMath.roundTo(physicalProperties['total_porosity'] as double, 1),
            unit: '%',
            description: 'Porosidade total do solo',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Índice de Qualidade',
            value: CalculatorMath.roundTo(soilQuality['quality_index'] as double, 1),
            unit: 'pontos',
            description: 'Índice geral de qualidade do solo (0-100)',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Capacidade de Retenção',
            value: CalculatorMath.roundTo(physicalProperties['water_retention'] as double, 1),
            unit: 'mm/cm',
            description: 'Capacidade de retenção de água',
          ),
          CalculationResultValue(
            label: 'Permeabilidade',
            value: CalculatorMath.roundTo(physicalProperties['permeability'] as double, 1),
            unit: 'cm/h',
            description: 'Taxa de infiltração estimada',
          ),
          CalculationResultValue(
            label: 'Fertilidade Química',
            value: CalculatorMath.roundTo(chemicalProperties['fertility_level'] as double, 1),
            unit: 'pontos',
            description: 'Nível de fertilidade química (0-100)',
          ),
          CalculationResultValue(
            label: 'Risco de Compactação',
            value: CalculatorMath.roundTo(physicalProperties['compaction_risk'] as double, 1),
            unit: 'pontos',
            description: 'Susceptibilidade à compactação (0-100)',
          ),
          CalculationResultValue(
            label: 'Estabilidade de Agregados',
            value: CalculatorMath.roundTo(physicalProperties['aggregate_stability'] as double, 1),
            unit: 'pontos',
            description: 'Estabilidade estrutural (0-100)',
          ),
        ],
        recommendations: recommendations,
        tableData: const [],
      );
    } catch (e) {
      return CalculationError(
        calculatorId: id,
        errorMessage: 'Erro no cálculo: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  Map<String, dynamic> _classifyTexture(double sand, double silt, double clay) {
    String textureClass;
    
    if (sand >= 85) {
      textureClass = 'Areia';
    } else if (sand >= 70 && clay < 15) {
      textureClass = 'Franco-arenoso';
    } else if (clay >= 40) {
      textureClass = 'Argila';
    } else if (clay >= 27 && clay < 40) {
      textureClass = 'Franco-argiloso';
    } else if (clay >= 20 && clay < 27) {
      textureClass = 'Franco';
    } else if (silt >= 50) {
      textureClass = 'Franco-siltoso';
    } else {
      textureClass = 'Franco-arenoso';
    }

    return {
      'texture_class': textureClass,
      'sand_dominance': sand / 100,
      'clay_content_level': clay < 15 ? 'Baixo' : clay < 35 ? 'Médio' : 'Alto',
    };
  }

  Map<String, dynamic> _analyzePhysicalProperties(
    Map<String, dynamic> textureAnalysis,
    double bulkDensity,
    double organicMatter,
  ) {
    // Porosidade total
    final double totalPorosity = (1 - (bulkDensity / 2.65)) * 100;

    // Capacidade de retenção de água
    double waterRetention = 0.0;
    final String textureClass = textureAnalysis['texture_class'] as String;
    
    switch (textureClass) {
      case 'Areia':
        waterRetention = 8.0;
        break;
      case 'Franco-arenoso':
        waterRetention = 12.0;
        break;
      case 'Franco':
        waterRetention = 18.0;
        break;
      case 'Franco-argiloso':
        waterRetention = 22.0;
        break;
      case 'Argila':
        waterRetention = 25.0;
        break;
      default:
        waterRetention = 15.0;
    }
    waterRetention *= (1 + organicMatter / 10); // Ajuste por MO

    // Permeabilidade
    double permeability = 0.0;
    switch (textureClass) {
      case 'Areia':
        permeability = 20.0;
        break;
      case 'Franco-arenoso':
        permeability = 8.0;
        break;
      case 'Franco':
        permeability = 3.0;
        break;
      case 'Franco-argiloso':
        permeability = 1.5;
        break;
      case 'Argila':
        permeability = 0.5;
        break;
      default:
        permeability = 5.0;
    }

    // Risco de compactação
    double compactionRisk = bulkDensity * 50; // Simplificado
    if (textureClass.contains('Argila')) compactionRisk *= 1.3;
    compactionRisk = math.min(100, compactionRisk);

    // Estabilidade de agregados
    double aggregateStability = organicMatter * 15; // Influência da MO
    if (textureClass.contains('Franco')) aggregateStability *= 1.2;
    aggregateStability = math.min(100, aggregateStability);

    return {
      'total_porosity': totalPorosity,
      'water_retention': waterRetention,
      'permeability': permeability,
      'compaction_risk': compactionRisk,
      'aggregate_stability': aggregateStability,
    };
  }

  Map<String, dynamic> _analyzeChemicalProperties(
    double soilPH,
    double cec,
    double baseSaturation,
    double organicMatter,
  ) {
    // Avaliação do pH
    String phClassification;
    double phScore = 0.0;
    
    if (soilPH < 5.0) {
      phClassification = 'Muito Ácido';
      phScore = 20.0;
    } else if (soilPH < 6.0) {
      phClassification = 'Ácido';
      phScore = 60.0;
    } else if (soilPH <= 7.0) {
      phClassification = 'Ligeiramente Ácido';
      phScore = 90.0;
    } else if (soilPH <= 8.0) {
      phClassification = 'Neutro/Alcalino';
      phScore = 85.0;
    } else {
      phClassification = 'Muito Alcalino';
      phScore = 50.0;
    }

    // Avaliação da CTC
    String cecClassification;
    double cecScore = 0.0;
    
    if (cec < 5.0) {
      cecClassification = 'Baixa';
      cecScore = 40.0;
    } else if (cec < 10.0) {
      cecClassification = 'Média';
      cecScore = 70.0;
    } else if (cec < 15.0) {
      cecClassification = 'Alta';
      cecScore = 90.0;
    } else {
      cecClassification = 'Muito Alta';
      cecScore = 100.0;
    }

    // Nível de fertilidade
    double fertilityLevel = (phScore + cecScore + baseSaturation + organicMatter * 10) / 4;
    fertilityLevel = math.min(100, fertilityLevel);

    return {
      'ph_classification': phClassification,
      'ph_score': phScore,
      'cec_classification': cecClassification,
      'cec_score': cecScore,
      'fertility_level': fertilityLevel,
    };
  }

  Map<String, dynamic> _assessSoilQuality(
    Map<String, dynamic> physicalProperties,
    Map<String, dynamic> chemicalProperties,
    Map<String, dynamic> textureAnalysis,
  ) {
    final double physicalScore = (
      (physicalProperties['total_porosity'] as double) * 0.7 + // Máximo ~45
      (100 - (physicalProperties['compaction_risk'] as double)) * 0.5 + // Máximo 50
      (physicalProperties['aggregate_stability'] as double) * 0.8 // Máximo ~80
    ) / 3;

    final double chemicalScore = chemicalProperties['fertility_level'] as double;

    final double qualityIndex = (physicalScore * 0.6 + chemicalScore * 0.4);

    String qualityClassification;
    if (qualityIndex >= 80) {
      qualityClassification = 'Excelente';
    } else if (qualityIndex >= 65) {
      qualityClassification = 'Boa';
    } else if (qualityIndex >= 50) {
      qualityClassification = 'Regular';
    } else {
      qualityClassification = 'Ruim';
    }

    return {
      'quality_index': qualityIndex,
      'quality_classification': qualityClassification,
      'physical_score': physicalScore,
      'chemical_score': chemicalScore,
    };
  }

  List<String> _generateManagementRecommendations(
    Map<String, dynamic> textureAnalysis,
    Map<String, dynamic> physicalProperties,
    Map<String, dynamic> chemicalProperties,
    Map<String, dynamic> soilQuality,
  ) {
    final List<String> recommendations = [];

    final String textureClass = textureAnalysis['texture_class'] as String;
    final double compactionRisk = physicalProperties['compaction_risk'] as double;
    final double fertilityLevel = chemicalProperties['fertility_level'] as double;
    final String phClassification = chemicalProperties['ph_classification'] as String;

    // Recomendações por textura
    if (textureClass.contains('Areia')) {
      recommendations.add('Solo arenoso: aumentar matéria orgânica para melhorar retenção de água e nutrientes.');
    } else if (textureClass.contains('Argila')) {
      recommendations.add('Solo argiloso: evitar tráfego em condições úmidas para prevenir compactação.');
    }

    // Recomendações por compactação
    if (compactionRisk > 70) {
      recommendations.add('Alto risco de compactação: considerar descompactação mecânica ou biológica.');
    }

    // Recomendações por fertilidade
    if (fertilityLevel < 60) {
      recommendations.add('Fertilidade baixa: implementar programa de correção e adubação.');
    }

    // Recomendações por pH
    if (phClassification.contains('Ácido')) {
      recommendations.add('Solo ácido: realizar calagem para elevar pH e V%.');
    } else if (phClassification.contains('Alcalino')) {
      recommendations.add('Solo alcalino: monitorar disponibilidade de micronutrientes.');
    }

    // Recomendações gerais
    recommendations.add('Implementar práticas conservacionistas para manter qualidade do solo.');
    recommendations.add('Monitorar regularmente através de análises físico-químicas.');

    return recommendations;
  }
}