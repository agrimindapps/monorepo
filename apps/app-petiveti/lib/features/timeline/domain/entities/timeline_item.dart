import 'package:flutter/material.dart';

/// Tipo de evento na timeline
enum TimelineEventType {
  vaccine,
  medication,
  appointment,
  weight,
  reminder,
}

/// Item unificado para a timeline
/// Representa qualquer evento do pet em ordem cronológica
class TimelineItem {
  final String id;
  final TimelineEventType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final String? animalId;
  final String? animalName;
  final IconData icon;
  final Map<String, dynamic>? metadata;

  const TimelineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    this.animalId,
    this.animalName,
    required this.icon,
    this.metadata,
  });

  /// Retorna a cor associada ao tipo de evento
  Color getTypeColor(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    switch (type) {
      case TimelineEventType.vaccine:
        return primary;
      case TimelineEventType.medication:
        return Colors.orange;
      case TimelineEventType.appointment:
        return Colors.blue;
      case TimelineEventType.weight:
        return Colors.green;
      case TimelineEventType.reminder:
        return Colors.purple;
    }
  }

  /// Retorna o label do tipo de evento
  String get typeLabel {
    switch (type) {
      case TimelineEventType.vaccine:
        return 'Vacina';
      case TimelineEventType.medication:
        return 'Medicamento';
      case TimelineEventType.appointment:
        return 'Consulta';
      case TimelineEventType.weight:
        return 'Peso';
      case TimelineEventType.reminder:
        return 'Lembrete';
    }
  }
}
