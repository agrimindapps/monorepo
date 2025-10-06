import 'package:core/core.dart' show Equatable;

class Vaccine extends Equatable {
  final String id;
  final String animalId;
  final String name;
  final String veterinarian;
  final DateTime date;
  final DateTime? nextDueDate;
  final String? batch;
  final String? manufacturer;
  final String? dosage;
  final String? notes;
  final bool isRequired;
  final bool isCompleted;
  final DateTime? reminderDate;
  final VaccineStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Vaccine({
    required this.id,
    required this.animalId,
    required this.name,
    required this.veterinarian,
    required this.date,
    this.nextDueDate,
    this.batch,
    this.manufacturer,
    this.dosage,
    this.notes,
    this.isRequired = true,
    this.isCompleted = false,
    this.reminderDate,
    this.status = VaccineStatus.scheduled,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Vaccine copyWith({
    String? id,
    String? animalId,
    String? name,
    String? veterinarian,
    DateTime? date,
    DateTime? nextDueDate,
    String? batch,
    String? manufacturer,
    String? dosage,
    String? notes,
    bool? isRequired,
    bool? isCompleted,
    DateTime? reminderDate,
    VaccineStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Vaccine(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      name: name ?? this.name,
      veterinarian: veterinarian ?? this.veterinarian,
      date: date ?? this.date,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      batch: batch ?? this.batch,
      manufacturer: manufacturer ?? this.manufacturer,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderDate: reminderDate ?? this.reminderDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
  bool get isValid {
    return name.trim().isNotEmpty &&
        veterinarian.trim().isNotEmpty &&
        animalId.trim().isNotEmpty &&
        date.isBefore(
          DateTime.now().add(const Duration(days: 1)),
        ); // Can't be in future
  }

  bool get isPending {
    if (nextDueDate == null || isCompleted) return false;
    return nextDueDate!.isAfter(DateTime.now()) &&
        status == VaccineStatus.scheduled;
  }

  bool get isOverdue {
    if (nextDueDate == null || isCompleted) return false;
    return nextDueDate!.isBefore(DateTime.now()) &&
        !isCompleted &&
        isRequired &&
        status != VaccineStatus.cancelled;
  }

  bool get isDueToday {
    if (nextDueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return nextDueDate!.year == now.year &&
        nextDueDate!.month == now.month &&
        nextDueDate!.day == now.day &&
        !isCompleted;
  }

  bool get isDueSoon {
    if (nextDueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final daysDiff = nextDueDate!.difference(now).inDays;
    return daysDiff >= 0 && daysDiff <= 7 && !isCompleted; // Due within 7 days
  }

  bool get needsReminder {
    if (reminderDate == null || isCompleted) return false;
    final now = DateTime.now();
    return reminderDate!.isBefore(now) || reminderDate!.isAtSameMomentAs(now);
  }

  int get daysUntilNextDose {
    if (nextDueDate == null) return -1;
    return nextDueDate!.difference(DateTime.now()).inDays;
  }

  int get daysSinceApplication {
    return DateTime.now().difference(date).inDays;
  }

  String get displayStatus {
    if (isCompleted) return 'Concluída';

    switch (status) {
      case VaccineStatus.applied:
        return 'Aplicada';
      case VaccineStatus.scheduled:
        return 'Agendada';
      case VaccineStatus.overdue:
        return 'Vencida';
      case VaccineStatus.completed:
        return 'Completa';
      case VaccineStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get priorityLevel {
    if (isCompleted) return 'Baixa';
    if (isOverdue && isRequired) return 'Alta';
    if (isDueToday) return 'Alta';
    if (isDueSoon) return 'Média';
    return 'Baixa';
  }

  String get nextDoseInfo {
    if (nextDueDate == null) return 'Dose única';
    if (isCompleted) return 'Vacina concluída';

    if (isOverdue) {
      final days = DateTime.now().difference(nextDueDate!).inDays;
      return 'Atrasada há $days ${days == 1 ? 'dia' : 'dias'}';
    } else if (isDueToday) {
      return 'Vence hoje';
    } else if (isDueSoon) {
      return 'Vence em $daysUntilNextDose ${daysUntilNextDose == 1 ? 'dia' : 'dias'}';
    } else if (isPending) {
      return 'Vence em $daysUntilNextDose ${daysUntilNextDose == 1 ? 'dia' : 'dias'}';
    }

    return 'Próxima dose programada';
  }

  String get reminderInfo {
    if (reminderDate == null) return 'Sem lembrete';
    if (needsReminder) return 'Lembrete ativo';

    final days = reminderDate!.difference(DateTime.now()).inDays;
    if (days == 0) return 'Lembrete hoje';
    if (days > 0) return 'Lembrete em $days ${days == 1 ? 'dia' : 'dias'}';
    return 'Lembrete vencido';
  }
  bool canBeMarkedAsCompleted() {
    return !isCompleted &&
        status != VaccineStatus.cancelled &&
        date.isBefore(DateTime.now().add(const Duration(days: 1)));
  }

  bool requiresNextDose() {
    return nextDueDate != null && !isCompleted && isRequired;
  }

  Vaccine markAsCompleted() {
    if (!canBeMarkedAsCompleted()) return this;

    return copyWith(
      isCompleted: true,
      status: VaccineStatus.applied,
      updatedAt: DateTime.now(),
    );
  }

  Vaccine scheduleReminder(DateTime reminderDateTime) {
    return copyWith(reminderDate: reminderDateTime, updatedAt: DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    animalId,
    name,
    veterinarian,
    date,
    nextDueDate,
    batch,
    manufacturer,
    dosage,
    notes,
    isRequired,
    isCompleted,
    reminderDate,
    status,
    createdAt,
    updatedAt,
    isDeleted,
  ];
}

enum VaccineStatus {
  scheduled, // Agendada (ex-pending)
  applied, // Aplicada
  overdue, // Atrasada (ex-expired)
  completed, // Completa
  cancelled, // Cancelada
}

extension VaccineStatusExtension on VaccineStatus {
  String get displayText {
    switch (this) {
      case VaccineStatus.scheduled:
        return 'Agendada';
      case VaccineStatus.applied:
        return 'Aplicada';
      case VaccineStatus.overdue:
        return 'Atrasada';
      case VaccineStatus.completed:
        return 'Completa';
      case VaccineStatus.cancelled:
        return 'Cancelada';
    }
  }

  int get priority {
    switch (this) {
      case VaccineStatus.overdue:
        return 0;
      case VaccineStatus.scheduled:
        return 1;
      case VaccineStatus.applied:
        return 2;
      case VaccineStatus.completed:
        return 3;
      case VaccineStatus.cancelled:
        return 4;
    }
  }

  bool get isActive {
    switch (this) {
      case VaccineStatus.scheduled:
      case VaccineStatus.applied:
      case VaccineStatus.overdue:
        return true;
      case VaccineStatus.completed:
      case VaccineStatus.cancelled:
        return false;
    }
  }
}
