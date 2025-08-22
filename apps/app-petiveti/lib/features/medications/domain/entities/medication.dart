import 'package:equatable/equatable.dart';

class Medication extends Equatable {
  final String id;
  final String animalId;
  final String name;
  final String dosage;
  final String frequency;
  final String? duration;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final String? prescribedBy;
  final MedicationType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Medication({
    required this.id,
    required this.animalId,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.duration,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.prescribedBy,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Medication copyWith({
    String? id,
    String? animalId,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    String? prescribedBy,
    MedicationType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Medication(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      prescribedBy: prescribedBy ?? this.prescribedBy,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Verifica se o tratamento ainda está ativo
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !isDeleted;
  }

  /// Calcula a duração total do tratamento em dias
  int get totalDurationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Retorna os dias restantes para o fim do tratamento
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  /// Calcula o progresso do tratamento (0.0 a 1.0)
  double get progress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;
    
    final elapsed = now.difference(startDate).inDays;
    final total = totalDurationInDays;
    return total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;
  }

  /// Verifica se o medicamento está próximo do vencimento (menos de 3 dias)
  bool get isExpiringSoon {
    final now = DateTime.now();
    final daysUntilExpiry = endDate.difference(now).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry > 0;
  }

  /// Retorna uma descrição amigável do intervalo de tratamento
  String get treatmentInterval {
    final start = "${startDate.day}/${startDate.month}/${startDate.year}";
    final end = "${endDate.day}/${endDate.month}/${endDate.year}";
    return "$start - $end";
  }

  /// Retorna um resumo completo do medicamento
  String get summary {
    return "Medicamento: $name, Dosagem: $dosage, Frequência: $frequency${duration != null ? ', Duração: $duration' : ''}, Período: $treatmentInterval";
  }

  /// Status do tratamento baseado nas datas
  MedicationStatus get status {
    final now = DateTime.now();
    if (isDeleted) return MedicationStatus.discontinued;
    if (now.isBefore(startDate)) return MedicationStatus.scheduled;
    if (now.isAfter(endDate)) return MedicationStatus.completed;
    return MedicationStatus.active;
  }

  @override
  List<Object?> get props => [
        id,
        animalId,
        name,
        dosage,
        frequency,
        duration,
        startDate,
        endDate,
        notes,
        prescribedBy,
        type,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

enum MedicationType {
  antibiotic,
  antiInflammatory,
  painkiller,
  vitamin,
  supplement,
  antifungal,
  antiparasitic,
  vaccine,
  other;

  String get displayName {
    switch (this) {
      case MedicationType.antibiotic:
        return 'Antibiótico';
      case MedicationType.antiInflammatory:
        return 'Anti-inflamatório';
      case MedicationType.painkiller:
        return 'Analgésico';
      case MedicationType.vitamin:
        return 'Vitamina';
      case MedicationType.supplement:
        return 'Suplemento';
      case MedicationType.antifungal:
        return 'Antifúngico';
      case MedicationType.antiparasitic:
        return 'Antiparasitário';
      case MedicationType.vaccine:
        return 'Vacina';
      case MedicationType.other:
        return 'Outro';
    }
  }
}

enum MedicationStatus {
  scheduled,
  active,
  completed,
  discontinued;

  String get displayName {
    switch (this) {
      case MedicationStatus.scheduled:
        return 'Agendado';
      case MedicationStatus.active:
        return 'Ativo';
      case MedicationStatus.completed:
        return 'Concluído';
      case MedicationStatus.discontinued:
        return 'Descontinuado';
    }
  }
}