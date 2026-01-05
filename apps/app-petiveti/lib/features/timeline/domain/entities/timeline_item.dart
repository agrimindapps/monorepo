import 'package:flutter/material.dart';

/// Tipo de evento na timeline
enum TimelineEventType {
  vaccine,
  medication,
  appointment,
  weight,
  expense,
}

/// Item unificado para a timeline
/// Representa qualquer evento do pet em ordem cronológica
class TimelineItem {
  final String id;
  final TimelineEventType type;
  final String title;
  final DateTime date;
  final String? animalId;
  final String? animalName;
  final IconData icon;

  // Campos específicos por tipo - Vacina
  final String? veterinarian;
  final DateTime? nextDueDate;
  final String? batch;
  final String? manufacturer;
  final String? dosage;

  // Campos específicos - Medicamento
  final String? frequency;
  final String? duration;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? medicationType;
  final bool? isActive;

  // Campos específicos - Consulta
  final String? location;
  final String? status;
  final String? description;
  final double? cost;

  // Campos específicos - Peso
  final double? weight;
  final String? weightUnit;
  final int? bodyConditionScore;

  // Campos específicos - Despesa
  final double? amount;
  final String? category;
  final String? paymentMethod;
  final bool? isPaid;

  // Campo genérico
  final String? notes;

  const TimelineItem({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    this.animalId,
    this.animalName,
    required this.icon,
    this.veterinarian,
    this.nextDueDate,
    this.batch,
    this.manufacturer,
    this.dosage,
    this.frequency,
    this.duration,
    this.startDate,
    this.endDate,
    this.medicationType,
    this.isActive,
    this.location,
    this.status,
    this.description,
    this.cost,
    this.weight,
    this.weightUnit,
    this.bodyConditionScore,
    this.amount,
    this.category,
    this.paymentMethod,
    this.isPaid,
    this.notes,
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
      case TimelineEventType.expense:
        return Colors.red;
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
      case TimelineEventType.expense:
        return 'Despesa';
    }
  }
}
