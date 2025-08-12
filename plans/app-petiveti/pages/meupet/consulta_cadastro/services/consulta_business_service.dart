// Project imports:
import '../../../../models/12_consulta_model.dart';

/// Service responsible for business logic related to consulta operations
class ConsultaBusinessService {
  /// Validates business rules for a consulta
  Map<String, String?> validateBusinessRules(Consulta consulta) {
    final errors = <String, String?>{};

    // Business rule: Valor should be within reasonable veterinary consultation range
    if (consulta.valor < 0) {
      errors['valor'] = 'Valor não pode ser negativo';
    } else if (consulta.valor > 10000) {
      errors['valor'] = 'Valor parece muito alto para uma consulta veterinária';
    }

    // Business rule: Data cannot be too far in the future
    final consultaDate =
        DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
    final sixMonthsFromNow = DateTime.now().add(const Duration(days: 180));
    if (consultaDate.isAfter(sixMonthsFromNow)) {
      errors['dataConsulta'] =
          'Data da consulta não pode ser agendada para mais de 6 meses no futuro';
    }

    // Business rule: Validate motivo and diagnostico consistency
    final motivoProblematico = ['Emergência', 'Cirurgia'];
    if (motivoProblematico.contains(consulta.motivo) &&
        consulta.diagnostico.toLowerCase().contains('rotina')) {
      errors['diagnostico'] =
          'Diagnóstico inconsistente com motivo da consulta';
    }

    return errors;
  }

  /// Suggests diagnostico based on motivo
  String? suggestDiagnostico(String motivo) {
    final suggestions = {
      'Consulta de rotina': 'Animal apresenta bom estado geral de saúde.',
      'Check-up':
          'Exame clínico completo realizado sem alterações significativas.',
      'Vacina': 'Vacinação realizada conforme protocolo veterinário.',
      'Emergência': 'Atendimento de emergência realizado.',
      'Cirurgia': 'Procedimento cirúrgico realizado com sucesso.',
      'Exame': 'Exames complementares realizados.',
      'Tratamento': 'Tratamento iniciado conforme prescrição médica.',
      'Retorno': 'Retorno para acompanhamento do tratamento anterior.',
      'Outros': 'Procedimento específico realizado.',
    };

    return suggestions[motivo];
  }

  /// Generates recommendations based on consulta data
  List<String> generateRecommendations(Consulta consulta) {
    final recommendations = <String>[];

    // Recommendation based on motivo
    switch (consulta.motivo) {
      case 'Vacina':
        recommendations.add('Agendar próxima vacinação conforme calendário');
        break;
      case 'Emergência':
        recommendations.add('Acompanhar evolução nas próximas 24-48 horas');
        break;
      case 'Cirurgia':
        recommendations
            .add('Retorno em 7-10 dias para avaliação da cicatrização');
        break;
      case 'Check-up':
        recommendations.add('Próximo check-up recomendado em 12 meses');
        break;
    }

    // Recommendation based on valor
    if (consulta.valor > 500) {
      recommendations.add(
          'Consulta de alto valor - verificar se procedimentos especiais foram realizados');
    }

    // Time-based recommendations
    final consultaDate =
        DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
    final daysSinceConsulta = DateTime.now().difference(consultaDate).inDays;

    if (daysSinceConsulta > 365) {
      recommendations
          .add('Consulta há mais de 1 ano - considerar agendar novo check-up');
    }

    return recommendations;
  }

  /// Calculates consultation statistics
  Map<String, dynamic> calculateConsultationStats(List<Consulta> consultas) {
    if (consultas.isEmpty) {
      return {
        'total': 0,
        'averageValue': 0.0,
        'averageInterval': 0,
        'mostCommonMotivo': null,
        'totalValue': 0.0,
      };
    }

    final total = consultas.length;
    final totalValue = consultas.fold(0.0, (sum, c) => sum + c.valor);
    final averageValue = totalValue / total;

    // Calculate average interval between consultations
    int averageInterval = 0;
    if (consultas.length > 1) {
      consultas.sort((a, b) => a.dataConsulta.compareTo(b.dataConsulta));
      int totalDays = 0;
      for (int i = 1; i < consultas.length; i++) {
        final current =
            DateTime.fromMillisecondsSinceEpoch(consultas[i].dataConsulta);
        final previous =
            DateTime.fromMillisecondsSinceEpoch(consultas[i - 1].dataConsulta);
        totalDays += current.difference(previous).inDays;
      }
      averageInterval = totalDays ~/ (consultas.length - 1);
    }

    // Find most common motivo
    final motivoCounts = <String, int>{};
    for (final consulta in consultas) {
      motivoCounts[consulta.motivo] = (motivoCounts[consulta.motivo] ?? 0) + 1;
    }

    String? mostCommonMotivo;
    int maxCount = 0;
    motivoCounts.forEach((motivo, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonMotivo = motivo;
      }
    });

    return {
      'total': total,
      'averageValue': averageValue,
      'averageInterval': averageInterval,
      'mostCommonMotivo': mostCommonMotivo,
      'totalValue': totalValue,
    };
  }

  /// Validates if a consulta can be duplicated
  bool canDuplicateConsulta(Consulta consulta) {
    // Business rule: Cannot duplicate emergency consultations
    if (consulta.motivo == 'Emergência') {
      return false;
    }

    // Business rule: Cannot duplicate very recent consultations (same day)
    final consultaDate =
        DateTime.fromMillisecondsSinceEpoch(consulta.dataConsulta);
    final today = DateTime.now();
    if (consultaDate.year == today.year &&
        consultaDate.month == today.month &&
        consultaDate.day == today.day) {
      return false;
    }

    return true;
  }

  /// Creates a default consulta with business logic applied
  Consulta createDefaultConsulta({
    required String animalId,
    String? preferredVeterinario,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return Consulta(
      id: '',
      createdAt: now,
      updatedAt: now,        
      isDeleted: false,
      needsSync: true,
      version: 1,
      lastSyncAt: null,
      animalId: animalId,
      dataConsulta: now,
      veterinario: preferredVeterinario ?? 'Dr. ',
      motivo: 'Consulta de rotina',
      diagnostico: '',
      valor: 0.0,
      observacoes: null,
    );
  }

  /// Validates if consultation data has significant changes
  bool hasSignificantChanges(Consulta original, Consulta updated) {
    // Changes in critical fields are considered significant
    return original.animalId != updated.animalId ||
        original.veterinario != updated.veterinario ||
        original.motivo != updated.motivo ||
        original.diagnostico != updated.diagnostico ||
        (original.valor - updated.valor).abs() > 0.01 ||
        (original.dataConsulta - updated.dataConsulta).abs() >
            86400000; // 1 day in ms
  }

  /// Generates audit message for changes
  String generateAuditMessage(Consulta original, Consulta updated) {
    final changes = <String>[];

    if (original.animalId != updated.animalId) {
      changes.add('Animal alterado');
    }
    if (original.veterinario != updated.veterinario) {
      changes
          .add('Veterinário: ${original.veterinario} → ${updated.veterinario}');
    }
    if (original.motivo != updated.motivo) {
      changes.add('Motivo: ${original.motivo} → ${updated.motivo}');
    }
    if (original.diagnostico != updated.diagnostico) {
      changes.add('Diagnóstico alterado');
    }
    if ((original.valor - updated.valor).abs() > 0.01) {
      changes.add(
          'Valor: R\$ ${original.valor.toStringAsFixed(2)} → R\$ ${updated.valor.toStringAsFixed(2)}');
    }

    final originalDate =
        DateTime.fromMillisecondsSinceEpoch(original.dataConsulta);
    final updatedDate =
        DateTime.fromMillisecondsSinceEpoch(updated.dataConsulta);
    if (originalDate.difference(updatedDate).inDays.abs() > 0) {
      changes.add('Data alterada');
    }

    if (changes.isEmpty) {
      return 'Nenhuma alteração significativa';
    }

    return 'Alterações: ${changes.join(', ')}';
  }

  /// Validates consultation timing conflicts
  List<String> validateTimingConflicts(
    Consulta newConsulta,
    List<Consulta> existingConsultas,
  ) {
    final conflicts = <String>[];
    final newDate =
        DateTime.fromMillisecondsSinceEpoch(newConsulta.dataConsulta);

    for (final existing in existingConsultas) {
      if (existing.id == newConsulta.id) continue; // Skip self when editing

      final existingDate =
          DateTime.fromMillisecondsSinceEpoch(existing.dataConsulta);
      final hoursDifference = newDate.difference(existingDate).inHours.abs();

      // Warn about consultations too close in time
      if (hoursDifference < 2) {
        conflicts.add(
            'Existe outra consulta muito próxima no horário (${existing.veterinario})');
      }

      // Warn about duplicate consultations on same day
      if (newDate.year == existingDate.year &&
          newDate.month == existingDate.month &&
          newDate.day == existingDate.day &&
          newConsulta.veterinario == existing.veterinario) {
        conflicts
            .add('Já existe consulta no mesmo dia com ${existing.veterinario}');
      }
    }

    return conflicts;
  }
}
