import 'package:injectable/injectable.dart';

import '../../domain/repositories/calculator_data_repository.dart';

/// Implementação do repositório de dados das calculadoras
/// 
/// Centraliza todos os dados hardcoded que estavam espalhados nas calculadoras
/// Implementa Single Responsibility Principle (SRP) e Dependency Inversion (DIP)
@LazySingleton(as: ICalculatorDataRepository)
class CalculatorDataRepositoryImpl implements ICalculatorDataRepository {

  @override
  Future<CropRequirementsData> getCropRequirements(String cropType, double expectedYield) async {
    final Map<String, Map<String, double>> cropData = {
      'Milho': {'n': 25.0, 'p': 8.0, 'k': 18.0},
      'Soja': {'n': 80.0, 'p': 15.0, 'k': 37.0}, // N da FBN
      'Trigo': {'n': 30.0, 'p': 12.0, 'k': 25.0},
      'Arroz': {'n': 22.0, 'p': 10.0, 'k': 30.0},
      'Feijão': {'n': 35.0, 'p': 8.0, 'k': 25.0},
      'Café': {'n': 45.0, 'p': 7.0, 'k': 40.0},
      'Algodão': {'n': 60.0, 'p': 25.0, 'k': 45.0},
      'Cana-de-açúcar': {'n': 1.8, 'p': 0.8, 'k': 2.5},
      'Tomate': {'n': 3.0, 'p': 1.2, 'k': 4.5},
      'Batata': {'n': 4.5, 'p': 1.8, 'k': 7.0},
    };

    final requirements = cropData[cropType] ?? cropData['Milho']!;
    
    return CropRequirementsData(
      cropType: cropType,
      yieldTarget: expectedYield,
      nitrogenPerTon: requirements['n']!,
      phosphorusPerTon: requirements['p']!,
      potassiumPerTon: requirements['k']!,
      totalNitrogen: requirements['n']! * expectedYield,
      totalPhosphorus: requirements['p']! * expectedYield,
      totalPotassium: requirements['k']! * expectedYield,
    );
  }

  @override
  Future<List<String>> getAvailableCrops() async {
    return [
      'Milho', 'Soja', 'Trigo', 'Arroz', 'Feijão', 
      'Café', 'Algodão', 'Cana-de-açúcar', 'Tomate', 'Batata'
    ];
  }

  @override
  Future<SoilTextureData> getSoilTextureFactors(String soilTexture) async {
    final Map<String, Map<String, double>> textureData = {
      'Arenoso': {
        'retentionFactor': 0.7,
        'nEfficiency': 0.6,
        'pEfficiency': 0.15,
        'kEfficiency': 0.8,
        'infiltrationRate': 25.0,
        'organicMatterFactor': 0.8,
      },
      'Franco-arenoso': {
        'retentionFactor': 0.8,
        'nEfficiency': 0.7,
        'pEfficiency': 0.20,
        'kEfficiency': 0.85,
        'infiltrationRate': 15.0,
        'organicMatterFactor': 0.9,
      },
      'Franco': {
        'retentionFactor': 1.0,
        'nEfficiency': 0.8,
        'pEfficiency': 0.25,
        'kEfficiency': 0.9,
        'infiltrationRate': 8.0,
        'organicMatterFactor': 1.0,
      },
      'Franco-argiloso': {
        'retentionFactor': 1.1,
        'nEfficiency': 0.75,
        'pEfficiency': 0.30,
        'kEfficiency': 0.85,
        'infiltrationRate': 3.0,
        'organicMatterFactor': 1.1,
      },
      'Argiloso': {
        'retentionFactor': 1.2,
        'nEfficiency': 0.7,
        'pEfficiency': 0.20,
        'kEfficiency': 0.8,
        'infiltrationRate': 1.0,
        'organicMatterFactor': 1.2,
      },
    };

    final data = textureData[soilTexture] ?? textureData['Franco']!;
    
    return SoilTextureData(
      textureClass: soilTexture,
      retentionFactor: data['retentionFactor']!,
      nitrogenEfficiency: data['nEfficiency']!,
      phosphorusEfficiency: data['pEfficiency']!,
      potassiumEfficiency: data['kEfficiency']!,
      infiltrationRate: data['infiltrationRate']!,
      organicMatterFactor: data['organicMatterFactor']!,
    );
  }

  @override
  Future<List<String>> getAvailableSoilTextures() async {
    return ['Arenoso', 'Franco-arenoso', 'Franco', 'Franco-argiloso', 'Argiloso'];
  }

  @override
  Future<List<FertilizerProduct>> getFertilizerProducts() async {
    return [
      const FertilizerProduct(
        name: 'Ureia',
        nutrientContent: {'N': 45.0},
        unit: 'kg/ha',
        pricePerKg: 4.50,
        applicationMethods: ['Plantio', 'Cobertura', 'Fertirrigação'],
        notes: 'Aplicação parcelada recomendada',
      ),
      const FertilizerProduct(
        name: 'MAP (Fosfato Monoamônico)',
        nutrientContent: {'P2O5': 52.0, 'N': 11.0},
        unit: 'kg/ha',
        pricePerKg: 8.00,
        applicationMethods: ['Plantio'],
        notes: 'Aplicação no plantio',
      ),
      const FertilizerProduct(
        name: 'Cloreto de Potássio',
        nutrientContent: {'K2O': 60.0},
        unit: 'kg/ha',
        pricePerKg: 5.50,
        applicationMethods: ['Plantio', 'Cobertura'],
        notes: 'Aplicação parcelada em solos arenosos',
      ),
      const FertilizerProduct(
        name: 'Superfosfato Simples',
        nutrientContent: {'P2O5': 18.0, 'Ca': 16.0, 'S': 10.0},
        unit: 'kg/ha',
        pricePerKg: 3.20,
        applicationMethods: ['Plantio'],
        notes: 'Fonte de fósforo com cálcio e enxofre',
      ),
      const FertilizerProduct(
        name: 'Sulfato de Amônio',
        nutrientContent: {'N': 21.0, 'S': 24.0},
        unit: 'kg/ha',
        pricePerKg: 3.80,
        applicationMethods: ['Plantio', 'Cobertura'],
        notes: 'Fonte de nitrogênio com enxofre',
      ),
    ];
  }

  @override
  Future<FertilizerProduct?> getFertilizerByNutrient(String nutrient) async {
    final products = await getFertilizerProducts();
    
    switch (nutrient.toUpperCase()) {
      case 'N':
        return products.firstWhere((p) => p.name == 'Ureia');
      case 'P2O5':
      case 'P':
        return products.firstWhere((p) => p.name == 'MAP (Fosfato Monoamônico)');
      case 'K2O':
      case 'K':
        return products.firstWhere((p) => p.name == 'Cloreto de Potássio');
      default:
        return null;
    }
  }

  @override
  Future<List<ApplicationSchedule>> getApplicationSchedule(String cropType) async {
    switch (cropType) {
      case 'Milho':
        return [
          const ApplicationSchedule(
            period: 'Plantio',
            nitrogenPercentage: 30.0,
            phosphorusPercentage: 100.0,
            potassiumPercentage: 50.0,
            instructions: '30% N, 100% P, 50% K no sulco de plantio',
          ),
          const ApplicationSchedule(
            period: 'V6 (6 folhas)',
            nitrogenPercentage: 70.0,
            phosphorusPercentage: 0.0,
            potassiumPercentage: 50.0,
            instructions: '70% N restante em cobertura, 50% K restante',
          ),
        ];
      case 'Soja':
        return [
          const ApplicationSchedule(
            period: 'Plantio',
            nitrogenPercentage: 100.0,
            phosphorusPercentage: 100.0,
            potassiumPercentage: 100.0,
            instructions: 'Aplicação única no plantio - soja depende da FBN',
          ),
        ];
      case 'Café':
        return [
          const ApplicationSchedule(
            period: 'Setembro/Outubro',
            nitrogenPercentage: 30.0,
            phosphorusPercentage: 100.0,
            potassiumPercentage: 30.0,
            instructions: 'Primeira aplicação após colheita',
          ),
          const ApplicationSchedule(
            period: 'Dezembro/Janeiro',
            nitrogenPercentage: 40.0,
            phosphorusPercentage: 0.0,
            potassiumPercentage: 40.0,
            instructions: 'Segunda aplicação no período chuvoso',
          ),
          const ApplicationSchedule(
            period: 'Março/Abril',
            nitrogenPercentage: 30.0,
            phosphorusPercentage: 0.0,
            potassiumPercentage: 30.0,
            instructions: 'Terceira aplicação antes da seca',
          ),
        ];
      default:
        return [
          const ApplicationSchedule(
            period: 'Plantio',
            nitrogenPercentage: 40.0,
            phosphorusPercentage: 100.0,
            potassiumPercentage: 60.0,
            instructions: '40% N, 100% P, 60% K no plantio',
          ),
          const ApplicationSchedule(
            period: 'Cobertura',
            nitrogenPercentage: 60.0,
            phosphorusPercentage: 0.0,
            potassiumPercentage: 40.0,
            instructions: '60% N restante e 40% K restante em cobertura',
          ),
        ];
    }
  }

  @override
  Future<PreviousCropEffect> getPreviousCropEffect(String previousCrop) async {
    switch (previousCrop) {
      case 'Leguminosa':
        return PreviousCropEffect(
          cropType: previousCrop,
          nitrogenContribution: 40.0,
          organicMatterContribution: 0.2,
          description: 'Contribuição da fixação biológica de nitrogênio residual',
        );
      case 'Adubação Verde':
        return PreviousCropEffect(
          cropType: previousCrop,
          nitrogenContribution: 30.0,
          organicMatterContribution: 0.3,
          description: 'Contribuição da mineralização da biomassa',
        );
      case 'Pousio':
        return PreviousCropEffect(
          cropType: previousCrop,
          nitrogenContribution: 15.0,
          organicMatterContribution: 0.1,
          description: 'Mineralização durante o período de descanso',
        );
      case 'Gramínea':
        return PreviousCropEffect(
          cropType: previousCrop,
          nitrogenContribution: 5.0,
          organicMatterContribution: 0.15,
          description: 'Contribuição mínima de nitrogênio, boa estruturação do solo',
        );
      default: // 'Nenhuma'
        return const PreviousCropEffect(
          cropType: 'Nenhuma',
          nitrogenContribution: 0.0,
          organicMatterContribution: 0.0,
          description: 'Sem contribuição de cultura anterior',
        );
    }
  }

  @override
  Future<List<String>> getAgronomicRecommendations({
    required String cropType,
    required String soilTexture,
    required double organicMatter,
    required double nNeed,
    required double pNeed,
    required double kNeed,
  }) async {
    final List<String> recommendations = [];
    if (nNeed > 150) {
      recommendations.add('Alto requerimento de N. Considere aplicação parcelada em 3 vezes para aumentar eficiência.');
    } else if (nNeed < 50) {
      recommendations.add('Baixo requerimento de N. Solo bem suprido ou cultura com fixação biológica.');
    }

    if (pNeed > 80) {
      recommendations.add('Alto requerimento de P. Verifique e corrija pH do solo (6,0-6,5) para melhor aproveitamento.');
    }

    if (kNeed > 120) {
      recommendations.add('Alto requerimento de K. Em solos arenosos, aplique parceladamente para evitar lixiviação.');
    }
    switch (soilTexture) {
      case 'Arenoso':
        recommendations.add('Solo arenoso: parcelar N e K em 2-3 aplicações para evitar perdas por lixiviação.');
        break;
      case 'Argiloso':
        recommendations.add('Solo argiloso: atenção ao parcelamento de P em cultivos sucessivos para evitar fixação.');
        break;
      case 'Franco':
        recommendations.add('Solo franco: textura ideal, manter manejo balanceado de nutrientes.');
        break;
    }
    if (organicMatter < 2.0) {
      recommendations.add('Baixo teor de MO (${organicMatter.toStringAsFixed(1)}%). Considere adubação orgânica complementar.');
    } else if (organicMatter > 5.0) {
      recommendations.add('Alto teor de MO (${organicMatter.toStringAsFixed(1)}%). Monitore disponibilidade de micronutrientes.');
    }
    switch (cropType) {
      case 'Milho':
        recommendations.add('Milho: aplicar N em V6 (6 folhas) para máxima eficiência de absorção.');
        break;
      case 'Soja':
        recommendations.add('Soja: priorizar P e K. Realizar inoculação com Bradyrhizobium para fixação de N.');
        break;
      case 'Café':
        recommendations.add('Café: dividir adubação em 3-4 aplicações ao longo do ano conforme precipitação.');
        break;
      case 'Algodão':
        recommendations.add('Algodão: atenção especial ao boro e enxofre para qualidade da fibra.');
        break;
    }
    recommendations.addAll([
      'Realizar análise foliar aos 60-80 dias para acompanhamento nutricional.',
      'Considerar aplicação de micronutrientes conforme análise de solo específica.',
      'Adequar pH do solo entre 6,0-6,5 para melhor aproveitamento dos nutrientes.',
      'Implementar sistema de rotação de culturas para sustentabilidade do sistema.',
    ]);

    return recommendations;
  }

  @override
  Future<double> getConversionFactor(String fromUnit, String toUnit) async {
    const Map<String, Map<String, double>> conversionTable = {
      'mg/dm3': {
        'kg/ha': 2.0, // Considerando 20 cm de profundidade
        'ppm': 1.0,
      },
      'kg/ha': {
        'mg/dm3': 0.5,
        'ton/ha': 0.001,
      },
      'P': {
        'P2O5': 2.29,
      },
      'K': {
        'K2O': 1.20,
      },
    };

    return conversionTable[fromUnit]?[toUnit] ?? 1.0;
  }

  @override
  Future<ValidationRanges> getValidationRanges(String parameterType) async {
    switch (parameterType) {
      case 'expected_yield':
        return const ValidationRanges(
          minValue: 0.5,
          maxValue: 50.0,
          optimalMin: 5.0,
          optimalMax: 15.0,
          unit: 't/ha',
        );
      case 'soil_n':
        return const ValidationRanges(
          minValue: 0.0,
          maxValue: 200.0,
          optimalMin: 20.0,
          optimalMax: 60.0,
          unit: 'mg/dm³',
        );
      case 'soil_p':
        return const ValidationRanges(
          minValue: 0.0,
          maxValue: 100.0,
          optimalMin: 15.0,
          optimalMax: 40.0,
          unit: 'mg/dm³',
        );
      case 'soil_k':
        return const ValidationRanges(
          minValue: 0.0,
          maxValue: 500.0,
          optimalMin: 80.0,
          optimalMax: 200.0,
          unit: 'mg/dm³',
        );
      case 'organic_matter':
        return const ValidationRanges(
          minValue: 0.5,
          maxValue: 15.0,
          optimalMin: 2.5,
          optimalMax: 5.0,
          unit: '%',
        );
      case 'area':
        return const ValidationRanges(
          minValue: 0.01,
          maxValue: 10000.0,
          optimalMin: 1.0,
          optimalMax: 100.0,
          unit: 'ha',
        );
      default:
        return const ValidationRanges(
          minValue: 0.0,
          maxValue: double.infinity,
          optimalMin: 0.0,
          optimalMax: double.infinity,
          unit: '',
        );
    }
  }
}
