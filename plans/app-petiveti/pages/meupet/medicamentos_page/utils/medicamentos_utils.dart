// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../../../app-petiveti/utils/date_utils.dart' as app_date_utils;
import '../../../../../../app-petiveti/utils/format_utils.dart';
import '../../../../../../app-petiveti/utils/medicamentos_utils.dart' as app_medicamentos_utils;
import '../../../../../../app-petiveti/utils/string_utils.dart';

class MedicamentosUtils {
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
  static List<DateTime> getDateRange(DateTime start, DateTime end) => app_date_utils.DateUtils.getDateRange(start, end);
  static String normalize(DateTime date) => app_date_utils.DateUtils.normalizeDate(date).toString();
  static String capitalize(String text) => StringUtils.capitalize(text);
  static String capitalizeWords(String text) => StringUtils.capitalizeWords(text);
  static String sanitizeText(String text) => StringUtils.sanitizeText(text);
  static String truncateText(String text, int maxLength) => FormatUtils.truncateText(text, maxLength);
  static String escapeForCsv(String field) => FormatUtils.escapeForCsv(field);
  static double calculatePercentage(double value, double total) => FormatUtils.calculatePercentage(value, total);
  static String formatPercentage(double percentage) => FormatUtils.formatPercentage(percentage);
  static List<String> getAvailableTipos() => app_medicamentos_utils.MedicamentosUtils.getAvailableTipos();
  static List<String> getCommonTipos() => app_medicamentos_utils.MedicamentosUtils.getCommonTipos();
  static List<String> getFrequencias() => app_medicamentos_utils.MedicamentosUtils.getFrequencias();
  static List<String> getUnidades() => app_medicamentos_utils.MedicamentosUtils.getUnidades();
  static String getTipoIcon(String tipo) => app_medicamentos_utils.MedicamentosUtils.getTipoIcon(tipo);
  static Color getTipoColor(String tipo) => app_medicamentos_utils.MedicamentosUtils.getTipoColor(tipo);
  static String? getTipoSuggestion(String tipo) => app_medicamentos_utils.MedicamentosUtils.getTipoSuggestion(tipo);
  static int diasRestantesTratamento(DateTime dataInicio, int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.diasRestantesTratamento(dataInicio, duracaoDias);
  static bool isMedicamentoActive(DateTime dataInicio, int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.isMedicamentoActive(dataInicio, duracaoDias);
  static bool isMedicamentoExpired(DateTime dataInicio, int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.isMedicamentoExpired(dataInicio, duracaoDias);
  static double progressoTratamento(DateTime dataInicio, int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.progressoTratamento(dataInicio, duracaoDias);
  static String getStatusText(DateTime dataInicio, int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.getStatusText(dataInicio, duracaoDias);
  static Color getStatusColor(DateTime dataInicio, int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.getStatusColor(dataInicio, duracaoDias);
  static String getStatusIcon(DateTime dataInicio, int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.getStatusIcon(dataInicio, duracaoDias);
  static String getDuracaoTratamento(int duracaoDias) => app_medicamentos_utils.MedicamentosUtils.getDuracaoTratamento(duracaoDias);
  static List<String> gerarListaMesesDisponiveis(List<dynamic> medicamentos) => app_medicamentos_utils.MedicamentosUtils.gerarListaMesesDisponiveis(medicamentos);
  static String formatarPeriodoMedicamentos(List<dynamic> medicamentos) => app_medicamentos_utils.MedicamentosUtils.formatarPeriodoMedicamentos(medicamentos);

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
    return app_medicamentos_utils.MedicamentosUtils.exportToJson(
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

  // Page-specific functions (keep these)
  static Map<String, dynamic> getMedicamentosStatistics(List<dynamic> medicamentos) {
    if (medicamentos.isEmpty) {
      return {
        'total': 0,
        'ativos': 0,
        'finalizados': 0,
        'naoIniciados': 0,
        'porTipo': <String, int>{},
        'porMes': <String, int>{},
        'proximoMedicamento': null,
        'ultimoMedicamento': null,
      };
    }

    int ativos = 0;
    int finalizados = 0;
    int naoIniciados = 0;
    final porTipo = <String, int>{};
    final porMes = <String, int>{};

    for (final medicamento in medicamentos) {
      if (medicamento is Map) {
        final dataInicioTimestamp = medicamento['dataInicio'] as int? ?? 0;
        final duracao = medicamento['duracao'] as int? ?? 0;
        final tipo = medicamento['tipo'] as String? ?? 'Outros';
        
        if (dataInicioTimestamp > 0) {
          final dataInicio = DateTime.fromMillisecondsSinceEpoch(dataInicioTimestamp);
          final monthKey = '${dataInicio.year}-${dataInicio.month.toString().padLeft(2, '0')}';
          
          porMes[monthKey] = (porMes[monthKey] ?? 0) + 1;
          porTipo[tipo] = (porTipo[tipo] ?? 0) + 1;
          
          final status = getStatusText(dataInicio, duracao);
          switch (status) {
            case 'Não iniciado':
              naoIniciados++;
              break;
            case 'Em andamento':
              ativos++;
              break;
            case 'Finalizado':
              finalizados++;
              break;
          }
        }
      }
    }

    final sortedMedicamentos = List<dynamic>.from(medicamentos)
      ..sort((a, b) {
        final dateA = a is Map ? (a['dataInicio'] as int? ?? 0) : 0;
        final dateB = b is Map ? (b['dataInicio'] as int? ?? 0) : 0;
        return dateA.compareTo(dateB);
      });

    return {
      'total': medicamentos.length,
      'ativos': ativos,
      'finalizados': finalizados,
      'naoIniciados': naoIniciados,
      'porTipo': porTipo,
      'porMes': porMes,
      'proximoMedicamento': sortedMedicamentos.isNotEmpty ? sortedMedicamentos.first : null,
      'ultimoMedicamento': sortedMedicamentos.isNotEmpty ? sortedMedicamentos.last : null,
    };
  }

  static String getMedicamentoTitle(Map<String, dynamic> medicamento) {
    final nome = medicamento['nome'] as String? ?? 'Medicamento';
    final tipo = medicamento['tipo'] as String? ?? 'Outros';
    final icon = getTipoIcon(tipo);
    return '$icon $nome';
  }

  static String getMedicamentoSubtitle(Map<String, dynamic> medicamento) {
    final dataInicioTimestamp = medicamento['dataInicio'] as int? ?? 0;
    final duracao = medicamento['duracao'] as int? ?? 0;
    final dosagem = medicamento['dosagem'] as String? ?? '';
    final frequencia = medicamento['frequencia'] as String? ?? '';
    
    if (dataInicioTimestamp > 0) {
      final dataInicio = DateTime.fromMillisecondsSinceEpoch(dataInicioTimestamp);
      final statusText = getStatusText(dataInicio, duracao);
      final info = dosagem.isNotEmpty && frequencia.isNotEmpty ? '$dosagem • $frequencia' : '';
      return info.isNotEmpty ? '$statusText • $info' : statusText;
    }
    
    return dosagem.isNotEmpty && frequencia.isNotEmpty ? '$dosagem • $frequencia' : 'Sem informações';
  }

  static List<Map<String, dynamic>> sortMedicamentosByDate(
    List<Map<String, dynamic>> medicamentos, {
    bool ascending = false,
  }) {
    final sorted = List<Map<String, dynamic>>.from(medicamentos);
    sorted.sort((a, b) {
      final dateA = a['dataInicio'] as int? ?? 0;
      final dateB = b['dataInicio'] as int? ?? 0;
      final comparison = dateA.compareTo(dateB);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<Map<String, dynamic>> sortMedicamentosByStatus(
    List<Map<String, dynamic>> medicamentos,
  ) {
    final sorted = List<Map<String, dynamic>>.from(medicamentos);
    sorted.sort((a, b) {
      final dataInicioA = a['dataInicio'] as int? ?? 0;
      final duracaoA = a['duracao'] as int? ?? 0;
      final dataInicioB = b['dataInicio'] as int? ?? 0;
      final duracaoB = b['duracao'] as int? ?? 0;
      
      if (dataInicioA == 0 || dataInicioB == 0) return 0;
      
      final statusA = getStatusText(DateTime.fromMillisecondsSinceEpoch(dataInicioA), duracaoA);
      final statusB = getStatusText(DateTime.fromMillisecondsSinceEpoch(dataInicioB), duracaoB);
      
      // Order: Em andamento, Não iniciado, Finalizado
      final priorities = {'Em andamento': 0, 'Não iniciado': 1, 'Finalizado': 2};
      final priorityA = priorities[statusA] ?? 3;
      final priorityB = priorities[statusB] ?? 3;
      
      return priorityA.compareTo(priorityB);
    });
    return sorted;
  }

  static List<Map<String, dynamic>> filterMedicamentosByDateRange(
    List<Map<String, dynamic>> medicamentos,
    DateTime startDate,
    DateTime endDate,
  ) {
    return medicamentos.where((medicamento) {
      final timestamp = medicamento['dataInicio'] as int? ?? 0;
      if (timestamp == 0) return false;
      
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  static List<Map<String, dynamic>> filterMedicamentosByTipo(
    List<Map<String, dynamic>> medicamentos,
    String tipo,
  ) {
    return medicamentos.where((medicamento) {
      final medicamentoTipo = medicamento['tipo'] as String? ?? '';
      return medicamentoTipo.toLowerCase().contains(tipo.toLowerCase());
    }).toList();
  }

  static List<Map<String, dynamic>> filterMedicamentosByAnimal(
    List<Map<String, dynamic>> medicamentos,
    String animalId,
  ) {
    return medicamentos.where((medicamento) {
      final medicamentoAnimalId = medicamento['animalId'] as String? ?? '';
      return medicamentoAnimalId == animalId;
    }).toList();
  }

  static List<Map<String, dynamic>> filterMedicamentosByStatus(
    List<Map<String, dynamic>> medicamentos,
    String status, // 'naoIniciado', 'ativo', 'finalizado'
  ) {
    return medicamentos.where((medicamento) {
      final dataInicioTimestamp = medicamento['dataInicio'] as int? ?? 0;
      final duracao = medicamento['duracao'] as int? ?? 0;
      if (dataInicioTimestamp == 0) return false;
      
      final dataInicio = DateTime.fromMillisecondsSinceEpoch(dataInicioTimestamp);
      final statusText = getStatusText(dataInicio, duracao);
      
      switch (status.toLowerCase()) {
        case 'naoiniciado':
        case 'nao_iniciado':
          return statusText == 'Não iniciado';
        case 'ativo':
        case 'em_andamento':
          return statusText == 'Em andamento';
        case 'finalizado':
          return statusText == 'Finalizado';
        default:
          return true;
      }
    }).toList();
  }

  static String getFilterDescription(String filter, Map<String, int> counts) {
    switch (filter.toLowerCase()) {
      case 'todos':
        return 'Todos os medicamentos (${counts['todos'] ?? 0})';
      case 'ativos':
        return 'Em andamento (${counts['ativos'] ?? 0})';
      case 'finalizados':
        return 'Finalizados (${counts['finalizados'] ?? 0})';
      case 'nao_iniciados':
        return 'Não iniciados (${counts['naoIniciados'] ?? 0})';
      default:
        return filter;
    }
  }

  // Quick access functions for common operations
  static List<Map<String, dynamic>> getMedicamentosAtivos(List<Map<String, dynamic>> medicamentos) {
    return filterMedicamentosByStatus(medicamentos, 'ativo');
  }

  static List<Map<String, dynamic>> getMedicamentosFinalizados(List<Map<String, dynamic>> medicamentos) {
    return filterMedicamentosByStatus(medicamentos, 'finalizado');
  }

  static List<Map<String, dynamic>> getMedicamentosNaoIniciados(List<Map<String, dynamic>> medicamentos) {
    return filterMedicamentosByStatus(medicamentos, 'naoIniciado');
  }

  static int getCountByStatus(List<Map<String, dynamic>> medicamentos, String status) {
    return filterMedicamentosByStatus(medicamentos, status).length;
  }

  static Map<String, int> getAllStatusCounts(List<Map<String, dynamic>> medicamentos) {
    return {
      'todos': medicamentos.length,
      'ativos': getCountByStatus(medicamentos, 'ativo'),
      'finalizados': getCountByStatus(medicamentos, 'finalizado'),
      'naoIniciados': getCountByStatus(medicamentos, 'naoIniciado'),
    };
  }

  // Search functions
  static List<Map<String, dynamic>> searchMedicamentos(
    List<Map<String, dynamic>> medicamentos,
    String query,
  ) {
    if (query.trim().isEmpty) return medicamentos;
    
    final lowercaseQuery = query.toLowerCase();
    return medicamentos.where((medicamento) {
      final nome = (medicamento['nome'] as String? ?? '').toLowerCase();
      final tipo = (medicamento['tipo'] as String? ?? '').toLowerCase();
      final dosagem = (medicamento['dosagem'] as String? ?? '').toLowerCase();
      final frequencia = (medicamento['frequencia'] as String? ?? '').toLowerCase();
      final observacoes = (medicamento['observacoes'] as String? ?? '').toLowerCase();
      
      return nome.contains(lowercaseQuery) ||
             tipo.contains(lowercaseQuery) ||
             dosagem.contains(lowercaseQuery) ||
             frequencia.contains(lowercaseQuery) ||
             observacoes.contains(lowercaseQuery);
    }).toList();
  }

  static String formatSearchResults(int total, int filtered, String query) {
    if (query.isEmpty) {
      return 'Total: $total ${total == 1 ? 'medicamento' : 'medicamentos'}';
    } else {
      return '$filtered de $total medicamentos encontrados';
    }
  }

  // Urgency sorting - medications ending soon should appear first
  static List<Map<String, dynamic>> sortMedicamentosByUrgency(
    List<Map<String, dynamic>> medicamentos,
  ) {
    final ativos = getMedicamentosAtivos(medicamentos);
    final sorted = List<Map<String, dynamic>>.from(ativos);
    
    sorted.sort((a, b) {
      final dataInicioA = a['dataInicio'] as int? ?? 0;
      final duracaoA = a['duracao'] as int? ?? 0;
      final dataInicioB = b['dataInicio'] as int? ?? 0;
      final duracaoB = b['duracao'] as int? ?? 0;
      
      if (dataInicioA == 0 || dataInicioB == 0) return 0;
      
      final diasRestantesA = diasRestantesTratamento(DateTime.fromMillisecondsSinceEpoch(dataInicioA), duracaoA);
      final diasRestantesB = diasRestantesTratamento(DateTime.fromMillisecondsSinceEpoch(dataInicioB), duracaoB);
      
      return diasRestantesA.compareTo(diasRestantesB);
    });
    
    return sorted;
  }

  static List<Map<String, dynamic>> getMedicamentosUrgentes(List<Map<String, dynamic>> medicamentos) {
    return getMedicamentosAtivos(medicamentos).where((medicamento) {
      final dataInicioTimestamp = medicamento['dataInicio'] as int? ?? 0;
      final duracao = medicamento['duracao'] as int? ?? 0;
      
      if (dataInicioTimestamp == 0) return false;
      
      final dataInicio = DateTime.fromMillisecondsSinceEpoch(dataInicioTimestamp);
      final diasRestantes = diasRestantesTratamento(dataInicio, duracao);
      
      return diasRestantes <= 3; // 3 days or less
    }).toList();
  }
}
