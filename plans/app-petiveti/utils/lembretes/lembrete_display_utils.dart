// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'lembrete_core.dart';

class LembreteDisplayUtils {
  static Color getStatusColor(DateTime? dataHora) {
    if (dataHora == null) return Colors.grey;
    
    if (LembreteCore.isOverdue(dataHora)) {
      return Colors.red;
    } else if (LembreteCore.isUrgent(dataHora)) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  static IconData getStatusIcon(DateTime? dataHora) {
    if (dataHora == null) return Icons.schedule;
    
    if (LembreteCore.isOverdue(dataHora)) {
      return Icons.warning;
    } else if (LembreteCore.isUrgent(dataHora)) {
      return Icons.schedule;
    } else {
      return Icons.check_circle_outline;
    }
  }

  static String getStatusText(DateTime? dataHora) {
    if (dataHora == null) return 'Sem data';
    
    if (LembreteCore.isOverdue(dataHora)) {
      return 'Vencido';
    } else if (LembreteCore.isUrgent(dataHora)) {
      return 'Urgente';
    } else {
      return 'No prazo';
    }
  }

  static IconData getTipoIcon(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'medicamento':
        return Icons.medication;
      case 'consulta':
        return Icons.medical_services;
      case 'vacina':
        return Icons.vaccines;
      case 'banho e tosa':
        return Icons.bathtub;
      case 'ração':
        return Icons.dinner_dining;
      case 'exercício':
        return Icons.fitness_center;
      default:
        return Icons.event_note;
    }
  }

  static Color getTipoColor(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'medicamento':
        return Colors.blue;
      case 'consulta':
        return Colors.teal;
      case 'vacina':
        return Colors.purple;
      case 'banho e tosa':
        return Colors.cyan;
      case 'ração':
        return Colors.brown;
      case 'exercício':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static Widget buildStatusBadge(DateTime? dataHora) {
    final color = getStatusColor(dataHora);
    final icon = getStatusIcon(dataHora);
    final text = getStatusText(dataHora);

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

  static Widget buildTipoBadge(String? tipo) {
    final color = getTipoColor(tipo);
    final icon = getTipoIcon(tipo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            tipo ?? 'Outro',
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
}
