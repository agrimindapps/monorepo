import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart' as input;

/// Resultado da calculadora de gestação e parto
class PregnancyBirthResult extends CalculationResult {
  const PregnancyBirthResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}

/// Calculadora de Gestação e Parto
/// Calcula data de parto e fases de gestação baseado em diferentes métodos
class PregnancyBirthCalculator extends Calculator {
  const PregnancyBirthCalculator();

  @override
  String get id => 'pregnancy_birth';

  @override
  String get name => 'Gestação e Parto';

  @override
  String get description => 
      'Calcula data estimada de parto e fases da gestação baseado na data de '
      'acasalamento ou resultados de ultrassom, com informações específicas por espécie.';

  @override
  CalculatorCategory get category => CalculatorCategory.health;

  @override
  String get iconName => 'pregnant_woman';

  @override
  String get version => '1.0.0';

  @override
  List<input.InputField> get inputFields => [
    const input.InputField(
      key: 'species',
      label: 'Espécie',
      type: input.InputFieldType.dropdown,
      options: ['Cão', 'Gato', 'Coelho', 'Hamster'],
      isRequired: true,
      helperText: 'Espécie do animal',
    ),
    const input.InputField(
      key: 'breed',
      label: 'Raça',
      type: input.InputFieldType.dropdown,
      options: [
        'Sem raça definida',
        'Chihuahua',
        'Yorkshire',
        'Bulldog',
        'São Bernardo',
        'Pastor Alemão',
        'Labrador',
        'Poodle',
        'Rottweiler',
        'Siamês',
        'Persa',
        'Maine Coon',
        'Ragdoll',
        'Outras raças',
      ],
      isRequired: true,
      helperText: 'Raça do animal (afeta duração da gestação)',
    ),
    const input.InputField(
      key: 'calculation_method',
      label: 'Método de Cálculo',
      type: input.InputFieldType.dropdown,
      options: [
        'Data de acasalamento',
        'Ultrassom (cães e gatos)',
      ],
      isRequired: true,
      helperText: 'Método para calcular a data de parto',
    ),
    const input.InputField(
      key: 'mating_date',
      label: 'Data do Acasalamento',
      type: input.InputFieldType.text,
      isRequired: false,
      helperText: 'Data do acasalamento (formato: dd/mm/aaaa)',
    ),
    const input.InputField(
      key: 'ultrasound_date',
      label: 'Data do Ultrassom',
      type: input.InputFieldType.text,
      isRequired: false,
      helperText: 'Data do ultrassom (formato: dd/mm/aaaa)',
    ),
    const input.InputField(
      key: 'fetus_size',
      label: 'Tamanho do Feto',
      type: input.InputFieldType.number,
      unit: 'mm',
      isRequired: false,
      minValue: 5.0,
      maxValue: 100.0,
      helperText: 'Tamanho do feto em milímetros (para ultrassom)',
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final species = inputs['species'] as String;
    final breed = inputs['breed'] as String;
    final calculationMethod = inputs['calculation_method'] as String;

    DateTime? referenceDate;
    DateTime? birthDate;
    String method = '';

    if (calculationMethod.contains('acasalamento') && inputs['mating_date'] != null) {
      referenceDate = _parseDate(inputs['mating_date'] as String);
      if (referenceDate != null) {
        method = 'acasalamento';
        birthDate = _calculateBirthDateFromMating(referenceDate, species, breed);
      }
    } else if (calculationMethod.contains('Ultrassom') && 
               inputs['ultrasound_date'] != null && 
               inputs['fetus_size'] != null) {
      referenceDate = _parseDate(inputs['ultrasound_date'] as String);
      final fetusSize = inputs['fetus_size'] as double;
      if (referenceDate != null) {
        method = 'ultrassom';
        birthDate = _calculateBirthDateFromUltrasound(referenceDate, fetusSize, species);
      }
    }

    if (birthDate == null) {
      throw ArgumentError('Não foi possível calcular a data de parto com os dados fornecidos');
    }

    final today = DateTime.now();
    final daysToDelivery = birthDate.difference(today).inDays;
    final gestationDay = _calculateGestationDay(referenceDate!, today, method, species);
    final currentPhase = _getCurrentGestationPhase(gestationDay, species);
    final allPhases = _getGestationPhases(species);

    final results = [
      ResultItem(
        label: 'Data Estimada de Parto',
        value: _formatDate(birthDate),
        severity: ResultSeverity.success,
      ),
      ResultItem(
        label: 'Dias até o Parto',
        value: daysToDelivery,
        unit: 'dias',
        severity: _getDeliveryUrgencySeverity(daysToDelivery),
        description: daysToDelivery <= 7 ? 'Parto iminente' : null,
      ),
      ResultItem(
        label: 'Dia da Gestação',
        value: gestationDay,
        unit: 'dias',
        severity: ResultSeverity.info,
      ),
      ResultItem(
        label: 'Fase Atual da Gestação',
        value: currentPhase['name']?.toString(),
        severity: ResultSeverity.info,
        description: currentPhase['description']?.toString(),
      ),
    ];

    final recommendations = _generateRecommendations(daysToDelivery, gestationDay, species);
    
    // Adicionar informações sobre todas as fases
    for (final phase in allPhases) {
      recommendations.add(
        Recommendation(
          title: 'Fase ${phase['name']} (${phase['start']}-${phase['end']} dias)',
          message: phase['description']?.toString() ?? '',
          severity: ResultSeverity.info,
        ),
      );
    }

    return PregnancyBirthResult(
      calculatorId: id,
      results: results,
      recommendations: recommendations,
      summary: 'Parto estimado: ${_formatDate(birthDate)} | '
               'Dias restantes: $daysToDelivery | '
               'Fase: ${currentPhase['name']}',
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

    // Validar campos obrigatórios básicos
    if (!inputs.containsKey('species') || inputs['species'] == null) {
      errors.add('Espécie é obrigatória');
    }

    if (!inputs.containsKey('calculation_method') || inputs['calculation_method'] == null) {
      errors.add('Método de cálculo é obrigatório');
    }

    final calculationMethod = inputs['calculation_method'] as String?;

    // Validar campos específicos do método
    if (calculationMethod?.contains('acasalamento') == true) {
      if (!inputs.containsKey('mating_date') || inputs['mating_date'] == null || (inputs['mating_date'] as String).isEmpty) {
        errors.add('Data de acasalamento é obrigatória para este método');
      } else {
        final date = _parseDate(inputs['mating_date'] as String);
        if (date == null) {
          errors.add('Data de acasalamento deve estar no formato dd/mm/aaaa');
        }
      }
    } else if (calculationMethod?.contains('Ultrassom') == true) {
      if (!inputs.containsKey('ultrasound_date') || inputs['ultrasound_date'] == null || (inputs['ultrasound_date'] as String).isEmpty) {
        errors.add('Data do ultrassom é obrigatória para este método');
      } else {
        final date = _parseDate(inputs['ultrasound_date'] as String);
        if (date == null) {
          errors.add('Data do ultrassom deve estar no formato dd/mm/aaaa');
        }
      }

      if (!inputs.containsKey('fetus_size') || inputs['fetus_size'] == null) {
        errors.add('Tamanho do feto é obrigatório para ultrassom');
      }
    }

    return errors;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  DateTime _calculateBirthDateFromMating(DateTime matingDate, String species, String breed) {
    // Duração média da gestação por espécie
    final gestationDays = {
      'Cão': 63,
      'Gato': 65,
      'Coelho': 31,
      'Hamster': 18,
    };

    // Ajustes por raça
    final breedAdjustments = {
      'Cão': {
        'Chihuahua': -2,
        'Yorkshire': -1,
        'Bulldog': 1,
        'São Bernardo': 3,
        'Pastor Alemão': 0,
        'Labrador': 0,
        'Poodle': -1,
        'Rottweiler': 1,
      },
      'Gato': {
        'Siamês': -1,
        'Persa': 2,
        'Maine Coon': 1,
        'Ragdoll': 1,
      },
    };

    int days = gestationDays[species] ?? 63;
    final adjustment = breedAdjustments[species]?[breed] ?? 0;
    days += adjustment;

    return matingDate.add(Duration(days: days));
  }

  DateTime _calculateBirthDateFromUltrasound(DateTime ultrasoundDate, double fetusSize, String species) {
    // Estimativa de idade gestacional baseada no tamanho do feto (para cães)
    final sizeToAge = [
      {'size': 10, 'days': 30},
      {'size': 15, 'days': 35},
      {'size': 20, 'days': 40},
      {'size': 30, 'days': 45},
      {'size': 45, 'days': 50},
      {'size': 60, 'days': 55},
      {'size': 90, 'days': 60},
    ];

    int estimatedGestationDay = 30; // padrão
    for (final entry in sizeToAge) {
      if (fetusSize <= entry['size']!) {
        estimatedGestationDay = entry['days']!;
        break;
      }
    }

    final totalGestationDays = species == 'Cão' ? 63 : 65;
    final remainingDays = totalGestationDays - estimatedGestationDay;

    return ultrasoundDate.add(Duration(days: remainingDays));
  }

  int _calculateGestationDay(DateTime referenceDate, DateTime currentDate, String method, String species) {
    if (method == 'acasalamento') {
      return currentDate.difference(referenceDate).inDays;
    } else {
      // Para ultrassom, precisaríamos calcular baseado no tamanho do feto
      // Por simplicidade, assumimos que é o dia do ultrassom
      return currentDate.difference(referenceDate).inDays + 30; // estimativa
    }
  }

  Map<String, dynamic> _getCurrentGestationPhase(int gestationDay, String species) {
    final phases = _getGestationPhases(species);
    
    for (final phase in phases) {
      if (gestationDay >= (phase['start'] as num) && gestationDay <= (phase['end'] as num)) {
        return phase;
      }
    }

    return {
      'name': 'Pós-termo',
      'description': 'Gestação pode estar prolongada. Consulte veterinário.',
      'start': gestationDay,
      'end': gestationDay,
    };
  }

  List<Map<String, dynamic>> _getGestationPhases(String species) {
    final phases = {
      'Cão': [
        {
          'name': 'Primeira Fase',
          'start': 0,
          'end': 21,
          'description': 'Fertilização e implantação dos embriões. Fetos não visíveis em ultrassom.',
        },
        {
          'name': 'Segunda Fase',
          'start': 22,
          'end': 42,
          'description': 'Desenvolvimento fetal inicial. Fetos visíveis em ultrassom. Batimentos cardíacos detectáveis.',
        },
        {
          'name': 'Terceira Fase',
          'start': 43,
          'end': 58,
          'description': 'Desenvolvimento fetal avançado. Mamas aumentam, ganho de peso visível.',
        },
        {
          'name': 'Quarta Fase',
          'start': 59,
          'end': 63,
          'description': 'Preparação para o parto. Temperatura corporal cai 24h antes do parto.',
        },
      ],
      'Gato': [
        {
          'name': 'Primeira Fase',
          'start': 0,
          'end': 15,
          'description': 'Fertilização e implantação. Não há sinais externos visíveis.',
        },
        {
          'name': 'Segunda Fase',
          'start': 16,
          'end': 35,
          'description': 'Desenvolvimento embrionário. Mamilos mais rosados. Fetos visíveis em ultrassom após dia 20.',
        },
        {
          'name': 'Terceira Fase',
          'start': 36,
          'end': 57,
          'description': 'Desenvolvimento fetal. Abdômen inchado, movimentos fetais palpáveis.',
        },
        {
          'name': 'Quarta Fase',
          'start': 58,
          'end': 65,
          'description': 'Pré-parto. Gata procura local para parto, produção de leite começa.',
        },
      ],
    };

    return phases[species] ?? phases['Cão']!;
  }

  ResultSeverity _getDeliveryUrgencySeverity(int daysToDelivery) {
    if (daysToDelivery <= 3) return ResultSeverity.danger;
    if (daysToDelivery <= 7) return ResultSeverity.warning;
    return ResultSeverity.info;
  }

  List<Recommendation> _generateRecommendations(int daysToDelivery, int gestationDay, String species) {
    final recommendations = <Recommendation>[];

    if (daysToDelivery <= 7) {
      recommendations.addAll([
        const Recommendation(
          title: 'Preparação para o Parto',
          message: 'Prepare um local tranquilo e limpo para o parto',
          severity: ResultSeverity.warning,
        ),
        const Recommendation(
          title: 'Monitoramento',
          message: 'Monitore a temperatura corporal diariamente - queda indica parto iminente',
          severity: ResultSeverity.warning,
        ),
        const Recommendation(
          title: 'Veterinário',
          message: 'Tenha contato do veterinário disponível 24h',
          severity: ResultSeverity.danger,
        ),
      ]);
    } else if (daysToDelivery <= 14) {
      recommendations.addAll([
        const Recommendation(
          title: 'Preparação',
          message: 'Comece a preparar o ambiente para o parto',
          severity: ResultSeverity.info,
        ),
        const Recommendation(
          title: 'Nutrição',
          message: 'Aumente gradualmente a quantidade de ração de alta qualidade',
          severity: ResultSeverity.info,
        ),
      ]);
    }

    // Recomendações gerais baseadas na fase da gestação
    if (gestationDay >= 45) {
      recommendations.add(
        const Recommendation(
          title: 'Exercícios',
          message: 'Reduza exercícios intensos, prefira caminhadas curtas',
          severity: ResultSeverity.info,
        ),
      );
    }

    if (gestationDay >= 35) {
      recommendations.add(
        const Recommendation(
          title: 'Alimentação',
          message: 'Aumente a frequência das refeições para 3-4 vezes ao dia',
          severity: ResultSeverity.info,
        ),
      );
    }

    return recommendations;
  }
}