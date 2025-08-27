import 'dart:math' as math;

import '../entities/medication_data.dart';
import '../entities/medication_dosage_input.dart';
import '../entities/medication_dosage_output.dart';
import 'calculator_strategy.dart';

/// Strategy para cálculo de dosagem de medicamentos
class MedicationDosageStrategy implements CalculatorStrategy<MedicationDosageInput, MedicationDosageOutput> {
  final List<MedicationData> _medicationsDatabase;

  MedicationDosageStrategy(this._medicationsDatabase);

  @override
  MedicationDosageOutput calculate(MedicationDosageInput input) {
    // Buscar dados do medicamento
    final medicationData = _getMedicationData(input.medicationId);
    
    if (medicationData == null) {
      throw ArgumentError('Medicamento não encontrado: ${input.medicationId}');
    }

    // Obter faixa de dosagem apropriada
    final dosageRange = medicationData.getDosageRange(input.species, input.ageGroup);
    
    if (dosageRange == null) {
      throw ArgumentError('Dosagem não definida para ${input.species.displayName} - ${input.ageGroup.displayName}');
    }

    // Calcular dosagem base
    final baseDosagePerKg = _calculateBaseDosage(dosageRange, input);
    
    // Aplicar ajustes por condições especiais
    final adjustedDosagePerKg = _applyDosageAdjustments(baseDosagePerKg, input, medicationData);
    
    // Calcular doses
    final calculations = _performDosageCalculations(adjustedDosagePerKg, input, medicationData);
    
    // Gerar alertas de segurança
    final alerts = _generateSafetyAlerts(input, medicationData, dosageRange, adjustedDosagePerKg);
    
    // Criar informações de monitoramento
    final monitoringInfo = _createMonitoringInfo(medicationData, input);
    
    // Criar instruções de administração
    final instructions = _createAdministrationInstructions(medicationData, input);
    
    // Determinar se é seguro administrar
    final isSafe = _isSafeToAdminister(alerts);

    return MedicationDosageOutput(
      medicationName: medicationData.name,
      dosagePerKg: adjustedDosagePerKg,
      totalDailyDose: calculations['totalDailyDose']!,
      dosePerAdministration: calculations['dosePerAdministration']!,
      volumeToAdminister: calculations['volumeToAdminister'],
      unit: _getDosageUnit(medicationData),
      administrationsPerDay: input.frequency.timesPerDay,
      intervalBetweenDoses: _calculateInterval(input.frequency),
      alerts: alerts,
      monitoringInfo: monitoringInfo,
      instructions: instructions,
      calculationDetails: {
        'baseDosagePerKg': baseDosagePerKg,
        'adjustmentFactors': _getAdjustmentFactors(input),
        'safetyMargin': _calculateSafetyMargin(adjustedDosagePerKg, dosageRange),
        'concentrationUsed': input.concentration,
      },
      calculatedAt: DateTime.now(),
      isSafeToAdminister: isSafe,
    );
  }

  /// Busca dados do medicamento por ID
  MedicationData? _getMedicationData(String medicationId) {
    try {
      return _medicationsDatabase.firstWhere((med) => med.id == medicationId);
    } catch (e) {
      return null;
    }
  }

  /// Calcula dosagem base dentro da faixa terapêutica
  double _calculateBaseDosage(DosageRange dosageRange, MedicationDosageInput input) {
    // Para condições normais, usar dosagem média
    if (input.specialConditions.isEmpty && !input.isEmergency) {
      return (dosageRange.minDose + dosageRange.maxDose) / 2;
    }
    
    // Para emergências, pode usar dosagem mais alta
    if (input.isEmergency) {
      return dosageRange.maxDose * 0.9; // 90% da dose máxima
    }
    
    // Para condições especiais, geralmente começar com dosagem menor
    return dosageRange.minDose + (dosageRange.maxDose - dosageRange.minDose) * 0.3;
  }

  /// Aplica ajustes de dosagem baseados em condições especiais com proteção contra subdosagem perigosa
  double _applyDosageAdjustments(double baseDosage, MedicationDosageInput input, MedicationData medicationData) {
    double cumulativeReduction = 1.0;
    const double minimumDosageFactor = 0.4; // Nunca reduzir mais que 60%
    const double severityWeightFactor = 0.7; // Fator de peso para condições severas múltiplas
    
    // Aplicar ajustes com peso baseado em severidade e número de condições
    final Map<SpecialCondition, double> conditionFactors = {};
    
    for (final condition in input.specialConditions) {
      double conditionFactor = _getConditionAdjustmentFactor(condition, medicationData);
      conditionFactors[condition] = conditionFactor;
    }
    
    // Se múltiplas condições, aplicar fator de redução ponderado ao invés de multiplicativo
    if (conditionFactors.length > 1) {
      // Para múltiplas condições, usar média ponderada ao invés de produto
      double weightedSum = 0.0;
      double totalWeight = 0.0;
      
      for (final entry in conditionFactors.entries) {
        final weight = _getConditionSeverityWeight(entry.key);
        weightedSum += entry.value * weight;
        totalWeight += weight;
      }
      
      // Aplicar fator de suavização para múltiplas condições
      final avgFactor = weightedSum / totalWeight;
      cumulativeReduction = severityWeightFactor + (avgFactor * (1.0 - severityWeightFactor));
    } else if (conditionFactors.isNotEmpty) {
      // Uma única condição: aplicar fator direto
      cumulativeReduction = conditionFactors.values.first;
    }
    
    // Ajuste adicional por idade (aplicado separadamente para não ser cumulativo)
    double ageAdjustment = 1.0;
    if (input.ageGroup == AgeGroup.puppy) {
      ageAdjustment = 0.8; // Filhotes geralmente precisam de doses menores por kg
    } else if (input.ageGroup == AgeGroup.senior) {
      ageAdjustment = 0.85; // Idosos: metabolismo mais lento
    }
    
    // Garantir que não reduzimos além do mínimo terapêutico
    cumulativeReduction = math.max(cumulativeReduction, minimumDosageFactor);
    
    // Aplicar ajustes finais
    double adjustedDosage = baseDosage * cumulativeReduction * ageAdjustment;
    
    // Verificação final: garantir que ainda está dentro da faixa terapêutica mínima
    final dosageRange = medicationData.getDosageRange(input.species, input.ageGroup);
    if (dosageRange != null) {
      final absoluteMinimum = dosageRange.minDose * 0.6; // 60% da dose mínima como limite absoluto
      adjustedDosage = math.max(adjustedDosage, absoluteMinimum);
    }
    
    return adjustedDosage;
  }
  
  /// Obtém fator de ajuste específico para cada condição
  double _getConditionAdjustmentFactor(SpecialCondition condition, MedicationData medicationData) {
    switch (condition) {
      case SpecialCondition.renalDisease:
        // Ajuste baseado na metabolização renal do medicamento
        return _isRenallyMetabolized(medicationData) ? 0.6 : 0.8;
      case SpecialCondition.hepaticDisease:
        // Ajuste baseado na metabolização hepática
        return _isHepaticallyMetabolized(medicationData) ? 0.5 : 0.75;
      case SpecialCondition.geriatric:
        // Redução conservadora para geriátricos
        return 0.8;
      case SpecialCondition.heartDisease:
        // Ajuste específico dependendo do medicamento
        if (medicationData.category.toLowerCase().contains('diurético')) {
          return 1.0; // Manter dose para diuréticos em cardiopatas
        } else {
          return 0.9; // Redução leve para outros medicamentos
        }
      case SpecialCondition.pregnant:
        // Ajuste baseado na categoria de gravidez
        if (!medicationData.isSafeForPregnancy()) {
          return 0.7; // Dose mais conservadora
        }
        return 0.9; // Redução leve se seguro na gravidez
      case SpecialCondition.diabetes:
        // Ajuste para diabéticos (depende do medicamento)
        if (medicationData.category.toLowerCase().contains('corticoide')) {
          return 0.7; // Redução maior para corticoides em diabéticos
        }
        return 0.9; // Redução leve para outros
      case SpecialCondition.lactating:
        return 0.85; // Redução moderada durante lactação
      default:
        // Outras condições: redução conservadora
        return 0.9;
    }
  }
  
  /// Obtém peso de severidade para cada condição (usado no cálculo de média ponderada)
  double _getConditionSeverityWeight(SpecialCondition condition) {
    switch (condition) {
      case SpecialCondition.renalDisease:
      case SpecialCondition.hepaticDisease:
        return 3.0; // Condições críticas têm peso maior
      case SpecialCondition.heartDisease:
      case SpecialCondition.diabetes:
        return 2.5; // Condições sérias
      case SpecialCondition.geriatric:
      case SpecialCondition.pregnant:
        return 2.0; // Condições importantes
      default:
        return 1.0; // Peso padrão
    }
  }

  /// Realiza cálculos de dosagem
  Map<String, double?> _performDosageCalculations(double dosagePerKg, MedicationDosageInput input, MedicationData medicationData) {
    // Dose total diária = peso × dosagem por kg
    final totalDailyDose = input.weight * dosagePerKg;
    
    // Dose por administração = dose total ÷ frequência
    final dosePerAdministration = totalDailyDose / input.frequency.timesPerDay;
    
    // Volume a administrar (se concentração fornecida)
    double? volumeToAdminister;
    if (input.concentration != null && input.concentration! > 0) {
      volumeToAdminister = dosePerAdministration / input.concentration!;
    }
    
    return {
      'totalDailyDose': totalDailyDose,
      'dosePerAdministration': dosePerAdministration,
      'volumeToAdminister': volumeToAdminister,
    };
  }

  /// Gera alertas de segurança
  List<SafetyAlert> _generateSafetyAlerts(
    MedicationDosageInput input,
    MedicationData medicationData,
    DosageRange dosageRange,
    double calculatedDosage,
  ) {
    final alerts = <SafetyAlert>[];

    // Verificar faixa de dosagem
    if (!dosageRange.isDoseInSafeRange(calculatedDosage)) {
      if (calculatedDosage < dosageRange.minDose) {
        alerts.add(SafetyAlert(
          type: AlertType.underdose,
          level: AlertLevel.warning,
          message: 'Dosagem abaixo do mínimo terapêutico (${dosageRange.minDose} mg/kg)',
          recommendation: 'Considere aumentar a dose ou verificar indicação',
        ));
      } else if (calculatedDosage > dosageRange.maxDose) {
        alerts.add(SafetyAlert(
          type: AlertType.overdose,
          level: AlertLevel.danger,
          message: 'Dosagem acima do máximo recomendado (${dosageRange.maxDose} mg/kg)',
          recommendation: 'REDUZIR DOSE IMEDIATAMENTE',
          isBlocking: true,
        ));
      }
    }

    // Verificar toxicidade
    if (dosageRange.isDosePotentiallyToxic(calculatedDosage)) {
      alerts.add(SafetyAlert(
        type: AlertType.toxicity,
        level: AlertLevel.danger,
        message: 'PERIGO: Dose potencialmente tóxica (≥${dosageRange.toxicDose} mg/kg)',
        recommendation: 'NÃO ADMINISTRAR - Consultar veterinário imediatamente',
        isBlocking: true,
      ));
    }

    // Verificar letalidade
    if (dosageRange.isDosePotentiallyLethal(calculatedDosage)) {
      alerts.add(SafetyAlert(
        type: AlertType.toxicity,
        level: AlertLevel.danger,
        message: 'PERIGO EXTREMO: Dose potencialmente letal (≥${dosageRange.lethalDose} mg/kg)',
        recommendation: 'NÃO ADMINISTRAR JAMAIS - Dose letal',
        isBlocking: true,
      ));
    }

    // Verificar contraindicações
    final contraindications = medicationData.getContraindications(input.specialConditions);
    for (final contraindication in contraindications) {
      alerts.add(SafetyAlert(
        type: AlertType.conditionContraindication,
        level: contraindication.isAbsolute ? AlertLevel.danger : AlertLevel.warning,
        message: 'Contraindicação: ${contraindication.reason}',
        recommendation: contraindication.alternative != null 
            ? 'Considere ${contraindication.alternative}'
            : 'Evitar uso nesta condição',
        isBlocking: contraindication.isAbsolute,
      ));
    }

    // Verificar gravidez
    if (input.specialConditions.contains(SpecialCondition.pregnant) && 
        !medicationData.isSafeForPregnancy()) {
      alerts.add(SafetyAlert(
        type: AlertType.conditionContraindication,
        level: AlertLevel.warning,
        message: 'Uso em gestantes: categoria ${medicationData.pregnancyCategory ?? "não definida"}',
        recommendation: 'Avaliar risco-benefício com veterinário',
      ));
    }

    // Verificar lactação
    if (input.specialConditions.contains(SpecialCondition.lactating) && 
        !medicationData.isSafeForLactation()) {
      alerts.add(const SafetyAlert(
        type: AlertType.conditionContraindication,
        level: AlertLevel.caution,
        message: 'Uso durante lactação pode afetar filhotes',
        recommendation: 'Monitorar filhotes durante tratamento',
      ));
    }

    // Alertas específicos da espécie
    final speciesWarnings = medicationData.getSpeciesWarnings(input.species);
    for (final warning in speciesWarnings) {
      alerts.add(SafetyAlert(
        type: AlertType.speciesContraindication,
        level: AlertLevel.caution,
        message: warning,
        recommendation: 'Monitoramento especial necessário',
      ));
    }

    // Verificar idade
    if (!medicationData.isAppropriateForAge(input.ageGroup, input.species)) {
      alerts.add(SafetyAlert(
        type: AlertType.ageContraindication,
        level: AlertLevel.warning,
        message: 'Medicamento não recomendado para ${input.ageGroup.displayName}',
        recommendation: 'Considerar alternativa adequada para a idade',
      ));
    }

    return alerts;
  }

  /// Cria informações de monitoramento
  MonitoringInfo? _createMonitoringInfo(MedicationData medicationData, MedicationDosageInput input) {
    final parametersToMonitor = <String>[];
    final warningSignsToWatch = <String>[];
    String frequency = 'Conforme orientação veterinária';
    String duration = 'Durante todo o tratamento';

    // Parâmetros baseados na categoria do medicamento
    switch (medicationData.category.toLowerCase()) {
      case 'antibiótico':
        parametersToMonitor.addAll(['Melhora dos sintomas', 'Efeitos gastrointestinais']);
        warningSignsToWatch.addAll(['Diarreia persistente', 'Vômitos', 'Perda de apetite']);
        frequency = 'Diariamente';
        break;
      case 'anti-inflamatório':
        parametersToMonitor.addAll(['Função renal', 'Função gastrointestinal', 'Hidratação']);
        warningSignsToWatch.addAll(['Diminuição da urinação', 'Vômitos', 'Letargia', 'Perda de apetite']);
        frequency = 'A cada 2-3 dias';
        break;
      case 'diurético':
        parametersToMonitor.addAll(['Eletrólitos', 'Hidratação', 'Peso corporal']);
        warningSignsToWatch.addAll(['Desidratação', 'Fraqueza', 'Alteração do comportamento']);
        frequency = 'Diariamente';
        break;
      case 'corticoide':
        parametersToMonitor.addAll(['Glicemia', 'Peso', 'Comportamento']);
        warningSignsToWatch.addAll(['Sede excessiva', 'Urinação excessiva', 'Aumento do apetite']);
        frequency = 'A cada 3-5 dias';
        break;
    }

    // Parâmetros adicionais baseados em condições especiais
    if (input.specialConditions.contains(SpecialCondition.renalDisease)) {
      parametersToMonitor.add('Função renal');
      warningSignsToWatch.add('Mudanças na urinação');
    }

    if (input.specialConditions.contains(SpecialCondition.hepaticDisease)) {
      parametersToMonitor.add('Função hepática');
      warningSignsToWatch.add('Icterícia');
    }

    if (parametersToMonitor.isNotEmpty) {
      return MonitoringInfo(
        parametersToMonitor: parametersToMonitor,
        frequency: frequency,
        duration: duration,
        warningSignsToWatch: warningSignsToWatch,
        emergencyProtocol: 'Contatar veterinário imediatamente se observar sinais de alerta',
      );
    }

    return null;
  }

  /// Cria instruções de administração
  AdministrationInstructions _createAdministrationInstructions(MedicationData medicationData, MedicationDosageInput input) {
    String route = medicationData.administrationRoutes.first;
    String timing = 'Conforme prescrição';
    
    // Timing específico por medicamento
    if (medicationData.name.toLowerCase().contains('omeprazol')) {
      timing = 'Em jejum, 30 minutos antes da refeição';
    } else if (medicationData.category.toLowerCase().contains('anti-inflamatório')) {
      timing = 'Com alimento para reduzir irritação gástrica';
    } else if (medicationData.category.toLowerCase().contains('antibiótico')) {
      timing = 'Preferencialmente com alimento';
    }

    return AdministrationInstructions(
      route: route,
      timing: timing,
      dilution: input.pharmaceuticalForm?.contains('suspensão') == true 
          ? 'Agitar bem antes de usar' : null,
      storage: medicationData.storageInstructions ?? 'Armazenar em temperatura ambiente',
      contraindications: medicationData.contraindications.map((c) => c.condition).toList(),
      sideEffects: medicationData.sideEffects,
    );
  }

  /// Determina se é seguro administrar
  bool _isSafeToAdminister(List<SafetyAlert> alerts) {
    return !alerts.any((alert) => alert.isBlocking);
  }

  /// Retorna unidade de dosagem
  String _getDosageUnit(MedicationData medicationData) {
    // Por padrão, assumir mg
    return 'mg';
  }

  /// Calcula intervalo entre doses
  String _calculateInterval(AdministrationFrequency frequency) {
    switch (frequency) {
      case AdministrationFrequency.once:
        return '24 horas';
      case AdministrationFrequency.twice:
        return '12 horas';
      case AdministrationFrequency.thrice:
      case AdministrationFrequency.everyEightHours:
        return '8 horas';
      case AdministrationFrequency.fourTimes:
      case AdministrationFrequency.everySixHours:
        return '6 horas';
      default:
        return '12 horas';
    }
  }

  /// Retorna fatores de ajuste aplicados
  Map<String, double> _getAdjustmentFactors(MedicationDosageInput input) {
    final factors = <String, double>{};
    
    for (final condition in input.specialConditions) {
      switch (condition) {
        case SpecialCondition.renalDisease:
          factors['renal'] = 0.6;
          break;
        case SpecialCondition.hepaticDisease:
          factors['hepatic'] = 0.5;
          break;
        case SpecialCondition.geriatric:
          factors['geriatric'] = 0.8;
          break;
        default:
          factors[condition.name] = 0.9;
      }
    }
    
    return factors;
  }

  /// Calcula margem de segurança
  double _calculateSafetyMargin(double calculatedDosage, DosageRange dosageRange) {
    if (dosageRange.toxicDose != null) {
      return (dosageRange.toxicDose! - calculatedDosage) / dosageRange.toxicDose! * 100;
    }
    return (dosageRange.maxDose - calculatedDosage) / dosageRange.maxDose * 100;
  }

  /// Verifica se medicamento é predominantemente metabolizado pelos rins
  bool _isRenallyMetabolized(MedicationData medication) {
    // Lista de medicamentos que são predominantemente eliminados pelos rins
    const renalMetabolizedMedications = [
      'furosemide',
      'enrofloxacin', 
      'amoxicillin',
      'gabapentin',
    ];
    
    return renalMetabolizedMedications.contains(medication.id) ||
           medication.category.toLowerCase().contains('diurético') ||
           medication.category.toLowerCase().contains('quinolona');
  }

  /// Verifica se medicamento é predominantemente metabolizado pelo fígado
  bool _isHepaticallyMetabolized(MedicationData medication) {
    // Lista de medicamentos que são predominantemente metabolizados pelo fígado
    const hepaticallyMetabolizedMedications = [
      'meloxicam',
      'tramadol',
      'prednisolone',
      'metronidazole',
    ];
    
    return hepaticallyMetabolizedMedications.contains(medication.id) ||
           medication.category.toLowerCase().contains('anti-inflamatório') ||
           medication.category.toLowerCase().contains('corticoide') ||
           medication.category.toLowerCase().contains('analgésico');
  }

  @override
  List<String> validateInput(MedicationDosageInput input) {
    final errors = <String>[];
    
    if (input.weight <= 0) {
      errors.add('Peso deve ser maior que zero');
    }
    
    if (input.weight > 100) {
      errors.add('Peso muito alto (máximo 100kg)');
    }
    
    if (input.medicationId.isEmpty) {
      errors.add('ID do medicamento é obrigatório');
    } else if (_getMedicationData(input.medicationId) == null) {
      errors.add('Medicamento não encontrado');
    }
    
    return errors;
  }

  @override
  String get id => 'medication_dosage_calculator';

  @override
  String get name => 'Calculadora de Dosagem de Medicamentos';

  @override
  String get description => 'Calcula dosagens seguras de medicamentos para animais';

  @override
  String get version => '1.0.0';

  @override
  List<Object?> get props => [id, version];

  @override
  bool? get stringify => null;

  // Implementação explícita do isInputValid para garantir compatibilidade
  @override
  bool isInputValid(MedicationDosageInput input) => validateInput(input).isEmpty;
}