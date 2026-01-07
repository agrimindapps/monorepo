/// Calculadora de Idade Animal
/// Converte idade do pet em anos humanos equivalentes
library;

enum PetSpecies { dog, cat }

enum DogSize { small, medium, large, giant }

enum LifeStage {
  puppy,
  youngAdult,
  adult,
  matureAdult,
  senior,
  geriatric,
}

class AnimalAgeResult {
  /// Idade em anos humanos equivalentes
  final int humanAge;

  /// Estágio de vida
  final LifeStage lifeStage;

  /// Descrição do estágio
  final String lifeStageText;

  /// Recomendações de cuidados
  final List<String> careRecommendations;

  /// Descrição comparativa
  final String ageComparison;

  const AnimalAgeResult({
    required this.humanAge,
    required this.lifeStage,
    required this.lifeStageText,
    required this.careRecommendations,
    required this.ageComparison,
  });
}

class AnimalAgeCalculator {
  // Tabelas de conversão para cães por tamanho
  static const Map<DogSize, int> _dogFirstYearAge = {
    DogSize.small: 15,
    DogSize.medium: 15,
    DogSize.large: 14,
    DogSize.giant: 12,
  };

  static const Map<DogSize, int> _dogSecondYearAge = {
    DogSize.small: 24,
    DogSize.medium: 24,
    DogSize.large: 22,
    DogSize.giant: 19,
  };

  static const Map<DogSize, int> _dogYearlyFactor = {
    DogSize.small: 4,
    DogSize.medium: 5,
    DogSize.large: 6,
    DogSize.giant: 7,
  };

  static const Map<DogSize, String> dogSizeDescriptions = {
    DogSize.small: 'Pequeno (até 10kg)',
    DogSize.medium: 'Médio (10-25kg)',
    DogSize.large: 'Grande (25-45kg)',
    DogSize.giant: 'Gigante (acima de 45kg)',
  };

  /// Calcula idade equivalente em anos humanos
  static AnimalAgeResult calculate({
    required PetSpecies species,
    required double ageYears,
    DogSize? dogSize,
  }) {
    int humanAge;

    if (species == PetSpecies.dog) {
      final size = dogSize ?? DogSize.medium;
      humanAge = _calculateDogAge(ageYears, size);
    } else {
      humanAge = _calculateCatAge(ageYears);
    }

    final lifeStage = _getLifeStage(species, ageYears, dogSize);
    final lifeStageText = _getLifeStageText(lifeStage);
    final careRecommendations = _getCareRecommendations(lifeStage, species);
    final ageComparison = _getAgeComparison(humanAge, species);

    return AnimalAgeResult(
      humanAge: humanAge,
      lifeStage: lifeStage,
      lifeStageText: lifeStageText,
      careRecommendations: careRecommendations,
      ageComparison: ageComparison,
    );
  }

  static int _calculateDogAge(double ageYears, DogSize size) {
    if (ageYears <= 0) return 0;
    if (ageYears <= 1) {
      return (_dogFirstYearAge[size]! * ageYears).round();
    }
    if (ageYears <= 2) {
      final firstYear = _dogFirstYearAge[size]!;
      final secondYearProgress = ageYears - 1;
      final secondYearValue = _dogSecondYearAge[size]! - firstYear;
      return (firstYear + secondYearProgress * secondYearValue).round();
    }

    // 3+ anos: base do segundo ano + fator anual
    final baseAge = _dogSecondYearAge[size]!;
    final yearlyFactor = _dogYearlyFactor[size]!;
    return baseAge + ((ageYears - 2) * yearlyFactor).round();
  }

  static int _calculateCatAge(double ageYears) {
    if (ageYears <= 0) return 0;
    if (ageYears <= 1) return (15 * ageYears).round();
    if (ageYears <= 2) return (15 + (ageYears - 1) * 9).round(); // 15 + 9 = 24

    // 3+ anos: 24 + 4 por ano adicional
    return 24 + ((ageYears - 2) * 4).round();
  }

  static LifeStage _getLifeStage(
    PetSpecies species,
    double ageYears,
    DogSize? dogSize,
  ) {
    if (species == PetSpecies.cat) {
      if (ageYears < 1) return LifeStage.puppy;
      if (ageYears < 2) return LifeStage.youngAdult;
      if (ageYears < 6) return LifeStage.adult;
      if (ageYears < 10) return LifeStage.matureAdult;
      if (ageYears < 15) return LifeStage.senior;
      return LifeStage.geriatric;
    }

    // Cães - varia por tamanho
    final size = dogSize ?? DogSize.medium;
    final seniorAge = _getSeniorAgeThreshold(size);

    if (ageYears < 1) return LifeStage.puppy;
    if (ageYears < 2) return LifeStage.youngAdult;
    if (ageYears < seniorAge * 0.5) return LifeStage.adult;
    if (ageYears < seniorAge) return LifeStage.matureAdult;
    if (ageYears < seniorAge * 1.5) return LifeStage.senior;
    return LifeStage.geriatric;
  }

  static double _getSeniorAgeThreshold(DogSize size) {
    return switch (size) {
      DogSize.small => 10.0,
      DogSize.medium => 8.0,
      DogSize.large => 6.0,
      DogSize.giant => 5.0,
    };
  }

  static String _getLifeStageText(LifeStage stage) {
    return switch (stage) {
      LifeStage.puppy => 'Filhote',
      LifeStage.youngAdult => 'Jovem Adulto',
      LifeStage.adult => 'Adulto',
      LifeStage.matureAdult => 'Adulto Maduro',
      LifeStage.senior => 'Idoso',
      LifeStage.geriatric => 'Idoso Avançado',
    };
  }

  static List<String> _getCareRecommendations(
    LifeStage stage,
    PetSpecies species,
  ) {
    final pet = species == PetSpecies.dog ? 'cão' : 'gato';

    return switch (stage) {
      LifeStage.puppy => [
        'Vacinação completa e vermifugação',
        'Socialização e treinamento básico',
        'Alimentação específica para filhotes',
        'Consultas veterinárias frequentes',
        'Muita atividade física supervisionada',
      ],
      LifeStage.youngAdult => [
        'Manter vacinação em dia',
        'Exercícios regulares e intensos',
        'Alimentação balanceada para adultos',
        'Check-up anual',
        'Considerar castração se não planejado criação',
      ],
      LifeStage.adult => [
        'Manter peso ideal',
        'Exercícios diários moderados',
        'Check-up anual completo',
        'Cuidados dentários regulares',
        'Alimentação de qualidade para adultos',
      ],
      LifeStage.matureAdult => [
        'Check-up semestral recomendado',
        'Exames de sangue periódicos',
        'Atenção ao peso e articulações',
        'Considerar ração para $pet maduro',
        'Monitorar mudanças de comportamento',
      ],
      LifeStage.senior => [
        'Check-up a cada 6 meses',
        'Exames completos (sangue, urina, coração)',
        'Alimentação específica para idosos',
        'Exercícios leves e regulares',
        'Ambiente confortável e acessível',
      ],
      LifeStage.geriatric => [
        'Acompanhamento veterinário frequente',
        'Monitoramento de doenças crônicas',
        'Alimentação de fácil digestão',
        'Muito conforto e carinho',
        'Adaptações no ambiente (rampas, camas baixas)',
      ],
    };
  }

  static String _getAgeComparison(int humanAge, PetSpecies species) {
    final pet = species == PetSpecies.dog ? 'Seu cão' : 'Seu gato';

    if (humanAge < 18) {
      return '$pet é equivalente a um adolescente humano';
    }
    if (humanAge < 30) {
      return '$pet está na flor da idade, como um jovem adulto';
    }
    if (humanAge < 50) {
      return '$pet está na meia-idade, cheio de experiência';
    }
    if (humanAge < 70) {
      return '$pet é como uma pessoa madura e sábia';
    }
    return '$pet tem a sabedoria de um idoso experiente';
  }

  static String getDogSizeDescription(DogSize size) {
    return dogSizeDescriptions[size]!;
  }
}
