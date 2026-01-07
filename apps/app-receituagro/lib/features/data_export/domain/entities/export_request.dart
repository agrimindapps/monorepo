import 'package:core/core.dart' hide Column;

/// Enumeration of available export formats
enum ExportFormat {
  json('JSON'),
  csv('CSV'),
  xml('XML'),
  pdf('PDF');

  const ExportFormat(this.displayName);

  final String displayName;
}

/// Enumeration of data types available for export
enum DataType {
  userProfile('Perfil do usuário'),
  favorites('Favoritos'),
  comments('Comentários'),
  searchHistory('Histórico de busca'),
  diagnostics('Diagnósticos realizados'),
  subscriptionData('Dados de assinatura'),
  appUsage('Dados de uso do app'),
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
    required this.availableDataTypes,
    this.estimatedSizeInBytes,
  }) : isAvailable = true,
        reason = null,
        earliestAvailableDate = null;

  /// Creates an unavailable result
  const ExportAvailabilityResult.unavailable({
    required this.reason,
    this.earliestAvailableDate,
  }) : isAvailable = false,
        availableDataTypes = const {},
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
