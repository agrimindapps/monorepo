// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart';
import '../../../../../../app-petiveti/utils/format_utils.dart';
import 'animal_calculations.dart';

class AnimalFormatters {
  // Format animal age in a human-readable way
  static String formatAge(int dataNascimento) {
    final detailedAge = AnimalCalculations.getDetailedAge(dataNascimento);
    final years = detailedAge['years']!;
    final months = detailedAge['months']!;
    final days = detailedAge['days']!;

    if (years > 0) {
      if (months > 0) {
        return '$years ${years == 1 ? 'ano' : 'anos'} e $months ${months == 1 ? 'mês' : 'meses'}';
      } else {
        return '$years ${years == 1 ? 'ano' : 'anos'}';
      }
    } else if (months > 0) {
      if (days > 7) {
        final weeks = days ~/ 7;
        return '$months ${months == 1 ? 'mês' : 'meses'} e $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
      } else {
        return '$months ${months == 1 ? 'mês' : 'meses'}';
      }
    } else {
      if (days > 0) {
        return '$days ${days == 1 ? 'dia' : 'dias'}';
      } else {
        return 'Recém-nascido';
      }
    }
  }

  // Format age in short form (for cards/lists)
  static String formatAgeShort(int dataNascimento) {
    final age = AnimalCalculations.getAnimalAge(dataNascimento);
    final ageInMonths = AnimalCalculations.getAnimalAgeInMonths(dataNascimento);

    if (age > 0) {
      return '${age}a';
    } else if (ageInMonths > 0) {
      return '${ageInMonths}m';
    } else {
      final days = AnimalCalculations.getAnimalAgeInDays(dataNascimento);
      return '${days}d';
    }
  }

  // Get animal initials for avatar
  static String getAnimalInitials(String nome) {
    if (nome.isEmpty) return 'AN';

    final words = nome.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase() +
          (words[0].length > 1 ? words[0].substring(1, 2).toUpperCase() : '');
    } else {
      return words[0].substring(0, 1).toUpperCase() +
          words[1].substring(0, 1).toUpperCase();
    }
  }

  // Format weight with appropriate unit
  static String formatWeight(double peso) {
    return FormatUtils.formatWeight(peso);
  }

  // Format weight change
  static String formatWeightChange(double change) {
    final abs = change.abs();
    final sign = change >= 0 ? '+' : '-';

    if (abs >= 1.0) {
      return '$sign${abs.toStringAsFixed(1)} kg';
    } else {
      final gramas = (abs * 1000).round();
      return '$sign${gramas}g';
    }
  }

  // Format birth date
  static String formatBirthDate(int dataNascimento) {
    return DateUtils.formatDate(dataNascimento);
  }

  // Format date range
  static String formatDateRange(DateTime start, DateTime end) {
    return DateUtils.formatDateRange(start, end);
  }

  // Format species/breed display
  static String formatBreed(String especie, String raca) {
    if (raca.toLowerCase() == 'sem raça definida' ||
        raca.toLowerCase() == 'srd') {
      return '$especie SRD';
    }
    return '$especie - $raca';
  }

  // Format human equivalent age
  static String formatHumanAge(int dataNascimento, String especie) {
    final humanAge =
        AnimalCalculations.getHumanEquivalentAge(dataNascimento, especie);
    return '$humanAge ${humanAge == 1 ? 'ano' : 'anos'} (humano)';
  }

  // Format life stage with icon
  static Map<String, String> formatLifeStage(
      int dataNascimento, String especie) {
    final stage = AnimalCalculations.getLifeStage(dataNascimento, especie);

    String icon;
    switch (stage) {
      case 'Filhote':
        icon = '🐣';
        break;
      case 'Jovem':
        icon = '🌱';
        break;
      case 'Adulto':
        icon = '🦁';
        break;
      case 'Idoso':
        icon = '👴';
        break;
      default:
        icon = '🐾';
    }

    return {'stage': stage, 'icon': icon};
  }

  // Format weight status with color code
  static Map<String, dynamic> formatWeightStatus(
      double peso, String especie, String raca, String sexo) {
    final status =
        AnimalCalculations.getWeightStatus(peso, especie, raca, sexo);

    String color;
    String icon;

    switch (status) {
      case 'Muito abaixo do peso':
        color = '#FF5252'; // Red
        icon = '⬇️';
        break;
      case 'Abaixo do peso':
        color = '#FF9800'; // Orange
        icon = '📉';
        break;
      case 'Peso ideal':
        color = '#4CAF50'; // Green
        icon = '✅';
        break;
      case 'Acima do peso':
        color = '#FF9800'; // Orange
        icon = '📈';
        break;
      case 'Muito acima do peso':
        color = '#FF5252'; // Red
        icon = '⬆️';
        break;
      default:
        color = '#757575'; // Grey
        icon = '❓';
    }

    return {
      'status': status,
      'color': color,
      'icon': icon,
    };
  }

  // Format vaccination status
  static String formatVaccinationStatus(List<Map<String, dynamic>> schedule) {
    final due = schedule.where((v) => v['status'] == 'due').length;
    final total = schedule.length;

    if (due == 0) {
      return 'Em dia';
    } else {
      return '$due de $total pendente${due > 1 ? 's' : ''}';
    }
  }

  // Format daily calories
  static String formatCalories(double calories) {
    return '${calories.round()} kcal/dia';
  }

  // Format percentage
  static String formatPercentage(double percentage) {
    return FormatUtils.formatPercentage(percentage);
  }

  // Format decimal places for weight
  static String formatPreciseWeight(double peso) {
    return peso.toStringAsFixed(2);
  }

  // Format time period
  static String formatTimePeriod(Duration duration) {
    return DateUtils.formatTimePeriod(duration);
  }

  // Format large numbers (for statistics)
  static String formatLargeNumber(int number) {
    return FormatUtils.formatLargeNumber(number);
  }

  // Format animal count with proper pluralization
  static String formatAnimalCount(int count, String type) {
    if (count == 0) {
      return 'Nenhum $type';
    } else if (count == 1) {
      return '1 $type';
    } else {
      // Simple pluralization
      final plural =
          type.endsWith('ão') ? type.replaceAll('ão', 'ões') : '${type}s';
      return '$count $plural';
    }
  }

  // Format search result count
  static String formatSearchResults(int total, int filtered, String query) {
    if (query.isEmpty) {
      return formatAnimalCount(total, 'animal');
    } else {
      return '$filtered de $total animais';
    }
  }

  // Format filter description
  static String formatFilterDescription(
      String filter, Map<String, int> counts) {
    switch (filter) {
      case 'todos':
        return 'Todos os animais (${counts['todos'] ?? 0})';
      case 'cachorros':
        return 'Cachorros (${counts['cachorros'] ?? 0})';
      case 'gatos':
        return 'Gatos (${counts['gatos'] ?? 0})';
      case 'outros':
        return 'Outros (${counts['outros'] ?? 0})';
      default:
        return filter;
    }
  }

  // Format animal card subtitle
  static String formatCardSubtitle(
      String especie, String raca, int dataNascimento) {
    final breed = formatBreed(especie, raca);
    final age = formatAgeShort(dataNascimento);
    return '$breed • $age';
  }

  // Format statistics summary
  static String formatStatsSummary(Map<String, dynamic> stats) {
    final total = stats['total'] ?? 0;
    final avgAge = stats['idade_media'] ?? 0.0;
    final avgWeight = stats['peso_medio'] ?? 0.0;

    return 'Total: $total • Idade média: ${avgAge.toStringAsFixed(1)} anos • Peso médio: ${formatWeight(avgWeight)}';
  }
}
