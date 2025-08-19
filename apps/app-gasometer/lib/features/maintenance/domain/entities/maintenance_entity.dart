import 'package:equatable/equatable.dart';

enum MaintenanceType {
  preventive,
  corrective,
  inspection,
  emergency;
  
  String get displayName {
    switch (this) {
      case MaintenanceType.preventive:
        return 'Preventiva';
      case MaintenanceType.corrective:
        return 'Corretiva';
      case MaintenanceType.inspection:
        return 'Revisão';
      case MaintenanceType.emergency:
        return 'Emergencial';
    }
  }
  
  String get description {
    switch (this) {
      case MaintenanceType.preventive:
        return 'Manutenção programada para prevenir problemas';
      case MaintenanceType.corrective:
        return 'Reparo de problema identificado';
      case MaintenanceType.inspection:
        return 'Revisão geral do veículo';
      case MaintenanceType.emergency:
        return 'Reparo urgente e imprevisto';
    }
  }
}

enum MaintenanceStatus {
  pending,
  inProgress,
  completed,
  cancelled;
  
  String get displayName {
    switch (this) {
      case MaintenanceStatus.pending:
        return 'Pendente';
      case MaintenanceStatus.inProgress:
        return 'Em Andamento';
      case MaintenanceStatus.completed:
        return 'Concluída';
      case MaintenanceStatus.cancelled:
        return 'Cancelada';
    }
  }
}

class MaintenanceEntity extends Equatable {
  final String id;
  final String userId;
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
  final List<String> photos;
  final List<String> invoices;
  final Map<String, String> parts; // partName -> partNumber/info
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const MaintenanceEntity({
    required this.id,
    required this.userId,
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
    this.photos = const [],
    this.invoices = const [],
    this.parts = const {},
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
    id,
    userId,
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
    photos,
    invoices,
    parts,
    notes,
    createdAt,
    updatedAt,
    metadata,
  ];

  MaintenanceEntity copyWith({
    String? id,
    String? userId,
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
    List<String>? photos,
    List<String>? invoices,
    Map<String, String>? parts,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return MaintenanceEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      serviceDate: serviceDate ?? this.serviceDate,
      odometer: odometer ?? this.odometer,
      workshopName: workshopName ?? this.workshopName,
      workshopPhone: workshopPhone ?? this.workshopPhone,
      workshopAddress: workshopAddress ?? this.workshopAddress,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
      nextServiceOdometer: nextServiceOdometer ?? this.nextServiceOdometer,
      photos: photos ?? this.photos,
      invoices: invoices ?? this.invoices,
      parts: parts ?? this.parts,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper getters
  bool get isCompleted => status == MaintenanceStatus.completed;
  bool get isPending => status == MaintenanceStatus.pending;
  bool get isInProgress => status == MaintenanceStatus.inProgress;
  bool get isCancelled => status == MaintenanceStatus.cancelled;
  
  bool get isPreventive => type == MaintenanceType.preventive;
  bool get isCorrective => type == MaintenanceType.corrective;
  bool get isInspection => type == MaintenanceType.inspection;
  bool get isEmergency => type == MaintenanceType.emergency;
  
  bool get hasWorkshopInfo => workshopName != null && workshopName!.isNotEmpty;
  bool get hasNextService => nextServiceDate != null || nextServiceOdometer != null;
  bool get hasPhotos => photos.isNotEmpty;
  bool get hasInvoices => invoices.isNotEmpty;
  bool get hasParts => parts.isNotEmpty;
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  
  // Check if next service is due
  bool isNextServiceDue(double currentOdometer) {
    if (nextServiceOdometer != null && currentOdometer >= nextServiceOdometer!) {
      return true;
    }
    if (nextServiceDate != null && DateTime.now().isAfter(nextServiceDate!)) {
      return true;
    }
    return false;
  }
  
  // Days since last service
  int get daysSinceService => DateTime.now().difference(serviceDate).inDays;
  
  // Formatted getters
  String get formattedCost => 'R\$ ${cost.toStringAsFixed(2)}';
  String get formattedOdometer => '${odometer.toStringAsFixed(0)} km';
  String get formattedNextServiceOdometer => nextServiceOdometer != null 
      ? '${nextServiceOdometer!.toStringAsFixed(0)} km' 
      : 'N/A';
  
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
  
  // Service urgency level
  String get urgencyLevel {
    if (!hasNextService) return 'none';
    
    if (isNextServiceDue(odometer)) {
      return 'overdue';
    }
    
    final now = DateTime.now();
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
}