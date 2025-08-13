// Package imports:
import 'package:intl/intl.dart';

/// Utilitários centralizados para formatação de datas
/// Consolidação do DateFormattingService com melhorias
class AppDateUtils {
  static const AppDateUtils _instance = AppDateUtils._internal();
  factory AppDateUtils() => _instance;
  const AppDateUtils._internal();

  // Constantes para validação de range
  static final DateTime _minDate = DateTime(1900, 1, 1);
  static final DateTime _maxDate = DateTime(2100, 12, 31);

  /// Formata data para exibição relativa (hoje, amanhã, em X dias)
  /// Usado pelos TaskItemWidgets para mostrar datas de forma user-friendly
  static String formatRelative(DateTime? data, {String? locale}) {
    final effectiveLocale = locale ?? 'pt_BR';
    try {
      if (data == null) return 'Data não informada';

      if (data.isBefore(_minDate) || data.isAfter(_maxDate)) {
        return formatAbsolute(data, locale: effectiveLocale);
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDate = DateTime(data.year, data.month, data.day);

      final difference = targetDate.difference(today).inDays;

      if (difference == 0) return 'Hoje';
      if (difference == 1) return 'Amanhã';
      if (difference == -1) return 'Ontem';

      // Casos passados (para tarefas atrasadas)
      if (difference < -1) {
        final abs = difference.abs();
        if (abs <= 7) {
          return 'Há $abs dia${abs > 1 ? 's' : ''}';
        } else {
          return formatAbsolute(data, locale: effectiveLocale);
        }
      }

      // Casos futuros
      if (difference > 1) {
        if (difference <= 7) {
          return 'Em $difference dia${difference > 1 ? 's' : ''}';
        } else {
          return formatAbsolute(data, locale: effectiveLocale);
        }
      }

      return formatAbsolute(data, locale: effectiveLocale);
    } catch (e) {
      return _safeFallbackFormat(data);
    }
  }

  /// Formata data para tarefas com contexto de atraso
  /// Especializado para os TaskItemWidgets
  static String formatTaskDate(DateTime? date, {bool? isOverdue}) {
    if (date == null) return 'Data não informada';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final actuallyOverdue = isOverdue ?? taskDate.isBefore(today);

    if (actuallyOverdue) {
      final overdueDays = today.difference(taskDate).inDays;
      if (overdueDays == 0) {
        return 'Venceu hoje';
      } else if (overdueDays == 1) {
        return 'Venceu ontem';
      } else {
        return 'Venceu há $overdueDays dia${overdueDays > 1 ? 's' : ''}';
      }
    } else {
      final difference = taskDate.difference(today).inDays;
      if (difference == 0) {
        return 'Hoje';
      } else if (difference == 1) {
        return 'Amanhã';
      } else if (difference <= 7) {
        return 'Em $difference dia${difference > 1 ? 's' : ''}';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    }
  }

  /// Versão simplificada para widgets que só precisam de "Até dd/MM" ou "Atrasado desde dd/MM"
  static String formatTaskDateSimple(DateTime? date, {bool? isOverdue}) {
    if (date == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    final actuallyOverdue = isOverdue ?? taskDate.isBefore(today);

    if (actuallyOverdue) {
      return 'Atrasado desde ${DateFormat('dd/MM').format(date)}';
    } else {
      return 'Até ${DateFormat('dd/MM').format(date)}';
    }
  }

  /// Formata data no formato absoluto (dd/MM/yyyy)
  static String formatAbsolute(DateTime? data, {String? locale}) {
    final effectiveLocale = locale ?? 'pt_BR';
    try {
      if (data == null) return 'Data não informada';

      if (data.isBefore(_minDate) || data.isAfter(_maxDate)) {
        return 'Data inválida';
      }

      try {
        final formatter = DateFormat('dd/MM/yyyy', effectiveLocale);
        return formatter.format(data);
      } catch (e) {
        final formatter = DateFormat('dd/MM/yyyy', 'pt_BR');
        return formatter.format(data);
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

      if (data.isBefore(_minDate) || data.isAfter(_maxDate)) {
        return 'Data inválida';
      }

      try {
        final formatter = DateFormat('d \'de\' MMMM \'de\' yyyy', locale);
        return formatter.format(data);
      } catch (e) {
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

  /// Verifica se uma data está vencida (para tarefas)
  static bool isOverdue(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    return taskDate.isBefore(today);
  }

  /// Verifica se uma data é hoje
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate == today;
  }

  /// Verifica se uma data é amanhã
  static bool isTomorrow(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate == tomorrow;
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

      final day = data.day.toString().padLeft(2, '0');
      final month = data.month.toString().padLeft(2, '0');
      final year = data.year.toString();

      return '$day/$month/$year';
    } catch (e) {
      return 'Data inválida';
    }
  }
}
