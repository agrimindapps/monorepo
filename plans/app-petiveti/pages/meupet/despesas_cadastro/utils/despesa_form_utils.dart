// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../app-petiveti/utils/despesas_utils.dart';
import '../../../../utils/format_utils.dart';

/// Consolidated utils that delegate to centralized DespesasUtils
/// Replaces despesa_form_utils.dart with centralized approach
class DespesaFormUtils {
  // Delegated functions to centralized utils
  static String formatValor(double valor) => FormatUtils.formatValor(valor);
  static String formatValorComMoeda(double valor) => FormatUtils.formatValorComMoeda(valor);
  static double parseValor(String valorString) => FormatUtils.parseValor(valorString);
  static String formatData(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  static String formatDataCompleta(DateTime date) => '${formatData(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  static DateTime? parseData(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }
  static String capitalize(String text) => FormatUtils.capitalize(text);
  static String capitalizeWords(String text) => FormatUtils.capitalizeWords(text);
  static String sanitizeText(String text) => FormatUtils.sanitizeText(text);
  static String truncateText(String text, int maxLength) => DespesasUtils.truncateText(text, maxLength);
  static bool isToday(DateTime date) => DespesasUtils.isToday(date);
  static bool isThisWeek(DateTime date) => DespesasUtils.isThisWeek(date);
  static bool isThisMonth(DateTime date) => DespesasUtils.isThisMonth(date);
  static bool isThisYear(DateTime date) => DespesasUtils.isThisYear(date);
  static String getRelativeTime(DateTime date) => DespesasUtils.getRelativeTime(date);
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
  static String escapeForCsv(String field) => DespesasUtils.escapeForCsv(field);
  static double calculatePercentage(double value, double total) => DespesasUtils.calculatePercentage(value, total);
  static String formatPercentage(double percentage) => DespesasUtils.formatPercentage(percentage);
  static DateTime getStartOfDay(DateTime date) => DespesasUtils.getStartOfDay(date);
  static DateTime getEndOfDay(DateTime date) => DespesasUtils.getEndOfDay(date);
  static DateTime getStartOfMonth(DateTime date) => DespesasUtils.getStartOfMonth(date);
  static DateTime getEndOfMonth(DateTime date) => DespesasUtils.getEndOfMonth(date);
  static String getTipoIcon(String tipo) => DespesasUtils.getTipoIcon(tipo);
  static Color getTipoColor(String tipo) => DespesasUtils.getTipoColor(tipo);
  static List<String> getAvailableTipos() => DespesasUtils.getAvailableTipos();
  static List<String> getCommonTipos() => DespesasUtils.getCommonTipos();
  static String? getDefaultTipo() => DespesasUtils.getDefaultTipo();
  static bool isTipoValid(String tipo) => DespesasUtils.isTipoValid(tipo);
  static String normalizeTipo(String tipo) => DespesasUtils.normalizeTipo(tipo);
  static bool isValidValor(double valor) => DespesasUtils.isValidValor(valor);
  static bool isValidDescricao(String descricao) => DespesasUtils.isValidDescricao(descricao);
  static bool isValidObservacao(String? observacao) => DespesasUtils.isValidObservacao(observacao);
  static String getValidationMessage(String field, String? error) => DespesasUtils.getValidationMessage(field, error);
  static String? generateSuggestion(String tipo, String? currentText) => DespesasUtils.generateSuggestion(tipo, currentText);
  static double roundToTwoDecimals(double value) => DespesasUtils.roundToTwoDecimals(value);
  static bool isValidValueRange(double value) => DespesasUtils.isValidValueRange(value);
  static bool isValidDescriptionLength(String description) => DespesasUtils.isValidDescriptionLength(description);
  static String limitDescription(String description) => DespesasUtils.limitDescription(description);

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required DateTime dataDespesa,
    required String tipo,
    required String descricao,
    required double valor,
  }) {
    return DespesasUtils.exportToJson(
      animalId: animalId,
      data: dataDespesa,
      tipo: tipo,
      valor: valor,
      descricao: descricao,
    );
  }

  // Legacy compatibility methods
  static bool isValidValue(String value) {
    try {
      final parsedValue = parseValor(value);
      return isValidValor(parsedValue);
    } catch (e) {
      return false;
    }
  }

  static bool isValidDate(String date) {
    return parseData(date) != null;
  }

  // Additional date utility methods from original file
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime getEndOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = getStartOfDay(start);
    final normalizedEnd = getStartOfDay(end);
    
    while (!current.isAfter(normalizedEnd)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return dates;
  }

  static bool isInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }

  static String getFormattedRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatData(start);
    }
    return '${formatData(start)} - ${formatData(end)}';
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Form-specific utility functions (keep these local)
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
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    return {
      'hasAnimal': animalId.isNotEmpty,
      'hasTipo': tipo.isNotEmpty,
      'hasValor': valor > 0,
      'hasDescricao': descricao.isNotEmpty,
      'hasObservacao': observacao != null && observacao.isNotEmpty,
      'tipoLength': tipo.length,
      'descricaoLength': descricao.length,
      'observacaoLength': observacao?.length ?? 0,
      'completionPercentage': _calculateCompletionPercentage(
        animalId: animalId,
        tipo: tipo,
        valor: valor,
        descricao: descricao,
        observacao: observacao,
      ),
    };
  }

  static double _calculateCompletionPercentage({
    required String animalId,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    int completed = 0;
    const int total = 4; // Required fields only

    if (animalId.isNotEmpty) completed++;
    if (tipo.isNotEmpty) completed++;
    if (valor > 0) completed++;
    if (descricao.isNotEmpty) completed++;

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
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    return animalId.isNotEmpty &&
        isTipoValid(tipo) &&
        isValidValor(valor) &&
        isValidDescricao(descricao) &&
        isValidObservacao(observacao);
  }

  static Map<String, String?> validateForm({
    required String animalId,
    required String tipo,
    required double valor,
    required String descricao,
    String? observacao,
  }) {
    final errors = <String, String?>{};

    if (animalId.isEmpty) {
      errors['animalId'] = 'Animal é obrigatório';
    }

    if (!isTipoValid(tipo)) {
      errors['tipo'] = 'Tipo de despesa inválido';
    }

    if (!isValidValor(valor)) {
      errors['valor'] = 'Valor deve ser maior que R\$ 0,00 e menor que R\$ 99.999,99';
    }

    if (!isValidDescricao(descricao)) {
      errors['descricao'] = 'Descrição é obrigatória e deve ter no máximo 255 caracteres';
    }

    if (!isValidObservacao(observacao)) {
      errors['observacao'] = 'Observação deve ter no máximo 500 caracteres';
    }

    return errors;
  }
}
