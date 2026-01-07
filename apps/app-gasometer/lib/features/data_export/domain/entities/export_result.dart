import 'export_metadata.dart';

/// Resultado de uma operação de exportação de dados
class ExportResult {
  const ExportResult({
    required this.success,
    this.filePath,
    this.metadata,
    this.errorMessage,
    required this.completedAt,
    required this.processingTime,
  });

  factory ExportResult.success({
    required String filePath,
    required ExportMetadata metadata,
    required Duration processingTime,
  }) => ExportResult(
    success: true,
    filePath: filePath,
    metadata: metadata,
    completedAt: DateTime.now(),
    processingTime: processingTime,
  );

  factory ExportResult.failure({
    required String errorMessage,
    required Duration processingTime,
  }) => ExportResult(
    success: false,
    errorMessage: errorMessage,
    completedAt: DateTime.now(),
    processingTime: processingTime,
  );

  factory ExportResult.fromJson(Map<String, dynamic> json) => ExportResult(
    success: json['success'] as bool,
    filePath: json['file_path'] as String?,
    metadata: json['metadata'] != null
        ? ExportMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
        : null,
    errorMessage: json['error_message'] as String?,
    completedAt: DateTime.parse(json['completed_at'] as String),
    processingTime: Duration(milliseconds: json['processing_time_ms'] as int),
  );
  final bool success;
  final String? filePath;
  final ExportMetadata? metadata;
  final String? errorMessage;
  final DateTime completedAt;
  final Duration processingTime;

  Map<String, dynamic> toJson() => {
    'success': success,
    'file_path': filePath,
    'metadata': metadata?.toJson(),
    'error_message': errorMessage,
    'completed_at': completedAt.toIso8601String(),
    'processing_time_ms': processingTime.inMilliseconds,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportResult &&
          success == other.success &&
          filePath == other.filePath;

  @override
  int get hashCode => Object.hash(success, filePath);
}

// Helper functions for legacy compatibility
// ignore: non_constant_identifier_names
ExportResult ExportRight({
  required String filePath,
  required ExportMetadata metadata,
  required Duration processingTime,
}) => ExportResult.success(
  filePath: filePath,
  metadata: metadata,
  processingTime: processingTime,
);
