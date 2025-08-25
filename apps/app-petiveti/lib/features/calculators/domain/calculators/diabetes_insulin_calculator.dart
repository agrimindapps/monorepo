import 'package:equatable/equatable.dart';

import '../entities/calculation_result.dart';
import '../entities/calculator.dart';
import '../entities/input_field.dart';

enum InsulinType {
  regular,
  nph,
  lente,
  ultralente,
}

enum DiabetesType {
  type1,
  type2,
  gestational,
}

class DiabetesInsulinInput extends Equatable {
  final double weight;
  final double glucoseLevel;
  final InsulinType insulinType;
  final DiabetesType diabetesType;
  final bool isFirstDose;
  final double? previousDose;
  final int? timeSinceLastDose;
  final bool isEmergency;

  const DiabetesInsulinInput({
    required this.weight,
    required this.glucoseLevel,
    required this.insulinType,
    required this.diabetesType,
    this.isFirstDose = false,
    this.previousDose,
    this.timeSinceLastDose,
    this.isEmergency = false,
  });

  @override
  List<Object?> get props => [
        weight,
        glucoseLevel,
        insulinType,
        diabetesType,
        isFirstDose,
        previousDose,
        timeSinceLastDose,
        isEmergency,
      ];
}

class DiabetesInsulinResult extends CalculationResult {
  const DiabetesInsulinResult({
    required super.calculatorId,
    required super.results,
    super.recommendations,
    super.summary,
    super.calculatedAt,
  });
}

class DiabetesInsulinCalculator extends Calculator {
  const DiabetesInsulinCalculator();

  @override
  String get id => 'diabetes_insulin';
  
  @override
  String get name => 'Calculadora de Insulina para Diabetes';
  
  @override
  String get description => 'Calcula dosagem de insulina baseada no peso, nível de glicose e tipo de diabetes';
  
  @override
  CalculatorCategory get category => CalculatorCategory.medication;
  
  @override
  String get iconName => 'medication';
  
  @override
  String get version => '1.0.0';
  
  @override
  List<InputField> get inputFields => [
    const InputField(
      key: 'weight',
      label: 'Peso do animal',
      type: InputFieldType.number,
      unit: 'kg',
      minValue: 0.1,
      maxValue: 100.0,
      isRequired: true,
      helperText: 'Peso do animal em quilogramas',
    ),
    const InputField(
      key: 'glucoseLevel',
      label: 'Nível de glicose',
      type: InputFieldType.number,
      unit: 'mg/dL',
      minValue: 20.0,
      maxValue: 1000.0,
      isRequired: true,
      helperText: 'Nível atual de glicose no sangue',
    ),
    const InputField(
      key: 'insulinType',
      label: 'Tipo de insulina',
      type: InputFieldType.dropdown,
      options: ['regular', 'nph', 'lente', 'ultralente'],
      isRequired: true,
      helperText: 'Tipo de insulina a ser administrada',
    ),
    const InputField(
      key: 'diabetesType',
      label: 'Tipo de diabetes',
      type: InputFieldType.dropdown,
      options: ['type1', 'type2', 'gestational'],
      isRequired: true,
      helperText: 'Tipo de diabetes do animal',
    ),
    const InputField(
      key: 'isFirstDose',
      label: 'É a primeira dose?',
      type: InputFieldType.switch_,
      isRequired: true,
      defaultValue: false,
    ),
    const InputField(
      key: 'previousDose',
      label: 'Dose anterior (UI)',
      type: InputFieldType.number,
      unit: 'UI',
      minValue: 0.0,
      maxValue: 100.0,
      isRequired: false,
      helperText: 'Dose anterior administrada (se aplicável)',
    ),
    const InputField(
      key: 'timeSinceLastDose',
      label: 'Horas desde última dose',
      type: InputFieldType.number,
      unit: 'horas',
      minValue: 1,
      maxValue: 48,
      isRequired: false,
      helperText: 'Tempo decorrido desde a última administração',
    ),
    const InputField(
      key: 'isEmergency',
      label: 'É uma emergência?',
      type: InputFieldType.switch_,
      isRequired: true,
      defaultValue: false,
    ),
  ];

  @override
  CalculationResult calculate(Map<String, dynamic> inputs) {
    final input = _createInputFromMap(inputs);
    return _calculateInternal(input);
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
      } else if ((weight as num) <= 0) {
        errors.add('Peso deve ser maior que zero');
      }
    }

    if (inputs.containsKey('glucoseLevel')) {
      final glucose = inputs['glucoseLevel'];
      if (glucose is! double && glucose is! int) {
        errors.add('Nível de glicose deve ser um número');
      } else if ((glucose as num) <= 0) {
        errors.add('Nível de glicose deve ser maior que zero');
      } else if (glucose > 1000) {
        errors.add('Nível de glicose muito alto (>1000 mg/dL)');
      }
    }

    return errors;
  }

  DiabetesInsulinInput _createInputFromMap(Map<String, dynamic> inputs) {
    return DiabetesInsulinInput(
      weight: (inputs['weight'] as num).toDouble(),
      glucoseLevel: (inputs['glucoseLevel'] as num).toDouble(),
      insulinType: _parseInsulinType(inputs['insulinType'] as String),
      diabetesType: _parseDiabetesType(inputs['diabetesType'] as String),
      isFirstDose: inputs['isFirstDose'] as bool? ?? false,
      previousDose: inputs['previousDose'] != null ? (inputs['previousDose'] as num).toDouble() : null,
      timeSinceLastDose: inputs['timeSinceLastDose'] != null ? (inputs['timeSinceLastDose'] as num).toInt() : null,
      isEmergency: inputs['isEmergency'] as bool? ?? false,
    );
  }

  InsulinType _parseInsulinType(String value) {
    switch (value.toLowerCase()) {
      case 'regular': return InsulinType.regular;
      case 'nph': return InsulinType.nph;
      case 'lente': return InsulinType.lente;
      case 'ultralente': return InsulinType.ultralente;
      default: return InsulinType.regular;
    }
  }

  DiabetesType _parseDiabetesType(String value) {
    switch (value.toLowerCase()) {
      case 'type1': return DiabetesType.type1;
      case 'type2': return DiabetesType.type2;
      case 'gestational': return DiabetesType.gestational;
      default: return DiabetesType.type1;
    }
  }

  static DiabetesInsulinResult _calculateInternal(DiabetesInsulinInput input) {
    _validateInput(input);

    // Calcular dose base de insulina
    final baseDose = _calculateBaseDose(input);
    
    // Ajustar dose baseada na glicemia
    final adjustedDose = _adjustDoseForGlucose(baseDose, input.glucoseLevel);
    
    // Aplicar fatores do tipo de insulina
    final finalDoseUnits = _applyInsulinTypeFactor(adjustedDose, input.insulinType);
    
    // Converter para mL (assumindo concentração padrão de 40 UI/mL)
    final doseML = finalDoseUnits / 40.0;
    
    // Determinar via de administração
    final route = _determineAdministrationRoute(input);
    
    // Calcular intervalo de monitoramento
    final monitoringInterval = _calculateMonitoringInterval(input);
    
    // Definir faixa alvo de glicose
    final targetRange = _getTargetGlucoseRange(input.diabetesType);
    
    // Gerar avisos de segurança
    final warnings = _generateWarnings(input, finalDoseUnits);
    
    // Calcular próxima dose
    final nextDoseTime = _calculateNextDoseTime(input.insulinType);
    
    // Verificar se requer supervisão veterinária
    final requiresSupervision = _requiresVeterinarySupervision(input, finalDoseUnits);

    // Criar resultados
    final results = [
      ResultItem(
        label: 'Dose de Insulina',
        value: finalDoseUnits.toStringAsFixed(2),
        unit: 'UI',
        severity: finalDoseUnits > input.weight * 1.0 ? ResultSeverity.warning : ResultSeverity.info,
      ),
      ResultItem(
        label: 'Volume',
        value: doseML.toStringAsFixed(2),
        unit: 'mL',
      ),
      ResultItem(
        label: 'Via de Administração',
        value: route,
      ),
      ResultItem(
        label: 'Próxima Dose',
        value: nextDoseTime,
      ),
    ];

    // Criar recomendações
    final recommendations = warnings.map((warning) {
      final severity = warning.contains('EMERGÊNCIA') ? ResultSeverity.danger :
                       warning.contains('URGENTE') ? ResultSeverity.warning :
                       ResultSeverity.info;
      return Recommendation(
        title: 'Aviso de Segurança',
        message: warning,
        severity: severity,
      );
    }).toList();

    return DiabetesInsulinResult(
      calculatorId: 'diabetes_insulin',
      results: results,
      recommendations: recommendations,
      summary: 'Dose de insulina: ${finalDoseUnits.toStringAsFixed(2)} UI ($route)',
      calculatedAt: DateTime.now(),
    );
  }

  static void _validateInput(DiabetesInsulinInput input) {
    if (input.weight <= 0) {
      throw ArgumentError('Peso deve ser maior que zero');
    }
    if (input.glucoseLevel <= 0) {
      throw ArgumentError('Nível de glicose deve ser maior que zero');
    }
    if (input.glucoseLevel > 1000) {
      throw ArgumentError('Nível de glicose muito alto (>1000 mg/dL)');
    }
    if (!input.isFirstDose && input.previousDose == null) {
      throw ArgumentError('Dose anterior deve ser informada se não for primeira dose');
    }
  }

  static double _calculateBaseDose(DiabetesInsulinInput input) {
    // Dose base: 0.25-0.5 UI/kg para cães, 0.25-1.0 UI/kg para gatos
    // Assumindo que é um cão (seria ideal ter a espécie como parâmetro)
    double baseDosePerKg;
    
    switch (input.diabetesType) {
      case DiabetesType.type1:
        baseDosePerKg = 0.5; // Dose mais alta para tipo 1
        break;
      case DiabetesType.type2:
        baseDosePerKg = 0.25; // Dose menor para tipo 2
        break;
      case DiabetesType.gestational:
        baseDosePerKg = 0.3; // Dose moderada para gestacional
        break;
    }
    
    if (input.isFirstDose) {
      baseDosePerKg *= 0.7; // Reduzir 30% na primeira dose por segurança
    }
    
    return input.weight * baseDosePerKg;
  }

  static double _adjustDoseForGlucose(double baseDose, double glucoseLevel) {
    if (glucoseLevel <= 110) {
      return baseDose * 0.5;
    } else if (glucoseLevel <= 250) {
      return baseDose * 0.8;
    } else if (glucoseLevel <= 400) {
      return baseDose;
    } else {
      return baseDose * 1.2;
    }
  }

  static double _applyInsulinTypeFactor(double dose, InsulinType type) {
    switch (type) {
      case InsulinType.regular:
        return dose;
      case InsulinType.nph:
        return dose * 0.9;
      case InsulinType.lente:
        return dose * 0.8;
      case InsulinType.ultralente:
        return dose * 0.7;
    }
  }

  static String _determineAdministrationRoute(DiabetesInsulinInput input) {
    if (input.isEmergency || input.glucoseLevel > 500) {
      return 'Subcutânea (emergência)';
    }
    return 'Subcutânea';
  }

  static int _calculateMonitoringInterval(DiabetesInsulinInput input) {
    if (input.isEmergency || input.isFirstDose) {
      return 2;
    } else if (input.glucoseLevel > 400) {
      return 4;
    } else {
      return 8;
    }
  }

  static double _getTargetGlucoseRange(DiabetesType type) {
    switch (type) {
      case DiabetesType.type1:
        return 150.0;
      case DiabetesType.type2:
        return 180.0;
      case DiabetesType.gestational:
        return 120.0;
    }
  }

  static List<String> _generateWarnings(DiabetesInsulinInput input, double finalDose) {
    final warnings = <String>[];
    
    if (input.isFirstDose) {
      warnings.add('⚠️ PRIMEIRA DOSE: Monitorar glicemia a cada 2 horas');
    }
    
    if (input.glucoseLevel > 500) {
      warnings.add('🚨 EMERGÊNCIA: Glicemia muito alta, considerar hospitalização');
    }
    
    if (input.glucoseLevel < 80) {
      warnings.add('⚠️ HIPOGLICEMIA: Não administrar insulina, tratar hipoglicemia primeiro');
    }
    
    if (finalDose > input.weight * 1.0) {
      warnings.add('⚠️ DOSE ALTA: Dose superior a 1 UI/kg, revisar cálculo');
    }
    
    if (input.timeSinceLastDose != null && input.timeSinceLastDose! < 6) {
      warnings.add('⚠️ INTERVALO CURTO: Menos de 6h desde última dose');
    }
    
    warnings.add('📋 SEMPRE confirmar dose com veterinário antes da administração');
    
    return warnings;
  }

  static String _calculateNextDoseTime(InsulinType type) {
    final now = DateTime.now();
    int hoursToAdd;
    
    switch (type) {
      case InsulinType.regular:
        hoursToAdd = 8;
        break;
      case InsulinType.nph:
        hoursToAdd = 12;
        break;
      case InsulinType.lente:
        hoursToAdd = 12;
        break;
      case InsulinType.ultralente:
        hoursToAdd = 24;
        break;
    }
    
    final nextDose = now.add(Duration(hours: hoursToAdd));
    return '${nextDose.hour.toString().padLeft(2, '0')}:${nextDose.minute.toString().padLeft(2, '0')}';
  }

  static bool _requiresVeterinarySupervision(DiabetesInsulinInput input, double finalDose) {
    return input.isFirstDose || 
           input.isEmergency || 
           input.glucoseLevel > 500 || 
           input.glucoseLevel < 80 ||
           finalDose > input.weight * 0.8;
  }

}