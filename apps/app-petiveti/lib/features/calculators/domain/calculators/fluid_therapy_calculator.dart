import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart';

/// Calculadora de Fluidoterapia
/// Calcula necessidades de fluidos para manutenção, reposição e perdas
class FluidTherapyCalculator extends Calculator {
  const FluidTherapyCalculator();

  @override
  String get id => 'fluid_therapy';

  @override
  String get name => 'Fluidoterapia';

  @override
  String get description => 
      'Calcula as necessidades de fluidos para manutenção, '
      'reposição de déficits e perdas contínuas.';

  @override
  CalculatorCategory get category => CalculatorCategory.treatment;

  @override
  String get iconName => 'water_drop';

  @override
  String get version => '1.0.0';

  @override
  List<InputField> get inputFields => [
    const InputField(
      key: 'weight',
      label: 'Peso do Animal',
      helperText: 'Peso atual do animal em quilogramas',
      type: InputFieldType.number,
      unit: 'kg',
      isRequired: true,
      minValue: 0.5,
      maxValue: 100.0,
    ),
    const InputField(
      key: 'dehydration_percentage',
      label: 'Grau de Desidratação',
      helperText: 'Porcentagem de desidratação estimada',
      type: InputFieldType.dropdown,
      options: [
        '0% (Sem desidratação)',
        '3% (Leve)',
        '5% (Moderada)',
        '8% (Grave)',
        '10% (Severa)',
        '12% (Crítica)',
      ],
      isRequired: true,
    ),
    const InputField(
      key: 'ongoing_losses',
      label: 'Perdas Contínuas',
      helperText: 'Volume de perdas estimadas por dia',
      type: InputFieldType.number,
      unit: 'ml/dia',
      defaultValue: 0.0,
      minValue: 0.0,
      maxValue: 2000.0,
    ),
    const InputField(
      key: 'vomiting_frequency',
      label: 'Frequência de Vômitos',
      helperText: 'Número de episódios de vômito por dia',
      type: InputFieldType.dropdown,
      options: ['0', '1-2', '3-5', '6-10', '>10'],
      defaultValue: '0',
    ),
    const InputField(
      key: 'diarrhea_severity',
      label: 'Severidade da Diarreia',
      helperText: 'Intensidade da diarreia',
      type: InputFieldType.dropdown,
      options: ['Nenhuma', 'Leve', 'Moderada', 'Severa'],
      defaultValue: 'Nenhuma',
    ),
    const InputField(
      key: 'correction_hours',
      label: 'Horas para Correção',
      helperText: 'Tempo desejado para corrigir déficit',
      type: InputFieldType.dropdown,
      options: ['6', '12', '24', '48'],
      defaultValue: '24',
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final weight = inputs['weight'] as double;
    final dehydrationPercentage = _parseDehydrationPercentage(inputs['dehydration_percentage'] as String);
    final ongoingLosses = (inputs['ongoing_losses'] as double?) ?? 0.0;
    final vomitingFrequency = inputs['vomiting_frequency'] as String;
    final diarrheaSeverity = inputs['diarrhea_severity'] as String;
    final correctionHours = int.parse(inputs['correction_hours'] as String);
    final maintenanceNeeds = _calculateMaintenanceNeeds(weight);
    final dehydrationDeficit = _calculateDehydrationDeficit(weight, dehydrationPercentage);
    final additionalLosses = _calculateAdditionalLosses(
      weight, vomitingFrequency, diarrheaSeverity, ongoingLosses
    );
    final maintenanceRate = maintenanceNeeds / 24; // ml/h
    final deficitRate = dehydrationDeficit / correctionHours; // ml/h
    final lossRate = additionalLosses / 24; // ml/h
    final totalRate = maintenanceRate + deficitRate + lossRate;
    final totalDaily = maintenanceNeeds + additionalLosses;
    final totalWithDeficit = totalDaily + dehydrationDeficit;

    final resultItems = [
      ResultItem(
        label: 'Necessidades de Manutenção',
        value: maintenanceNeeds.round(),
        unit: 'ml',
      ),
      ResultItem(
        label: 'Déficit de Desidratação',
        value: dehydrationDeficit.round(),
        unit: 'ml',
      ),
      ResultItem(
        label: 'Taxa de Manutenção',
        value: maintenanceRate.toStringAsFixed(1),
        unit: 'ml/h',
      ),
      ResultItem(
        label: 'Taxa Total',
        value: totalRate.toStringAsFixed(1),
        unit: 'ml/h',
      ),
      ResultItem(
        label: 'Volume Total Diário',
        value: totalDaily.round(),
        unit: 'ml/dia',
      ),
    ];

    return _FluidTherapyResult(
      calculatorId: id,
      results: resultItems,
      summary: 'Taxa total: ${totalRate.toStringAsFixed(1)} ml/h (${totalWithDeficit.round()} ml em ${correctionHours}h)',
      calculatedAt: DateTime.now(),
    );
  }

  @override
  bool validateInputs(Map<String, dynamic> inputs) {
    return getValidationErrors(inputs).isEmpty;
  }

  @override
  List<String> getValidationErrors(Map<String, dynamic> inputs) {
    final errors = <String>[];

    for (final field in inputFields) {
      if (field.isRequired && !inputs.containsKey(field.key)) {
        errors.add('${field.label} é obrigatório');
      }
    }

    if (inputs.containsKey('weight')) {
      final weight = inputs['weight'];
      if (weight is! double && weight is! int) {
        errors.add('Peso deve ser um número');
      } else {
        final weightValue = weight is int ? weight.toDouble() : weight as double;
        if (weightValue <= 0) {
          errors.add('Peso deve ser maior que zero');
        }
      }
    }

    return errors;
  }

  double _parseDehydrationPercentage(String dehydration) {
    if (dehydration.contains('0%')) return 0.0;
    if (dehydration.contains('3%')) return 3.0;
    if (dehydration.contains('5%')) return 5.0;
    if (dehydration.contains('8%')) return 8.0;
    if (dehydration.contains('10%')) return 10.0;
    if (dehydration.contains('12%')) return 12.0;
    return 0.0;
  }

  double _calculateMaintenanceNeeds(double weight) {
    return weight * 70;
  }

  double _calculateDehydrationDeficit(double weight, double dehydrationPercentage) {
    return weight * (dehydrationPercentage / 100) * 1000;
  }

  double _calculateAdditionalLosses(double weight, String vomiting, String diarrhea, double ongoingLosses) {
    double additionalLosses = ongoingLosses;
    switch (vomiting) {
      case '1-2':
        additionalLosses += weight * 5; // 5 ml/kg/dia
        break;
      case '3-5':
        additionalLosses += weight * 10; // 10 ml/kg/dia
        break;
      case '6-10':
        additionalLosses += weight * 20; // 20 ml/kg/dia
        break;
      case '>10':
        additionalLosses += weight * 30; // 30 ml/kg/dia
        break;
    }
    switch (diarrhea) {
      case 'Leve':
        additionalLosses += weight * 10; // 10 ml/kg/dia
        break;
      case 'Moderada':
        additionalLosses += weight * 20; // 20 ml/kg/dia
        break;
      case 'Severa':
        additionalLosses += weight * 40; // 40 ml/kg/dia
        break;
    }

    return additionalLosses;
  }

  List<Map<String, String>> _generateFluidRecommendations(
      double dehydrationPercentage, String vomiting, String diarrhea) {
    final recommendations = <Map<String, String>>[];

    if (dehydrationPercentage == 0.0 && vomiting == '0' && diarrhea == 'Nenhuma') {
      recommendations.add({
        'fluid': 'Solução de Ringer Lactato',
        'indication': 'Manutenção normal',
        'composition': 'Eletrólitos balanceados',
      });
    } else {
      if (dehydrationPercentage <= 5.0) {
        recommendations.add({
          'fluid': 'Solução de Ringer Lactato',
          'indication': 'Desidratação leve a moderada',
          'composition': 'Na+ 130, K+ 4, Ca++ 2.7, Cl- 109, Lactato 28 mEq/L',
        });
      } else {
        recommendations.add({
          'fluid': 'Solução Salina 0.9%',
          'indication': 'Desidratação grave - fase inicial',
          'composition': 'Na+ 154, Cl- 154 mEq/L',
        });
        recommendations.add({
          'fluid': 'Solução de Ringer Lactato',
          'indication': 'Manutenção após estabilização',
          'composition': 'Eletrólitos balanceados',
        });
      }
      if (vomiting != '0') {
        recommendations.add({
          'fluid': 'Solução Salina 0.45% + KCl',
          'indication': 'Reposição de perdas por vômito',
          'composition': 'Hipotônica com potássio (20-40 mEq/L)',
        });
      }

      if (diarrhea != 'Nenhuma') {
        recommendations.add({
          'fluid': 'Solução de Ringer + KCl',
          'indication': 'Reposição de perdas por diarreia',
          'composition': 'Eletrólitos + K+ adicional (20-40 mEq/L)',
        });
      }
    }

    return recommendations;
  }

  List<String> _getMonitoringParameters() {
    return [
      'Peso corporal (a cada 6-12h)',
      'Sinais vitais (FC, FR, temperatura)',
      'Turgor cutâneo e hidratação de mucosas',
      'Produção urinária (2-4 ml/kg/h normal)',
      'Pressão venosa central (se disponível)',
      'Eletrólitos séricos (Na+, K+, Cl-)',
      'Ureia e creatinina',
      'Hematócrito e proteínas plasmáticas',
      'Sinais de sobrecarga hídrica (edema, dispneia)',
    ];
  }
}

/// Implementação concreta do resultado da calculadora de fluidoterapia
class _FluidTherapyResult extends CalculationResult {
  const _FluidTherapyResult({
    required super.calculatorId,
    required super.results,
    super.summary,
    super.calculatedAt,
  });
}