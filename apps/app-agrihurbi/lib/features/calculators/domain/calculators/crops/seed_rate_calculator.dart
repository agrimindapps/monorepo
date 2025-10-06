import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Taxa de Semeadura
/// Calcula quantidade ideal de sementes baseado em população e características
class SeedRateCalculator extends CalculatorEntity {
  const SeedRateCalculator()
      : super(
          id: 'seed_rate_calculator',
          name: 'Taxa de Semeadura',
          description: 'Calcula quantidade ideal de sementes por hectare baseado em população desejada, germinação e perdas',
          category: CalculatorCategory.crops,
          parameters: const [
            CalculatorParameter(
              id: 'crop_type',
              name: 'Tipo de Cultura',
              description: 'Cultura a ser semeada',
              type: ParameterType.selection,
              options: ['Milho', 'Soja', 'Feijão', 'Trigo', 'Arroz', 'Algodão', 'Girassol', 'Sorgo'],
              defaultValue: 'Milho',
            ),
            CalculatorParameter(
              id: 'target_population',
              name: 'População Desejada',
              description: 'Número de plantas desejadas por hectare',
              type: ParameterType.integer,
              unit: ParameterUnit.plantasha,
              minValue: 10000,
              maxValue: 1000000,
              defaultValue: 65000,
              validationMessage: 'População deve estar entre 10.000 e 1.000.000 plantas/ha',
            ),
            CalculatorParameter(
              id: 'germination_rate',
              name: 'Taxa de Germinação',
              description: 'Porcentagem de germinação das sementes (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 60.0,
              maxValue: 100.0,
              defaultValue: 85.0,
              validationMessage: 'Germinação deve estar entre 60% e 100%',
            ),
            CalculatorParameter(
              id: 'field_losses',
              name: 'Perdas no Campo',
              description: 'Perdas esperadas por pragas, doenças, etc. (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.0,
              maxValue: 30.0,
              defaultValue: 8.0,
              validationMessage: 'Perdas devem estar entre 0% e 30%',
            ),
            CalculatorParameter(
              id: 'seed_purity',
              name: 'Pureza das Sementes',
              description: 'Porcentagem de pureza das sementes (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 85.0,
              maxValue: 100.0,
              defaultValue: 98.0,
              validationMessage: 'Pureza deve estar entre 85% e 100%',
            ),
            CalculatorParameter(
              id: 'thousand_seed_weight',
              name: 'Peso de 1000 Sementes',
              description: 'Peso de 1000 sementes (gramas)',
              type: ParameterType.decimal,
              unit: ParameterUnit.grama,
              minValue: 1.0,
              maxValue: 500.0,
              defaultValue: 320.0,
              validationMessage: 'Peso deve estar entre 1 e 500 gramas',
            ),
            CalculatorParameter(
              id: 'field_area',
              name: 'Área do Campo',
              description: 'Área total a ser semeada (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.1,
              maxValue: 10000.0,
              defaultValue: 50.0,
              validationMessage: 'Área deve estar entre 0.1 e 10.000 ha',
            ),
            CalculatorParameter(
              id: 'safety_margin',
              name: 'Margem de Segurança',
              description: 'Margem adicional de segurança (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.0,
              maxValue: 20.0,
              defaultValue: 5.0,
              validationMessage: 'Margem deve estar entre 0% e 20%',
            ),
          ],
          formula: 'Taxa = População ÷ (Germinação × Pureza × (1 - Perdas)) × (1 + Margem)',
          references: const [
            'Marcos Filho (2005) - Fisiologia de sementes',
            'Peske & Villela (2003) - Sementes: fundamentos científicos',
            'Embrapa (2018) - Tecnologia de sementes',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final String cropType = inputs['crop_type'].toString();
      final int targetPopulation = int.parse(inputs['target_population'].toString());
      final double germinationRate = double.parse(inputs['germination_rate'].toString());
      final double fieldLosses = double.parse(inputs['field_losses'].toString());
      final double seedPurity = double.parse(inputs['seed_purity'].toString());
      final double thousandSeedWeight = double.parse(inputs['thousand_seed_weight'].toString());
      final double fieldArea = double.parse(inputs['field_area'].toString());
      final double safetyMargin = double.parse(inputs['safety_margin'].toString());
      final double establishmentEfficiency = (germinationRate / 100) * 
                                           (seedPurity / 100) * 
                                           ((100 - fieldLosses) / 100);
      final double seedsPerHa = targetPopulation / establishmentEfficiency;
      final double finalSeedsPerHa = seedsPerHa * (1 + safetyMargin / 100);
      final double seedWeightPerHa = (finalSeedsPerHa * thousandSeedWeight) / 1000000;
      final double totalSeeds = finalSeedsPerHa * fieldArea;
      final double totalWeight = seedWeightPerHa * fieldArea;
      final Map<String, dynamic> qualityAnalysis = _analyzeQuality(
        germinationRate, seedPurity, fieldLosses, cropType);
      final List<String> recommendations = _generateRecommendations(
        cropType, establishmentEfficiency, qualityAnalysis);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Sementes por Hectare',
            value: CalculatorMath.roundTo(finalSeedsPerHa, 0),
            unit: 'sementes/ha',
            description: 'Número de sementes necessárias por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Peso por Hectare',
            value: CalculatorMath.roundTo(seedWeightPerHa, 2),
            unit: 'kg/ha',
            description: 'Peso das sementes por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Total de Sementes',
            value: CalculatorMath.roundTo(totalSeeds, 0),
            unit: 'sementes',
            description: 'Total de sementes para a área',
          ),
          CalculationResultValue(
            label: 'Peso Total',
            value: CalculatorMath.roundTo(totalWeight, 1),
            unit: 'kg',
            description: 'Peso total das sementes',
          ),
          CalculationResultValue(
            label: 'Eficiência de Estabelecimento',
            value: CalculatorMath.roundTo(establishmentEfficiency * 100, 1),
            unit: '%',
            description: 'Eficiência esperada de estabelecimento',
          ),
          CalculationResultValue(
            label: 'Índice de Qualidade',
            value: CalculatorMath.roundTo(qualityAnalysis['quality_index'] as double, 1),
            unit: 'pontos',
            description: 'Índice de qualidade das sementes',
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

  Map<String, dynamic> _analyzeQuality(
    double germination,
    double purity,
    double losses,
    String cropType,
  ) {
    double qualityIndex = 0.0;
    qualityIndex += (germination / 100) * 40;
    qualityIndex += (purity / 100) * 30;
    qualityIndex += ((100 - losses) / 100) * 30;

    String classification;
    if (qualityIndex >= 90) {
      classification = 'Excelente';
    } else if (qualityIndex >= 75) {
      classification = 'Boa';
    } else if (qualityIndex >= 60) {
      classification = 'Regular';
    } else {
      classification = 'Ruim';
    }

    return {
      'quality_index': qualityIndex,
      'classification': classification,
    };
  }

  List<String> _generateRecommendations(
    String cropType,
    double efficiency,
    Map<String, dynamic> qualityAnalysis,
  ) {
    final List<String> recommendations = [];

    if (efficiency < 0.7) {
      recommendations.add('Baixa eficiência de estabelecimento - verificar qualidade das sementes.');
    }

    final double qualityIndex = qualityAnalysis['quality_index'] as double;
    if (qualityIndex < 70) {
      recommendations.add('Qualidade das sementes comprometida - considerar novo lote.');
    }

    recommendations.add('Realizar teste de germinação antes do plantio.');
    recommendations.add('Calibrar equipamentos para distribuição uniforme.');
    recommendations.add('Monitorar emergência para confirmar estabelecimento.');

    return recommendations;
  }
}