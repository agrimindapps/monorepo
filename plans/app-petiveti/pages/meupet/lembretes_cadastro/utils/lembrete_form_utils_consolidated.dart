// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart' as app_date_utils;
import '../../../../../../app-petiveti/utils/format_utils.dart';
import '../../../../../../app-petiveti/utils/lembrete_utils.dart';
import '../../../../../../app-petiveti/utils/string_utils.dart';

class LembreteFormUtils {
  // Delegated functions to centralized utils
  static String formatDate(DateTime date) => app_date_utils.DateUtils.formatDate(date.millisecondsSinceEpoch);
  static String formatDateComplete(DateTime date) => app_date_utils.DateUtils.formatDateComplete(date);
  static DateTime? parseDate(String dateString) => app_date_utils.DateUtils.parseStringToDate(dateString);
  static String capitalize(String text) => StringUtils.capitalize(text);
  static String capitalizeWords(String text) => StringUtils.capitalizeWords(text);
  static String sanitizeText(String text) => StringUtils.sanitizeText(text);
  static String truncateText(String text, int maxLength) => FormatUtils.truncateText(text, maxLength);
  static bool isToday(DateTime date) => app_date_utils.DateUtils.isToday(date);
  static bool isTomorrow(DateTime date) => app_date_utils.DateUtils.isTomorrow(date);
  static bool isYesterday(DateTime date) => app_date_utils.DateUtils.isYesterday(date);
  static bool isThisWeek(DateTime date) => app_date_utils.DateUtils.isThisWeek(date);
  static bool isThisMonth(DateTime date) => app_date_utils.DateUtils.isThisMonth(date);
  static bool isThisYear(DateTime date) => app_date_utils.DateUtils.isThisYear(date);
  static bool isOverdue(DateTime date) => app_date_utils.DateUtils.isOverdue(date);
  static String getRelativeTime(DateTime date) => app_date_utils.DateUtils.getRelativeTimeString(date);
  static String getMes(int month) => app_date_utils.DateUtils.getMes(month);
  static String getMesAbreviado(int month) => app_date_utils.DateUtils.getMesAbreviado(month);
  static String getDiaSemana(int weekday) => app_date_utils.DateUtils.getDiaSemana(weekday);
  static String getDiaSemanaAbreviado(int weekday) => app_date_utils.DateUtils.getDiaSemanaAbreviado(weekday);
  static String escapeForCsv(String field) => FormatUtils.escapeForCsv(field);
  static DateTime getStartOfDay(DateTime date) => app_date_utils.DateUtils.getStartOfDay(date);
  static DateTime getEndOfDay(DateTime date) => app_date_utils.DateUtils.getEndOfDay(date);
  static List<String> getAvailableTipos() => LembreteUtils.getAvailableTipos();
  static String getTipoIcon(String tipo) => LembreteUtils.getTipoIcon(tipo);
  static Color getTipoColor(String tipo) => LembreteUtils.getTipoColor(tipo);
  static List<String> getRepetirOpcoes() => LembreteUtils.getRepetirOpcoes();
  static String? getTipoSuggestion(String tipo) => LembreteUtils.getTipoSuggestion(tipo);
  static bool isValidTitulo(String titulo) => LembreteUtils.isValidTitulo(titulo);
  static bool isValidDescricao(String? descricao) => LembreteUtils.isValidDescricao(descricao);
  static bool isValidDataHora(DateTime dataHora) => LembreteUtils.isValidDataHora(dataHora);
  static String getValidationMessage(String field, String? error) => LembreteUtils.getValidationMessage(field, error);
  static bool isLembreteAtrasado(DateTime dataHora) => LembreteUtils.isLembreteAtrasado(dataHora);
  static bool isLembreteHoje(DateTime dataHora) => LembreteUtils.isLembreteHoje(dataHora);
  static bool isLembreteUrgente(DateTime dataHora) => LembreteUtils.isLembreteUrgente(dataHora);
  static String getTempoRestante(DateTime dataHora) => LembreteUtils.getTempoRestante(dataHora);
  static Color getStatusColor(DateTime dataHora) => LembreteUtils.getStatusColor(dataHora);
  static String getStatusIcon(DateTime dataHora) => LembreteUtils.getStatusIcon(dataHora);
  static String getStatusText(DateTime dataHora) => LembreteUtils.getStatusText(dataHora);

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required String titulo,
    required DateTime dataHora,
    required String tipo,
    String? descricao,
    String? repetir,
  }) {
    return LembreteUtils.exportToJson(
      animalId: animalId,
      titulo: titulo,
      dataHora: dataHora,
      tipo: tipo,
      descricao: descricao,
      repetir: repetir,
    );
  }

  // Form-specific utility functions (keep these)
  static String getCharacterCountText(int current, int max) {
    return '$current/$max';
  }

  static Color getCharacterCountColor(int current, int max) {
    final percentage = current / max;

    if (percentage >= 1.0) {
      return const Color(0xFFE53935); // Red - over limit
    } else if (percentage >= 0.8) {
      return const Color(0xFFFF9800); // Orange - near limit
    } else {
      return const Color(0xFF757575); // Gray - normal
    }
  }

  static bool isCharacterLimitExceeded(int current, int max) {
    return current > max;
  }

  static bool isCharacterLimitNear(int current, int max) {
    return current > (max * 0.8);
  }

  static Map<String, dynamic> getFormStatistics({
    required String animalId,
    required String titulo,
    required DateTime? dataHora,
    required String tipo,
    String? descricao,
    String? repetir,
  }) {
    return {
      'hasAnimal': animalId.isNotEmpty,
      'hasTitulo': titulo.isNotEmpty,
      'hasDataHora': dataHora != null,
      'hasTipo': tipo.isNotEmpty,
      'hasDescricao': descricao != null && descricao.isNotEmpty,
      'hasRepetir': repetir != null && repetir.isNotEmpty,
      'tituloLength': titulo.length,
      'descricaoLength': descricao?.length ?? 0,
      'completionPercentage': _calculateCompletionPercentage(
        animalId: animalId,
        titulo: titulo,
        dataHora: dataHora,
        tipo: tipo,
        descricao: descricao,
        repetir: repetir,
      ),
    };
  }

  static double _calculateCompletionPercentage({
    required String animalId,
    required String titulo,
    required DateTime? dataHora,
    required String tipo,
    String? descricao,
    String? repetir,
  }) {
    int completed = 0;
    const int total = 4; // Required fields only

    if (animalId.isNotEmpty) completed++;
    if (titulo.isNotEmpty) completed++;
    if (dataHora != null) completed++;
    if (tipo.isNotEmpty) completed++;

    return (completed / total) * 100;
  }

  static String getFormCompletionText(double percentage) {
    if (percentage == 100) {
      return 'Formulário completo';
    } else if (percentage >= 75) {
      return 'Quase pronto';
    } else if (percentage >= 50) {
      return 'Metade completo';
    } else if (percentage > 0) {
      return 'Iniciado';
    } else {
      return 'Não iniciado';
    }
  }

  static Color getFormCompletionColor(double percentage) {
    if (percentage == 100) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage >= 75) {
      return const Color(0xFF66BB6A); // Light green
    } else if (percentage >= 50) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return const Color(0xFF757575); // Gray
    }
  }

  // Validation functions for forms
  static bool isFormValid({
    required String animalId,
    required String titulo,
    required DateTime? dataHora,
    required String tipo,
    String? descricao,
    String? repetir,
  }) {
    return animalId.isNotEmpty &&
        isValidTitulo(titulo) &&
        dataHora != null &&
        isValidDataHora(dataHora) &&
        tipo.isNotEmpty &&
        isValidDescricao(descricao);
  }

  static Map<String, String?> validateForm({
    required String animalId,
    required String titulo,
    required DateTime? dataHora,
    required String tipo,
    String? descricao,
    String? repetir,
  }) {
    final errors = <String, String?>{};

    if (animalId.isEmpty) {
      errors['animalId'] = 'Animal é obrigatório';
    }

    if (!isValidTitulo(titulo)) {
      errors['titulo'] = 'Título é obrigatório e deve ter no máximo 100 caracteres';
    }

    if (dataHora == null) {
      errors['dataHora'] = 'Data e hora são obrigatórias';
    } else if (!isValidDataHora(dataHora)) {
      errors['dataHora'] = 'Data deve estar entre hoje e um ano no futuro';
    }

    if (tipo.isEmpty) {
      errors['tipo'] = 'Tipo é obrigatório';
    }

    if (!isValidDescricao(descricao)) {
      errors['descricao'] = 'Descrição deve ter no máximo 500 caracteres';
    }

    return errors;
  }

  // Date/Time specific utilities
  static String formatTimeOnly(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDateTimeForDisplay(DateTime dateTime) {
    return '${formatDate(dateTime)} às ${formatTimeOnly(dateTime)}';
  }

  static DateTime? combineDateAndTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static TimeOfDay getTimeFromDateTime(DateTime dateTime) {
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  static DateTime getDateFromDateTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
