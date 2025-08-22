import '../entities/calculation_result.dart';
import 'package:equatable/equatable.dart';

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
    required String calculatorId,
    required List<ResultItem> results,
    List<Recommendation> recommendations = const [],
    String? summary,
    DateTime? calculatedAt,
  }) : super(
          calculatorId: calculatorId,
          results: results,
          recommendations: recommendations,
          summary: summary,
          calculatedAt: calculatedAt,
        );
}

class DiabetesInsulinCalculator {
  static const String id = 'diabetes_insulin';
  static const String name = 'Calculadora de Insulina para Diabetes';
  static const String description = 'Calcula dosagem de insulina baseada no peso, nível de glicose e tipo de diabetes';

  static DiabetesInsulinResult calculate(DiabetesInsulinInput input) {
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
      calculatorId: id,
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

  static Map<String, dynamic> getInputParameters() {
    return {
      'weight': {
        'type': 'double',
        'label': 'Peso do animal (kg)',
        'min': 0.1,
        'max': 100.0,
        'step': 0.1,
        'required': true,
      },
      'glucoseLevel': {
        'type': 'double',
        'label': 'Nível de glicose (mg/dL)',
        'min': 20.0,
        'max': 1000.0,
        'step': 1.0,
        'required': true,
      },
      'insulinType': {
        'type': 'enum',
        'label': 'Tipo de insulina',
        'options': InsulinType.values,
        'required': true,
      },
      'diabetesType': {
        'type': 'enum',
        'label': 'Tipo de diabetes',
        'options': DiabetesType.values,
        'required': true,
      },
      'isFirstDose': {
        'type': 'bool',
        'label': 'É a primeira dose?',
        'required': true,
      },
      'previousDose': {
        'type': 'double',
        'label': 'Dose anterior (UI)',
        'min': 0.0,
        'max': 100.0,
        'step': 0.1,
        'required': false,
      },
      'timeSinceLastDose': {
        'type': 'int',
        'label': 'Horas desde última dose',
        'min': 1,
        'max': 48,
        'step': 1,
        'required': false,
      },
      'isEmergency': {
        'type': 'bool',
        'label': 'É uma emergência?',
        'required': true,
      },
    };
  }
}