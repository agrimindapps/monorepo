// Dart imports:
import 'dart:math' as math;

class AnimalCalculations {
  // Calculate animal age in different units
  static int getAnimalAge(int dataNascimento) {
    final birthDate = DateTime.fromMillisecondsSinceEpoch(dataNascimento);
    final now = DateTime.now();

    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Calculate age in months
  static int getAnimalAgeInMonths(int dataNascimento) {
    final birthDate = DateTime.fromMillisecondsSinceEpoch(dataNascimento);
    final now = DateTime.now();

    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) {
      months--;
    }

    return math.max(0, months);
  }

  // Calculate age in days
  static int getAnimalAgeInDays(int dataNascimento) {
    final birthDate = DateTime.fromMillisecondsSinceEpoch(dataNascimento);
    final now = DateTime.now();

    return now.difference(birthDate).inDays;
  }

  // Get detailed age breakdown
  static Map<String, int> getDetailedAge(int dataNascimento) {
    final birthDate = DateTime.fromMillisecondsSinceEpoch(dataNascimento);
    final now = DateTime.now();

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      final lastMonth = DateTime(now.year, now.month, 0);
      days += lastMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {
      'years': math.max(0, years),
      'months': math.max(0, months),
      'days': math.max(0, days),
    };
  }

  // Calculate BMI for animals (simplified)
  static double calculateAnimalBMI(double weight, double? height) {
    if (height == null || height <= 0) return 0.0;

    // Simplified BMI calculation for animals
    // Note: This is a simplified approach - real veterinary BMI would be more complex
    return weight / (height * height);
  }

  // Calculate ideal weight range based on species and breed
  static Map<String, double> getIdealWeightRange(
      String especie, String raca, String sexo) {
    final especieLower = especie.toLowerCase();
    final racaLower = raca.toLowerCase();
    final isMale = sexo.toLowerCase().contains('macho');

    // Cat weight ranges
    if (especieLower.contains('gato')) {
      if (isMale) {
        return {'min': 3.5, 'max': 7.0};
      } else {
        return {'min': 2.5, 'max': 5.5};
      }
    }

    // Dog weight ranges (breed-specific)
    if (especieLower.contains('cachorro') || especieLower.contains('cão')) {
      return _getDogWeightRange(racaLower, isMale);
    }

    // Other animals - very general range
    return {'min': 1.0, 'max': 50.0};
  }

  // Calculate weight status
  static String getWeightStatus(
      double currentWeight, String especie, String raca, String sexo) {
    final idealRange = getIdealWeightRange(especie, raca, sexo);

    if (currentWeight < idealRange['min']!) {
      final deficit =
          ((idealRange['min']! - currentWeight) / idealRange['min']!) * 100;
      if (deficit > 20) return 'Muito abaixo do peso';
      return 'Abaixo do peso';
    } else if (currentWeight > idealRange['max']!) {
      final excess =
          ((currentWeight - idealRange['max']!) / idealRange['max']!) * 100;
      if (excess > 20) return 'Muito acima do peso';
      return 'Acima do peso';
    } else {
      return 'Peso ideal';
    }
  }

  // Calculate daily calorie needs (simplified)
  static double calculateDailyCalories(
      double weight, int age, String especie, String activityLevel) {
    final especieLower = especie.toLowerCase();
    double baseCalories = 0;

    // Base metabolic rate calculation
    if (especieLower.contains('gato')) {
      baseCalories = 70 * math.pow(weight, 0.75).toDouble();
    } else if (especieLower.contains('cachorro') ||
        especieLower.contains('cão')) {
      baseCalories = 132 * math.pow(weight, 0.75).toDouble();
    } else {
      baseCalories =
          100 * math.pow(weight, 0.75).toDouble(); // General calculation
    }

    // Activity multipliers
    double activityMultiplier = 1.0;
    switch (activityLevel.toLowerCase()) {
      case 'baixa':
      case 'sedentario':
        activityMultiplier = 1.2;
        break;
      case 'moderada':
      case 'normal':
        activityMultiplier = 1.6;
        break;
      case 'alta':
      case 'ativo':
        activityMultiplier = 2.0;
        break;
      case 'muito_alta':
      case 'muito_ativo':
        activityMultiplier = 2.5;
        break;
    }

    // Age adjustments
    if (age < 1) {
      activityMultiplier *= 2.0; // Growing animals need more calories
    } else if (age > 7) {
      activityMultiplier *= 0.9; // Senior animals need fewer calories
    }

    return baseCalories * activityMultiplier;
  }

  // Calculate life stage
  static String getLifeStage(int dataNascimento, String especie) {
    final ageInMonths = getAnimalAgeInMonths(dataNascimento);
    final especieLower = especie.toLowerCase();

    if (especieLower.contains('gato')) {
      if (ageInMonths < 12) return 'Filhote';
      if (ageInMonths < 36) return 'Jovem';
      if (ageInMonths < 84) return 'Adulto';
      return 'Idoso';
    } else if (especieLower.contains('cachorro') ||
        especieLower.contains('cão')) {
      if (ageInMonths < 12) return 'Filhote';
      if (ageInMonths < 18) return 'Jovem';
      if (ageInMonths < 84) return 'Adulto';
      return 'Idoso';
    } else {
      if (ageInMonths < 12) return 'Filhote';
      if (ageInMonths < 24) return 'Jovem';
      if (ageInMonths < 72) return 'Adulto';
      return 'Idoso';
    }
  }

  // Calculate human equivalent age
  static int getHumanEquivalentAge(int dataNascimento, String especie) {
    final ageInYears = getAnimalAge(dataNascimento);
    final especieLower = especie.toLowerCase();

    if (especieLower.contains('gato')) {
      if (ageInYears <= 0) return 0;
      if (ageInYears == 1) return 15;
      if (ageInYears == 2) return 24;
      return 24 + (ageInYears - 2) * 4;
    } else if (especieLower.contains('cachorro') ||
        especieLower.contains('cão')) {
      if (ageInYears <= 0) return 0;
      if (ageInYears == 1) return 15;
      if (ageInYears == 2) return 24;
      return 24 + (ageInYears - 2) * 5;
    } else {
      // General calculation for other animals
      return ageInYears * 7;
    }
  }

  // Calculate breeding readiness
  static Map<String, dynamic> getBreedingInfo(
      int dataNascimento, String especie, String sexo) {
    final ageInMonths = getAnimalAgeInMonths(dataNascimento);
    final especieLower = especie.toLowerCase();
    final isFemale = sexo.toLowerCase().contains('fêmea') ||
        sexo.toLowerCase().contains('femea');

    Map<String, dynamic> info = {
      'ready_for_breeding': false,
      'min_age_months': 6,
      'max_age_months': 96,
      'recommendation': '',
    };

    if (especieLower.contains('gato')) {
      info['min_age_months'] = isFemale ? 6 : 8;
      info['max_age_months'] = isFemale ? 84 : 120;
    } else if (especieLower.contains('cachorro') ||
        especieLower.contains('cão')) {
      info['min_age_months'] = isFemale ? 8 : 10;
      info['max_age_months'] = isFemale ? 96 : 120;
    }

    if (ageInMonths < info['min_age_months']) {
      info['recommendation'] = 'Muito jovem para reprodução';
    } else if (ageInMonths > info['max_age_months']) {
      info['recommendation'] = 'Idade avançada - consultar veterinário';
    } else {
      info['ready_for_breeding'] = true;
      info['recommendation'] = 'Idade adequada para reprodução';
    }

    return info;
  }

  // Calculate vaccination schedule
  static List<Map<String, dynamic>> getVaccinationSchedule(
      int dataNascimento, String especie) {
    final ageInWeeks = getAnimalAgeInDays(dataNascimento) ~/ 7;
    final especieLower = especie.toLowerCase();
    final schedule = <Map<String, dynamic>>[];

    if (especieLower.contains('gato')) {
      schedule.addAll([
        {
          'age_weeks': 6,
          'vaccine': 'Primeira dose múltipla',
          'status': ageInWeeks >= 6 ? 'due' : 'future'
        },
        {
          'age_weeks': 10,
          'vaccine': 'Segunda dose múltipla',
          'status': ageInWeeks >= 10 ? 'due' : 'future'
        },
        {
          'age_weeks': 14,
          'vaccine': 'Terceira dose múltipla + Raiva',
          'status': ageInWeeks >= 14 ? 'due' : 'future'
        },
        {
          'age_weeks': 52,
          'vaccine': 'Reforço anual',
          'status': ageInWeeks >= 52 ? 'due' : 'future'
        },
      ]);
    } else if (especieLower.contains('cachorro') ||
        especieLower.contains('cão')) {
      schedule.addAll([
        {
          'age_weeks': 6,
          'vaccine': 'Primeira dose múltipla',
          'status': ageInWeeks >= 6 ? 'due' : 'future'
        },
        {
          'age_weeks': 9,
          'vaccine': 'Segunda dose múltipla',
          'status': ageInWeeks >= 9 ? 'due' : 'future'
        },
        {
          'age_weeks': 12,
          'vaccine': 'Terceira dose múltipla',
          'status': ageInWeeks >= 12 ? 'due' : 'future'
        },
        {
          'age_weeks': 16,
          'vaccine': 'Raiva',
          'status': ageInWeeks >= 16 ? 'due' : 'future'
        },
        {
          'age_weeks': 52,
          'vaccine': 'Reforço anual',
          'status': ageInWeeks >= 52 ? 'due' : 'future'
        },
      ]);
    }

    return schedule;
  }

  // Helper method for dog weight ranges
  static Map<String, double> _getDogWeightRange(String raca, bool isMale) {
    // Simplified breed weight ranges
    if (raca.contains('poodle toy') || raca.contains('chihuahua')) {
      return {'min': 1.5, 'max': 3.0};
    } else if (raca.contains('poodle miniatura') || raca.contains('york')) {
      return {'min': 2.0, 'max': 4.0};
    } else if (raca.contains('poodle medio') || raca.contains('cocker')) {
      return {'min': 8.0, 'max': 15.0};
    } else if (raca.contains('poodle standard') ||
        raca.contains('border collie')) {
      return {'min': 15.0, 'max': 25.0};
    } else if (raca.contains('labrador') || raca.contains('golden')) {
      return isMale ? {'min': 29.0, 'max': 36.0} : {'min': 25.0, 'max': 32.0};
    } else if (raca.contains('pastor alemão') || raca.contains('rottweiler')) {
      return isMale ? {'min': 30.0, 'max': 40.0} : {'min': 22.0, 'max': 32.0};
    } else if (raca.contains('são bernardo') || raca.contains('mastiff')) {
      return isMale ? {'min': 65.0, 'max': 82.0} : {'min': 54.0, 'max': 64.0};
    } else {
      // General ranges by size category
      if (raca.contains('pequeno') || raca.contains('mini')) {
        return {'min': 3.0, 'max': 10.0};
      } else if (raca.contains('medio')) {
        return {'min': 10.0, 'max': 25.0};
      } else if (raca.contains('grande')) {
        return {'min': 25.0, 'max': 45.0};
      } else {
        return {'min': 5.0, 'max': 40.0}; // Very general range
      }
    }
  }
}
