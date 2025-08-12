// Package imports:
import 'package:intl/intl.dart';

class ConsultaFormUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
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
    final now = DateTime.now();
    return date.year == now.year;
  }

  static String getDiaSemana(int weekday) {
    const diasSemana = [
      'Segunda-feira',
      'Terça-feira', 
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo'
    ];
    
    if (weekday >= 1 && weekday <= 7) {
      return diasSemana[weekday - 1];
    }
    return 'Dia inválido';
  }

  static String getMes(int month) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    
    if (month >= 1 && month <= 12) {
      return meses[month - 1];
    }
    return 'Mês inválido';
  }

  static DateTime parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      throw FormatException('Formato de data inválido: $dateString');
    }
  }

  static DateTime? parseDateSafe(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) {
      return null;
    }
    
    try {
      return parseDate(dateString);
    } catch (e) {
      return null;
    }
  }

  static bool isValidDateRange(DateTime startDate, DateTime endDate) {
    return startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate);
  }

  static int daysBetween(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  static String getRelativeTimeString(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays == -1) {
      return 'Amanhã';
    } else if (difference.inDays > 1 && difference.inDays <= 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < -1 && difference.inDays >= -7) {
      return 'Em ${-difference.inDays} dias';
    } else {
      return formatDate(date);
    }
  }

  static String formatCurrency(double value) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(value);
  }

  static double? parseCurrency(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    
    // Remove símbolos de moeda e espaços
    String cleanValue = value
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');
    
    return double.tryParse(cleanValue);
  }
}
