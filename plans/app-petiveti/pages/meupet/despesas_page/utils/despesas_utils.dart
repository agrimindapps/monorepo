// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import '../../../../models/13_despesa_model.dart';
import '../../../../utils/despesas_utils.dart' as centralized_utils;

class DespesasUtils {
  static String formatarData(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatarDataAtual() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[now.month - 1]} ${now.year.toString().substring(2)}';
  }

  /// Gera lista de meses baseada nos registros de despesa existentes
  static List<String> gerarListaMesesDisponiveis(List<DespesaVet> despesas) {
    if (despesas.isEmpty) {
      // Se não há registros, retorna o mês atual
      return [formatarDataAtual()];
    }

    // Ordena despesas por data
    final sortedDespesas = List<DespesaVet>.from(despesas)
      ..sort((a, b) => a.dataDespesa.compareTo(b.dataDespesa));

    // Obtém data mais antiga e mais recente
    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.first.dataDespesa);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.last.dataDespesa);

    // Gera lista de meses entre as datas
    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = '${months[currentDate.month - 1]} ${currentDate.year.toString().substring(2)}';
      meses.add(mesFormatado);
      
      // Avança para o próximo mês
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    // Se o mês atual não está na lista, adiciona
    final mesAtual = formatarDataAtual();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList(); // Mais recente primeiro
  }

  /// Obtém o período de registros (mês mais antigo ao mais recente)
  static String formatarPeriodoDespesas(List<DespesaVet> despesas) {
    if (despesas.isEmpty) {
      return formatarDataAtual();
    }

    final sortedDespesas = List<DespesaVet>.from(despesas)
      ..sort((a, b) => a.dataDespesa.compareTo(b.dataDespesa));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.first.dataDespesa);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedDespesas.last.dataDespesa);

    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    final mesInicial = '${months[dataInicial.month - 1]} ${dataInicial.year.toString().substring(2)}';
    final mesFinal = '${months[dataFinal.month - 1]} ${dataFinal.year.toString().substring(2)}';

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  static String formatarDataCompleta(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatarDataRelativa(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semana${weeks > 1 ? 's' : ''} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ano${years > 1 ? 's' : ''} atrás';
    }
  }

  static String formatarValor(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  static String formatarValorComMoeda(double valor) {
    return 'R\$ ${formatarValor(valor)}';
  }

  static String formatarValorAbreviado(double valor) {
    if (valor >= 1000000) {
      return 'R\$ ${(valor / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M';
    } else if (valor >= 1000) {
      return 'R\$ ${(valor / 1000).toStringAsFixed(1).replaceAll('.', ',')}K';
    } else {
      return formatarValorComMoeda(valor);
    }
  }

  static double parseValor(String valorString) {
    try {
      // Remove currency symbols and replace comma with dot
      final cleanValue = valorString
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll(',', '.');
      return double.parse(cleanValue);
    } catch (e) {
      return 0.0;
    }
  }

  static String getMes(int month) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }

  static String getMesAbreviado(int month) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months[month - 1];
  }

  static String getDiaSemana(int weekday) {
    const weekdays = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira',
      'Sexta-feira', 'Sábado', 'Domingo'
    ];
    return weekdays[weekday - 1];
  }

  static String getDiaSemanaAbreviado(int weekday) {
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return weekdays[weekday - 1];
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool isValidValue(String value) {
    try {
      final parsedValue = parseValor(value);
      return parsedValue >= 0;
    } catch (e) {
      return false;
    }
  }

  static bool isValidDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return false;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      if (day < 1 || day > 31) return false;
      if (month < 1 || month > 12) return false;
      if (year < 1900 || year > 2100) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static DateTime? parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  static String escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static List<String> getCommonTipos() {
    return [
      'Consulta',
      'Vacina',
      'Medicamento',
      'Exame',
      'Cirurgia',
      'Emergência',
      'Banho e Tosa',
      'Alimentação',
      'Petiscos',
      'Brinquedos',
      'Acessórios',
      'Hospedagem',
      'Transporte',
      'Seguro',
      'Outros',
    ];
  }

  static String getTipoIcon(String tipo) {
    return centralized_utils.DespesasUtils.getTipoIcon(tipo);
  }

  static String getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'consulta':
        return '#4CAF50'; // Green
      case 'vacina':
        return '#2196F3'; // Blue
      case 'medicamento':
        return '#FF9800'; // Orange
      case 'exame':
        return '#9C27B0'; // Purple
      case 'cirurgia':
        return '#F44336'; // Red
      case 'emergência':
        return '#E91E63'; // Pink
      case 'banho e tosa':
        return '#00BCD4'; // Cyan
      case 'alimentação':
        return '#8BC34A'; // Light Green
      case 'petiscos':
        return '#FFC107'; // Amber
      case 'brinquedos':
        return '#FF5722'; // Deep Orange
      case 'acessórios':
        return '#673AB7'; // Deep Purple
      case 'hospedagem':
        return '#795548'; // Brown
      case 'transporte':
        return '#607D8B'; // Blue Grey
      case 'seguro':
        return '#3F51B5'; // Indigo
      default:
        return '#9E9E9E'; // Grey
    }
  }

  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static String getFormattedRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatarData(start.millisecondsSinceEpoch);
    }
    return '${formatarData(start.millisecondsSinceEpoch)} - ${formatarData(end.millisecondsSinceEpoch)}';
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  static Map<String, dynamic> generateSummary(List<DespesaVet> despesas) {
    if (despesas.isEmpty) {
      return {
        'total': 0.0,
        'count': 0,
        'average': 0.0,
        'highest': null,
        'lowest': null,
        'mostCommonType': '',
        'thisMonth': 0.0,
        'thisYear': 0.0,
      };
    }

    final total = despesas.fold(0.0, (sum, d) => sum + d.valor);
    final average = total / despesas.length;
    
    final sorted = List<DespesaVet>.from(despesas);
    sorted.sort((a, b) => b.valor.compareTo(a.valor));
    
    final highest = sorted.first;
    final lowest = sorted.last;
    
    // Most common type
    final typeCounts = <String, int>{};
    for (final despesa in despesas) {
      typeCounts[despesa.tipo] = (typeCounts[despesa.tipo] ?? 0) + 1;
    }
    
    String mostCommonType = '';
    int maxCount = 0;
    for (final entry in typeCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostCommonType = entry.key;
      }
    }
    
    // This month and year totals
    final thisMonthDespesas = despesas.where((d) {
      final date = DateTime.fromMillisecondsSinceEpoch(d.dataDespesa);
      return isThisMonth(date);
    });
    
    final thisYearDespesas = despesas.where((d) {
      final date = DateTime.fromMillisecondsSinceEpoch(d.dataDespesa);
      return isThisYear(date);
    });
    
    final thisMonthTotal = thisMonthDespesas.fold(0.0, (sum, d) => sum + d.valor);
    final thisYearTotal = thisYearDespesas.fold(0.0, (sum, d) => sum + d.valor);

    return {
      'total': total,
      'count': despesas.length,
      'average': average,
      'highest': highest,
      'lowest': lowest,
      'mostCommonType': mostCommonType,
      'thisMonth': thisMonthTotal,
      'thisYear': thisYearTotal,
    };
  }

  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'há $years ano${years > 1 ? 's' : ''}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'há $months mês${months > 1 ? 'es' : ''}';
    } else if (difference.inDays > 0) {
      return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'há ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'agora';
    }
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }
}
