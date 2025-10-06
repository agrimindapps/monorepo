import 'dart:math' as math;

import 'package:core/core.dart' show injectable;

import '../entities/calculation_result.dart';
import '../entities/calculator_parameter.dart';
import '../interfaces/calculator_strategy.dart';
import '../repositories/calculator_data_repository.dart';

/// Estratégia específica para cálculos NPK
///
/// Implementa Strategy Pattern focado em cálculos de nutrição NPK,
/// seguindo Single Responsibility Principle (SRP) e Open/Closed Principle (OCP)
@injectable
class NPKCalculationStrategy implements INutritionCalculatorStrategy {
  final ICalculatorDataRepository _dataRepository;

  NPKCalculationStrategy(this._dataRepository);

  @override
  String get strategyId => 'npk_nutrition_strategy';

  @override
  String get strategyName => 'Calculadora NPK Avançada';

  @override
  String get description =>
      'Estratégia para cálculo de necessidades nutricionais NPK baseada '
      'em análise de solo, exigência da cultura e fatores de eficiência';

  @override
  List<CalculatorParameter> get parameters => const [
    CalculatorParameter(
      id: 'crop_type',
      name: 'Tipo da Cultura',
      description: 'Cultura a ser cultivada',
      type: ParameterType.selection,
      options: [
        'Milho',
        'Soja',
        'Trigo',
        'Arroz',
        'Feijão',
        'Café',
        'Algodão',
        'Cana-de-açúcar',
        'Tomate',
        'Batata',
      ],
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
      options: [
        'Arenoso',
        'Franco-arenoso',
        'Franco',
        'Franco-argiloso',
        'Argiloso',
      ],
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
      options: [
        'Nenhuma',
        'Leguminosa',
        'Gramínea',
        'Pousio',
        'Adubação Verde',
      ],
      defaultValue: 'Nenhuma',
    ),
  ];

  @override
  Future<ValidationResult> validateInputs(Map<String, dynamic> inputs) async {
    final errors = <String>[];
    final warnings = <String>[];
    final sanitizedInputs = Map<String, dynamic>.from(inputs);

    // Validação de parâmetros obrigatórios
    for (final param in parameters) {
      if (!inputs.containsKey(param.id)) {
        errors.add('Parâmetro obrigatório ${param.name} não fornecido');
        continue;
      }

      final value = inputs[param.id];

      // Validação de tipo e range
      if (param.type == ParameterType.decimal) {
        final numValue = double.tryParse(value.toString());
        if (numValue == null) {
          errors.add('${param.name} deve ser um número válido');
        } else {
          if (param.minValue != null && numValue < (param.minValue! as num)) {
            errors.add('${param.name} deve ser maior que ${param.minValue}');
          }
          if (param.maxValue != null && numValue > (param.maxValue! as num)) {
            errors.add('${param.name} deve ser menor que ${param.maxValue}');
          }
          sanitizedInputs[param.id] = numValue;
        }
      } else if (param.type == ParameterType.selection) {
        if (!param.options!.contains(value.toString())) {
          errors.add(
            '${param.name} deve ser uma das opções válidas: ${param.options!.join(', ')}',
          );
        }
      }
    }

    // Validações específicas de negócio
    final organicMatter =
        double.tryParse(inputs['organic_matter']?.toString() ?? '0') ?? 0;
    if (organicMatter < 1.0) {
      warnings.add(
        'Teor de matéria orgânica muito baixo (${organicMatter.toStringAsFixed(1)}%). Considere adubação orgânica.',
      );
    }

    final expectedYield =
        double.tryParse(inputs['expected_yield']?.toString() ?? '0') ?? 0;
    final cropType = inputs['crop_type']?.toString() ?? '';
    if (_isYieldRealistic(cropType, expectedYield)) {
      warnings.add(
        'Produtividade esperada pode estar acima da média regional para $cropType',
      );
    }

    return errors.isEmpty
        ? ValidationResult.success(sanitizedInputs)
        : ValidationResult.failure(errors, warnings);
  }

  @override
  Future<CalculationResult> executeCalculation(
    Map<String, dynamic> inputs,
  ) async {
    try {
      // 1. Calcular exigências nutricionais
      final nutritionalNeeds = await calculateNutritionalNeeds(inputs);

      // 2. Calcular fornecimento do solo
      final soilSupply = await calculateSoilSupply(inputs);

      // 3. Calcular fatores de eficiência
      final efficiencyFactors = await calculateEfficiencyFactors(inputs);

      // 4. Gerar recomendações de fertilizantes
      final fertilizerRecommendations = await generateFertilizerRecommendations(
        nutritionalNeeds,
        soilSupply,
        efficiencyFactors,
      );

      // 5. Calcular necessidades líquidas
      final netNeeds = _calculateNetNeeds(
        nutritionalNeeds,
        soilSupply,
        efficiencyFactors,
      );

      // 6. Gerar cronograma de aplicação
      final applicationSchedule = await _generateApplicationSchedule(
        inputs,
        netNeeds,
      );

      // 7. Gerar recomendações agronômicas
      final recommendations = await _generateRecommendations(inputs, netNeeds);

      // 8. Calcular custos
      final estimatedCost = _calculateCosts(netNeeds, inputs['area'] as double);

      return CalculationResult(
        calculatorId: strategyId,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: _buildResultValues(netNeeds, soilSupply, inputs, estimatedCost),
        recommendations: recommendations,
        tableData: [
          ...applicationSchedule,
          ...fertilizerRecommendations.products.map(
            (p) => {
              'produto': p.productName,
              'quantidade': p.quantity,
              'unidade': p.unit,
              'nutriente': p.nutrientContent,
              'observacao': p.applicationMethods.join(', '),
            },
          ),
        ],
      );
    } catch (e) {
      return CalculationError(
        calculatorId: strategyId,
        errorMessage: 'Erro no cálculo NPK: ${e.toString()}',
        inputs: inputs,
      );
    }
  }

  @override
  Future<CalculationResult> postProcessResults(
    CalculationResult result,
    Map<String, dynamic> inputs,
  ) async {
    return result;
  }

  @override
  bool canProcess(Map<String, dynamic> inputs) {
    return inputs.containsKey('crop_type') &&
        inputs.containsKey('expected_yield') &&
        inputs.containsKey('soil_n') &&
        inputs.containsKey('soil_p') &&
        inputs.containsKey('soil_k');
  }

  @override
  StrategyMetadata get metadata => StrategyMetadata(
    version: '2.0.0',
    supportedCrops: [
      'Milho',
      'Soja',
      'Trigo',
      'Arroz',
      'Feijão',
      'Café',
      'Algodão',
      'Cana-de-açúcar',
      'Tomate',
      'Batata',
    ],
    supportedRegions: ['Brasil', 'América do Sul'],
    calculationMethod: 'Baseado em Raij et al. (1997) e CQFS-RS/SC (2016)',
    references: [
      'Raij et al. (1997) - Recomendações de adubação para o Estado de São Paulo',
      'CQFS-RS/SC (2016) - Manual de adubação e calagem',
      'Cantarella et al. (2007) - Adubação nitrogenada em sistemas intensivos',
    ],
    lastUpdated: DateTime.now(),
  );

  // ============= IMPLEMENTAÇÃO DOS MÉTODOS DA INTERFACE =============

  @override
  Future<NutritionalRequirements> calculateNutritionalNeeds(
    Map<String, dynamic> inputs,
  ) async {
    final cropType = inputs['crop_type'] as String;
    final expectedYield = inputs['expected_yield'] as double;

    final cropData = await _dataRepository.getCropRequirements(
      cropType,
      expectedYield,
    );

    return NutritionalRequirements(
      nitrogen: cropData.totalNitrogen,
      phosphorus: cropData.totalPhosphorus,
      potassium: cropData.totalPotassium,
      organicMatter: 0.0, // Não é exigência, mas contribuição
      micronutrients: const {},
    );
  }

  @override
  Future<SoilSupply> calculateSoilSupply(Map<String, dynamic> inputs) async {
    final soilN = inputs['soil_n'] as double;
    final soilP = inputs['soil_p'] as double;
    final soilK = inputs['soil_k'] as double;
    final soilTexture = inputs['soil_texture'] as String;
    final organicMatter = inputs['organic_matter'] as double;
    final previousCrop = inputs['previous_crop'] as String;

    // Fatores de conversão mg/dm³ para kg/ha (20 cm profundidade)
    const double conversionFactor = 2.0;

    // Fornecimento base do solo
    double nSupply = soilN * conversionFactor;
    double pSupply = soilP * conversionFactor * 2.29; // P para P₂O₅
    double kSupply = soilK * conversionFactor * 1.20; // K para K₂O

    // Ajustes por matéria orgânica
    final double omBonus = (organicMatter - 2.0) * 10.0;
    nSupply += math.max(0, omBonus);

    // Ajustes por cultura anterior
    final previousCropEffect = await _dataRepository.getPreviousCropEffect(
      previousCrop,
    );
    nSupply += previousCropEffect.nitrogenContribution;

    // Ajustes por textura
    final textureData = await _dataRepository.getSoilTextureFactors(
      soilTexture,
    );
    pSupply *= textureData.retentionFactor;
    kSupply *= textureData.retentionFactor;

    return SoilSupply(
      availableNitrogen: nSupply,
      availablePhosphorus: pSupply,
      availablePotassium: kSupply,
      organicMatterContribution: previousCropEffect.organicMatterContribution,
      micronutrientSupply: const {},
    );
  }

  @override
  Future<EfficiencyFactors> calculateEfficiencyFactors(
    Map<String, dynamic> inputs,
  ) async {
    final soilTexture = inputs['soil_texture'] as String;
    final organicMatter = inputs['organic_matter'] as double;

    final textureData = await _dataRepository.getSoilTextureFactors(
      soilTexture,
    );

    // Ajuste por matéria orgânica
    final double omFactor = 1.0 + (organicMatter - 3.0) * 0.05;

    return EfficiencyFactors(
      nitrogenEfficiency: textureData.nitrogenEfficiency * omFactor,
      phosphorusEfficiency: textureData.phosphorusEfficiency,
      potassiumEfficiency: textureData.potassiumEfficiency,
      micronutrientEfficiency: const {},
    );
  }

  @override
  Future<FertilizerRecommendations> generateFertilizerRecommendations(
    NutritionalRequirements needs,
    SoilSupply supply,
    EfficiencyFactors efficiency,
  ) async {
    final netNeeds = _calculateNetNeeds(needs, supply, efficiency);
    final products = await _dataRepository.getFertilizerProducts();

    final recommendations = <FertilizerRecommendation>[];

    // Fertilizante nitrogenado
    if (netNeeds.nitrogen > 0) {
      final urea = products.firstWhere((p) => p.name == 'Ureia');
      final quantity = netNeeds.nitrogen / urea.nutrientContent['N']!;
      recommendations.add(
        FertilizerRecommendation(
          productName: urea.name,
          quantity: quantity,
          unit: urea.unit,
          nutrientContent: '${urea.nutrientContent['N']}% N',
          applicationMethods: urea.applicationMethods,
        ),
      );
    }

    // Fertilizante fosfatado
    if (netNeeds.phosphorus > 0) {
      final map = products.firstWhere((p) => p.name.contains('MAP'));
      final quantity = netNeeds.phosphorus / map.nutrientContent['P2O5']!;
      recommendations.add(
        FertilizerRecommendation(
          productName: map.name,
          quantity: quantity,
          unit: map.unit,
          nutrientContent: '${map.nutrientContent['P2O5']}% P₂O₅',
          applicationMethods: map.applicationMethods,
        ),
      );
    }

    // Fertilizante potássico
    if (netNeeds.potassium > 0) {
      final kcl = products.firstWhere((p) => p.name.contains('Cloreto'));
      final quantity = netNeeds.potassium / kcl.nutrientContent['K2O']!;
      recommendations.add(
        FertilizerRecommendation(
          productName: kcl.name,
          quantity: quantity,
          unit: kcl.unit,
          nutrientContent: '${kcl.nutrientContent['K2O']}% K₂O',
          applicationMethods: kcl.applicationMethods,
        ),
      );
    }

    return FertilizerRecommendations(
      products: recommendations,
      schedule: [], // Será preenchido em outro método
      estimatedCost: _calculateCosts(netNeeds, 1.0), // Por hectare
      applicationNotes: [
        'Aplicar conforme cronograma específico da cultura',
        'Considerar parcelamento em solos arenosos',
        'Realizar análise foliar para acompanhamento',
      ],
    );
  }

  // ============= MÉTODOS AUXILIARES =============

  NPKNeeds _calculateNetNeeds(
    NutritionalRequirements needs,
    SoilSupply supply,
    EfficiencyFactors efficiency,
  ) {
    final nNeed = math.max(
      0,
      (needs.nitrogen - supply.availableNitrogen) /
          efficiency.nitrogenEfficiency,
    );
    final pNeed = math.max(
      0,
      (needs.phosphorus - supply.availablePhosphorus) /
          efficiency.phosphorusEfficiency,
    );
    final kNeed = math.max(
      0,
      (needs.potassium - supply.availablePotassium) /
          efficiency.potassiumEfficiency,
    );

    return NPKNeeds(
      nitrogen: nNeed.toDouble(),
      phosphorus: pNeed.toDouble(),
      potassium: kNeed.toDouble(),
    );
  }

  bool _isYieldRealistic(String cropType, double expectedYield) {
    // Produtividades médias consideradas altas
    final Map<String, double> highYields = {
      'Milho': 12.0,
      'Soja': 4.0,
      'Trigo': 5.0,
      'Arroz': 8.0,
      'Feijão': 3.0,
      'Café': 30.0,
      'Algodão': 4.0,
      'Cana-de-açúcar': 80.0,
      'Tomate': 60.0,
      'Batata': 30.0,
    };

    final threshold = highYields[cropType] ?? 10.0;
    return expectedYield > threshold * 1.5;
  }

  List<CalculationResultValue> _buildResultValues(
    NPKNeeds netNeeds,
    SoilSupply soilSupply,
    Map<String, dynamic> inputs,
    double estimatedCost,
  ) {
    final area = inputs['area'] as double;

    return [
      CalculationResultValue(
        label: 'Nitrogênio (N)',
        value: _roundTo(netNeeds.nitrogen, 1),
        unit: 'kg/ha',
        description: 'Necessidade de nitrogênio por hectare',
        isPrimary: true,
      ),
      CalculationResultValue(
        label: 'Fósforo (P₂O₅)',
        value: _roundTo(netNeeds.phosphorus, 1),
        unit: 'kg/ha',
        description: 'Necessidade de fósforo por hectare',
        isPrimary: true,
      ),
      CalculationResultValue(
        label: 'Potássio (K₂O)',
        value: _roundTo(netNeeds.potassium, 1),
        unit: 'kg/ha',
        description: 'Necessidade de potássio por hectare',
        isPrimary: true,
      ),
      CalculationResultValue(
        label: 'Total N para Área',
        value: _roundTo(netNeeds.nitrogen * area, 0),
        unit: 'kg',
        description: 'Nitrogênio total para $area ha',
      ),
      CalculationResultValue(
        label: 'Total P₂O₅ para Área',
        value: _roundTo(netNeeds.phosphorus * area, 0),
        unit: 'kg',
        description: 'Fósforo total para $area ha',
      ),
      CalculationResultValue(
        label: 'Total K₂O para Área',
        value: _roundTo(netNeeds.potassium * area, 0),
        unit: 'kg',
        description: 'Potássio total para $area ha',
      ),
      CalculationResultValue(
        label: 'Custo Estimado',
        value: _roundTo(estimatedCost * area, 0),
        unit: 'R\$',
        description: 'Custo estimado dos fertilizantes',
      ),
    ];
  }

  Future<List<Map<String, dynamic>>> _generateApplicationSchedule(
    Map<String, dynamic> inputs,
    NPKNeeds netNeeds,
  ) async {
    final cropType = inputs['crop_type'] as String;
    final schedule = await _dataRepository.getApplicationSchedule(cropType);

    return schedule
        .map(
          (s) => {
            'periodo': s.period,
            'n': _roundTo(netNeeds.nitrogen * s.nitrogenPercentage / 100, 1),
            'p': _roundTo(
              netNeeds.phosphorus * s.phosphorusPercentage / 100,
              1,
            ),
            'k': _roundTo(netNeeds.potassium * s.potassiumPercentage / 100, 1),
            'observacao': s.instructions,
          },
        )
        .toList();
  }

  Future<List<String>> _generateRecommendations(
    Map<String, dynamic> inputs,
    NPKNeeds netNeeds,
  ) async {
    final cropType = inputs['crop_type'] as String;
    final soilTexture = inputs['soil_texture'] as String;
    final organicMatter = inputs['organic_matter'] as double;

    return await _dataRepository.getAgronomicRecommendations(
      cropType: cropType,
      soilTexture: soilTexture,
      organicMatter: organicMatter,
      nNeed: netNeeds.nitrogen,
      pNeed: netNeeds.phosphorus,
      kNeed: netNeeds.potassium,
    );
  }

  double _calculateCosts(NPKNeeds netNeeds, double area) {
    // Preços médios por kg de nutriente (R$/kg)
    const double nPrice = 4.50;
    const double pPrice = 8.00;
    const double kPrice = 5.50;

    return (netNeeds.nitrogen * nPrice +
            netNeeds.phosphorus * pPrice +
            netNeeds.potassium * kPrice) *
        area;
  }

  double _roundTo(double value, int decimals) {
    final factor = math.pow(10, decimals).toDouble();
    return (value * factor).round() / factor;
  }
}

/// Classe auxiliar para necessidades NPK calculadas
class NPKNeeds {
  final double nitrogen;
  final double phosphorus;
  final double potassium;

  const NPKNeeds({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
  });
}
