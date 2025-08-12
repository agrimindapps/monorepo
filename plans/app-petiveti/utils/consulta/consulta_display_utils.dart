// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'consulta_core.dart';
import 'consulta_date_utils.dart';

class ConsultaDisplayUtils {
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

  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 4:
        return const Color(0xFFE53935); // Crítico - Vermelho
      case 3:
        return const Color(0xFFFF5722); // Alto - Laranja escuro
      case 2:
        return const Color(0xFFFF9800); // Médio - Laranja
      case 1:
        return const Color(0xFF4CAF50); // Baixo - Verde
      default:
        return const Color(0xFF9E9E9E); // Normal - Cinza
    }
  }

  static IconData getPriorityIcon(int priority) {
    switch (priority) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning;
      case 2:
        return Icons.info;
      case 1:
        return Icons.check_circle;
      default:
        return Icons.radio_button_unchecked;
    }
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeText(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static Widget buildMotivoBadge(String motivo) {
    final color = getMotivoColor(motivo);
    final icon = getMotivoIcon(motivo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            motivo,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPriorityBadge(int priority) {
    final color = getPriorityColor(priority);
    final icon = getPriorityIcon(priority);
    final text = ConsultaCore.getPriorityText(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> exportDisplayData({
    required String animalId,
    required DateTime dataConsulta,
    required String veterinario,
    required String motivo,
    required String diagnostico,
    String? observacoes,
  }) {
    final priority = ConsultaCore.calculatePriority(motivo);
    
    return {
      'animalId': animalId,
      'dataConsulta': dataConsulta.toIso8601String(),
      'veterinario': veterinario,
      'motivo': motivo,
      'diagnostico': diagnostico,
      'observacoes': observacoes,
      'dataFormatada': ConsultaDateUtils.formatData(dataConsulta),
      'motivoIcon': getMotivoIcon(motivo),
      'priority': priority,
      'priorityText': ConsultaCore.getPriorityText(priority),
      'tempoRelativo': ConsultaDateUtils.getRelativeTime(dataConsulta),
      'requiresFollowUp': ConsultaCore.requiresFollowUp(motivo),
      'estimatedDuration': ConsultaCore.getEstimatedDuration(motivo),
    };
  }

  static String escapeForCsv(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static Widget buildStatusIndicator({
    required String motivo,
    required DateTime dataConsulta,
    bool? completed,
  }) {
    final color = getMotivoColor(motivo);
    final icon = getMotivoIcon(motivo);
    final isRecent = ConsultaDateUtils.isToday(dataConsulta) || 
                    ConsultaDateUtils.getRelativeTime(dataConsulta).contains('hora');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color,
          width: isRecent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                motivo,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                ConsultaDateUtils.formatData(dataConsulta),
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (completed == true) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }
}
