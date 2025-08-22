import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final String animalId;
  final String veterinarianName;
  final DateTime date;
  final String reason;
  final String? diagnosis;
  final String? notes;
  final AppointmentStatus status;
  final double? cost;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Appointment({
    required this.id,
    required this.animalId,
    required this.veterinarianName,
    required this.date,
    required this.reason,
    this.diagnosis,
    this.notes,
    this.status = AppointmentStatus.scheduled,
    this.cost,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Appointment copyWith({
    String? id,
    String? animalId,
    String? veterinarianName,
    DateTime? date,
    String? reason,
    String? diagnosis,
    String? notes,
    AppointmentStatus? status,
    double? cost,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Appointment(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isUpcoming {
    return date.isAfter(DateTime.now()) && status == AppointmentStatus.scheduled;
  }

  bool get isPast {
    return date.isBefore(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String get formattedCost {
    if (cost == null || cost == 0) return '';
    return 'R\$ ${cost!.toStringAsFixed(2)}';
  }

  String get displayStatus {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Agendada';
      case AppointmentStatus.completed:
        return 'Realizada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.inProgress:
        return 'Em andamento';
    }
  }

  @override
  List<Object?> get props => [id];
}

enum AppointmentStatus {
  scheduled,
  completed,
  cancelled,
  inProgress,
}