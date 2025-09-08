import '../../entities/calculation_result.dart';
import '../../entities/calculator_category.dart';
import '../../entities/calculator_engine.dart';
import '../../entities/calculator_entity.dart';
import '../../entities/calculator_parameter.dart';

/// Calculadora de Adubação Orgânica
/// Calcula quantidade necessária de adubos orgânicos baseado na análise do solo
class OrganicFertilizerCalculator extends CalculatorEntity {
  const OrganicFertilizerCalculator()
      : super(
          id: 'organic_fertilizer',
          name: 'Adubação Orgânica',
          description: 'Calcula a quantidade necessária de adubos orgânicos baseado na análise de solo e necessidades da cultura',
          category: CalculatorCategory.nutrition,
          parameters: const [
            CalculatorParameter(
              id: 'soil_organic_matter',
              name: 'Matéria Orgânica do Solo',
              description: 'Teor atual de matéria orgânica no solo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 0.5,
              maxValue: 15.0,
              defaultValue: 2.5,
              validationMessage: 'MO deve estar entre 0.5% e 15%',
            ),
            CalculatorParameter(
              id: 'target_organic_matter',
              name: 'Meta de Matéria Orgânica',
              description: 'Teor desejado de matéria orgânica (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 1.0,
              maxValue: 20.0,
              defaultValue: 4.0,
              validationMessage: 'Meta deve estar entre 1% e 20%',
            ),
            CalculatorParameter(
              id: 'area',
              name: 'Área a ser Adubada',
              description: 'Área total a receber adubação orgânica (hectares)',
              type: ParameterType.decimal,
              unit: ParameterUnit.hectare,
              minValue: 0.01,
              maxValue: 10000.0,
              defaultValue: 1.0,
              validationMessage: 'Área deve ser maior que 0.01 ha',
            ),
            CalculatorParameter(
              id: 'soil_depth',
              name: 'Profundidade de Incorporação',
              description: 'Profundidade de incorporação do adubo (cm)',
              type: ParameterType.decimal,
              unit: ParameterUnit.centimetro,
              minValue: 10.0,
              maxValue: 50.0,
              defaultValue: 20.0,
              validationMessage: 'Profundidade deve estar entre 10 e 50 cm',
            ),
            CalculatorParameter(
              id: 'fertilizer_type',
              name: 'Tipo de Adubo Orgânico',
              description: 'Tipo do adubo orgânico a ser utilizado',
              type: ParameterType.selection,
              options: ['Esterco Bovino', 'Esterco Suíno', 'Esterco Galinha', 'Compostagem', 'Biossólido', 'Húmus de Minhoca'],
              defaultValue: 'Esterco Bovino',
            ),
            CalculatorParameter(
              id: 'fertilizer_mo_content',
              name: 'Teor de MO do Adubo',
              description: 'Teor de matéria orgânica do adubo (%)',
              type: ParameterType.percentage,
              unit: ParameterUnit.percentual,
              minValue: 10.0,
              maxValue: 80.0,
              defaultValue: 30.0,
              validationMessage: 'Teor de MO deve estar entre 10% e 80%',
            ),
            CalculatorParameter(
              id: 'soil_density',
              name: 'Densidade do Solo',
              description: 'Densidade aparente do solo (g/cm³)',
              type: ParameterType.decimal,
              unit: ParameterUnit.none,
              minValue: 1.0,
              maxValue: 2.0,
              defaultValue: 1.3,
              validationMessage: 'Densidade deve estar entre 1.0 e 2.0 g/cm³',
            ),
          ],
          formula: 'Necessidade = (Meta - Atual) × Densidade × Profundidade × Área / (Teor MO Adubo × Eficiência)',
          references: const [
            'Raij et al. (1997) - Recomendações de adubação para o Estado de São Paulo',
            'CQFS-RS/SC (2016) - Manual de adubação e calagem',
          ],
        );

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    try {
      final double currentOM = double.parse(inputs['soil_organic_matter'].toString());
      final double targetOM = double.parse(inputs['target_organic_matter'].toString());
      final double area = double.parse(inputs['area'].toString());
      final double soilDepth = double.parse(inputs['soil_depth'].toString());
      final String fertilizerType = inputs['fertilizer_type'].toString();
      final double fertilizerOMContent = double.parse(inputs['fertilizer_mo_content'].toString());
      final double soilDensity = double.parse(inputs['soil_density'].toString());

      // Validação
      if (targetOM <= currentOM) {
        return CalculationError(
          calculatorId: id,
          errorMessage: 'Meta de MO deve ser maior que o teor atual',
          inputs: inputs,
        );
      }

      // Obter características do adubo
      final Map<String, dynamic> fertilizerData = _getFertilizerCharacteristics(fertilizerType);
      final double efficiency = fertilizerData['efficiency'] as double;
      final double moistureContent = fertilizerData['moisture'] as double;
      final double npkN = fertilizerData['n'] as double;
      final double npkP = fertilizerData['p'] as double;
      final double npkK = fertilizerData['k'] as double;

      // Cálculo da necessidade de MO
      final double omDeficit = targetOM - currentOM; // % de MO a aumentar
      
      // Volume de solo por hectare (em m³)
      final double soilVolumePerHa = 10000 * (soilDepth / 100); // m³/ha
      
      // Massa de solo seco por hectare (em toneladas)
      final double soilMassPerHa = soilVolumePerHa * soilDensity * 1000 / 1000; // t/ha
      
      // Necessidade de MO em toneladas por hectare
      final double omNeedPerHa = (omDeficit / 100) * soilMassPerHa; // t MO/ha
      
      // Quantidade de adubo necessária por hectare (base seca)
      final double fertilizerDryPerHa = omNeedPerHa / ((fertilizerOMContent / 100) * efficiency);
      
      // Quantidade de adubo úmido por hectare
      final double fertilizerWetPerHa = fertilizerDryPerHa / (1 - moistureContent / 100);
      
      // Quantidade total para a área
      final double totalFertilizerWet = fertilizerWetPerHa * area;
      final double totalFertilizerDry = fertilizerDryPerHa * area;

      // Nutrientes fornecidos
      final double totalNitrogen = totalFertilizerDry * (npkN / 100);
      final double totalPhosphorus = totalFertilizerDry * (npkP / 100);
      final double totalPotassium = totalFertilizerDry * (npkK / 100);

      // Equivalente em fertilizantes minerais
      final double ureaEquivalent = totalNitrogen / 0.45; // Uréia 45% N
      // ignore: unused_local_variable
      final double superphosphateEquivalent = totalPhosphorus / 0.18; // Super simples 18% P2O5
      // ignore: unused_local_variable
      final double kclEquivalent = totalPotassium / 0.60; // KCl 60% K2O

      // Cronograma de aplicação
      final List<Map<String, dynamic>> applicationSchedule = _generateApplicationSchedule(
        fertilizerWetPerHa, fertilizerType);

      // Custos estimados
      final double estimatedCost = _estimateCost(totalFertilizerWet, fertilizerType);

      // Recomendações
      final List<String> recommendations = _generateRecommendations(
        fertilizerType, omDeficit, fertilizerWetPerHa, currentOM);

      return CalculationResult(
        calculatorId: id,
        calculatedAt: DateTime.now(),
        inputs: inputs,
        type: ResultType.multiple,
        values: [
          CalculationResultValue(
            label: 'Adubo Orgânico Necessário',
            value: CalculatorMath.roundTo(fertilizerWetPerHa, 2),
            unit: 't/ha',
            description: 'Quantidade de adubo úmido por hectare',
            isPrimary: true,
          ),
          CalculationResultValue(
            label: 'Total para a Área',
            value: CalculatorMath.roundTo(totalFertilizerWet, 1),
            unit: 'toneladas',
            description: 'Quantidade total de adubo para $area ha',
          ),
          CalculationResultValue(
            label: 'Base Seca por Hectare',
            value: CalculatorMath.roundTo(fertilizerDryPerHa, 2),
            unit: 't/ha',
            description: 'Quantidade em base seca',
          ),
          CalculationResultValue(
            label: 'Déficit de MO',
            value: CalculatorMath.roundTo(omDeficit, 2),
            unit: '%',
            description: 'Incremento necessário de matéria orgânica',
          ),
          CalculationResultValue(
            label: 'Nitrogênio Total',
            value: CalculatorMath.roundTo(totalNitrogen, 1),
            unit: 'kg',
            description: 'Nitrogênio fornecido pelo adubo orgânico',
          ),
          CalculationResultValue(
            label: 'Fósforo Total',
            value: CalculatorMath.roundTo(totalPhosphorus, 1),
            unit: 'kg',
            description: 'Fósforo fornecido pelo adubo orgânico',
          ),
          CalculationResultValue(
            label: 'Potássio Total',
            value: CalculatorMath.roundTo(totalPotassium, 1),
            unit: 'kg',
            description: 'Potássio fornecido pelo adubo orgânico',
          ),
          CalculationResultValue(
            label: 'Equivalente em Ureia',
            value: CalculatorMath.roundTo(ureaEquivalent, 1),
            unit: 'kg',
            description: 'Equivalente em fertilizante nitrogenado',
          ),
          CalculationResultValue(
            label: 'Custo Estimado',
            value: CalculatorMath.roundTo(estimatedCost, 0),
            unit: 'R\$',
            description: 'Custo estimado do adubo orgânico',
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

  Map<String, dynamic> _getFertilizerCharacteristics(String type) {
    switch (type) {
      case 'Esterco Bovino':
        return {
          'efficiency': 0.3, // 30% de eficiência
          'moisture': 70.0, // 70% umidade
          'n': 1.5, // 1.5% N
          'p': 1.0, // 1.0% P2O5
          'k': 2.0, // 2.0% K2O
        };
      case 'Esterco Suíno':
        return {
          'efficiency': 0.4,
          'moisture': 75.0,
          'n': 2.5,
          'p': 1.8,
          'k': 1.5,
        };
      case 'Esterco Galinha':
        return {
          'efficiency': 0.5,
          'moisture': 65.0,
          'n': 3.0,
          'p': 2.5,
          'k': 2.0,
        };
      case 'Compostagem':
        return {
          'efficiency': 0.6,
          'moisture': 40.0,
          'n': 1.8,
          'p': 1.2,
          'k': 1.5,
        };
      case 'Biossólido':
        return {
          'efficiency': 0.7,
          'moisture': 20.0,
          'n': 4.0,
          'p': 3.0,
          'k': 0.5,
        };
      case 'Húmus de Minhoca':
        return {
          'efficiency': 0.8,
          'moisture': 50.0,
          'n': 2.0,
          'p': 1.5,
          'k': 1.8,
        };
      default:
        return {
          'efficiency': 0.4,
          'moisture': 60.0,
          'n': 2.0,
          'p': 1.5,
          'k': 1.5,
        };
    }
  }

  List<Map<String, dynamic>> _generateApplicationSchedule(
    double quantityPerHa,
    String fertilizerType,
  ) {
    final List<Map<String, dynamic>> schedule = [];
    
    // Divide aplicação baseada no tipo de adubo
    switch (fertilizerType) {
      case 'Esterco Bovino':
      case 'Esterco Suíno':
        // Aplicação única no preparo do solo
        schedule.add({
          'periodo': 'Preparo do Solo',
          'quantidade': quantityPerHa,
          'percentual': 100,
          'observacao': 'Incorporar ao solo imediatamente'
        });
        break;
      case 'Compostagem':
      case 'Húmus de Minhoca':
        // Aplicação parcelada
        schedule.add({
          'periodo': 'Preparo (60 dias antes)',
          'quantidade': quantityPerHa * 0.7,
          'percentual': 70,
          'observacao': 'Aplicação principal'
        });
        schedule.add({
          'periodo': 'Cobertura (30 dias após)',
          'quantidade': quantityPerHa * 0.3,
          'percentual': 30,
          'observacao': 'Complemento nutricional'
        });
        break;
      default:
        schedule.add({
          'periodo': 'Aplicação Única',
          'quantidade': quantityPerHa,
          'percentual': 100,
          'observacao': 'Conforme recomendação'
        });
    }
    
    return schedule;
  }

  double _estimateCost(double totalQuantity, String fertilizerType) {
    // Preços estimados por tonelada (R\$/t)
    final Map<String, double> prices = {
      'Esterco Bovino': 80.0,
      'Esterco Suíno': 90.0,
      'Esterco Galinha': 120.0,
      'Compostagem': 150.0,
      'Biossólido': 60.0,
      'Húmus de Minhoca': 300.0,
    };
    
    final double pricePerTon = prices[fertilizerType] ?? 100.0;
    return totalQuantity * pricePerTon;
  }

  List<String> _generateRecommendations(
    String fertilizerType,
    double omDeficit,
    double quantityPerHa,
    double currentOM,
  ) {
    final List<String> recommendations = [];

    // Recomendações baseadas no déficit de MO
    if (omDeficit > 3.0) {
      recommendations.add('Alto déficit de MO. Considere aplicação parcelada em 2-3 anos.');
    } else if (omDeficit < 1.0) {
      recommendations.add('Baixo déficit de MO. Aplicação única será suficiente.');
    }

    // Recomendações baseadas na quantidade
    if (quantityPerHa > 20.0) {
      recommendations.add('Quantidade elevada. Divida a aplicação para evitar perdas.');
    }

    // Recomendações baseadas no MO atual
    if (currentOM < 2.0) {
      recommendations.add('Solo com baixo teor de MO. Priorize melhoria da estrutura.');
    }

    // Recomendações específicas por tipo
    switch (fertilizerType) {
      case 'Esterco Bovino':
        recommendations.add('Esterco bovino: realize compostagem por 90 dias antes da aplicação.');
        break;
      case 'Esterco Galinha':
        recommendations.add('Esterco de galinha: cuidado com o excesso de nitrogênio.');
        break;
      case 'Biossólido':
        recommendations.add('Biossólido: verifique análise de metais pesados.');
        break;
      case 'Húmus de Minhoca':
        recommendations.add('Húmus: excelente para culturas sensíveis e mudas.');
        break;
    }

    // Recomendações gerais
    recommendations.add('Incorpore o adubo orgânico em até 24 horas após aplicação.');
    recommendations.add('Monitore a umidade do solo para melhor decomposição.');
    recommendations.add('Faça análise de solo anualmente para acompanhar evolução da MO.');

    return recommendations;
  }
}