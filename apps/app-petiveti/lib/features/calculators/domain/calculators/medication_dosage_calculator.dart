import '../entities/calculator.dart';
import '../entities/calculation_result.dart';
import '../entities/input_field.dart';

/// Calculadora de Dosagem de Medicamentos
/// Calcula doses precisas baseadas no peso e tipo de medicamento
class MedicationDosageCalculator extends Calculator {
  const MedicationDosageCalculator();

  @override
  String get id => 'medication_dosage';

  @override
  String get name => 'Dosagem de Medicamentos';

  @override
  String get description => 
      'Calcula a dosagem correta de medicamentos baseada no peso do animal '
      'e protocolo veterinário estabelecido.';

  @override
  CalculatorCategory get category => CalculatorCategory.medication;

  @override
  String get iconName => 'medication';

  @override
  String get version => '1.0.0';

  @override
  List<InputField> get inputFields => [
    const InputField(
      id: 'weight',
      label: 'Peso do Animal',
      description: 'Peso atual do animal em quilogramas',
      type: InputFieldType.number,
      unit: 'kg',
      isRequired: true,
      minValue: 0.1,
      maxValue: 100.0,
    ),
    const InputField(
      id: 'medication',
      label: 'Medicamento',
      description: 'Selecione o medicamento',
      type: InputFieldType.dropdown,
      options: [
        'Amoxicilina',
        'Cefalexina',
        'Doxiciclina',
        'Enrofloxacina',
        'Metronidazol',
        'Prednisolona',
        'Meloxicam',
        'Tramadol',
        'Furosemida',
        'Omeprazol',
      ],
      isRequired: true,
    ),
    const InputField(
      id: 'species',
      label: 'Espécie',
      description: 'Tipo de animal',
      type: InputFieldType.dropdown,
      options: ['Cão', 'Gato'],
      isRequired: true,
    ),
    const InputField(
      id: 'frequency',
      label: 'Frequência',
      description: 'Quantas vezes ao dia',
      type: InputFieldType.dropdown,
      options: ['1x/dia', '2x/dia', '3x/dia', '4x/dia'],
      isRequired: true,
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    if (!validateInputs(inputs)) {
      throw ArgumentError('Inputs inválidos para cálculo');
    }

    final weight = inputs['weight'] as double;
    final medication = inputs['medication'] as String;
    final species = inputs['species'] as String;
    final frequency = inputs['frequency'] as String;

    final dosageInfo = _getMedicationDosage(medication, species);
    final dosagePerKg = dosageInfo['dosage'] as double;
    final unit = dosageInfo['unit'] as String;
    final warnings = dosageInfo['warnings'] as List<String>;

    // Calcular dose total
    final totalDose = weight * dosagePerKg;
    
    // Calcular dose por administração
    final frequencyNumber = _getFrequencyNumber(frequency);
    final dosePerAdministration = totalDose / frequencyNumber;

    final results = {
      'total_daily_dose': totalDose,
      'dose_per_administration': dosePerAdministration,
      'unit': unit,
      'frequency': frequency,
      'frequency_number': frequencyNumber,
      'warnings': warnings,
    };

    return CalculationResult(
      calculatorId: id,
      timestamp: DateTime.now(),
      inputs: inputs,
      results: results,
      summary: 'Dose: ${dosePerAdministration.toStringAsFixed(1)} $unit por administração ($frequency)',
    );
  }

  @override
  bool validateInputs(Map<String, dynamic> inputs) {
    return getValidationErrors(inputs).isEmpty;
  }

  @override
  List<String> getValidationErrors(Map<String, dynamic> inputs) {
    final errors = <String>[];

    // Validar campos obrigatórios
    for (final field in inputFields) {
      if (field.isRequired && !inputs.containsKey(field.id)) {
        errors.add('${field.label} é obrigatório');
      }
    }

    // Validar peso
    if (inputs.containsKey('weight')) {
      final weight = inputs['weight'];
      if (weight is! double && weight is! int) {
        errors.add('Peso deve ser um número');
      } else {
        final weightValue = weight is int ? weight.toDouble() : weight as double;
        if (weightValue <= 0) {
          errors.add('Peso deve ser maior que zero');
        }
        if (weightValue > 100) {
          errors.add('Peso muito alto - verifique o valor');
        }
      }
    }

    return errors;
  }

  Map<String, dynamic> _getMedicationDosage(String medication, String species) {
    // Base de dados simplificada de dosagens
    // Em produção, isso viria de uma base de dados veterinária
    final dosages = {
      'Amoxicilina': {
        'Cão': {'dosage': 20.0, 'unit': 'mg', 'warnings': ['Administrar com alimento']},
        'Gato': {'dosage': 15.0, 'unit': 'mg', 'warnings': ['Administrar com alimento', 'Monitorar função renal']},
      },
      'Cefalexina': {
        'Cão': {'dosage': 25.0, 'unit': 'mg', 'warnings': ['Completar todo o tratamento']},
        'Gato': {'dosage': 20.0, 'unit': 'mg', 'warnings': ['Completar todo o tratamento', 'Pode causar diarreia']},
      },
      'Doxiciclina': {
        'Cão': {'dosage': 5.0, 'unit': 'mg', 'warnings': ['Não administrar com laticínios']},
        'Gato': {'dosage': 5.0, 'unit': 'mg', 'warnings': ['Não administrar com laticínios', 'Pode causar esofagite']},
      },
      'Enrofloxacina': {
        'Cão': {'dosage': 5.0, 'unit': 'mg', 'warnings': ['Evitar em filhotes em crescimento']},
        'Gato': {'dosage': 2.5, 'unit': 'mg', 'warnings': ['Evitar em filhotes', 'Pode causar cegueira em gatos']},
      },
      'Metronidazol': {
        'Cão': {'dosage': 15.0, 'unit': 'mg', 'warnings': ['Pode causar náusea']},
        'Gato': {'dosage': 10.0, 'unit': 'mg', 'warnings': ['Pode causar náusea', 'Uso com cautela']},
      },
      'Prednisolona': {
        'Cão': {'dosage': 1.0, 'unit': 'mg', 'warnings': ['Administrar com alimento', 'Reduzir gradualmente']},
        'Gato': {'dosage': 1.0, 'unit': 'mg', 'warnings': ['Administrar com alimento', 'Monitorar diabetes']},
      },
      'Meloxicam': {
        'Cão': {'dosage': 0.1, 'unit': 'mg', 'warnings': ['Administrar com alimento', 'Monitorar função renal']},
        'Gato': {'dosage': 0.05, 'unit': 'mg', 'warnings': ['Uso limitado em gatos', 'Apenas primeira dose']},
      },
      'Tramadol': {
        'Cão': {'dosage': 3.0, 'unit': 'mg', 'warnings': ['Pode causar sedação']},
        'Gato': {'dosage': 2.0, 'unit': 'mg', 'warnings': ['Pode causar sedação', 'Metabolismo diferente']},
      },
      'Furosemida': {
        'Cão': {'dosage': 2.0, 'unit': 'mg', 'warnings': ['Monitorar eletrólitos', 'Aumentar ingestão de água']},
        'Gato': {'dosage': 1.0, 'unit': 'mg', 'warnings': ['Monitorar eletrólitos', 'Risco de desidratação']},
      },
      'Omeprazol': {
        'Cão': {'dosage': 1.0, 'unit': 'mg', 'warnings': ['Administrar em jejum']},
        'Gato': {'dosage': 0.7, 'unit': 'mg', 'warnings': ['Administrar em jejum', 'Uso off-label']},
      },
    };

    return dosages[medication]?[species] ?? 
           {'dosage': 0.0, 'unit': 'mg', 'warnings': ['Medicamento não encontrado']};
  }

  int _getFrequencyNumber(String frequency) {
    switch (frequency) {
      case '1x/dia': return 1;
      case '2x/dia': return 2;
      case '3x/dia': return 3;
      case '4x/dia': return 4;
      default: return 1;
    }
  }
}