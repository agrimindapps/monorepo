import 'package:equatable/equatable.dart';

class Vaccine extends Equatable {
  final String id;
  final String animalId;
  final String name;
  final DateTime applicationDate;
  final DateTime? nextDoseDate;
  final String? veterinarianName;
  final String? batch;
  final String? notes;
  final VaccineStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Vaccine({
    required this.id,
    required this.animalId,
    required this.name,
    required this.applicationDate,
    this.nextDoseDate,
    this.veterinarianName,
    this.batch,
    this.notes,
    this.status = VaccineStatus.applied,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Vaccine copyWith({
    String? id,
    String? animalId,
    String? name,
    DateTime? applicationDate,
    DateTime? nextDoseDate,
    String? veterinarianName,
    String? batch,
    String? notes,
    VaccineStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Vaccine(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      name: name ?? this.name,
      applicationDate: applicationDate ?? this.applicationDate,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      batch: batch ?? this.batch,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isPending {
    if (nextDoseDate == null) return false;
    return nextDoseDate!.isAfter(DateTime.now()) && status == VaccineStatus.applied;
  }

  bool get isOverdue {
    if (nextDoseDate == null) return false;
    return nextDoseDate!.isBefore(DateTime.now()) && status == VaccineStatus.applied;
  }

  bool get isDueToday {
    if (nextDoseDate == null) return false;
    final now = DateTime.now();
    return nextDoseDate!.year == now.year &&
        nextDoseDate!.month == now.month &&
        nextDoseDate!.day == now.day;
  }

  bool get isDueSoon {
    if (nextDoseDate == null) return false;
    final now = DateTime.now();
    final daysDiff = nextDoseDate!.difference(now).inDays;
    return daysDiff >= 0 && daysDiff <= 7; // Due within 7 days
  }

  int get daysUntilNextDose {
    if (nextDoseDate == null) return -1;
    return nextDoseDate!.difference(DateTime.now()).inDays;
  }

  String get displayStatus {
    switch (status) {
      case VaccineStatus.applied:
        return 'Aplicada';
      case VaccineStatus.pending:
        return 'Pendente';
      case VaccineStatus.expired:
        return 'Vencida';
      case VaccineStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get nextDoseInfo {
    if (nextDoseDate == null) return 'Dose única';
    
    if (isOverdue) {
      final days = DateTime.now().difference(nextDoseDate!).inDays;
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

  @override
  List<Object?> get props => [
        id,
        animalId,
        name,
        applicationDate,
        nextDoseDate,
        veterinarianName,
        batch,
        notes,
        status,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

enum VaccineStatus {
  applied,
  pending,
  expired,
  cancelled,
}