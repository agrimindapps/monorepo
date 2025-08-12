// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart' as app_date_utils;
import '../../../../../../app-petiveti/utils/format_utils.dart';
import '../../../../../../app-petiveti/utils/medicamentos_utils.dart';
import '../../../../../../app-petiveti/utils/string_utils.dart';

class MedicamentoUtils {
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
  static List<String> getAvailableTipos() => MedicamentosUtils.getAvailableTipos();
  static List<String> getCommonTipos() => MedicamentosUtils.getCommonTipos();
  static List<String> getFrequencias() => MedicamentosUtils.getFrequencias();
  static List<String> getUnidades() => MedicamentosUtils.getUnidades();
  static String getTipoIcon(String tipo) => MedicamentosUtils.getTipoIcon(tipo);
  static Color getTipoColor(String tipo) => MedicamentosUtils.getTipoColor(tipo);
  static String? getTipoSuggestion(String tipo) => MedicamentosUtils.getTipoSuggestion(tipo);
  static bool isValidNome(String nome) => MedicamentosUtils.isValidNome(nome);
  static bool isValidTipo(String tipo) => MedicamentosUtils.isValidTipo(tipo);
  static bool isValidDosagem(String dosagem) => MedicamentosUtils.isValidDosagem(dosagem);
  static bool isValidFrequencia(String frequencia) => MedicamentosUtils.isValidFrequencia(frequencia);
  static bool isValidDuracao(int duracao) => MedicamentosUtils.isValidDuracao(duracao);
  static bool isValidObservacoes(String? observacoes) => MedicamentosUtils.isValidObservacoes(observacoes);
  static String getValidationMessage(String field, String? error) => MedicamentosUtils.getValidationMessage(field, error);
  static int diasRestantesTratamento(DateTime dataInicio, int duracaoDias) => MedicamentosUtils.diasRestantesTratamento(dataInicio, duracaoDias);
  static bool isMedicamentoActive(DateTime dataInicio, int duracaoDias) => MedicamentosUtils.isMedicamentoActive(dataInicio, duracaoDias);
  static bool isMedicamentoExpired(DateTime dataInicio, int duracaoDias) => MedicamentosUtils.isMedicamentoExpired(dataInicio, duracaoDias);
  static double progressoTratamento(DateTime dataInicio, int duracaoDias) => MedicamentosUtils.progressoTratamento(dataInicio, duracaoDias);
  static String getStatusText(DateTime dataInicio, int duracaoDias) => MedicamentosUtils.getStatusText(dataInicio, duracaoDias);
  static Color getStatusColor(DateTime dataInicio, int duracaoDias) => MedicamentosUtils.getStatusColor(dataInicio, duracaoDias);
  static String getStatusIcon(DateTime dataInicio, int duracaoDias) => MedicamentosUtils.getStatusIcon(dataInicio, duracaoDias);
  static String getDuracaoTratamento(int duracaoDias) => MedicamentosUtils.getDuracaoTratamento(duracaoDias);

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required String nome,
    required String tipo,
    required String dosagem,
    required String frequencia,
    required int duracao,
    required DateTime dataInicio,
    String? observacoes,
  }) {
    return MedicamentosUtils.exportToJson(
      animalId: animalId,
      nome: nome,
      tipo: tipo,
      dosagem: dosagem,
      frequencia: frequencia,
      duracao: duracao,
      dataInicio: dataInicio,
      observacoes: observacoes,
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
    required String nome,
    required String tipo,
    required String dosagem,
    required String frequencia,
    required int duracao,
    required DateTime? dataInicio,
    String? observacoes,
  }) {
    return {
      'hasAnimal': animalId.isNotEmpty,
      'hasNome': nome.isNotEmpty,
      'hasTipo': tipo.isNotEmpty,
      'hasDosagem': dosagem.isNotEmpty,
      'hasFrequencia': frequencia.isNotEmpty,
      'hasDuracao': duracao > 0,
      'hasDataInicio': dataInicio != null,
      'hasObservacoes': observacoes != null && observacoes.isNotEmpty,
      'nomeLength': nome.length,
      'dosagemLength': dosagem.length,
      'frequenciaLength': frequencia.length,
      'observacoesLength': observacoes?.length ?? 0,
      'completionPercentage': _calculateCompletionPercentage(
        animalId: animalId,
        nome: nome,
        tipo: tipo,
        dosagem: dosagem,
        frequencia: frequencia,
        duracao: duracao,
        dataInicio: dataInicio,
        observacoes: observacoes,
      ),
    };
  }

  static double _calculateCompletionPercentage({
    required String animalId,
    required String nome,
    required String tipo,
    required String dosagem,
    required String frequencia,
    required int duracao,
    required DateTime? dataInicio,
    String? observacoes,
  }) {
    int completed = 0;
    const int total = 7; // Required fields

    if (animalId.isNotEmpty) completed++;
    if (nome.isNotEmpty) completed++;
    if (tipo.isNotEmpty) completed++;
    if (dosagem.isNotEmpty) completed++;
    if (frequencia.isNotEmpty) completed++;
    if (duracao > 0) completed++;
    if (dataInicio != null) completed++;

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
    required String nome,
    required String tipo,
    required String dosagem,
    required String frequencia,
    required int duracao,
    required DateTime? dataInicio,
    String? observacoes,
  }) {
    return animalId.isNotEmpty &&
        isValidNome(nome) &&
        isValidTipo(tipo) &&
        isValidDosagem(dosagem) &&
        isValidFrequencia(frequencia) &&
        isValidDuracao(duracao) &&
        dataInicio != null &&
        isValidObservacoes(observacoes);
  }

  static Map<String, String?> validateForm({
    required String animalId,
    required String nome,
    required String tipo,
    required String dosagem,
    required String frequencia,
    required int duracao,
    required DateTime? dataInicio,
    String? observacoes,
  }) {
    final errors = <String, String?>{};

    if (animalId.isEmpty) {
      errors['animalId'] = 'Animal é obrigatório';
    }

    if (!isValidNome(nome)) {
      errors['nome'] = 'Nome é obrigatório e deve ter no máximo 100 caracteres';
    }

    if (!isValidTipo(tipo)) {
      errors['tipo'] = 'Tipo de medicamento é obrigatório';
    }

    if (!isValidDosagem(dosagem)) {
      errors['dosagem'] = 'Dosagem é obrigatória e deve ter no máximo 50 caracteres';
    }

    if (!isValidFrequencia(frequencia)) {
      errors['frequencia'] = 'Frequência é obrigatória e deve ter no máximo 100 caracteres';
    }

    if (!isValidDuracao(duracao)) {
      errors['duracao'] = 'Duração deve ser entre 1 e 365 dias';
    }

    if (dataInicio == null) {
      errors['dataInicio'] = 'Data de início é obrigatória';
    }

    if (!isValidObservacoes(observacoes)) {
      errors['observacoes'] = 'Observações devem ter no máximo 500 caracteres';
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

  // Treatment schedule helpers
  static List<DateTime> generateTreatmentSchedule(
    DateTime dataInicio,
    int duracao,
    String frequencia,
  ) {
    final schedule = <DateTime>[];
    var current = dataInicio;
    final end = dataInicio.add(Duration(days: duracao));

    int intervalHours = 24; // Default
    switch (frequencia.toLowerCase()) {
      case '2x ao dia':
        intervalHours = 12;
        break;
      case '3x ao dia':
        intervalHours = 8;
        break;
      case '4x ao dia':
        intervalHours = 6;
        break;
      case 'a cada 6 horas':
        intervalHours = 6;
        break;
      case 'a cada 8 horas':
        intervalHours = 8;
        break;
      case 'a cada 12 horas':
        intervalHours = 12;
        break;
      case 'a cada 24 horas':
      case '1x ao dia':
      default:
        intervalHours = 24;
        break;
    }

    while (current.isBefore(end)) {
      schedule.add(current);
      current = current.add(Duration(hours: intervalHours));
    }

    return schedule;
  }

  static DateTime? getNextDose(
    DateTime dataInicio,
    int duracao,
    String frequencia,
  ) {
    final schedule = generateTreatmentSchedule(dataInicio, duracao, frequencia);
    final now = DateTime.now();
    
    for (final dose in schedule) {
      if (dose.isAfter(now)) {
        return dose;
      }
    }
    
    return null; // Treatment completed
  }
}
