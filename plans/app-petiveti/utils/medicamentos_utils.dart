// Flutter imports:
import 'package:flutter/material.dart';

class MedicamentosUtils {
  /// Get icon for medication type
  static String getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'antibiótico':
      case 'antibiotico':
        return '🦠';
      case 'anti-inflamatório':
      case 'anti-inflamatorio':
      case 'antiinflamatório':
      case 'antiinflamatorio':
        return '🩹';
      case 'analgésico':
      case 'analgesico':
        return '💊';
      case 'vitamina':
      case 'suplemento':
        return '🌿';
      case 'vermífugo':
      case 'vermifugo':
        return '🪱';
      case 'antipulgas':
      case 'carrapaticida':
        return '🕷️';
      case 'colírio':
      case 'colirio':
        return '👁️';
      case 'pomada':
      case 'creme':
        return '🧴';
      case 'xarope':
        return '🍯';
      case 'injeção':
      case 'injecao':
        return '💉';
      case 'spray':
        return '💨';
      case 'comprimido':
      case 'cápsula':
      case 'capsula':
        return '💊';
      case 'outros':
      default:
        return '💊';
    }
  }

  /// Get color for medication type
  static Color getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'antibiótico':
      case 'antibiotico':
        return const Color(0xFFE53935); // Red
      case 'anti-inflamatório':
      case 'anti-inflamatorio':
      case 'antiinflamatório':
      case 'antiinflamatorio':
        return const Color(0xFF1E88E5); // Blue
      case 'analgésico':
      case 'analgesico':
        return const Color(0xFF43A047); // Green
      case 'vitamina':
      case 'suplemento':
        return const Color(0xFFFFB300); // Amber
      case 'vermífugo':
      case 'vermifugo':
        return const Color(0xFF8E24AA); // Purple
      case 'antipulgas':
      case 'carrapaticida':
        return const Color(0xFF6D4C41); // Brown
      case 'colírio':
      case 'colirio':
        return const Color(0xFF00ACC1); // Cyan
      case 'pomada':
      case 'creme':
        return const Color(0xFF7CB342); // Light Green
      case 'xarope':
        return const Color(0xFFFF8F00); // Orange
      case 'injeção':
      case 'injecao':
        return const Color(0xFFD81B60); // Pink
      case 'spray':
        return const Color(0xFF546E7A); // Blue Grey
      case 'comprimido':
      case 'cápsula':
      case 'capsula':
        return const Color(0xFF5E35B1); // Deep Purple
      case 'outros':
      default:
        return const Color(0xFF78909C); // Grey
    }
  }

  /// Get available medication types
  static List<String> getAvailableTipos() {
    return [
      'Antibiótico',
      'Anti-inflamatório',
      'Analgésico',
      'Vitamina',
      'Suplemento',
      'Vermífugo',
      'Antipulgas',
      'Carrapaticida',
      'Colírio',
      'Pomada',
      'Creme',
      'Xarope',
      'Injeção',
      'Spray',
      'Comprimido',
      'Cápsula',
      'Outros',
    ];
  }

  /// Get common medication types for quick selection
  static List<String> getCommonTipos() {
    return [
      'Antibiótico',
      'Analgésico',
      'Vitamina',
      'Vermífugo',
      'Antipulgas',
    ];
  }

  /// Get available frequencies
  static List<String> getFrequencias() {
    return [
      '1x ao dia',
      '2x ao dia',
      '3x ao dia',
      '4x ao dia',
      'A cada 6 horas',
      'A cada 8 horas',
      'A cada 12 horas',
      'A cada 24 horas',
      'Conforme necessário',
      'Outros',
    ];
  }

  /// Get available units
  static List<String> getUnidades() {
    return [
      'mg',
      'ml',
      'comprimidos',
      'cápsulas',
      'gotas',
      'aplicações',
      'doses',
      'outros',
    ];
  }

  /// Calculate days remaining for treatment
  static int diasRestantesTratamento(DateTime dataInicio, int duracaoDias) {
    final now = DateTime.now();
    final dataFim = dataInicio.add(Duration(days: duracaoDias));
    final diasRestantes = dataFim.difference(now).inDays;
    return diasRestantes > 0 ? diasRestantes : 0;
  }

  /// Check if medication is currently active
  static bool isMedicamentoActive(DateTime dataInicio, int duracaoDias) {
    final now = DateTime.now();
    final dataFim = dataInicio.add(Duration(days: duracaoDias));
    return now.isAfter(dataInicio) && now.isBefore(dataFim);
  }

  /// Check if medication has expired
  static bool isMedicamentoExpired(DateTime dataInicio, int duracaoDias) {
    final now = DateTime.now();
    final dataFim = dataInicio.add(Duration(days: duracaoDias));
    return now.isAfter(dataFim);
  }

  /// Get treatment progress percentage
  static double progressoTratamento(DateTime dataInicio, int duracaoDias) {
    final now = DateTime.now();
    final dataFim = dataInicio.add(Duration(days: duracaoDias));
    
    if (now.isBefore(dataInicio)) return 0.0;
    if (now.isAfter(dataFim)) return 100.0;
    
    final totalDuration = dataFim.difference(dataInicio).inDays;
    final elapsed = now.difference(dataInicio).inDays;
    
    return (elapsed / totalDuration) * 100;
  }

  /// Get status text for medication
  static String getStatusText(DateTime dataInicio, int duracaoDias) {
    final now = DateTime.now();
    final dataFim = dataInicio.add(Duration(days: duracaoDias));
    
    if (now.isBefore(dataInicio)) {
      return 'Não iniciado';
    } else if (now.isAfter(dataFim)) {
      return 'Finalizado';
    } else {
      return 'Em andamento';
    }
  }

  /// Get status color for medication
  static Color getStatusColor(DateTime dataInicio, int duracaoDias) {
    final status = getStatusText(dataInicio, duracaoDias);
    
    switch (status) {
      case 'Não iniciado':
        return const Color(0xFF9E9E9E); // Grey
      case 'Em andamento':
        return const Color(0xFF4CAF50); // Green
      case 'Finalizado':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Get status icon for medication
  static String getStatusIcon(DateTime dataInicio, int duracaoDias) {
    final status = getStatusText(dataInicio, duracaoDias);
    
    switch (status) {
      case 'Não iniciado':
        return '⏳';
      case 'Em andamento':
        return '💊';
      case 'Finalizado':
        return '✅';
      default:
        return '❓';
    }
  }

  /// Get treatment duration text
  static String getDuracaoTratamento(int duracaoDias) {
    if (duracaoDias == 1) {
      return '1 dia';
    } else if (duracaoDias < 7) {
      return '$duracaoDias dias';
    } else if (duracaoDias < 30) {
      final semanas = (duracaoDias / 7).round();
      return '$semanas semana${semanas > 1 ? 's' : ''}';
    } else {
      final meses = (duracaoDias / 30).round();
      return '$meses mês${meses > 1 ? 'es' : ''}';
    }
  }

  /// Generate suggestion based on medication type
  static String? getTipoSuggestion(String tipo) {
    final suggestions = {
      'Antibiótico': 'Medicamento para combater infecções bacterianas',
      'Anti-inflamatório': 'Medicamento para reduzir inflamação e dor',
      'Analgésico': 'Medicamento para alívio da dor',
      'Vitamina': 'Suplemento vitamínico para fortalecimento',
      'Suplemento': 'Suplemento nutricional para saúde geral',
      'Vermífugo': 'Medicamento para eliminação de vermes',
      'Antipulgas': 'Medicamento para prevenção e tratamento de pulgas',
      'Carrapaticida': 'Medicamento para prevenção e tratamento de carrapatos',
      'Colírio': 'Medicamento oftálmico para tratamento dos olhos',
      'Pomada': 'Medicamento tópico para aplicação na pele',
      'Creme': 'Medicamento tópico para hidratação e tratamento',
      'Xarope': 'Medicamento líquido para administração oral',
      'Injeção': 'Medicamento para aplicação injetável',
      'Spray': 'Medicamento para aplicação por borrifação',
      'Comprimido': 'Medicamento sólido para administração oral',
      'Cápsula': 'Medicamento encapsulado para administração oral',
      'Outros': 'Medicamento específico conforme prescrição',
    };
    
    return suggestions[tipo];
  }

  /// Validate medication data
  static bool isValidNome(String nome) {
    return nome.trim().isNotEmpty && nome.length <= 100;
  }

  static bool isValidTipo(String tipo) {
    return getAvailableTipos().contains(tipo);
  }

  static bool isValidDosagem(String dosagem) {
    return dosagem.trim().isNotEmpty && dosagem.length <= 50;
  }

  static bool isValidFrequencia(String frequencia) {
    return frequencia.trim().isNotEmpty && frequencia.length <= 100;
  }

  static bool isValidDuracao(int duracao) {
    return duracao > 0 && duracao <= 365;
  }

  static bool isValidObservacoes(String? observacoes) {
    return observacoes == null || observacoes.length <= 500;
  }

  /// Get validation message
  static String getValidationMessage(String field, String? error) {
    if (error == null) return '';

    final fieldNames = {
      'animalId': 'Animal',
      'nome': 'Nome do medicamento',
      'tipo': 'Tipo',
      'dosagem': 'Dosagem',
      'frequencia': 'Frequência',
      'duracao': 'Duração',
      'dataInicio': 'Data de início',
      'observacoes': 'Observações',
    };

    final fieldName = fieldNames[field] ?? field;
    return '$fieldName: $error';
  }

  /// Export medication to JSON
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
    final dataFim = dataInicio.add(Duration(days: duracao));
    
    return {
      'animalId': animalId,
      'nome': nome,
      'tipo': tipo,
      'dosagem': dosagem,
      'frequencia': frequencia,
      'duracao': duracao,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'observacoes': observacoes,
      'dataInicioFormatada': '${dataInicio.day.toString().padLeft(2, '0')}/${dataInicio.month.toString().padLeft(2, '0')}/${dataInicio.year}',
      'dataFimFormatada': '${dataFim.day.toString().padLeft(2, '0')}/${dataFim.month.toString().padLeft(2, '0')}/${dataFim.year}',
      'tipoIcon': getTipoIcon(tipo),
      'statusText': getStatusText(dataInicio, duracao),
      'duracaoTexto': getDuracaoTratamento(duracao),
      'diasRestantes': diasRestantesTratamento(dataInicio, duracao),
      'progresso': progressoTratamento(dataInicio, duracao),
    };
  }

  /// Generate months list from medications
  static List<String> gerarListaMesesDisponiveis(List<dynamic> medicamentos) {
    if (medicamentos.isEmpty) {
      final now = DateTime.now();
      const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
      return ['${months[now.month - 1]} ${now.year.toString().substring(2)}'];
    }

    final sortedMedicamentos = List<dynamic>.from(medicamentos)
      ..sort((a, b) {
        final dateA = a is Map ? (a['dataInicio'] as int? ?? 0) : 0;
        final dateB = b is Map ? (b['dataInicio'] as int? ?? 0) : 0;
        return dateA.compareTo(dateB);
      });

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(
        sortedMedicamentos.first is Map ? (sortedMedicamentos.first['dataInicio'] as int? ?? 0) : 0);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(
        sortedMedicamentos.last is Map ? (sortedMedicamentos.last['dataInicio'] as int? ?? 0) : 0);

    final meses = <String>[];
    DateTime currentDate = DateTime(dataInicial.year, dataInicial.month);
    final endDate = DateTime(dataFinal.year, dataFinal.month);

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
      final mesFormatado = '${months[currentDate.month - 1]} ${currentDate.year.toString().substring(2)}';
      meses.add(mesFormatado);
      
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    final now = DateTime.now();
    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final mesAtual = '${months[now.month - 1]} ${now.year.toString().substring(2)}';
    if (!meses.contains(mesAtual)) {
      meses.add(mesAtual);
    }

    return meses.reversed.toList();
  }

  /// Format medications period
  static String formatarPeriodoMedicamentos(List<dynamic> medicamentos) {
    if (medicamentos.isEmpty) {
      final now = DateTime.now();
      const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
      return '${months[now.month - 1]} ${now.year.toString().substring(2)}';
    }

    final sortedMedicamentos = List<dynamic>.from(medicamentos)
      ..sort((a, b) {
        final dateA = a is Map ? (a['dataInicio'] as int? ?? 0) : 0;
        final dateB = b is Map ? (b['dataInicio'] as int? ?? 0) : 0;
        return dateA.compareTo(dateB);
      });

    final dataInicial = DateTime.fromMillisecondsSinceEpoch(
        sortedMedicamentos.first is Map ? (sortedMedicamentos.first['dataInicio'] as int? ?? 0) : 0);
    final dataFinal = DateTime.fromMillisecondsSinceEpoch(
        sortedMedicamentos.last is Map ? (sortedMedicamentos.last['dataInicio'] as int? ?? 0) : 0);

    const months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final mesInicial = '${months[dataInicial.month - 1]} ${dataInicial.year.toString().substring(2)}';
    final mesFinal = '${months[dataFinal.month - 1]} ${dataFinal.year.toString().substring(2)}';

    if (mesInicial == mesFinal) {
      return mesInicial;
    }

    return '$mesInicial - $mesFinal';
  }

}
