import 'package:equatable/equatable.dart';

/// Enumeration of available export formats
enum ExportFormat {
  json('JSON'),
  csv('CSV'),
  xml('XML'),
  pdf('PDF');

  const ExportFormat(this.displayName);

  final String displayName;
}

/// Enumeration of data types available for export specific to Plantis
enum DataType {
  userProfile('Perfil do usuário'),
  plants('Minhas plantas'),
  customCare('Cuidados personalizados'),
  reminders('Lembretes e notificações'),
  settings('Configurações da conta'),
  plantPhotos('Fotos das plantas'),
  spaces('Espaços criados'),
  plantTasks('Tarefas das plantas'),
  plantComments('Comentários das plantas'),
  all('Todos os dados');

  const DataType(this.displayName);

  final String displayName;
}

/// Represents the progress of an export operation
class ExportProgress extends Equatable {
  final double percentage;
  final String currentTask;
  final String? estimatedTimeRemaining;
  final bool isCompleted;
  final String? errorMessage;

  const ExportProgress({
    required this.percentage,
    required this.currentTask,
    this.estimatedTimeRemaining,
    this.isCompleted = false,
    this.errorMessage,
  });

  /// Creates a progress instance for initialization
  const ExportProgress.initial()
      : percentage = 0.0,
        currentTask = 'Iniciando exportação...',
        estimatedTimeRemaining = null,
        isCompleted = false,
        errorMessage = null;

  /// Creates a progress instance for completion
  const ExportProgress.completed()
      : percentage = 100.0,
        currentTask = 'Exportação concluída',
        estimatedTimeRemaining = null,
        isCompleted = true,
        errorMessage = null;

  /// Creates a progress instance for errors
  const ExportProgress.error(String error)
      : percentage = 0.0,
        currentTask = 'Erro na exportação',
        estimatedTimeRemaining = null,
        isCompleted = false,
        errorMessage = error;

  ExportProgress copyWith({
    double? percentage,
    String? currentTask,
    String? estimatedTimeRemaining,
    bool? isCompleted,
    String? errorMessage,
  }) {
    return ExportProgress(
      percentage: percentage ?? this.percentage,
      currentTask: currentTask ?? this.currentTask,
      estimatedTimeRemaining: estimatedTimeRemaining ?? this.estimatedTimeRemaining,
      isCompleted: isCompleted ?? this.isCompleted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        percentage,
        currentTask,
        estimatedTimeRemaining,
        isCompleted,
        errorMessage,
      ];
}

/// Represents the availability result of data export
class ExportAvailabilityResult extends Equatable {
  final bool isAvailable;
  final String? reason;
  final Map<DataType, bool> availableDataTypes;
  final DateTime? earliestAvailableDate;
  final int? estimatedSizeInBytes;

  const ExportAvailabilityResult({
    required this.isAvailable,
    this.reason,
    required this.availableDataTypes,
    this.earliestAvailableDate,
    this.estimatedSizeInBytes,
  });

  /// Creates an available result
  const ExportAvailabilityResult.available({
    required Map<DataType, bool> availableDataTypes,
    int? estimatedSizeInBytes,
  }) : isAvailable = true,
        reason = null,
        availableDataTypes = availableDataTypes,
        earliestAvailableDate = null,
        estimatedSizeInBytes = estimatedSizeInBytes;

  /// Creates an unavailable result
  const ExportAvailabilityResult.unavailable({
    required String reason,
    DateTime? earliestAvailableDate,
  }) : isAvailable = false,
        reason = reason,
        availableDataTypes = const {},
        earliestAvailableDate = earliestAvailableDate,
        estimatedSizeInBytes = null;

  @override
  List<Object?> get props => [
        isAvailable,
        reason,
        availableDataTypes,
        earliestAvailableDate,
        estimatedSizeInBytes,
      ];
}

/// Represents a data export request according to LGPD requirements
class ExportRequest extends Equatable {
  final String id;
  final String userId;
  final Set<DataType> dataTypes;
  final ExportFormat format;
  final DateTime requestDate;
  final DateTime? completionDate;
  final ExportRequestStatus status;
  final String? downloadUrl;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const ExportRequest({
    required this.id,
    required this.userId,
    required this.dataTypes,
    required this.format,
    required this.requestDate,
    this.completionDate,
    this.status = ExportRequestStatus.pending,
    this.downloadUrl,
    this.errorMessage,
    this.metadata,
  });

  ExportRequest copyWith({
    String? id,
    String? userId,
    Set<DataType>? dataTypes,
    ExportFormat? format,
    DateTime? requestDate,
    DateTime? completionDate,
    ExportRequestStatus? status,
    String? downloadUrl,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  }) {
    return ExportRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dataTypes: dataTypes ?? this.dataTypes,
      format: format ?? this.format,
      requestDate: requestDate ?? this.requestDate,
      completionDate: completionDate ?? this.completionDate,
      status: status ?? this.status,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Checks if the export request is expired (older than 30 days)
  bool get isExpired {
    if (completionDate == null) return false;
    return DateTime.now().difference(completionDate!).inDays > 30;
  }

  /// Gets the estimated expiration date for the export
  DateTime? get expirationDate {
    if (completionDate == null) return null;
    return completionDate!.add(const Duration(days: 30));
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        dataTypes,
        format,
        requestDate,
        completionDate,
        status,
        downloadUrl,
        errorMessage,
        metadata,
      ];
}

/// Status of an export request
enum ExportRequestStatus {
  pending('Pendente'),
  processing('Processando'),
  completed('Concluído'),
  failed('Falhou'),
  expired('Expirado');

  const ExportRequestStatus(this.displayName);

  final String displayName;
}

/// Plantis-specific export data entities
class PlantExportData extends Equatable {
  final String id;
  final String name;
  final String? species;
  final String? spaceId;
  final List<String> imageUrls;
  final DateTime? plantingDate;
  final String? notes;
  final PlantConfigExportData? config;
  final bool isFavorited;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlantExportData({
    required this.id,
    required this.name,
    this.species,
    this.spaceId,
    this.imageUrls = const [],
    this.plantingDate,
    this.notes,
    this.config,
    this.isFavorited = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        species,
        spaceId,
        imageUrls,
        plantingDate,
        notes,
        config,
        isFavorited,
        createdAt,
        updatedAt,
      ];
}

class PlantConfigExportData extends Equatable {
  final int? wateringIntervalDays;
  final int? fertilizingIntervalDays;
  final int? pruningIntervalDays;
  final String? lightRequirement;
  final String? waterAmount;
  final String? soilType;
  final bool? enableWateringCare;
  final DateTime? lastWateringDate;
  final bool? enableFertilizerCare;
  final DateTime? lastFertilizerDate;

  const PlantConfigExportData({
    this.wateringIntervalDays,
    this.fertilizingIntervalDays,
    this.pruningIntervalDays,
    this.lightRequirement,
    this.waterAmount,
    this.soilType,
    this.enableWateringCare,
    this.lastWateringDate,
    this.enableFertilizerCare,
    this.lastFertilizerDate,
  });

  @override
  List<Object?> get props => [
        wateringIntervalDays,
        fertilizingIntervalDays,
        pruningIntervalDays,
        lightRequirement,
        waterAmount,
        soilType,
        enableWateringCare,
        lastWateringDate,
        enableFertilizerCare,
        lastFertilizerDate,
      ];
}

class TaskExportData extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String plantId;
  final String plantName;
  final String type;
  final String status;
  final String priority;
  final DateTime dueDate;
  final DateTime? completedAt;
  final String? completionNotes;
  final bool isRecurring;
  final int? recurringIntervalDays;
  final DateTime? nextDueDate;
  final DateTime? createdAt;

  const TaskExportData({
    required this.id,
    required this.title,
    this.description,
    required this.plantId,
    required this.plantName,
    required this.type,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.completedAt,
    this.completionNotes,
    this.isRecurring = false,
    this.recurringIntervalDays,
    this.nextDueDate,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        plantId,
        plantName,
        type,
        status,
        priority,
        dueDate,
        completedAt,
        completionNotes,
        isRecurring,
        recurringIntervalDays,
        nextDueDate,
        createdAt,
      ];
}

class SpaceExportData extends Equatable {
  final String id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SpaceExportData({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        updatedAt,
      ];
}

class UserSettingsExportData extends Equatable {
  final Map<String, dynamic> notificationSettings;
  final Map<String, dynamic> backupSettings;
  final Map<String, dynamic> appPreferences;
  final DateTime? lastBackupDate;
  final DateTime? lastSyncDate;

  const UserSettingsExportData({
    this.notificationSettings = const {},
    this.backupSettings = const {},
    this.appPreferences = const {},
    this.lastBackupDate,
    this.lastSyncDate,
  });

  @override
  List<Object?> get props => [
        notificationSettings,
        backupSettings,
        appPreferences,
        lastBackupDate,
        lastSyncDate,
      ];
}

class PlantPhotoExportData extends Equatable {
  final String plantId;
  final String plantName;
  final List<String> photoUrls;
  final DateTime? takenAt;
  final String? caption;

  const PlantPhotoExportData({
    required this.plantId,
    required this.plantName,
    this.photoUrls = const [],
    this.takenAt,
    this.caption,
  });

  @override
  List<Object?> get props => [
        plantId,
        plantName,
        photoUrls,
        takenAt,
        caption,
      ];
}

class PlantCommentExportData extends Equatable {
  final String id;
  final String plantId;
  final String plantName;
  final String content;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlantCommentExportData({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.content,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        plantId,
        plantName,
        content,
        createdAt,
        updatedAt,
      ];
}