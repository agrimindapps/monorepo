// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart' as app_date_utils;
import '../../../../../../app-petiveti/utils/format_utils.dart';
import '../../../../../../app-petiveti/utils/lembrete_utils.dart';
import '../../../../../../app-petiveti/utils/string_utils.dart';

class LembretesUtils {
  // Delegated functions to centralized utils
  static String formatDateToString(int timestamp) => app_date_utils.DateUtils.formatDate(timestamp);
  static String formatDate(DateTime date) => app_date_utils.DateUtils.formatDate(date.millisecondsSinceEpoch);
  static String formatDateComplete(DateTime date) => app_date_utils.DateUtils.formatDateComplete(date);
  static DateTime? parseDate(String dateString) => app_date_utils.DateUtils.parseStringToDate(dateString);
  static String getFormattedMonth([DateTime? date]) => app_date_utils.DateUtils.getFormattedMonth(date);
  static String formatarDataAtual() => app_date_utils.DateUtils.formatarDataAtual();
  static String getMes(int month) => app_date_utils.DateUtils.getMes(month);
  static String getMesAbreviado(int month) => app_date_utils.DateUtils.getMesAbreviado(month);
  static String getDiaSemana(int weekday) => app_date_utils.DateUtils.getDiaSemana(weekday);
  static String getDiaSemanaAbreviado(int weekday) => app_date_utils.DateUtils.getDiaSemanaAbreviado(weekday);
  static bool isToday(DateTime date) => app_date_utils.DateUtils.isToday(date);
  static bool isTomorrow(DateTime date) => app_date_utils.DateUtils.isTomorrow(date);
  static bool isYesterday(DateTime date) => app_date_utils.DateUtils.isYesterday(date);
  static bool isThisWeek(DateTime date) => app_date_utils.DateUtils.isThisWeek(date);
  static bool isThisMonth(DateTime date) => app_date_utils.DateUtils.isThisMonth(date);
  static bool isThisYear(DateTime date) => app_date_utils.DateUtils.isThisYear(date);
  static bool isOverdue(DateTime date) => app_date_utils.DateUtils.isOverdue(date);
  static String getRelativeTime(DateTime date) => app_date_utils.DateUtils.getRelativeTimeString(date);
  static String getRelativeTimeString(DateTime date) => app_date_utils.DateUtils.getRelativeTimeString(date);
  static DateTime getStartOfDay(DateTime date) => app_date_utils.DateUtils.getStartOfDay(date);
  static DateTime getEndOfDay(DateTime date) => app_date_utils.DateUtils.getEndOfDay(date);
  static DateTime getStartOfMonth(DateTime date) => app_date_utils.DateUtils.getStartOfMonth(date);
  static DateTime getEndOfMonth(DateTime date) => app_date_utils.DateUtils.getEndOfMonth(date);
  static String capitalize(String text) => StringUtils.capitalize(text);
  static String capitalizeWords(String text) => StringUtils.capitalizeWords(text);
  static String sanitizeText(String text) => StringUtils.sanitizeText(text);
  static String truncateText(String text, int maxLength) => FormatUtils.truncateText(text, maxLength);
  static String escapeForCsv(String field) => FormatUtils.escapeForCsv(field);
  static double calculatePercentage(double value, double total) => FormatUtils.calculatePercentage(value, total);
  static String formatPercentage(double percentage) => FormatUtils.formatPercentage(percentage);
  static List<String> getAvailableTipos() => LembreteUtils.getAvailableTipos();
  static String getTipoIcon(String tipo) => LembreteUtils.getTipoIcon(tipo);
  static Color getTipoColor(String tipo) => LembreteUtils.getTipoColor(tipo);
  static List<String> getRepetirOpcoes() => LembreteUtils.getRepetirOpcoes();
  static String? getTipoSuggestion(String tipo) => LembreteUtils.getTipoSuggestion(tipo);
  static bool isLembreteAtrasado(DateTime dataHora) => LembreteUtils.isLembreteAtrasado(dataHora);
  static bool isLembreteHoje(DateTime dataHora) => LembreteUtils.isLembreteHoje(dataHora);
  static bool isLembreteUrgente(DateTime dataHora) => LembreteUtils.isLembreteUrgente(dataHora);
  static String getTempoRestante(DateTime dataHora) => LembreteUtils.getTempoRestante(dataHora);
  static Color getStatusColor(DateTime dataHora) => LembreteUtils.getStatusColor(dataHora);
  static String getStatusIcon(DateTime dataHora) => LembreteUtils.getStatusIcon(dataHora);
  static String getStatusText(DateTime dataHora) => LembreteUtils.getStatusText(dataHora);
  static List<String> gerarListaMesesDisponiveis(List<dynamic> lembretes) => LembreteUtils.gerarListaMesesDisponiveis(lembretes);
  static String formatarPeriodoLembretes(List<dynamic> lembretes) => LembreteUtils.formatarPeriodoLembretes(lembretes);

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

  // Page-specific functions (keep these)
  static Map<String, dynamic> getLembreteStatistics(List<dynamic> lembretes) {
    if (lembretes.isEmpty) {
      return {
        'total': 0,
        'atrasados': 0,
        'hoje': 0,
        'futuros': 0,
        'porTipo': <String, int>{},
        'porMes': <String, int>{},
        'proximoLembrete': null,
        'ultimoLembrete': null,
      };
    }

    int atrasados = 0;
    int hoje = 0;
    int futuros = 0;
    final porTipo = <String, int>{};
    final porMes = <String, int>{};

    for (final lembrete in lembretes) {
      if (lembrete is Map) {
        final timestamp = lembrete['dataHora'] as int? ?? 0;
        final tipo = lembrete['tipo'] as String? ?? 'Outros';
        
        if (timestamp > 0) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          
          porMes[monthKey] = (porMes[monthKey] ?? 0) + 1;
          porTipo[tipo] = (porTipo[tipo] ?? 0) + 1;
          
          if (isLembreteAtrasado(date)) {
            atrasados++;
          } else if (isLembreteHoje(date)) {
            hoje++;
          } else {
            futuros++;
          }
        }
      }
    }

    final sortedLembretes = List<dynamic>.from(lembretes)
      ..sort((a, b) {
        final dateA = a is Map ? (a['dataHora'] as int? ?? 0) : 0;
        final dateB = b is Map ? (b['dataHora'] as int? ?? 0) : 0;
        return dateA.compareTo(dateB);
      });

    return {
      'total': lembretes.length,
      'atrasados': atrasados,
      'hoje': hoje,
      'futuros': futuros,
      'porTipo': porTipo,
      'porMes': porMes,
      'proximoLembrete': sortedLembretes.isNotEmpty ? sortedLembretes.first : null,
      'ultimoLembrete': sortedLembretes.isNotEmpty ? sortedLembretes.last : null,
    };
  }

  static String getLembreteTitle(Map<String, dynamic> lembrete) {
    final titulo = lembrete['titulo'] as String? ?? 'Lembrete';
    final tipo = lembrete['tipo'] as String? ?? 'Outros';
    final icon = getTipoIcon(tipo);
    return '$icon $titulo';
  }

  static String getLembreteSubtitle(Map<String, dynamic> lembrete) {
    final timestamp = lembrete['dataHora'] as int? ?? 0;
    final tipo = lembrete['tipo'] as String? ?? '';
    
    if (timestamp > 0) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final dataFormatada = formatDate(date);
      final horaFormatada = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      return tipo.isNotEmpty ? '$dataFormatada às $horaFormatada • $tipo' : '$dataFormatada às $horaFormatada';
    }
    
    return tipo.isNotEmpty ? tipo : 'Sem informações';
  }

  static List<Map<String, dynamic>> sortLembretesByDate(
    List<Map<String, dynamic>> lembretes, {
    bool ascending = false,
  }) {
    final sorted = List<Map<String, dynamic>>.from(lembretes);
    sorted.sort((a, b) {
      final dateA = a['dataHora'] as int? ?? 0;
      final dateB = b['dataHora'] as int? ?? 0;
      final comparison = dateA.compareTo(dateB);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<Map<String, dynamic>> filterLembretesByDateRange(
    List<Map<String, dynamic>> lembretes,
    DateTime startDate,
    DateTime endDate,
  ) {
    return lembretes.where((lembrete) {
      final timestamp = lembrete['dataHora'] as int? ?? 0;
      if (timestamp == 0) return false;
      
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  static List<Map<String, dynamic>> filterLembretesByTipo(
    List<Map<String, dynamic>> lembretes,
    String tipo,
  ) {
    return lembretes.where((lembrete) {
      final lembreteTipo = lembrete['tipo'] as String? ?? '';
      return lembreteTipo.toLowerCase().contains(tipo.toLowerCase());
    }).toList();
  }

  static List<Map<String, dynamic>> filterLembretesByAnimal(
    List<Map<String, dynamic>> lembretes,
    String animalId,
  ) {
    return lembretes.where((lembrete) {
      final lembreteAnimalId = lembrete['animalId'] as String? ?? '';
      return lembreteAnimalId == animalId;
    }).toList();
  }

  static List<Map<String, dynamic>> filterLembretesByStatus(
    List<Map<String, dynamic>> lembretes,
    String status, // 'atrasado', 'hoje', 'futuro'
  ) {
    return lembretes.where((lembrete) {
      final timestamp = lembrete['dataHora'] as int? ?? 0;
      if (timestamp == 0) return false;
      
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      
      switch (status.toLowerCase()) {
        case 'atrasado':
          return isLembreteAtrasado(date);
        case 'hoje':
          return isLembreteHoje(date);
        case 'futuro':
          return !isLembreteAtrasado(date) && !isLembreteHoje(date);
        default:
          return true;
      }
    }).toList();
  }

  static String getFilterDescription(String filter, Map<String, int> counts) {
    switch (filter.toLowerCase()) {
      case 'todos':
        return 'Todos os lembretes (${counts['todos'] ?? 0})';
      case 'atrasados':
        return 'Atrasados (${counts['atrasados'] ?? 0})';
      case 'hoje':
        return 'Hoje (${counts['hoje'] ?? 0})';
      case 'futuros':
        return 'Futuros (${counts['futuros'] ?? 0})';
      default:
        return filter;
    }
  }

  // Quick access functions for common operations
  static List<Map<String, dynamic>> getLembretesAtrasados(List<Map<String, dynamic>> lembretes) {
    return filterLembretesByStatus(lembretes, 'atrasado');
  }

  static List<Map<String, dynamic>> getLembretesHoje(List<Map<String, dynamic>> lembretes) {
    return filterLembretesByStatus(lembretes, 'hoje');
  }

  static List<Map<String, dynamic>> getLembretesFuturos(List<Map<String, dynamic>> lembretes) {
    return filterLembretesByStatus(lembretes, 'futuro');
  }

  static int getCountByStatus(List<Map<String, dynamic>> lembretes, String status) {
    return filterLembretesByStatus(lembretes, status).length;
  }

  static Map<String, int> getAllStatusCounts(List<Map<String, dynamic>> lembretes) {
    return {
      'todos': lembretes.length,
      'atrasados': getCountByStatus(lembretes, 'atrasado'),
      'hoje': getCountByStatus(lembretes, 'hoje'),
      'futuros': getCountByStatus(lembretes, 'futuro'),
    };
  }

  // Search functions
  static List<Map<String, dynamic>> searchLembretes(
    List<Map<String, dynamic>> lembretes,
    String query,
  ) {
    if (query.trim().isEmpty) return lembretes;
    
    final lowercaseQuery = query.toLowerCase();
    return lembretes.where((lembrete) {
      final titulo = (lembrete['titulo'] as String? ?? '').toLowerCase();
      final tipo = (lembrete['tipo'] as String? ?? '').toLowerCase();
      final descricao = (lembrete['descricao'] as String? ?? '').toLowerCase();
      
      return titulo.contains(lowercaseQuery) ||
             tipo.contains(lowercaseQuery) ||
             descricao.contains(lowercaseQuery);
    }).toList();
  }

  static String formatSearchResults(int total, int filtered, String query) {
    if (query.isEmpty) {
      return 'Total: $total ${total == 1 ? 'lembrete' : 'lembretes'}';
    } else {
      return '$filtered de $total lembretes encontrados';
    }
  }
}
