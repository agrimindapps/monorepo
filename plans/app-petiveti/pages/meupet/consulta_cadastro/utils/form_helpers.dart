// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../utils/consulta_utils.dart';

class ConsultaCadastroFormHelpers {
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
    required String veterinario,
    required String motivo,
    required String diagnostico,
    String? observacoes,
  }) {
    return {
      'hasAnimal': animalId.isNotEmpty,
      'hasVeterinario': veterinario.isNotEmpty,
      'hasMotivo': motivo.isNotEmpty,
      'hasDiagnostico': diagnostico.isNotEmpty,
      'hasObservacoes': observacoes != null && observacoes.isNotEmpty,
      'veterinarioLength': veterinario.length,
      'motivoLength': motivo.length,
      'diagnosticoLength': diagnostico.length,
      'observacoesLength': observacoes?.length ?? 0,
      'completionPercentage': _calculateCompletionPercentage(
        animalId: animalId,
        veterinario: veterinario,
        motivo: motivo,
        diagnostico: diagnostico,
        observacoes: observacoes,
      ),
    };
  }

  static double _calculateCompletionPercentage({
    required String animalId,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    String? observacoes,
  }) {
    int completed = 0;
    const int total = 4; // Required fields only

    if (animalId.isNotEmpty) completed++;
    if (veterinario.isNotEmpty) completed++;
    if (motivo.isNotEmpty) completed++;
    if (diagnostico.isNotEmpty) completed++;

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

  static bool isFormValid({
    required String animalId,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    required DateTime? dataConsulta,
    String? observacoes,
  }) {
    return animalId.isNotEmpty &&
        ConsultaUtils.isValidVeterinario(veterinario) &&
        ConsultaUtils.isValidMotivo(motivo) &&
        ConsultaUtils.isValidDiagnostico(diagnostico) &&
        dataConsulta != null &&
        ConsultaUtils.isValidDate(dataConsulta) &&
        ConsultaUtils.isValidObservacoes(observacoes);
  }

  static Map<String, String?> validateForm({
    required String animalId,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    required DateTime? dataConsulta,
    String? observacoes,
  }) {
    final errors = <String, String?>{};

    if (animalId.isEmpty) {
      errors['animalId'] = 'Animal é obrigatório';
    }

    if (!ConsultaUtils.isValidVeterinario(veterinario)) {
      errors['veterinario'] = 'Nome do veterinário é obrigatório e deve ser válido';
    }

    if (!ConsultaUtils.isValidMotivo(motivo)) {
      errors['motivo'] = 'Motivo é obrigatório';
    }

    if (!ConsultaUtils.isValidDiagnostico(diagnostico)) {
      errors['diagnostico'] = 'Diagnóstico é obrigatório';
    }

    if (dataConsulta == null || !ConsultaUtils.isValidDate(dataConsulta)) {
      errors['dataConsulta'] = 'Data da consulta é obrigatória e deve ser válida';
    }

    if (!ConsultaUtils.isValidObservacoes(observacoes)) {
      errors['observacoes'] = 'Observações devem ter no máximo 1000 caracteres';
    }

    return errors;
  }

  static Widget buildProgressIndicator(double percentage) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso do formulário',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: getFormCompletionColor(percentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            getFormCompletionColor(percentage),
          ),
        ),
      ],
    );
  }

  static Widget buildStepIndicator({
    required int currentStep,
    required int totalSteps,
    required List<String> stepTitles,
  }) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;
        
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent 
                      ? Colors.blue 
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stepTitles[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted || isCurrent 
                      ? Colors.blue 
                      : Colors.grey[600],
                  fontWeight: isCurrent 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  static List<String> getFormSteps() {
    return [
      'Animal',
      'Veterinário',
      'Motivo',
      'Diagnóstico',
      'Data',
    ];
  }

  static int getCurrentStep({
    required String animalId,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    required DateTime? dataConsulta,
  }) {
    if (animalId.isEmpty) return 0;
    if (veterinario.isEmpty) return 1;
    if (motivo.isEmpty) return 2;
    if (diagnostico.isEmpty) return 3;
    if (dataConsulta == null) return 4;
    return 5;
  }

  static String? getSuggestionForMotivo(String motivo) {
    return ConsultaUtils.generateSuggestion(motivo, null);
  }

  static List<String> getQuickMotivoSuggestions() {
    return [
      'Consulta de rotina',
      'Check-up',
      'Vacina',
      'Exame',
    ];
  }

  static Widget buildQuickMotivoButtons({
    required Function(String) onMotivoSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: getQuickMotivoSuggestions()
          .map((motivo) => OutlinedButton(
                onPressed: () => onMotivoSelected(motivo),
                child: Text(motivo),
              ))
          .toList(),
    );
  }

  static bool shouldShowPriorityIndicator(String motivo) {
    final priority = ConsultaUtils.calculatePriority(motivo);
    return priority >= 2; // Médio ou acima
  }

  static Widget buildPriorityAlert(String motivo) {
    final priority = ConsultaUtils.calculatePriority(motivo);
    final priorityText = ConsultaUtils.getPriorityText(priority);
    final requiresFollowUp = ConsultaUtils.requiresFollowUp(motivo);

    if (priority < 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: priority >= 3 ? Colors.red.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        border: Border.all(
          color: priority >= 3 ? Colors.red : Colors.orange,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            priority >= 3 ? Icons.warning : Icons.info,
            color: priority >= 3 ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prioridade: $priorityText',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: priority >= 3 ? Colors.red : Colors.orange,
                  ),
                ),
                if (requiresFollowUp)
                  Text(
                    'Este tipo de consulta pode necessitar acompanhamento',
                    style: TextStyle(
                      fontSize: 12,
                      color: priority >= 3 ? Colors.red : Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
