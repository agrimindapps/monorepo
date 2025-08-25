import 'package:equatable/equatable.dart';
import 'calculation_result.dart';

/// Nível de alerta para dosagem
enum AlertLevel {
  safe('Seguro', 'green'),
  caution('Atenção', 'yellow'),
  warning('Alerta', 'orange'),
  danger('Perigo', 'red');

  const AlertLevel(this.displayName, this.color);
  final String displayName;
  final String color;
}

/// Tipo de alerta de segurança
enum AlertType {
  dosageRange('Faixa de Dosagem'),
  ageContraindication('Contraindicação por Idade'),
  speciesContraindication('Contraindicação por Espécie'),
  conditionContraindication('Contraindicação por Condição'),
  overdose('Possível Overdose'),
  underdose('Possível Subdosagem'),
  toxicity('Risco de Toxicidade'),
  interaction('Interação Medicamentosa'),
  monitoring('Monitoramento Necessário');

  const AlertType(this.displayName);
  final String displayName;
}

/// Alerta de segurança
class SafetyAlert extends Equatable {
  final AlertType type;
  final AlertLevel level;
  final String message;
  final String? recommendation;
  final bool isBlocking; // Impede administração

  const SafetyAlert({
    required this.type,
    required this.level,
    required this.message,
    this.recommendation,
    this.isBlocking = false,
  });

  @override
  List<Object?> get props => [type, level, message, recommendation, isBlocking];
}

/// Informações de monitoramento pós-administração
class MonitoringInfo extends Equatable {
  final List<String> parametersToMonitor;
  final String frequency;
  final String duration;
  final List<String> warningSignsToWatch;
  final String? emergencyProtocol;

  const MonitoringInfo({
    required this.parametersToMonitor,
    required this.frequency,
    required this.duration,
    required this.warningSignsToWatch,
    this.emergencyProtocol,
  });

  @override
  List<Object?> get props => [
        parametersToMonitor,
        frequency,
        duration,
        warningSignsToWatch,
        emergencyProtocol,
      ];
}

/// Instruções de administração
class AdministrationInstructions extends Equatable {
  final String route; // Via de administração
  final String timing; // Timing (com/sem alimento, etc.)
  final String? dilution; // Instruções de diluição
  final String? storage; // Armazenamento
  final List<String> contraindications;
  final List<String> sideEffects;

  const AdministrationInstructions({
    required this.route,
    required this.timing,
    this.dilution,
    this.storage,
    this.contraindications = const [],
    this.sideEffects = const [],
  });

  @override
  List<Object?> get props => [
        route,
        timing,
        dilution,
        storage,
        contraindications,
        sideEffects,
      ];
}

/// Helper method to map AlertLevel to ResultSeverity
ResultSeverity _mapAlertLevelToResultSeverity(AlertLevel level) {
  switch (level) {
    case AlertLevel.safe:
      return ResultSeverity.success;
    case AlertLevel.caution:
      return ResultSeverity.info;
    case AlertLevel.warning:
      return ResultSeverity.warning;
    case AlertLevel.danger:
      return ResultSeverity.danger;
  }
}

/// Resultado do cálculo de dosagem de medicamentos
class MedicationDosageOutput extends CalculationResult {
  final String medicationName;
  final double dosagePerKg; // mg/kg
  final double totalDailyDose; // mg
  final double dosePerAdministration; // mg
  final double? volumeToAdminister; // ml (se concentração fornecida)
  final String unit; // mg, ml, UI, etc.
  final int administrationsPerDay;
  final String intervalBetweenDoses; // "12 horas", "8 horas", etc.
  final List<SafetyAlert> alerts;
  final MonitoringInfo? monitoringInfo;
  final AdministrationInstructions instructions;
  final Map<String, dynamic> calculationDetails;
  final bool isSafeToAdminister;

  MedicationDosageOutput({
    required this.medicationName,
    required this.dosagePerKg,
    required this.totalDailyDose,
    required this.dosePerAdministration,
    this.volumeToAdminister,
    required this.unit,
    required this.administrationsPerDay,
    required this.intervalBetweenDoses,
    this.alerts = const [],
    this.monitoringInfo,
    required this.instructions,
    this.calculationDetails = const {},
    required DateTime calculatedAt,
    required this.isSafeToAdminister,
  }) : super(
    calculatorId: 'medication_dosage',
    results: [
      ResultItem(
        label: 'Dosagem Total Diária',
        value: totalDailyDose,
        unit: unit,
        severity: isSafeToAdminister ? ResultSeverity.success : ResultSeverity.danger,
      ),
      ResultItem(
        label: 'Dose por Administração',
        value: dosePerAdministration,
        unit: unit,
      ),
    ],
    recommendations: alerts.map((alert) => Recommendation(
      title: alert.type.displayName,
      message: alert.message,
      severity: _mapAlertLevelToResultSeverity(alert.level),
    )).toList(),
    calculatedAt: calculatedAt,
  );

  /// Retorna o nível de alerta mais alto
  AlertLevel get highestAlertLevel {
    if (alerts.isEmpty) return AlertLevel.safe;
    
    final levels = alerts.map((a) => a.level).toList();
    if (levels.contains(AlertLevel.danger)) return AlertLevel.danger;
    if (levels.contains(AlertLevel.warning)) return AlertLevel.warning;
    if (levels.contains(AlertLevel.caution)) return AlertLevel.caution;
    return AlertLevel.safe;
  }

  /// Retorna alertas que impedem administração
  List<SafetyAlert> get blockingAlerts {
    return alerts.where((alert) => alert.isBlocking).toList();
  }

  /// Retorna se há alertas críticos
  bool get hasCriticalAlerts {
    return alerts.any((alert) => 
      alert.level == AlertLevel.danger || alert.isBlocking);
  }

  /// Retorna resumo da prescrição
  String get prescriptionSummary {
    final volume = volumeToAdminister != null 
        ? ' (${volumeToAdminister!.toStringAsFixed(2)} ml)'
        : '';
    
    return '$medicationName: ${dosePerAdministration.toStringAsFixed(2)} $unit$volume '
           '- ${administrationsPerDay}x/dia';
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'medicationName': medicationName,
      'dosagePerKg': dosagePerKg,
      'totalDailyDose': totalDailyDose,
      'dosePerAdministration': dosePerAdministration,
      'volumeToAdminister': volumeToAdminister,
      'unit': unit,
      'administrationsPerDay': administrationsPerDay,
      'intervalBetweenDoses': intervalBetweenDoses,
      'alerts': alerts.map((a) => {
        'type': a.type.name,
        'level': a.level.name,
        'message': a.message,
        'recommendation': a.recommendation,
        'isBlocking': a.isBlocking,
      }).toList(),
      'monitoringInfo': monitoringInfo != null ? {
        'parametersToMonitor': monitoringInfo!.parametersToMonitor,
        'frequency': monitoringInfo!.frequency,
        'duration': monitoringInfo!.duration,
        'warningSignsToWatch': monitoringInfo!.warningSignsToWatch,
        'emergencyProtocol': monitoringInfo!.emergencyProtocol,
      } : null,
      'instructions': {
        'route': instructions.route,
        'timing': instructions.timing,
        'dilution': instructions.dilution,
        'storage': instructions.storage,
        'contraindications': instructions.contraindications,
        'sideEffects': instructions.sideEffects,
      },
      'calculationDetails': calculationDetails,
      'calculatedAt': calculatedAt?.toIso8601String(),
      'isSafeToAdminister': isSafeToAdminister,
    };
  }

  @override
  List<Object?> get props => [
        medicationName,
        dosagePerKg,
        totalDailyDose,
        dosePerAdministration,
        volumeToAdminister,
        unit,
        administrationsPerDay,
        intervalBetweenDoses,
        alerts,
        monitoringInfo,
        instructions,
        calculationDetails,
        calculatedAt,
        isSafeToAdminister,
      ];

  @override
  String toString() {
    return 'MedicationDosageOutput($prescriptionSummary, '
           'alerts: ${alerts.length}, safe: $isSafeToAdminister)';
  }
}