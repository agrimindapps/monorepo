/// Calculadora de Dosagem de Medicamentos para Pets
/// Calcula dosagens baseadas no peso do animal
library;

enum PetSpecies { dog, cat }

enum MedicationType {
  amoxicillin,
  cephalexin,
  metronidazole,
  prednisolone,
  meloxicam,
}

enum DosageFrequency {
  onceDailyBID,
  twiceDailyBID,
  threeDailyTID,
}

class MedicationDosageResult {
  /// Nome do medicamento
  final String medicationName;

  /// Dosagem por administração (mg)
  final double dosePerAdministration;

  /// Dosagem diária total (mg)
  final double dailyDose;

  /// Frequência de administração
  final String frequencyText;

  /// Número de administrações por dia
  final int administrationsPerDay;

  /// Avisos e precauções
  final List<String> warnings;

  /// Observações importantes
  final String observations;

  const MedicationDosageResult({
    required this.medicationName,
    required this.dosePerAdministration,
    required this.dailyDose,
    required this.frequencyText,
    required this.administrationsPerDay,
    required this.warnings,
    required this.observations,
  });
}

class MedicationDosageCalculator {
  /// Dosagens em mg/kg
  static const Map<MedicationType, double> _dosagesPerKg = {
    MedicationType.amoxicillin: 20.0,
    MedicationType.cephalexin: 25.0,
    MedicationType.metronidazole: 15.0,
    MedicationType.prednisolone: 1.0,
    MedicationType.meloxicam: 0.1,
  };

  /// Nomes dos medicamentos
  static const Map<MedicationType, String> _medicationNames = {
    MedicationType.amoxicillin: 'Amoxicilina',
    MedicationType.cephalexin: 'Cefalexina',
    MedicationType.metronidazole: 'Metronidazol',
    MedicationType.prednisolone: 'Prednisolona',
    MedicationType.meloxicam: 'Meloxicam',
  };

  /// Calcula a dosagem do medicamento
  static MedicationDosageResult calculate({
    required double weightKg,
    required MedicationType medicationType,
    required PetSpecies species,
    required DosageFrequency frequency,
  }) {
    // Validação
    if (weightKg <= 0 || weightKg > 100) {
      throw ArgumentError('Peso deve estar entre 0 e 100 kg');
    }

    final dosagePerKg = _dosagesPerKg[medicationType]!;
    final medicationName = _medicationNames[medicationType]!;

    // Calcula dosagem diária total
    final dailyDose = weightKg * dosagePerKg;

    // Número de administrações por dia
    final administrationsPerDay = _getAdministrationsPerDay(frequency);

    // Dosagem por administração
    final dosePerAdministration = dailyDose / administrationsPerDay;

    final frequencyText = _getFrequencyText(frequency);
    final warnings = _getWarnings(medicationType, species, weightKg);
    final observations = _getObservations(medicationType);

    return MedicationDosageResult(
      medicationName: medicationName,
      dosePerAdministration: dosePerAdministration,
      dailyDose: dailyDose,
      frequencyText: frequencyText,
      administrationsPerDay: administrationsPerDay,
      warnings: warnings,
      observations: observations,
    );
  }

  static int _getAdministrationsPerDay(DosageFrequency frequency) {
    return switch (frequency) {
      DosageFrequency.onceDailyBID => 1,
      DosageFrequency.twiceDailyBID => 2,
      DosageFrequency.threeDailyTID => 3,
    };
  }

  static String _getFrequencyText(DosageFrequency frequency) {
    return switch (frequency) {
      DosageFrequency.onceDailyBID => '1x ao dia (SID)',
      DosageFrequency.twiceDailyBID => '2x ao dia (BID)',
      DosageFrequency.threeDailyTID => '3x ao dia (TID)',
    };
  }

  static List<String> _getWarnings(
    MedicationType medication,
    PetSpecies species,
    double weightKg,
  ) {
    final warnings = <String>[
      '⚠️ ESTE CÁLCULO É APENAS INFORMATIVO',
      'Consulte sempre um veterinário antes de medicar',
      'Não administre sem prescrição profissional',
    ];

    switch (medication) {
      case MedicationType.amoxicillin:
        warnings.add('Observe reações alérgicas (coceira, inchaço)');
        warnings.add('Administre após as refeições');
        break;
      case MedicationType.cephalexin:
        warnings.add('Pode causar distúrbios gastrointestinais');
        warnings.add('Mantenha hidratação adequada');
        break;
      case MedicationType.metronidazole:
        warnings.add('Evite em fêmeas gestantes');
        warnings.add('Pode causar náuseas, administre com comida');
        break;
      case MedicationType.prednisolone:
        warnings.add('CORTICOSTEROIDE - use apenas com prescrição');
        warnings.add('Nunca interrompa abruptamente');
        warnings.add('Aumento de apetite e sede é esperado');
        break;
      case MedicationType.meloxicam:
        warnings.add('ANTI-INFLAMATÓRIO - monitore função renal');
        warnings.add('Evite em pets desidratados');
        if (species == PetSpecies.cat && weightKg < 2) {
          warnings.add('ATENÇÃO: Dose muito baixa para gatos pequenos');
        }
        break;
    }

    return warnings;
  }

  static String _getObservations(MedicationType medication) {
    return switch (medication) {
      MedicationType.amoxicillin =>
        'Antibiótico de amplo espectro. Complete todo o tratamento mesmo que melhore.',
      MedicationType.cephalexin =>
        'Antibiótico eficaz contra infecções bacterianas. Duração típica: 7-14 dias.',
      MedicationType.metronidazole =>
        'Antibiótico e antiparasitário. Eficaz contra Giardia e bactérias anaeróbicas.',
      MedicationType.prednisolone =>
        'Corticosteroide anti-inflamatório. Requer monitoramento veterinário regular.',
      MedicationType.meloxicam =>
        'Anti-inflamatório não esteroidal (AINE). Use com cautela em pets idosos.',
    };
  }

  static String getMedicationDescription(MedicationType type) {
    return _medicationNames[type]!;
  }

  static String getFrequencyDescription(DosageFrequency frequency) {
    return _getFrequencyText(frequency);
  }
}
