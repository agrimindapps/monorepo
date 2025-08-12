class ConsultaCore {
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

  static List<String> getCommonVeterinarios() {
    return [
      'Dr. João Silva',
      'Dra. Maria Santos',
      'Dr. Pedro Oliveira',
      'Dra. Ana Costa',
      'Dr. Carlos Ferreira',
      'Dra. Fernanda Lima',
      'Dr. Roberto Alves',
      'Dra. Carla Mendes',
    ];
  }

  static String? generateSuggestion(String motivo, String? currentText) {
    final suggestions = {
      'Consulta de rotina': 'Animal apresenta bom estado geral de saúde. Exame clínico dentro da normalidade.',
      'Check-up': 'Exame clínico completo realizado. Animal em boas condições gerais.',
      'Vacina': 'Vacinação realizada conforme protocolo. Animal apresentou boa tolerância.',
      'Emergência': 'Atendimento de emergência realizado. Quadro clínico estabilizado.',
      'Cirurgia': 'Procedimento cirúrgico realizado com sucesso. Prognóstico reservado.',
      'Exame': 'Exames complementares realizados. Aguardando resultados.',
      'Tratamento': 'Tratamento iniciado conforme prescrição médica.',
      'Retorno': 'Retorno para acompanhamento. Evolução satisfatória do quadro.',
      'Outros': 'Procedimento específico realizado conforme necessidade.',
    };

    if (currentText == null || currentText.trim().isEmpty) {
      return suggestions[motivo];
    }

    return null;
  }

  static Map<String, dynamic> exportToJson({
    required String animalId,
    required DateTime dataConsulta,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    String? observacoes,
  }) {
    return {
      'animalId': animalId,
      'dataConsulta': dataConsulta.toIso8601String(),
      'veterinario': veterinario,
      'motivo': motivo,
      'diagnostico': diagnostico,
      'observacoes': observacoes,
    };
  }

  static int calculatePriority(String motivo) {
    switch (motivo.toLowerCase()) {
      case 'emergência':
      case 'urgência':
        return 4; // Crítico
      case 'cirurgia':
        return 3; // Alto
      case 'exame':
      case 'tratamento':
        return 2; // Médio
      case 'consulta de rotina':
      case 'check-up':
      case 'retorno':
        return 1; // Baixo
      default:
        return 0; // Normal
    }
  }

  static String getPriorityText(int priority) {
    switch (priority) {
      case 4:
        return 'Crítico';
      case 3:
        return 'Alto';
      case 2:
        return 'Médio';
      case 1:
        return 'Baixo';
      default:
        return 'Normal';
    }
  }

  static bool requiresFollowUp(String motivo) {
    switch (motivo.toLowerCase()) {
      case 'cirurgia':
      case 'tratamento':
      case 'emergência':
        return true;
      default:
        return false;
    }
  }

  static int getEstimatedDuration(String motivo) {
    switch (motivo.toLowerCase()) {
      case 'consulta de rotina':
      case 'check-up':
        return 30; // minutos
      case 'vacina':
        return 15;
      case 'exame':
        return 45;
      case 'cirurgia':
        return 120;
      case 'emergência':
        return 60;
      case 'tratamento':
        return 30;
      case 'retorno':
        return 20;
      default:
        return 30;
    }
  }
}