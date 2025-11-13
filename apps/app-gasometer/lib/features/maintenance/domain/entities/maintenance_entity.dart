import 'package:core/core.dart';

/// Enum para tipos de manutenção
enum MaintenanceType {
  preventive('Preventiva', 'Manutenção programada para prevenir problemas'),
  corrective('Corretiva', 'Reparo de problema identificado'),
  inspection('Revisão', 'Revisão geral do veículo'),
  emergency('Emergencial', 'Reparo urgente e imprevisto');

  const MaintenanceType(this.displayName, this.description);
  final String displayName;
  final String description;

  /// Ícones associados aos tipos
  String get iconName {
    switch (this) {
      case MaintenanceType.preventive:
        return 'build_circle';
      case MaintenanceType.corrective:
        return 'build';
      case MaintenanceType.inspection:
        return 'fact_check';
      case MaintenanceType.emergency:
        return 'warning';
    }
  }

  /// Cores associadas aos tipos (hex)
  int get colorValue {
    switch (this) {
      case MaintenanceType.preventive:
        return 0xFF4CAF50; // Verde
      case MaintenanceType.corrective:
        return 0xFFFF9800; // Laranja
      case MaintenanceType.inspection:
        return 0xFF2196F3; // Azul
      case MaintenanceType.emergency:
        return 0xFFF44336; // Vermelho
    }
  }

  /// Se é uma manutenção recorrente/periódica
  bool get isRecurring {
    switch (this) {
      case MaintenanceType.preventive:
      case MaintenanceType.inspection:
        return true;
      case MaintenanceType.corrective:
      case MaintenanceType.emergency:
        return false;
    }
  }
}

/// Enum para status da manutenção
enum MaintenanceStatus {
  pending('Pendente', 'Manutenção agendada'),
  inProgress('Em Andamento', 'Manutenção sendo executada'),
  completed('Concluída', 'Manutenção finalizada com sucesso'),
  cancelled('Cancelada', 'Manutenção cancelada');

  const MaintenanceStatus(this.displayName, this.description);
  final String displayName;
  final String description;

  int get colorValue {
    switch (this) {
      case MaintenanceStatus.pending:
        return 0xFFFF9800; // Laranja
      case MaintenanceStatus.inProgress:
        return 0xFF2196F3; // Azul
      case MaintenanceStatus.completed:
        return 0xFF4CAF50; // Verde
      case MaintenanceStatus.cancelled:
        return 0xFF9E9E9E; // Cinza
    }
  }
}

/// Entidade principal para manutenções
class MaintenanceEntity extends BaseSyncEntity {

  const MaintenanceEntity({
    required super.id,
    required this.vehicleId,
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.cost,
    required this.serviceDate,
    required this.odometer,
    this.workshopName,
    this.workshopPhone,
    this.workshopAddress,
    this.nextServiceDate,
    this.nextServiceOdometer,
    this.photosPaths = const [],
    this.invoicesPaths = const [],
    this.parts = const {},
    this.notes,
    super.createdAt,
    super.updatedAt,
    super.lastSyncAt,
    super.isDirty,
    super.isDeleted,
    super.version,
    super.userId,
    super.moduleName,
    this.metadata = const {},
  });
  final String vehicleId;
  final MaintenanceType type;
  final MaintenanceStatus status;
  final String title;
  final String description;
  final double cost;
  final DateTime serviceDate;
  final double odometer;
  final String? workshopName;
  final String? workshopPhone;
  final String? workshopAddress;
  final DateTime? nextServiceDate;
  final double? nextServiceOdometer;
  final List<String> photosPaths;
  final List<String> invoicesPaths;
  final Map<String, String> parts; // nome da peça -> info/número da peça
  final String? notes;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [
    ...super.props,
    vehicleId,
    type,
    status,
    title,
    description,
    cost,
    serviceDate,
    odometer,
    workshopName,
    workshopPhone,
    workshopAddress,
    nextServiceDate,
    nextServiceOdometer,
    photosPaths,
    invoicesPaths,
    parts,
    notes,
    metadata,
  ];

  @override
  MaintenanceEntity copyWith({
    String? id,
    String? vehicleId,
    MaintenanceType? type,
    MaintenanceStatus? status,
    String? title,
    String? description,
    double? cost,
    DateTime? serviceDate,
    double? odometer,
    String? workshopName,
    String? workshopPhone,
    String? workshopAddress,
    DateTime? nextServiceDate,
    double? nextServiceOdometer,
    List<String>? photosPaths,
    List<String>? invoicesPaths,
    Map<String, String>? parts,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    bool? isDirty,
    bool? isDeleted,
    int? version,
    String? userId,
    String? moduleName,
    Map<String, dynamic>? metadata,
    bool clearWorkshop = false,
    bool clearNextService = false,
  }) {
    return MaintenanceEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      serviceDate: serviceDate ?? this.serviceDate,
      odometer: odometer ?? this.odometer,
      workshopName: clearWorkshop ? null : (workshopName ?? this.workshopName),
      workshopPhone: clearWorkshop ? null : (workshopPhone ?? this.workshopPhone),
      workshopAddress: clearWorkshop ? null : (workshopAddress ?? this.workshopAddress),
      nextServiceDate: clearNextService ? null : (nextServiceDate ?? this.nextServiceDate),
      nextServiceOdometer: clearNextService ? null : (nextServiceOdometer ?? this.nextServiceOdometer),
      photosPaths: photosPaths ?? this.photosPaths,
      invoicesPaths: invoicesPaths ?? this.invoicesPaths,
      parts: parts ?? this.parts,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isDirty: isDirty ?? this.isDirty,
      isDeleted: isDeleted ?? this.isDeleted,
      version: version ?? this.version,
      userId: userId ?? this.userId,
      moduleName: moduleName ?? this.moduleName,
      metadata: metadata ?? this.metadata,
    );
  }
  bool get isCompleted => status == MaintenanceStatus.completed;
  bool get isPending => status == MaintenanceStatus.pending;
  bool get isInProgress => status == MaintenanceStatus.inProgress;
  bool get isCancelled => status == MaintenanceStatus.cancelled;
  bool get isPreventive => type == MaintenanceType.preventive;
  bool get isCorrective => type == MaintenanceType.corrective;
  bool get isInspection => type == MaintenanceType.inspection;
  bool get isEmergency => type == MaintenanceType.emergency;
  bool get hasWorkshopInfo => workshopName != null && workshopName!.trim().isNotEmpty;
  bool get hasNextService => nextServiceDate != null || nextServiceOdometer != null;
  bool get hasPhotos => photosPaths.isNotEmpty;
  bool get hasInvoices => invoicesPaths.isNotEmpty;
  bool get hasParts => parts.isNotEmpty;
  bool get hasNotes => notes != null && notes!.trim().isNotEmpty;
  
  /// Verifica se a próxima manutenção está vencida
  bool isNextServiceDue(double currentOdometer) {
    if (nextServiceOdometer != null && currentOdometer >= nextServiceOdometer!) {
      return true;
    }
    if (nextServiceDate != null && DateTime.now().isAfter(nextServiceDate!)) {
      return true;
    }
    return false;
  }
  
  /// Dias desde a última manutenção
  int get daysSinceService => DateTime.now().difference(serviceDate).inDays;
  
  /// Quilometragem desde a última manutenção
  double kilometersFromLastService(double currentOdometer) {
    return currentOdometer - odometer;
  }
  
  /// Nível de urgência da próxima manutenção
  String get urgencyLevel {
    if (!hasNextService) return 'none';
    
    final now = DateTime.now();
    if (nextServiceDate != null && now.isAfter(nextServiceDate!)) {
      return 'overdue';
    }
    if (nextServiceDate != null) {
      final daysUntilService = nextServiceDate!.difference(now).inDays;
      if (daysUntilService <= 7) {
        return 'urgent';
      } else if (daysUntilService <= 30) {
        return 'soon';
      }
    }
    
    return 'normal';
  }
  
  String get urgencyDisplayName {
    switch (urgencyLevel) {
      case 'overdue':
        return 'Vencida';
      case 'urgent':
        return 'Urgente';
      case 'soon':
        return 'Em Breve';
      case 'normal':
        return 'Normal';
      default:
        return 'N/A';
    }
  }
  
  String get formattedCost => 'R\$ ${cost.toStringAsFixed(2).replaceAll('.', ',')}';
  String get formattedOdometer => '${odometer.toStringAsFixed(0)} km';
  String get formattedNextServiceOdometer => 
      nextServiceOdometer != null ? '${nextServiceOdometer!.toStringAsFixed(0)} km' : 'N/A';
  
  String get formattedServiceDate {
    final now = DateTime.now();
    final difference = now.difference(serviceDate);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'semana' : 'semanas'} atrás';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    }
  }
  
  String get formattedNextServiceDate {
    if (nextServiceDate == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = nextServiceDate!.difference(now);
    
    if (difference.inDays < 0) {
      return 'Vencida há ${(-difference.inDays)} dias';
    } else if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Amanhã';
    } else if (difference.inDays < 7) {
      return 'Em ${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Em $weeks ${weeks == 1 ? 'semana' : 'semanas'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Em $months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Em $years ${years == 1 ? 'ano' : 'anos'}';
    }
  }
  
  /// Verifica se a manutenção é de alto custo (acima de R$ 1000)
  bool get isHighCost => cost >= 1000.0;
  
  /// Retorna uma descrição resumida para listas
  String get summaryDescription {
    String summary = type.displayName;
    if (hasWorkshopInfo) {
      summary += ' • $workshopName';
    }
    summary += ' • $formattedCost';
    return summary;
  }
  
  /// Calcula o progresso até a próxima manutenção (0.0 a 1.0)
  double nextServiceProgress(double currentOdometer) {
    if (nextServiceOdometer == null) return 0.0;
    
    final totalDistance = nextServiceOdometer! - odometer;
    final currentDistance = currentOdometer - odometer;
    
    if (totalDistance <= 0) return 1.0;
    
    final progress = currentDistance / totalDistance;
    return progress.clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'MaintenanceEntity(id: $id, type: ${type.displayName}, status: ${status.displayName}, cost: $formattedCost)';
  }

  @override
  Map<String, dynamic> toFirebaseMap() {
    final map = <String, dynamic>{
      ...baseFirebaseFields,
      'vehicle_id': vehicleId,
      'type': type.name,
      'status': status.name,
      'title': title,
      'service_date': serviceDate.toIso8601String(),
    };

    // Adicionar campos obrigatórios
    map['description'] = description;
    map['cost'] = cost;
    map['odometer'] = odometer;
    if (workshopName != null) map['workshop_name'] = workshopName;
    if (workshopPhone != null) map['workshop_phone'] = workshopPhone;
    if (workshopAddress != null) map['workshop_address'] = workshopAddress;
    if (nextServiceDate != null) map['next_service_date'] = nextServiceDate!.toIso8601String();
    if (nextServiceOdometer != null) map['next_service_odometer'] = nextServiceOdometer;
    map['photos_paths'] = photosPaths;
    map['invoices_paths'] = invoicesPaths;
    map['parts'] = parts;
    map['metadata'] = metadata;

    return map;
  }

  static MaintenanceEntity fromFirebaseMap(Map<String, dynamic> map) {
    final baseFields = BaseSyncEntity.parseBaseFirebaseFields(map);
    return MaintenanceEntity(
      id: baseFields['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == map['type'] as String,
        orElse: () => MaintenanceType.preventive,
      ),
      status: MaintenanceStatus.values.firstWhere(
        (e) => e.name == map['status'] as String,
        orElse: () => MaintenanceStatus.pending,
      ),
      title: map['title'] as String,
      description: map['description'] as String,
      cost: (map['cost'] as num).toDouble(),
      serviceDate: DateTime.parse(map['service_date'] as String),
      odometer: (map['odometer'] as num).toDouble(),
      workshopName: map['workshop_name'] as String?,
      workshopPhone: map['workshop_phone'] as String?,
      workshopAddress: map['workshop_address'] as String?,
      nextServiceDate: map['next_service_date'] != null 
          ? DateTime.parse(map['next_service_date'] as String) 
          : null,
      nextServiceOdometer: map['next_service_odometer'] as double?,
      photosPaths: List<String>.from(map['photos_paths'] as List? ?? []),
      invoicesPaths: List<String>.from(map['invoices_paths'] as List? ?? []),
      parts: Map<String, String>.from(map['parts'] as Map? ?? {}),
      notes: map['notes'] as String?,
      createdAt: baseFields['createdAt'] as DateTime?,
      updatedAt: baseFields['updatedAt'] as DateTime?,
      lastSyncAt: baseFields['lastSyncAt'] as DateTime?,
      isDirty: baseFields['isDirty'] as bool,
      isDeleted: baseFields['isDeleted'] as bool,
      version: baseFields['version'] as int,
      userId: baseFields['userId'] as String?,
      moduleName: baseFields['moduleName'] as String?,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  @override
  MaintenanceEntity markAsDirty() {
    return copyWith(
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  MaintenanceEntity markAsSynced({DateTime? syncTime}) {
    return copyWith(
      isDirty: false,
      lastSyncAt: syncTime ?? DateTime.now(),
    );
  }

  @override
  MaintenanceEntity markAsDeleted() {
    return copyWith(
      isDeleted: true,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  MaintenanceEntity incrementVersion() {
    return copyWith(
      version: version + 1,
      updatedAt: DateTime.now(),
    );
  }

  @override
  MaintenanceEntity withUserId(String userId) {
    return copyWith(userId: userId);
  }

  @override
  MaintenanceEntity withModule(String moduleName) {
    return copyWith(moduleName: moduleName);
  }
}
