// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../models/12_consulta_model.dart';

class ConsultaUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String formatDateComplete(DateTime date) {
    return '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static DateTime? parseDate(String dateString) {
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

  static String getFormattedMonth([DateTime? date]) {
    final targetDate = date ?? DateTime.now();
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${months[targetDate.month - 1]} ${targetDate.year.toString().substring(2)}';
  }

  /// Gera lista de meses baseada nos registros de consulta existentes
  static List<String> gerarListaMesesDisponiveis(List<Consulta> consultas) {
    if (consultas.isEmpty) {
      // Se não há registros, retorna o mês atual
      return [getFormattedMonth()];
    }

    // Ordena consultas por data
    final sortedConsultas = List<Consulta>.from(consultas)
      ..sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));

    // Obtém data mais antiga e mais recente
    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.first.dataConsulta);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.last.dataConsulta);

    // Gera lista de meses entre as datas
    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final mesFormatado = getFormattedMonth(currentDate);
      meses.add(mesFormatado);
      
      // Avança para o próximo mês
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    // Se o mês atual não está na lista, adiciona
    final mesAtual = getFormattedMonth();
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList(); // Mais recente primeiro
  }

  /// Obtém o período de registros (mês mais antigo ao mais recente)
  static String formatarPeriodoConsultas(List<Consulta> consultas) {
    if (consultas.isEmpty) {
      return getFormattedMonth();
    }

    final sortedConsultas = List<Consulta>.from(consultas)
      ..sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.first.dataConsulta);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(sortedConsultas.last.dataConsulta);

    final mesInicial = getFormattedMonth(dataInicial);
    final mesFinal = getFormattedMonth(dataFinal);

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
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

  static String getRelativeTime(DateTime date) {
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

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String sanitizeText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static Color getMotivoColor(String motivo) {
    switch (motivo.toLowerCase()) {
      case 'consulta de rotina':
      case 'check-up':
      case 'rotina':
        return const Color(0xFF4CAF50);
      case 'vacina':
      case 'vacinação':
        return const Color(0xFF2196F3);
      case 'emergência':
      case 'urgência':
        return const Color(0xFFE53935);
      case 'cirurgia':
        return const Color(0xFFFF5722);
      case 'exame':
      case 'exames':
        return const Color(0xFF9C27B0);
      case 'tratamento':
        return const Color(0xFFFF9800);
      case 'retorno':
        return const Color(0xFF607D8B);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  static String getMotivoIcon(String motivo) {
    switch (motivo.toLowerCase()) {
      case 'consulta de rotina':
      case 'check-up':
      case 'rotina':
        return '🏥';
      case 'vacina':
      case 'vacinação':
        return '💉';
      case 'emergência':
      case 'urgência':
        return '🚨';
      case 'cirurgia':
        return '⚕️';
      case 'exame':
      case 'exames':
        return '🔬';
      case 'tratamento':
        return '💊';
      case 'retorno':
        return '🔄';
      default:
        return '📋';
    }
  }

  static String escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required DateTime dataConsulta,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    required String observacoes,
  }) {
    return {
      'animalId': animalId,
      'dataConsulta': dataConsulta.toIso8601String(),
      'veterinario': veterinario,
      'motivo': motivo,
      'diagnostico': diagnostico,
      'observacoes': observacoes,
      'dataFormatada': formatDate(dataConsulta),
      'motivoIcon': getMotivoIcon(motivo),
    };
  }

  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

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
      return formatDate(start);
    }
    return '${formatDate(start)} - ${formatDate(end)}';
  }

  static String getValidationMessage(String field, String? error) {
    if (error == null) return '';
    
    final fieldNames = {
      'animalId': 'Animal',
      'veterinario': 'Veterinário',
      'motivo': 'Motivo',
      'diagnostico': 'Diagnóstico',
      'observacoes': 'Observações',
      'dataConsulta': 'Data da consulta',
    };
    
    final fieldName = fieldNames[field] ?? field;
    return '$fieldName: $error';
  }

  static List<String> getAvailableMotivos() {
    return [
      'Consulta de rotina',
      'Check-up',
      'Vacina',
      'Emergência',
      'Cirurgia',
      'Exame',
      'Tratamento',
      'Retorno',
      'Outros',
    ];
  }

  static String? getDefaultMotivo() {
    final motivos = getAvailableMotivos();
    return motivos.isNotEmpty ? motivos.first : null;
  }

  static bool isMotivoValid(String motivo) {
    return getAvailableMotivos().contains(motivo);
  }

  static String normalizeMotivo(String motivo) {
    final found = getAvailableMotivos()
        .where((m) => m.toLowerCase() == motivo.toLowerCase())
        .firstOrNull;
    return found ?? motivo;
  }

  static bool isValidDate(DateTime date) {
    final now = DateTime.now();
    final twoYearsAgo = now.subtract(const Duration(days: 730));
    final oneYearFromNow = now.add(const Duration(days: 365));
    
    return date.isAfter(twoYearsAgo) && date.isBefore(oneYearFromNow);
  }

  static bool isValidVeterinario(String veterinario) {
    return veterinario.trim().isNotEmpty && veterinario.length <= 100;
  }

  static bool isValidMotivo(String motivo) {
    return motivo.trim().isNotEmpty && motivo.length <= 255;
  }

  static bool isValidDiagnostico(String diagnostico) {
    return diagnostico.length <= 500;
  }

  static bool isValidObservacoes(String observacoes) {
    return observacoes.length <= 1000;
  }

  static String? generateSuggestion(String motivo, String? currentText) {
    final suggestions = {
      'Consulta de rotina': 'Consulta de rotina para acompanhamento',
      'Check-up': 'Check-up geral de saúde',
      'Vacina': 'Aplicação de vacina preventiva',
      'Emergência': 'Atendimento de emergência',
      'Cirurgia': 'Procedimento cirúrgico',
      'Exame': 'Realização de exames',
      'Tratamento': 'Consulta para tratamento',
      'Retorno': 'Retorno para acompanhamento',
      'Outros': 'Outros procedimentos veterinários',
    };
    
    if (currentText == null || currentText.trim().isEmpty) {
      return suggestions[motivo];
    }
    
    return null;
  }

  static Map<String, dynamic> getConsultaStatistics(List<Consulta> consultas) {
    if (consultas.isEmpty) {
      return {
        'total': 0,
        'porMes': <String, int>{},
        'porVeterinario': <String, int>{},
        'porMotivo': <String, int>{},
        'proximaConsulta': null,
        'ultimaConsulta': null,
      };
    }

    final porMes = <String, int>{};
    final porVeterinario = <String, int>{};
    final porMotivo = <String, int>{};

    for (final consulta in consultas) {
      final date = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      porMes[monthKey] = (porMes[monthKey] ?? 0) + 1;
      porVeterinario[consulta.veterinario] = (porVeterinario[consulta.veterinario] ?? 0) + 1;
      porMotivo[consulta.motivo] = (porMotivo[consulta.motivo] ?? 0) + 1;
    }

    final sortedConsultas = List<Consulta>.from(consultas)
      ..sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));

    return {
      'total': consultas.length,
      'porMes': porMes,
      'porVeterinario': porVeterinario,
      'porMotivo': porMotivo,
      'proximaConsulta': null, // Implementar agendamento futuro se necessário
      'ultimaConsulta': sortedConsultas.isNotEmpty ? sortedConsultas.last : null,
    };
  }

  static String getConsultaTitle(Consulta consulta) {
    final date = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
    return '${getMotivoIcon(consulta.motivo)} ${consulta.motivo} - ${formatDate(date)}';
  }

  static String getConsultaSubtitle(Consulta consulta) {
    return 'Dr(a). ${consulta.veterinario}';
  }

  static List<Consulta> sortConsultasByDate(List<Consulta> consultas, {bool ascending = false}) {
    final sorted = List<Consulta>.from(consultas);
    sorted.sort((a, b) {
      final comparison = a.dataConsulta.compareTo(b.dataConsulta);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  static List<Consulta> filterConsultasByDateRange(
    List<Consulta> consultas,
    DateTime startDate,
    DateTime endDate,
  ) {
    return consultas.where((consulta) {
      final consultaDate = DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
      return consultaDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             consultaDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  static List<Consulta> filterConsultasByVeterinario(
    List<Consulta> consultas,
    String veterinario,
  ) {
    return consultas.where((consulta) =>
        consulta.veterinario.toLowerCase() == veterinario.toLowerCase()).toList();
  }

  static List<Consulta> filterConsultasByMotivo(
    List<Consulta> consultas,
    String motivo,
  ) {
    return consultas.where((consulta) =>
        consulta.motivo.toLowerCase().contains(motivo.toLowerCase())).toList();
  }
}
