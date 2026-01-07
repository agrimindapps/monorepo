/// Calculadora de Ciclo Reprodutivo
/// Calcula data prevista de parto e marcos do ciclo gestacional
library;

enum Species {
  cattle, // Bovino
  pig, // Suíno
  goat, // Caprino
  sheep, // Ovino
  horse, // Equino
  dog, // Canino
  cat, // Felino
}

class BreedingCycleResult {
  /// Data prevista do parto
  final DateTime birthDate;

  /// Dias de gestação
  final int gestationDays;

  /// Dias restantes até o parto
  final int daysRemaining;

  /// Marcos do primeiro trimestre
  final List<CycleMilestone> firstTrimester;

  /// Marcos do segundo trimestre
  final List<CycleMilestone> secondTrimester;

  /// Marcos do terceiro trimestre
  final List<CycleMilestone> thirdTrimester;

  /// Cuidados específicos
  final List<String> careTips;

  const BreedingCycleResult({
    required this.birthDate,
    required this.gestationDays,
    required this.daysRemaining,
    required this.firstTrimester,
    required this.secondTrimester,
    required this.thirdTrimester,
    required this.careTips,
  });
}

class CycleMilestone {
  final String event;
  final DateTime date;
  final String description;

  const CycleMilestone({
    required this.event,
    required this.date,
    required this.description,
  });
}

class BreedingCycleCalculator {
  // Período de gestação em dias
  static const Map<Species, int> gestationPeriods = {
    Species.cattle: 283,
    Species.pig: 114,
    Species.goat: 150,
    Species.sheep: 147,
    Species.horse: 340,
    Species.dog: 63,
    Species.cat: 65,
  };

  static const Map<Species, String> speciesNames = {
    Species.cattle: 'Bovino',
    Species.pig: 'Suíno',
    Species.goat: 'Caprino',
    Species.sheep: 'Ovino',
    Species.horse: 'Equino',
    Species.dog: 'Cão',
    Species.cat: 'Gato',
  };

  /// Calcula ciclo reprodutivo
  static BreedingCycleResult calculate({
    required Species species,
    required DateTime breedingDate,
  }) {
    final gestationDays = gestationPeriods[species]!;
    final birthDate = breedingDate.add(Duration(days: gestationDays));
    final now = DateTime.now();
    final daysRemaining = birthDate.difference(now).inDays.clamp(0, gestationDays);

    // Divide gestação em trimestres
    final trimesterDays = gestationDays ~/ 3;

    // Marcos do primeiro trimestre
    final firstTrimester = _getFirstTrimesterMilestones(
      species,
      breedingDate,
      trimesterDays,
    );

    // Marcos do segundo trimestre
    final secondTrimester = _getSecondTrimesterMilestones(
      species,
      breedingDate,
      trimesterDays,
    );

    // Marcos do terceiro trimestre
    final thirdTrimester = _getThirdTrimesterMilestones(
      species,
      breedingDate,
      birthDate,
      trimesterDays,
    );

    // Cuidados específicos
    final careTips = _getCareTips(species, daysRemaining, gestationDays);

    return BreedingCycleResult(
      birthDate: birthDate,
      gestationDays: gestationDays,
      daysRemaining: daysRemaining,
      firstTrimester: firstTrimester,
      secondTrimester: secondTrimester,
      thirdTrimester: thirdTrimester,
      careTips: careTips,
    );
  }

  static List<CycleMilestone> _getFirstTrimesterMilestones(
    Species species,
    DateTime breedingDate,
    int trimesterDays,
  ) {
    return [
      CycleMilestone(
        event: 'Cobertura/Inseminação',
        date: breedingDate,
        description: 'Início da gestação',
      ),
      CycleMilestone(
        event: 'Confirmação de Gestação',
        date: breedingDate.add(Duration(days: (trimesterDays * 0.5).round())),
        description: 'Realizar diagnóstico de gestação',
      ),
    ];
  }

  static List<CycleMilestone> _getSecondTrimesterMilestones(
    Species species,
    DateTime breedingDate,
    int trimesterDays,
  ) {
    final secondStart = breedingDate.add(Duration(days: trimesterDays));
    return [
      CycleMilestone(
        event: 'Início 2º Trimestre',
        date: secondStart,
        description: 'Desenvolvimento fetal acelerado',
      ),
      CycleMilestone(
        event: 'Reforço Nutricional',
        date: secondStart.add(Duration(days: (trimesterDays * 0.5).round())),
        description: 'Aumentar aporte nutricional',
      ),
    ];
  }

  static List<CycleMilestone> _getThirdTrimesterMilestones(
    Species species,
    DateTime breedingDate,
    DateTime birthDate,
    int trimesterDays,
  ) {
    final thirdStart = breedingDate.add(Duration(days: trimesterDays * 2));
    return [
      CycleMilestone(
        event: 'Início 3º Trimestre',
        date: thirdStart,
        description: 'Preparação para o parto',
      ),
      CycleMilestone(
        event: 'Pré-parto',
        date: birthDate.subtract(const Duration(days: 15)),
        description: 'Monitorar sinais de parto',
      ),
      CycleMilestone(
        event: 'Parto Previsto',
        date: birthDate,
        description: 'Data estimada do nascimento',
      ),
    ];
  }

  static List<String> _getCareTips(Species species, int daysRemaining, int totalDays) {
    final tips = <String>[];
    final progress = ((totalDays - daysRemaining) / totalDays * 100).round();

    // Dicas por fase
    if (progress < 33) {
      tips.add('1º Trimestre: Evite estresse e manejo brusco');
      tips.add('Mantenha nutrição adequada sem excessos');
    } else if (progress < 66) {
      tips.add('2º Trimestre: Aumente gradualmente a nutrição');
      tips.add('Monitore condição corporal');
    } else {
      tips.add('3º Trimestre: Prepare local do parto');
      tips.add('Observe sinais de parto iminente');
      tips.add('Tenha assistência veterinária de prontidão');
    }

    // Dicas específicas por espécie
    switch (species) {
      case Species.cattle:
        tips.add('Bovinos: Vacinação pré-parto conforme protocolo');
        break;
      case Species.pig:
        tips.add('Suínos: Transfira para maternidade 5-7 dias antes');
        break;
      case Species.goat:
      case Species.sheep:
        tips.add('Pequenos ruminantes: Preparar aprisco limpo e seco');
        break;
      case Species.horse:
        tips.add('Equinos: Monitore úbere e comportamento');
        break;
      case Species.dog:
      case Species.cat:
        tips.add('Prepare caixa de parto em local tranquilo');
        break;
    }

    // Dicas gerais
    tips.add('Mantenha acompanhamento veterinário regular');
    tips.add('Registre marcos e observações importantes');

    return tips;
  }

  static String getSpeciesName(Species species) => speciesNames[species]!;
}
