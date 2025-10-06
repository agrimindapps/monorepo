import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart';

/// Calculadora de Anestesia
/// Calcula dosagens de anestésicos baseada no peso e protocolo
class AnesthesiaCalculator extends Calculator {
  const AnesthesiaCalculator();

  @override
  String get id => 'anesthesia';

  @override
  String get name => 'Dosagem de Anestésicos';

  @override
  String get description => 
      'Calcula dosagens de medicamentos anestésicos para procedimentos '
      'veterinários baseado no peso e protocolo selecionado.';

  @override
  CalculatorCategory get category => CalculatorCategory.medication;

  @override
  String get iconName => 'local_hospital';

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
      key: 'species',
      label: 'Espécie',
      helperText: 'Tipo de animal',
      type: InputFieldType.dropdown,
      options: ['Cão', 'Gato'],
      isRequired: true,
    ),
    const InputField(
      key: 'procedure_type',
      label: 'Tipo de Procedimento',
      helperText: 'Duração e complexidade do procedimento',
      type: InputFieldType.dropdown,
      options: [
        'Sedação leve (exames)',
        'Sedação moderada (curativos)',
        'Anestesia curta (< 30min)',
        'Anestesia média (30-60min)',
        'Anestesia longa (> 60min)',
      ],
      isRequired: true,
    ),
    const InputField(
      key: 'age_group',
      label: 'Faixa Etária',
      helperText: 'Idade do animal',
      type: InputFieldType.dropdown,
      options: [
        'Filhote (< 6 meses)',
        'Jovem (6 meses - 2 anos)',
        'Adulto (2-8 anos)',
        'Senior (> 8 anos)',
      ],
      isRequired: true,
    ),
    const InputField(
      key: 'health_status',
      label: 'Estado de Saúde',
      helperText: 'Condição clínica geral',
      type: InputFieldType.dropdown,
      options: [
        'Saudável (ASA I)',
        'Doença leve (ASA II)',
        'Doença grave (ASA III)',
        'Risco de vida (ASA IV)',
      ],
      isRequired: true,
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final weight = inputs['weight'] as double;
    final species = inputs['species'] as String;
    final procedureType = inputs['procedure_type'] as String;
    final ageGroup = inputs['age_group'] as String;
    final healthStatus = inputs['health_status'] as String;
    final protocol = _selectProtocol(species, procedureType, ageGroup, healthStatus);
    final medications = <Map<String, dynamic>>[];
    
    for (final med in protocol['medications'] as List<Map<String, dynamic>>) {
      final dosagePerKg = med['dosage'] as double;
      final totalDose = weight * dosagePerKg;
      
      medications.add({
        'name': med['name'],
        'dosage_per_kg': dosagePerKg,
        'total_dose': totalDose,
        'unit': med['unit'],
        'route': med['route'],
        'timing': med['timing'],
        'notes': med['notes'],
      });
    }
    final resultItems = <ResultItem>[];
    for (final med in medications) {
      resultItems.add(ResultItem(
        label: med['name'] as String,
        value: '${med['total_dose'].toStringAsFixed(2)} ${med['unit']}',
        description: '${med['route']} - ${med['timing']}',
      ));
    }
    final recommendations = [
      ...(protocol['monitoring'] as List<String>).map((monitor) => Recommendation(
        title: 'Monitoramento',
        message: monitor,
      )),
      ...(protocol['warnings'] as List<String>).map((warning) => Recommendation(
        title: 'Aviso',
        message: warning,
        severity: ResultSeverity.warning,
      )),
    ];

    return _AnesthesiaResult(
      calculatorId: id,
      results: resultItems,
      recommendations: recommendations,
      summary: 'Protocolo: ${protocol['name']} - ${medications.length} medicamentos',
      calculatedAt: DateTime.now(),
      protocolName: protocol['name'] as String,
      medications: medications,
      monitoring: protocol['monitoring'] as List<String>,
      warnings: protocol['warnings'] as List<String>,
      duration: protocol['duration'] as String,
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

  Map<String, dynamic> _selectProtocol(String species, String procedureType, 
                                      String ageGroup, String healthStatus) {
    
    if (procedureType.contains('Sedação leve')) {
      return _getLightSedationProtocol(species, ageGroup, healthStatus);
    } else if (procedureType.contains('Sedação moderada')) {
      return _getModerateSedationProtocol(species, ageGroup, healthStatus);
    } else if (procedureType.contains('curta')) {
      return _getShortAnesthesiaProtocol(species, ageGroup, healthStatus);
    } else if (procedureType.contains('média')) {
      return _getMediumAnesthesiaProtocol(species, ageGroup, healthStatus);
    } else {
      return _getLongAnesthesiaProtocol(species, ageGroup, healthStatus);
    }
  }

  Map<String, dynamic> _getLightSedationProtocol(String species, String ageGroup, String healthStatus) {
    final isHighRisk = healthStatus.contains('ASA III') || healthStatus.contains('ASA IV');
    final dosageReduction = isHighRisk ? 0.7 : 1.0;

    return {
      'name': 'Sedação Leve',
      'duration': '15-30 minutos',
      'medications': [
        {
          'name': 'Acepromazina',
          'dosage': (species == 'Cão' ? 0.02 : 0.01) * dosageReduction,
          'unit': 'mg/kg',
          'route': 'IM',
          'timing': '15-20 min antes',
          'notes': 'Efeito prolongado em gatos',
        },
        {
          'name': 'Butorfanol',
          'dosage': (species == 'Cão' ? 0.2 : 0.1) * dosageReduction,
          'unit': 'mg/kg',
          'route': 'IM',
          'timing': '15-20 min antes',
          'notes': 'Analgesia leve a moderada',
        },
      ],
      'monitoring': [
        'Frequência cardíaca e respiratória a cada 5 min',
        'Temperatura corporal',
        'Reflexos e resposta a estímulos',
      ],
      'warnings': isHighRisk 
          ? ['Paciente de alto risco - monitoramento intensivo necessário']
          : ['Monitoramento básico adequado'],
    };
  }

  Map<String, dynamic> _getModerateSedationProtocol(String species, String ageGroup, String healthStatus) {
    final isHighRisk = healthStatus.contains('ASA III') || healthStatus.contains('ASA IV');
    final dosageReduction = isHighRisk ? 0.8 : 1.0;

    return {
      'name': 'Sedação Moderada',
      'duration': '30-45 minutos',
      'medications': [
        {
          'name': 'Midazolam',
          'dosage': (species == 'Cão' ? 0.2 : 0.2) * dosageReduction,
          'unit': 'mg/kg',
          'route': 'IM',
          'timing': 'Pré-medicação',
          'notes': 'Ansiolítico e relaxante muscular',
        },
        {
          'name': 'Medetomidina',
          'dosage': (species == 'Cão' ? 0.01 : 0.05) * dosageReduction,
          'unit': 'mg/kg',
          'route': 'IM',
          'timing': 'Pré-medicação',
          'notes': 'Sedação profunda, reversível com atipamezole',
        },
      ],
      'monitoring': [
        'Oximetria de pulso contínua',
        'Frequência cardíaca e respiratória a cada 5 min',
        'Pressão arterial',
        'Temperatura corporal',
      ],
      'warnings': [
        'Ter atipamezole disponível para reversão',
        'Monitorar hipotermia',
      ],
    };
  }

  Map<String, dynamic> _getShortAnesthesiaProtocol(String species, String ageGroup, String healthStatus) {
    final isHighRisk = healthStatus.contains('ASA III') || healthStatus.contains('ASA IV');
    final dosageReduction = isHighRisk ? 0.8 : 1.0;

    return {
      'name': 'Anestesia Curta',
      'duration': '15-30 minutos',
      'medications': [
        {
          'name': 'Propofol',
          'dosage': (species == 'Cão' ? 4.0 : 6.0) * dosageReduction,
          'unit': 'mg/kg',
          'route': 'IV lenta',
          'timing': 'Indução',
          'notes': 'Administrar lentamente até efeito',
        },
        {
          'name': 'Isoflurano',
          'dosage': species == 'Cão' ? 1.5 : 2.0,
          'unit': '%',
          'route': 'Inalatória',
          'timing': 'Manutenção',
          'notes': 'Ajustar conforme profundidade anestésica',
        },
      ],
      'monitoring': [
        'Capnografia contínua',
        'Oximetria de pulso contínua',
        'ECG contínuo',
        'Pressão arterial a cada 5 min',
        'Temperatura corporal',
        'Reflexos palpebral e pedal',
      ],
      'warnings': [
        'Ventilação assistida pode ser necessária',
        'Aquecimento ativo durante procedimento',
      ],
    };
  }

  Map<String, dynamic> _getMediumAnesthesiaProtocol(String species, String ageGroup, String healthStatus) {
    return _getShortAnesthesiaProtocol(species, ageGroup, healthStatus)
      ..['name'] = 'Anestesia Média'
      ..['duration'] = '30-60 minutos';
  }

  Map<String, dynamic> _getLongAnesthesiaProtocol(String species, String ageGroup, String healthStatus) {
    final baseProtocol = _getShortAnesthesiaProtocol(species, ageGroup, healthStatus);
    
    return baseProtocol
      ..['name'] = 'Anestesia Longa'
      ..['duration'] = '> 60 minutos'
      ..['warnings'] = [
        'Fluidoterapia obrigatória',
        'Aquecimento ativo essencial',
        'Monitoramento intensivo necessário',
        'Considerar ventilação mecânica',
      ];
  }
}

class _AnesthesiaResult extends CalculationResult {
  final String protocolName;
  final List<Map<String, dynamic>> medications;
  final List<String> monitoring;
  final List<String> warnings;
  final String duration;

  const _AnesthesiaResult({
    required this.protocolName,
    required this.medications,
    required this.monitoring,
    required this.warnings,
    required this.duration,
    required super.calculatorId,
    required super.results,
    super.recommendations = const [],
    super.summary,
    super.calculatedAt,
  });

  @override
  List<Object?> get props => [
        protocolName,
        medications,
        monitoring,
        warnings,
        duration,
        ...super.props,
      ];
}
