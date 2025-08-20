class LembreteCore {
  static bool isOverdue(DateTime? dataHora) {
    if (dataHora == null) return false;
    return dataHora.isBefore(DateTime.now());
  }

  static bool isUrgent(DateTime? dataHora) {
    if (dataHora == null) return false;
    final now = DateTime.now();
    final diff = dataHora.difference(now);
    return diff.inHours <= 24 && diff.inHours >= 0;
  }

  static int calculatePriority(DateTime? dataHora) {
    if (dataHora == null) return 0;
    final now = DateTime.now();
    final diff = dataHora.difference(now);
    
    if (diff.isNegative) return 3; // Vencido
    if (diff.inHours <= 24) return 2; // Urgente
    if (diff.inDays <= 7) return 1; // Próximo
    return 0; // Normal
  }

  static String getTimeRemaining(DateTime? dataHora) {
    if (dataHora == null) return '';
    
    final now = DateTime.now();
    final diff = dataHora.difference(now);
    
    if (diff.isNegative) {
      final overdue = now.difference(dataHora);
      if (overdue.inDays > 0) {
        return 'Vencido há ${overdue.inDays} dia(s)';
      } else if (overdue.inHours > 0) {
        return 'Vencido há ${overdue.inHours} hora(s)';
      } else {
        return 'Vencido há ${overdue.inMinutes} minuto(s)';
      }
    }
    
    if (diff.inDays > 0) {
      return 'Em ${diff.inDays} dia(s)';
    } else if (diff.inHours > 0) {
      return 'Em ${diff.inHours} hora(s)';
    } else if (diff.inMinutes > 0) {
      return 'Em ${diff.inMinutes} minuto(s)';
    } else {
      return 'Agora';
    }
  }

  static List<String> getSuggestedTypes() {
    return [
      'Medicamento',
      'Consulta',
      'Vacina',
      'Banho e Tosa',
      'Ração',
      'Exercício',
      'Outro',
    ];
  }

  static Map<String, dynamic> exportToJson(Map<String, dynamic> lembrete) {
    return {
      'id': lembrete['id'],
      'petId': lembrete['petId'],
      'tipo': lembrete['tipo'],
      'titulo': lembrete['titulo'],
      'descricao': lembrete['descricao'],
      'dataHora': lembrete['dataHora']?.toIso8601String(),
      'concluido': lembrete['concluido'] ?? false,
      'repetir': lembrete['repetir'],
      'criadoEm': lembrete['criadoEm']?.toIso8601String(),
    };
  }
}