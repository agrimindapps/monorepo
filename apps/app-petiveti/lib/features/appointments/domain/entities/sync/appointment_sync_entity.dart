import 'package:core/core.dart';
import '../appointment.dart';

/// Entidade Appointment para sincronização
/// Dados de consultas veterinárias com funcionalidades específicas:
/// - Single-user appointment management (usuário único)
/// - Emergency scheduling para consultas urgentes
/// - Real-time sync para agendamentos/cancelamentos
/// - Offline-first para histórico de consultas
class AppointmentSyncEntity extends BaseSyncEntity {
  const AppointmentSyncEntity({
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
    required this.veterinarianName,
    required this.date,
    required this.reason,
    this.diagnosis,
    this.notes,
    this.status = AppointmentStatus.scheduled,
    this.cost,
    this.isEmergency = false,
    this.priority = AppointmentPriority.normal,
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    this.veterinarianId,
    this.reminderSentAt,
    this.confirmationRequired = false,
    this.confirmedAt,
    this.cancellationReason,
    this.followUpRequired = false,
    this.followUpDate,
    this.documentUrls = const [],
    this.prescriptions = const [],
  });

  /// Informações básicas da consulta
  final String animalId;
  final String veterinarianName;
  final DateTime date;
  final String reason;
  final String? diagnosis;
  final String? notes;
  final AppointmentStatus status;
  final double? cost;

  /// Informações de emergência e prioridade
  final bool isEmergency;
  final AppointmentPriority priority;

  /// Informações da clínica
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicPhone;
  final String? veterinarianId;

  /// Gerenciamento de agendamento
  final DateTime? reminderSentAt;
  final bool confirmationRequired;
  final DateTime? confirmedAt;
  final String? cancellationReason;

  /// Follow-up
  final bool followUpRequired;
  final DateTime? followUpDate;

  /// Documentos e prescrições (single user)
  final List<String> documentUrls; // URLs de documentos/exames
  final List<String> prescriptions; // IDs de prescrições relacionadas

  /// Getters computados para compatibilidade
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

  /// Getters específicos de pet care
  bool get requiresUrgentSync => isEmergency || priority == AppointmentPriority.urgent;

  bool get needsConfirmation => confirmationRequired && confirmedAt == null && isUpcoming;

  bool get needsReminder {
    if (reminderSentAt != null) return false;
    if (!isUpcoming) return false;

    final hoursUntilAppointment = date.difference(DateTime.now()).inHours;
    return hoursUntilAppointment <= 24 && hoursUntilAppointment > 0;
  }

  bool get hasDocuments => documentUrls.isNotEmpty;

  bool get hasPrescriptions => prescriptions.isNotEmpty;

  Duration? get timeUntilAppointment {
    if (!isUpcoming) return null;
    return date.difference(DateTime.now());
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    final Map<String, dynamic> map = {
      ...baseFirebaseFields,
      'animal_id': animalId,
      'veterinarian_name': veterinarianName,
      'date': date.toIso8601String(),
      'reason': reason,
      'diagnosis': diagnosis,
      'notes': notes,
      'status': status.toString().split('.').last,
      'cost': cost,
      'is_emergency': isEmergency,
      'priority': priority.toString().split('.').last,
      'clinic_name': clinicName,
      'clinic_address': clinicAddress,
      'clinic_phone': clinicPhone,
      'veterinarian_id': veterinarianId,
      'reminder_sent_at': reminderSentAt?.toIso8601String(),
      'confirmation_required': confirmationRequired,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
      'follow_up_required': followUpRequired,
      'follow_up_date': followUpDate?.toIso8601String(),
      'document_urls': documentUrls,
      'prescriptions': prescriptions,
      'is_upcoming': isUpcoming,
      'is_past': isPast,
      'is_today': isToday,
      'requires_urgent_sync': requiresUrgentSync,
      'needs_confirmation': needsConfirmation,
      'needs_reminder': needsReminder,
      'has_documents': hasDocuments,
      'has_prescriptions': hasPrescriptions,
      'hours_until_appointment': timeUntilAppointment?.inHours,
    };
    map.removeWhere((key, value) => value == null);
    return map;
  }

  static AppointmentSyncEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);

    return AppointmentSyncEntity(
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
      veterinarianName: map['veterinarian_name'] as String,
      date: DateTime.parse(map['date'] as String),
      reason: map['reason'] as String,
      diagnosis: map['diagnosis'] as String?,
      notes: map['notes'] as String?,
      status: _parseAppointmentStatus(map['status'] as String?),
      cost: (map['cost'] as num?)?.toDouble(),
      isEmergency: map['is_emergency'] as bool? ?? false,
      priority: _parseAppointmentPriority(map['priority'] as String?),
      clinicName: map['clinic_name'] as String?,
      clinicAddress: map['clinic_address'] as String?,
      clinicPhone: map['clinic_phone'] as String?,
      veterinarianId: map['veterinarian_id'] as String?,
      reminderSentAt: map['reminder_sent_at'] != null
        ? DateTime.parse(map['reminder_sent_at'] as String)
        : null,
      confirmationRequired: map['confirmation_required'] as bool? ?? false,
      confirmedAt: map['confirmed_at'] != null
        ? DateTime.parse(map['confirmed_at'] as String)
        : null,
      cancellationReason: map['cancellation_reason'] as String?,
      followUpRequired: map['follow_up_required'] as bool? ?? false,
      followUpDate: map['follow_up_date'] != null
        ? DateTime.parse(map['follow_up_date'] as String)
        : null,
      documentUrls: (map['document_urls'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
      prescriptions: (map['prescriptions'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [],
    );
  }

  static AppointmentStatus _parseAppointmentStatus(String? statusString) {
    if (statusString == null) return AppointmentStatus.scheduled;

    try {
      return AppointmentStatus.values.firstWhere(
        (status) => status.toString().split('.').last == statusString,
        orElse: () => AppointmentStatus.scheduled,
      );
    } catch (e) {
      return AppointmentStatus.scheduled;
    }
  }

  static AppointmentPriority _parseAppointmentPriority(String? priorityString) {
    if (priorityString == null) return AppointmentPriority.normal;

    try {
      return AppointmentPriority.values.firstWhere(
        (priority) => priority.toString().split('.').last == priorityString,
        orElse: () => AppointmentPriority.normal,
      );
    } catch (e) {
      return AppointmentPriority.normal;
    }
  }

  @override
  AppointmentSyncEntity copyWith({
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
    String? veterinarianName,
    DateTime? date,
    String? reason,
    String? diagnosis,
    String? notes,
    AppointmentStatus? status,
    double? cost,
    bool? isEmergency,
    AppointmentPriority? priority,
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    String? veterinarianId,
    DateTime? reminderSentAt,
    bool? confirmationRequired,
    DateTime? confirmedAt,
    String? cancellationReason,
    bool? followUpRequired,
    DateTime? followUpDate,
    List<String>? documentUrls,
    List<String>? prescriptions,
  }) {
    return AppointmentSyncEntity(
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
      veterinarianName: veterinarianName ?? this.veterinarianName,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      isEmergency: isEmergency ?? this.isEmergency,
      priority: priority ?? this.priority,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      confirmationRequired: confirmationRequired ?? this.confirmationRequired,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      followUpRequired: followUpRequired ?? this.followUpRequired,
      followUpDate: followUpDate ?? this.followUpDate,
      documentUrls: documentUrls ?? this.documentUrls,
      prescriptions: prescriptions ?? this.prescriptions,
    );
  }

  @override
  AppointmentSyncEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  AppointmentSyncEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  AppointmentSyncEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  AppointmentSyncEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  AppointmentSyncEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  AppointmentSyncEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }

  /// Confirma consulta (single user)
  AppointmentSyncEntity confirm() {
    return copyWith(
      confirmedAt: DateTime.now(),
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Cancela consulta
  AppointmentSyncEntity cancel({String? reason}) {
    return copyWith(
      status: AppointmentStatus.cancelled,
      cancellationReason: reason,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Marca como concluída
  AppointmentSyncEntity complete({
    String? diagnosis,
    String? notes,
    double? cost,
    bool followUpRequired = false,
    DateTime? followUpDate,
  }) {
    return copyWith(
      status: AppointmentStatus.completed,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
      followUpRequired: followUpRequired,
      followUpDate: followUpDate,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }


  /// Adiciona documento
  AppointmentSyncEntity addDocument(String documentUrl) {
    if (documentUrls.contains(documentUrl)) return this;

    return copyWith(
      documentUrls: [...documentUrls, documentUrl],
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Marca lembrete como enviado
  AppointmentSyncEntity markReminderSent() {
    return copyWith(
      reminderSentAt: DateTime.now(),
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Converte para entidade Appointment legada (para compatibilidade)
  Appointment toLegacyAppointment() {
    return Appointment(
      id: id,
      animalId: animalId,
      veterinarianName: veterinarianName,
      date: date,
      reason: reason,
      diagnosis: diagnosis,
      notes: notes,
      status: status,
      cost: cost,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      isDeleted: isDeleted,
    );
  }

  /// Cria AppointmentSyncEntity a partir de entidade Appointment legada
  static AppointmentSyncEntity fromLegacyAppointment(Appointment appointment, {
    String? userId,
    String? moduleName,
    bool isEmergency = false,
    AppointmentPriority priority = AppointmentPriority.normal,
  }) {
    return AppointmentSyncEntity(
      id: appointment.id,
      createdAt: appointment.createdAt,
      updatedAt: appointment.updatedAt,
      userId: userId,
      moduleName: moduleName ?? 'petiveti',
      animalId: appointment.animalId,
      veterinarianName: appointment.veterinarianName,
      date: appointment.date,
      reason: appointment.reason,
      diagnosis: appointment.diagnosis,
      notes: appointment.notes,
      status: appointment.status,
      cost: appointment.cost,
      isEmergency: isEmergency,
      priority: priority,
      isDirty: true, // Marca como sujo para sync inicial
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    animalId,
    veterinarianName,
    date,
    reason,
    diagnosis,
    notes,
    status,
    cost,
    isEmergency,
    priority,
    clinicName,
    clinicAddress,
    clinicPhone,
    veterinarianId,
    reminderSentAt,
    confirmationRequired,
    confirmedAt,
    cancellationReason,
    followUpRequired,
    followUpDate,
    documentUrls,
    prescriptions,
  ];
}

/// Prioridade da consulta
enum AppointmentPriority {
  low,      // Consulta de rotina
  normal,   // Consulta padrão
  high,     // Consulta importante
  urgent,   // Consulta urgente
  emergency // Emergência médica
}

extension AppointmentPriorityExtension on AppointmentPriority {
  String get displayName {
    switch (this) {
      case AppointmentPriority.low:
        return 'Baixa';
      case AppointmentPriority.normal:
        return 'Normal';
      case AppointmentPriority.high:
        return 'Alta';
      case AppointmentPriority.urgent:
        return 'Urgente';
      case AppointmentPriority.emergency:
        return 'Emergência';
    }
  }

  int get numericValue {
    switch (this) {
      case AppointmentPriority.low:
        return 1;
      case AppointmentPriority.normal:
        return 2;
      case AppointmentPriority.high:
        return 3;
      case AppointmentPriority.urgent:
        return 4;
      case AppointmentPriority.emergency:
        return 5;
    }
  }
}
