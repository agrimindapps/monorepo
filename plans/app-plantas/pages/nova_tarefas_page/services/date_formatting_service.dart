// Package imports:
import 'package:intl/intl.dart';

/// Service centralizado para formatação de datas
/// Garante consistência e trata edge cases em toda a aplicação
class DateFormattingService {
  static const DateFormattingService _instance =
      DateFormattingService._internal();
  factory DateFormattingService() => _instance;
  const DateFormattingService._internal();

  // Constantes para validação de range
  static final DateTime _minDate = DateTime(1900, 1, 1);
  static final DateTime _maxDate = DateTime(2100, 12, 31);

  /// Formata data para exibição relativa (hoje, amanhã, em X dias)
  /// Trata edge cases como datas inválidas, extremas e problemas de timezone
  static String formatRelative(DateTime? data, {String? locale}) {
    final effectiveLocale = locale ?? 'pt_BR';
    try {
      // Validação de entrada
      if (data == null) return 'Data não informada';

      // Validação de range
      if (data.isBefore(_minDate) || data.isAfter(_maxDate)) {
        return formatAbsolute(data, locale: effectiveLocale);
      }

      // Normalizar datas para UTC para evitar problemas de timezone
      final now = DateTime.now().toUtc();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(data.year, data.month, data.day);

      final difference = targetDate.difference(today).inDays;

      // Casos relativos
      if (difference == 0) return 'Hoje';
      if (difference == 1) return 'Amanhã';
      if (difference == -1) return 'Ontem';

      // Casos passados
      if (difference < -1) {
        final abs = difference.abs();
        if (abs <= 7) {
          return 'Há $abs dia${abs > 1 ? 's' : ''}';
        } else if (abs <= 30) {
          final weeks = (abs / 7).floor();
          return 'Há $weeks semana${weeks > 1 ? 's' : ''}';
        } else {
          return formatAbsolute(data, locale: effectiveLocale);
        }
      }

      // Casos futuros
      if (difference > 1) {
        if (difference <= 7) {
          return 'Em $difference dia${difference > 1 ? 's' : ''}';
        } else if (difference <= 30) {
          final weeks = (difference / 7).floor();
          return 'Em $weeks semana${weeks > 1 ? 's' : ''}';
        } else {
          return formatAbsolute(data, locale: effectiveLocale);
        }
      }

      // Fallback para casos não cobertos
      return formatAbsolute(data, locale: effectiveLocale);
    } catch (e) {
      // Em caso de erro, retorna formatação absoluta segura
      return _safeFallbackFormat(data);
    }
  }

  /// Formata data no formato absoluto (dd/MM/yyyy)
  /// Com suporte a diferentes locales
  static String formatAbsolute(DateTime? data, {String? locale}) {
    final effectiveLocale = locale ?? 'pt_BR';
    try {
      if (data == null) return 'Data não informada';

      // Validação de range
      if (data.isBefore(_minDate) || data.isAfter(_maxDate)) {
        return 'Data inválida';
      }

      // Usar DateFormat para formatação locale-aware
      try {
        final formatter = DateFormat('dd/MM/yyyy', effectiveLocale);
        return formatter.format(data);
      } catch (e) {
        // Fallback para locale padrão se o locale especificado falhar
        final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
        return formatter.format(data);
      }
    } catch (e) {
      return _safeFallbackFormat(data);
    }
  }

  /// Formata data para seleção (com padding zero)
  static String formatSelection(DateTime? data, {String locale = 'pt_BR'}) {
    try {
      if (data == null) return 'Data não informada';

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(data.year, data.month, data.day);

      if (targetDate == today) {
        return 'Hoje';
      } else {
        return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
      }
    } catch (e) {
      return _safeFallbackFormat(data);
    }
  }

  /// Formata data com nome do mês (ex: 15 de Janeiro de 2024)
  static String formatWithMonthName(DateTime? data, {String? locale}) {
    final effectiveLocale = locale ?? 'pt_BR';
    try {
      if (data == null) return 'Data não informada';

      // Validação de range
      if (data.isBefore(_minDate) || data.isAfter(_maxDate)) {
        return 'Data inválida';
      }

      try {
        final formatter = DateFormat('d \'de\' MMMM \'de\' yyyy', locale);
        return formatter.format(data);
      } catch (e) {
        // Fallback manual para nomes de mês em português
        final monthNames = [
          '',
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

        if (data.month >= 1 && data.month <= 12) {
          return '${data.day} de ${monthNames[data.month]} de ${data.year}';
        } else {
          return formatAbsolute(data, locale: effectiveLocale);
        }
      }
    } catch (e) {
      return _safeFallbackFormat(data);
    }
  }

  /// Formata data com dia da semana (ex: Segunda-feira, 15 de Janeiro)
  static String formatWithWeekday(DateTime? data,
      {String? locale, bool includeYear = false}) {
    final effectiveLocale = locale ?? 'pt_BR';
    try {
      if (data == null) return 'Data não informada';

      // Validação de range
      if (data.isBefore(_minDate) || data.isAfter(_maxDate)) {
        return 'Data inválida';
      }

      try {
        final pattern = includeYear
            ? 'EEEE, d \'de\' MMMM \'de\' yyyy'
            : 'EEEE, d \'de\' MMMM';
        final formatter = DateFormat(pattern, effectiveLocale);
        return formatter.format(data);
      } catch (e) {
        // Fallback manual
        final weekdayNames = [
          '',
          'Segunda-feira',
          'Terça-feira',
          'Quarta-feira',
          'Quinta-feira',
          'Sexta-feira',
          'Sábado',
          'Domingo'
        ];

        final monthNames = [
          '',
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

        final weekday = data.weekday;
        final month = data.month;

        if (weekday >= 1 && weekday <= 7 && month >= 1 && month <= 12) {
          final result =
              '${weekdayNames[weekday]}, ${data.day} de ${monthNames[month]}';
          return includeYear ? '$result de ${data.year}' : result;
        } else {
          return formatAbsolute(data, locale: effectiveLocale);
        }
      }
    } catch (e) {
      return _safeFallbackFormat(data);
    }
  }

  /// Verifica se uma data está dentro do range válido
  static bool isValidDate(DateTime? data) {
    if (data == null) return false;
    return data.isAfter(_minDate) && data.isBefore(_maxDate);
  }

  /// Normaliza uma data para evitar problemas de timezone
  static DateTime normalizeDate(DateTime data) {
    try {
      return DateTime(data.year, data.month, data.day);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Calcula diferença segura entre datas em dias
  static int safeDaysDifference(DateTime? start, DateTime? end) {
    try {
      if (start == null || end == null) return 0;

      final normalizedStart = normalizeDate(start);
      final normalizedEnd = normalizeDate(end);

      return normalizedEnd.difference(normalizedStart).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Formato de fallback seguro quando tudo mais falha
  static String _safeFallbackFormat(DateTime? data) {
    try {
      if (data == null) return 'Data não informada';

      // Formatação manual básica sem dependências externas
      final day = data.day.toString().padLeft(2, '0');
      final month = data.month.toString().padLeft(2, '0');
      final year = data.year.toString();

      return '$day/$month/$year';
    } catch (e) {
      return 'Data inválida';
    }
  }

  /// Testa se o ano é bissexto (para validações extras)
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Valida se uma data específica é válida (ex: 29 de Fevereiro em ano não bissexto)
  static bool isValidSpecificDate(int year, int month, int day) {
    try {
      if (year < 1900 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;

      // Verificar dias por mês
      final daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

      // Ajustar para ano bissexto
      if (month == 2 && isLeapYear(year)) {
        daysInMonth[1] = 29;
      }

      return day <= daysInMonth[month - 1];
    } catch (e) {
      return false;
    }
  }
}
