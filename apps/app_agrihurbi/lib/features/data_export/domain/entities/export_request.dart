enum ExportFormat { json, csv }

enum DataType {
  userProfile,
  favorites,
  comments,
  preferences
}

class ExportRequest {
  final ExportFormat format;
  final Set<DataType> dataTypes;
  final bool sanitizeData;
  final String? fileName;

  const ExportRequest({
    required this.format,
    required this.dataTypes,
    this.sanitizeData = true,
    this.fileName,
  });

  String get fileExtension => format == ExportFormat.json ? 'json' : 'csv';

  String get defaultFileName {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return fileName ?? 'lgpd_export_$timestamp.$fileExtension';
  }

  ExportRequest copyWith({
    ExportFormat? format,
    Set<DataType>? dataTypes,
    bool? sanitizeData,
    String? fileName,
  }) {
    return ExportRequest(
      format: format ?? this.format,
      dataTypes: dataTypes ?? this.dataTypes,
      sanitizeData: sanitizeData ?? this.sanitizeData,
      fileName: fileName ?? this.fileName,
    );
  }
}

class ExportProgress {
  final int current;
  final int total;
  final String currentTask;
  final bool isCompleted;
  final String? error;

  const ExportProgress({
    required this.current,
    required this.total,
    required this.currentTask,
    this.isCompleted = false,
    this.error,
  });

  double get percentage => total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;

  bool get hasError => error != null;

  ExportProgress copyWith({
    int? current,
    int? total,
    String? currentTask,
    bool? isCompleted,
    String? error,
  }) {
    return ExportProgress(
      current: current ?? this.current,
      total: total ?? this.total,
      currentTask: currentTask ?? this.currentTask,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }
}