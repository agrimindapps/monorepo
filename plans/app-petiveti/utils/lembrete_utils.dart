// Main entry point for lembrete utilities
// Re-exports all lembrete utility functions for backward compatibility

// Legacy compatibility - will be deprecated

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'lembretes/lembrete_core.dart';
import 'lembretes/lembrete_date_utils.dart';
import 'lembretes/lembrete_display_utils.dart';
import 'lembretes/lembrete_form_helpers.dart';
import 'lembretes/lembrete_validators.dart';

export 'lembretes/lembrete_core.dart';
export 'lembretes/lembrete_date_utils.dart';
export 'lembretes/lembrete_display_utils.dart';
export 'lembretes/lembrete_form_helpers.dart';
export 'lembretes/lembrete_validators.dart';

class LembreteUtils {
  static Color getStatusColor(DateTime dataHora) {
    return LembreteDisplayUtils.getStatusColor(dataHora);
  }

  static String getStatusIcon(DateTime dataHora) {
    final icon = LembreteDisplayUtils.getStatusIcon(dataHora);
    switch (icon) {
      case Icons.warning:
        return '⏰';
      case Icons.schedule:
        return '🔔';
      case Icons.check_circle_outline:
        return '📋';
      default:
        return '📋';
    }
  }

  static String getStatusText(DateTime dataHora) {
    return LembreteDisplayUtils.getStatusText(dataHora);
  }

  static bool isLembreteAtrasado(DateTime dataHora) {
    return LembreteCore.isOverdue(dataHora);
  }

  static bool isLembreteHoje(DateTime dataHora) {
    return LembreteDateUtils.isToday(dataHora);
  }

  static bool isLembreteUrgente(DateTime dataHora) {
    return LembreteCore.isUrgent(dataHora);
  }

  static String getTempoRestante(DateTime dataHora) {
    return LembreteCore.getTimeRemaining(dataHora);
  }

  static List<String> getAvailableTipos() {
    return LembreteCore.getSuggestedTypes();
  }

  static String getTipoIcon(String tipo) {
    final iconData = LembreteDisplayUtils.getTipoIcon(tipo);
    switch (iconData) {
      case Icons.medical_services:
        return '🏥';
      case Icons.medication:
        return '💊';
      case Icons.vaccines:
        return '💉';
      case Icons.bathtub:
        return '🛁';
      case Icons.fitness_center:
        return '🏃';
      case Icons.dinner_dining:
        return '🍽️';
      default:
        return '📋';
    }
  }

  static Color getTipoColor(String tipo) {
    return LembreteDisplayUtils.getTipoColor(tipo);
  }

  static List<String> getRepetirOpcoes() {
    return LembreteFormHelpers.getRepetirOptions();
  }

  static String? getTipoSuggestion(String tipo) {
    return LembreteFormHelpers.getHintTextForTipo(tipo);
  }

  static bool isValidTitulo(String titulo) {
    return LembreteValidators.validateTitulo(titulo) == null;
  }

  static bool isValidDescricao(String? descricao) {
    return LembreteValidators.validateDescricao(descricao) == null;
  }

  static bool isValidDataHora(DateTime dataHora) {
    return LembreteValidators.validateDataHora(dataHora) == null;
  }

  static String getValidationMessage(String field, String? error) {
    if (error == null) return '';
    return '$field: $error';
  }
  static Map<String, dynamic> exportToJson({
    required String animalId,
    required String titulo,
    required DateTime dataHora,
    required String tipo,
    String? descricao,
    String? repetir,
  }) {
    return {
      'animalId': animalId,
      'titulo': titulo,
      'dataHora': dataHora.toIso8601String(),
      'tipo': tipo,
      'descricao': descricao,
      'repetir': repetir,
      'dataFormatada': LembreteDateUtils.formatDate(dataHora),
      'horaFormatada': LembreteDateUtils.formatTime(dataHora),
      'tipoIcon': getTipoIcon(tipo),
      'statusText': getStatusText(dataHora),
      'tempoRestante': getTempoRestante(dataHora),
    };
  }

  static List<String> gerarListaMesesDisponiveis(List<dynamic> lembretes) {
    if (lembretes.isEmpty) {
      return [_getFormattedMonth()];
    }

    final sortedLembretes = List<dynamic>.from(lembretes)
      ..sort((a, b) {
        final dateA = a is Map ? (a['dataHora'] as int? ?? 0) : 0;
        final dateB = b is Map ? (b['dataHora'] as int? ?? 0) : 0;
        return dateA.compareTo(dateB);
      });

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(
        sortedLembretes.first is Map ? (sortedLembretes.first['dataHora'] as int? ?? 0) : 0);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(
        sortedLembretes.last is Map ? (sortedLembretes.last['dataHora'] as int? ?? 0) : 0);

    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = _getFormattedMonth(currentDate);
      meses.add(mesFormatado);
      
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    final mesAtual = _getFormattedMonth();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList();
  }

  static String formatarPeriodoLembretes(List<dynamic> lembretes) {
    if (lembretes.isEmpty) {
      return _getFormattedMonth();
    }

    final sortedLembretes = List<dynamic>.from(lembretes)
      ..sort((a, b) {
        final dateA = a is Map ? (a['dataHora'] as int? ?? 0) : 0;
        final dateB = b is Map ? (b['dataHora'] as int? ?? 0) : 0;
        return dateA.compareTo(dateB);
      });

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(
        sortedLembretes.first is Map ? (sortedLembretes.first['dataHora'] as int? ?? 0) : 0);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(
        sortedLembretes.last is Map ? (sortedLembretes.last['dataHora'] as int? ?? 0) : 0);

    final mesInicial = _getFormattedMonth(dataInicial);
    final mesFinal = _getFormattedMonth(dataFinal);

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

  static String _getFormattedMonth([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[targetDate.month - 1]} ${targetDate.year.toString().substring(2)}';
  }
}
