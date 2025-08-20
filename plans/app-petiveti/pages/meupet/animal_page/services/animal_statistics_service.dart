// Project imports:
import '../../../../models/11_animal_model.dart';
import '../../../../models/17_peso_model.dart';

class AnimalStatisticsService {
  // Calculate animal age in years
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

  // Calculate detailed age (years, months, days)
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
      'years': years,
      'months': months,
      'days': days,
    };
  }

  // Get age category
  static String getAgeCategory(int dataNascimento) {
    final age = getAnimalAge(dataNascimento);

    if (age < 1) return 'Filhote';
    if (age < 3) return 'Jovem';
    if (age < 7) return 'Adulto';
    return 'Idoso';
  }

  // Calculate collection statistics
  static Map<String, dynamic> getCollectionStatistics(List<Animal> animals) {
    if (animals.isEmpty) {
      return {
        'total': 0,
        'especies': <String, int>{},
        'racas': <String, int>{},
        'cores': <String, int>{},
        'sexos': <String, int>{},
        'categorias_idade': <String, int>{},
        'idade_media': 0.0,
        'peso_medio': 0.0,
        'mais_novo': null,
        'mais_velho': null,
        'mais_pesado': null,
        'mais_leve': null,
      };
    }

    final especies = <String, int>{};
    final racas = <String, int>{};
    final cores = <String, int>{};
    final sexos = <String, int>{};
    final categoriasIdade = <String, int>{};

    double totalIdade = 0;
    double totalPeso = 0;
    Animal? maisNovo;
    Animal? maisVelho;
    Animal? maisPesado;
    Animal? maisLeve;

    for (final animal in animals) {
      // Count species
      especies[animal.especie] = (especies[animal.especie] ?? 0) + 1;

      // Count breeds
      racas[animal.raca] = (racas[animal.raca] ?? 0) + 1;

      // Count colors
      cores[animal.cor] = (cores[animal.cor] ?? 0) + 1;

      // Count sexes
      sexos[animal.sexo] = (sexos[animal.sexo] ?? 0) + 1;

      // Age calculations
      final idade = getAnimalAge(animal.dataNascimento);
      totalIdade += idade;

      final categoria = getAgeCategory(animal.dataNascimento);
      categoriasIdade[categoria] = (categoriasIdade[categoria] ?? 0) + 1;

      // Find youngest and oldest
      if (maisNovo == null || animal.dataNascimento > maisNovo.dataNascimento) {
        maisNovo = animal;
      }
      if (maisVelho == null ||
          animal.dataNascimento < maisVelho.dataNascimento) {
        maisVelho = animal;
      }

      // Weight calculations
      totalPeso += animal.pesoAtual;

      // Find heaviest and lightest
      if (maisPesado == null || animal.pesoAtual > maisPesado.pesoAtual) {
        maisPesado = animal;
      }
      if (maisLeve == null || animal.pesoAtual < maisLeve.pesoAtual) {
        maisLeve = animal;
      }
    }

    return {
      'total': animals.length,
      'especies': especies,
      'racas': racas,
      'cores': cores,
      'sexos': sexos,
      'categorias_idade': categoriasIdade,
      'idade_media': totalIdade / animals.length,
      'peso_medio': totalPeso / animals.length,
      'mais_novo': maisNovo,
      'mais_velho': maisVelho,
      'mais_pesado': maisPesado,
      'mais_leve': maisLeve,
    };
  }

  // Get weight statistics for an animal
  static Map<String, dynamic> getWeightStatistics(List<PesoAnimal> pesos) {
    if (pesos.isEmpty) {
      return {
        'total_pesagens': 0,
        'peso_atual': 0.0,
        'peso_inicial': 0.0,
        'peso_maximo': 0.0,
        'peso_minimo': 0.0,
        'peso_medio': 0.0,
        'variacao_total': 0.0,
        'variacao_percentual': 0.0,
        'tendencia': 'estavel',
      };
    }

    // Sort by date (oldest first)
    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));

    final pesoInicial = sortedPesos.first.peso;
    final pesoAtual = sortedPesos.last.peso;
    final pesoMaximo =
        sortedPesos.map((p) => p.peso).reduce((a, b) => a > b ? a : b);
    final pesoMinimo =
        sortedPesos.map((p) => p.peso).reduce((a, b) => a < b ? a : b);
    final pesoMedio = sortedPesos.map((p) => p.peso).reduce((a, b) => a + b) /
        sortedPesos.length;

    final variacaoTotal = pesoAtual - pesoInicial;
    final variacaoPercentual =
        pesoInicial > 0 ? (variacaoTotal / pesoInicial) * 100 : 0.0;

    // Determine trend based on recent weights
    String tendencia = 'estavel';
    if (sortedPesos.length >= 3) {
      final recent = sortedPesos.sublist(sortedPesos.length - 3);
      final firstRecent = recent.first.peso;
      final lastRecent = recent.last.peso;

      if (lastRecent > firstRecent + 0.1) {
        tendencia = 'crescimento';
      } else if (lastRecent < firstRecent - 0.1) {
        tendencia = 'perda';
      }
    }

    return {
      'total_pesagens': sortedPesos.length,
      'peso_atual': pesoAtual,
      'peso_inicial': pesoInicial,
      'peso_maximo': pesoMaximo,
      'peso_minimo': pesoMinimo,
      'peso_medio': pesoMedio,
      'variacao_total': variacaoTotal,
      'variacao_percentual': variacaoPercentual,
      'tendencia': tendencia,
    };
  }

  // Calculate monthly growth statistics
  static Map<String, dynamic> getMonthlyGrowthStats(List<PesoAnimal> pesos) {
    if (pesos.length < 2) return {};

    final sortedPesos = List<PesoAnimal>.from(pesos)
      ..sort((a, b) => a.dataPesagem.compareTo(b.dataPesagem));

    final monthlyStats = <String, List<double>>{};

    for (int i = 1; i < sortedPesos.length; i++) {
      final previous = sortedPesos[i - 1];
      final current = sortedPesos[i];

      final currentDate =
          DateTime.fromMillisecondsSinceEpoch(current.dataPesagem);

      final monthKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}';
      final weightDiff = current.peso - previous.peso;

      monthlyStats[monthKey] ??= [];
      monthlyStats[monthKey]!.add(weightDiff);
    }

    // Calculate averages for each month
    final monthlyAverages = <String, double>{};
    monthlyStats.forEach((month, diffs) {
      monthlyAverages[month] = diffs.reduce((a, b) => a + b) / diffs.length;
    });

    return {
      'monthly_changes': monthlyStats,
      'monthly_averages': monthlyAverages,
    };
  }

  // Generate age distribution for a group of animals
  static Map<String, int> getAgeDistribution(List<Animal> animals) {
    final distribution = <String, int>{
      '0-1 anos': 0,
      '1-3 anos': 0,
      '3-7 anos': 0,
      '7+ anos': 0,
    };

    for (final animal in animals) {
      final age = getAnimalAge(animal.dataNascimento);

      if (age < 1) {
        distribution['0-1 anos'] = distribution['0-1 anos']! + 1;
      } else if (age < 3) {
        distribution['1-3 anos'] = distribution['1-3 anos']! + 1;
      } else if (age < 7) {
        distribution['3-7 anos'] = distribution['3-7 anos']! + 1;
      } else {
        distribution['7+ anos'] = distribution['7+ anos']! + 1;
      }
    }

    return distribution;
  }

  // Get health indicators based on weight trends
  static Map<String, dynamic> getHealthIndicators(
      Animal animal, List<PesoAnimal> pesos) {
    final weightStats = getWeightStatistics(pesos);
    final age = getAnimalAge(animal.dataNascimento);

    // Basic health indicators
    final indicators = <String, dynamic>{
      'peso_ideal': _getIdealWeightRange(animal.especie, animal.raca),
      'status_peso':
          _getWeightStatus(animal.pesoAtual, animal.especie, animal.raca),
      'variacao_peso_saudavel': weightStats['variacao_percentual'].abs() < 10,
      'necessita_monitoramento': false,
      'recomendacoes': <String>[],
    };

    // Add recommendations based on analysis
    final recomendacoes = <String>[];

    if (weightStats['tendencia'] == 'perda' &&
        weightStats['variacao_percentual'] < -10) {
      recomendacoes.add('Consultar veterinário - perda de peso significativa');
      indicators['necessita_monitoramento'] = true;
    }

    if (weightStats['tendencia'] == 'crescimento' &&
        weightStats['variacao_percentual'] > 20) {
      recomendacoes.add('Revisar dieta - ganho de peso excessivo');
      indicators['necessita_monitoramento'] = true;
    }

    if (age > 7 && pesos.length < 4) {
      recomendacoes.add('Aumentar frequência de pesagens para animais idosos');
    }

    indicators['recomendacoes'] = recomendacoes;

    return indicators;
  }

  // Helper method to get ideal weight range by species/breed
  static Map<String, double> _getIdealWeightRange(String especie, String raca) {
    // This is a simplified version - in a real app, you'd have a comprehensive database
    final especieLower = especie.toLowerCase();

    if (especieLower.contains('gato')) {
      return {'min': 2.5, 'max': 7.0};
    } else if (especieLower.contains('cachorro') ||
        especieLower.contains('cão')) {
      // Simplified breed-based ranges
      final racaLower = raca.toLowerCase();
      if (racaLower.contains('poodle') || racaLower.contains('pequeno')) {
        return {'min': 3.0, 'max': 8.0};
      } else if (racaLower.contains('labrador') ||
          racaLower.contains('golden')) {
        return {'min': 25.0, 'max': 35.0};
      } else {
        return {'min': 5.0, 'max': 40.0}; // General range
      }
    }

    return {'min': 1.0, 'max': 50.0}; // Very general range
  }

  // Helper method to determine weight status
  static String _getWeightStatus(
      double pesoAtual, String especie, String raca) {
    final idealRange = _getIdealWeightRange(especie, raca);

    if (pesoAtual < idealRange['min']!) {
      return 'Abaixo do peso';
    } else if (pesoAtual > idealRange['max']!) {
      return 'Acima do peso';
    } else {
      return 'Peso ideal';
    }
  }
}
