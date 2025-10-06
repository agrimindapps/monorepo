import 'package:core/core.dart';
import '../medication.dart';

/// Entidade Medication para sincronização
/// Dados médicos CRÍTICOS com prioridade máxima de sync
/// Funcionalidades específicas:
/// - Emergency priority sync para medicações críticas
/// - Single-user medication management (usuário único)
/// - Offline-first com conflict resolution médico
/// - Real-time alerts para horários de medicação
class MedicationSyncEntity extends BaseSyncEntity {
  const MedicationSyncEntity({
    required super.id,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty = false,
    super.isDeleted = false,
    super.version = 1,
    super.userId,
    super.moduleName,
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
    this.isCritical = false,
    this.requiresSupervision = false,
    this.sideEffectsNotes,
    this.emergencyInstructions,
    this.missedDoses = const [],
    this.administrationTimes = const [],
    this.lastAdministeredAt,
    this.nextDoseAt,
  });

  /// Informações básicas da medicação
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

  /// Informações críticas de emergência - PRIORIDADE MÁXIMA para sync
  final bool isCritical;
  final bool requiresSupervision;
  final String? sideEffectsNotes;
  final String? emergencyInstructions;

  /// Doses administradas (single user)
  final List<DateTime> missedDoses;
  final List<DateTime> administrationTimes;
  final DateTime? lastAdministeredAt;
  final DateTime? nextDoseAt;

  /// Getters computados para compatibilidade
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate) && !isDeleted;
  }

  int get totalDurationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  double get progress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;

    final elapsed = now.difference(startDate).inDays;
    final total = totalDurationInDays;
    return total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;
  }

  bool get isExpiringSoon {
    final now = DateTime.now();
    final daysUntilExpiry = endDate.difference(now).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry > 0;
  }

  String get treatmentInterval {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';
    return '$start - $end';
  }

  String get summary {
    return "Medicamento: $name, Dosagem: $dosage, Frequência: $frequency${duration != null ? ', Duração: $duration' : ''}, Período: $treatmentInterval";
  }

  MedicationStatus get status {
    final now = DateTime.now();
    if (isDeleted) return MedicationStatus.discontinued;
    if (now.isBefore(startDate)) return MedicationStatus.scheduled;
    if (now.isAfter(endDate)) return MedicationStatus.completed;
    return MedicationStatus.active;
  }

  /// Getters específicos de pet care
  bool get hasMissedDoses => missedDoses.isNotEmpty;
  bool get isOverdue {
    if (nextDoseAt == null) return false;
    return DateTime.now().isAfter(nextDoseAt!);
  }

  bool get requiresEmergencySync => isCritical || requiresSupervision || isOverdue;

  int get adherencePercentage {
    if (administrationTimes.isEmpty) return 0;
    final expectedDoses = totalDurationInDays; // Simplificado
    final actualDoses = administrationTimes.length;
    final missedCount = missedDoses.length;

    if (expectedDoses == 0) return 100;
    final adherence = ((actualDoses / (actualDoses + missedCount)) * 100);
    return adherence.round().clamp(0, 100);
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    final Map<String, dynamic> map = {
      ...baseFirebaseFields,
      'animal_id': animalId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'notes': notes,
      'prescribed_by': prescribedBy,
      'type': type.toString().split('.').last,
      'is_critical': isCritical,
      'requires_supervision': requiresSupervision,
      'side_effects_notes': sideEffectsNotes,
      'emergency_instructions': emergencyInstructions,
      'missed_doses': missedDoses.map((d) => d.toIso8601String()).toList(),
      'administration_times': administrationTimes.map((d) => d.toIso8601String()).toList(),
      'last_administered_at': lastAdministeredAt?.toIso8601String(),
      'next_dose_at': nextDoseAt?.toIso8601String(),
      'is_active': isActive,
      'status': status.toString().split('.').last,
      'remaining_days': remainingDays,
      'progress': progress,
      'is_expiring_soon': isExpiringSoon,
      'is_overdue': isOverdue,
      'requires_emergency_sync': requiresEmergencySync,
      'adherence_percentage': adherencePercentage,
      'has_missed_doses': hasMissedDoses,
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  static MedicationSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return MedicationSyncEntity(
      id: baseFields['id'] as String,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: (baseFields['isDirty'] as bool?) ?? false,
      isDeleted: (baseFields['isDeleted'] as bool?) ?? false,
      version: (baseFields['version'] as int?) ?? 1,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      animalId: map['animal_id'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      frequency: map['frequency'] as String,
      duration: map['duration'] as String?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      notes: map['notes'] as String?,
      prescribedBy: map['prescribed_by'] as String?,
      type: _parseMedicationType(map['type'] as String?),
      isCritical: map['is_critical'] as bool? ?? false,
      requiresSupervision: map['requires_supervision'] as bool? ?? false,
      sideEffectsNotes: map['side_effects_notes'] as String?,
      emergencyInstructions: map['emergency_instructions'] as String?,

      missedDoses: (map['missed_doses'] as List<dynamic>?)
        ?.map((e) => DateTime.parse(e as String))
        .toList() ?? [],
      administrationTimes: (map['administration_times'] as List<dynamic>?)
        ?.map((e) => DateTime.parse(e as String))
        .toList() ?? [],
      lastAdministeredAt: map['last_administered_at'] != null
        ? DateTime.parse(map['last_administered_at'] as String)
        : null,
      nextDoseAt: map['next_dose_at'] != null
        ? DateTime.parse(map['next_dose_at'] as String)
        : null,
    );
  }

  static MedicationType _parseMedicationType(String? typeString) {
    if (typeString == null) return MedicationType.other;

    try {
      return MedicationType.values.firstWhere(
        (type) => type.toString().split('.').last == typeString,
        orElse: () => MedicationType.other,
      );
    } catch (e) {
      return MedicationType.other;
    }
  }

  @override
  MedicationSyncEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
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
    bool? isCritical,
    bool? requiresSupervision,
    String? sideEffectsNotes,
    String? emergencyInstructions,
    List<DateTime>? missedDoses,
    List<DateTime>? administrationTimes,
    DateTime? lastAdministeredAt,
    DateTime? nextDoseAt,
  }) {
    return MedicationSyncEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
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
      isCritical: isCritical ?? this.isCritical,
      requiresSupervision: requiresSupervision ?? this.requiresSupervision,
      sideEffectsNotes: sideEffectsNotes ?? this.sideEffectsNotes,
      emergencyInstructions: emergencyInstructions ?? this.emergencyInstructions,
      missedDoses: missedDoses ?? this.missedDoses,
      administrationTimes: administrationTimes ?? this.administrationTimes,
      lastAdministeredAt: lastAdministeredAt ?? this.lastAdministeredAt,
      nextDoseAt: nextDoseAt ?? this.nextDoseAt,
    );
  }

  @override
  MedicationSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  MedicationSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  MedicationSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  MedicationSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  MedicationSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  MedicationSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  /// Marca dose como administrada (single user)
  MedicationSyncEntity markDoseAdministered({
    DateTime? administeredAt,
  }) {
    final now = administeredAt ?? DateTime.now();

    return copyWith(
      administrationTimes: [...administrationTimes, now],
      lastAdministeredAt: now,
      nextDoseAt: _calculateNextDose(now),
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Marca dose como perdida
  MedicationSyncEntity markDoseMissed({DateTime? missedAt}) {
    final missedTime = missedAt ?? DateTime.now();

    return copyWith(
      missedDoses: [...missedDoses, missedTime],
      nextDoseAt: _calculateNextDose(missedTime),
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Atualiza instruções de emergência
  MedicationSyncEntity updateEmergencyInfo({
    bool? isCritical,
    bool? requiresSupervision,
    String? sideEffectsNotes,
    String? emergencyInstructions,
  }) {
    return copyWith(
      isCritical: isCritical ?? this.isCritical,
      requiresSupervision: requiresSupervision ?? this.requiresSupervision,
      sideEffectsNotes: sideEffectsNotes ?? this.sideEffectsNotes,
      emergencyInstructions: emergencyInstructions ?? this.emergencyInstructions,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Calcula próxima dose baseada na frequência
  DateTime? _calculateNextDose(DateTime lastDose) {
    if (frequency.toLowerCase().contains('diário') || frequency.toLowerCase().contains('daily')) {
      return lastDose.add(const Duration(days: 1));
    } else if (frequency.toLowerCase().contains('2x') || frequency.toLowerCase().contains('twice')) {
      return lastDose.add(const Duration(hours: 12));
    } else if (frequency.toLowerCase().contains('3x') || frequency.toLowerCase().contains('thrice')) {
      return lastDose.add(const Duration(hours: 8));
    } else if (frequency.toLowerCase().contains('semanal') || frequency.toLowerCase().contains('weekly')) {
      return lastDose.add(const Duration(days: 7));
    }
    return lastDose.add(const Duration(days: 1));
  }

  /// Converte para entidade Medication legada (para compatibilidade)
  Medication toLegacyMedication() {
    return Medication(
      id: id,
      animalId: animalId,
      name: name,
      dosage: dosage,
      frequency: frequency,
      duration: duration,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      prescribedBy: prescribedBy,
      type: type,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isDeleted: isDeleted,
    );
  }

  /// Cria MedicationSyncEntity a partir de entidade Medication legada
  static MedicationSyncEntity fromLegacyMedication(Medication medication, {
    String? userId,
    String? moduleName,
    bool isCritical = false,
    bool requiresSupervision = false,
  }) {
    return MedicationSyncEntity(
      id: medication.id,
      createdAt: medication.createdAt,
      updatedAt: medication.updatedAt,
      userId: userId,
      moduleName: moduleName ?? 'petiveti',
      animalId: medication.animalId,
      name: medication.name,
      dosage: medication.dosage,
      frequency: medication.frequency,
      duration: medication.duration,
      startDate: medication.startDate,
      endDate: medication.endDate,
      notes: medication.notes,
      prescribedBy: medication.prescribedBy,
      type: medication.type,
      isCritical: isCritical,
      requiresSupervision: requiresSupervision,
      isDirty: true, // Marca como sujo para sync inicial
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
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
    isCritical,
    requiresSupervision,
    sideEffectsNotes,
    emergencyInstructions,
    missedDoses,
    administrationTimes,
    lastAdministeredAt,
    nextDoseAt,
  ];
}
