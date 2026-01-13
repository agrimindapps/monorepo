import 'package:core/core.dart';

enum AttachmentType {
  image,
  pdf,
  document,
  other,
}

/// Task Attachment entity for file management
class TaskAttachmentEntity extends Equatable {
  final String id;
  final String taskId;
  final String fileName;
  final String? filePath; // Local path (for offline)
  final String? fileUrl; // Remote URL (Firebase Storage)
  final int fileSize; // in bytes
  final AttachmentType type;
  final String mimeType;
  final DateTime uploadedAt;
  final String uploadedBy;
  final bool isUploaded; // Sync status

  const TaskAttachmentEntity({
    required this.id,
    required this.taskId,
    required this.fileName,
    this.filePath,
    this.fileUrl,
    required this.fileSize,
    required this.type,
    required this.mimeType,
    required this.uploadedAt,
    required this.uploadedBy,
    this.isUploaded = false,
  });

  bool get isPending => !isUploaded && filePath != null;
  bool get isSynced => isUploaded && fileUrl != null;
  
  // 25MB limit (same as MS To Do)
  static const int maxFileSizeBytes = 25 * 1024 * 1024;
  
  bool get exceedsMaxSize => fileSize > maxFileSizeBytes;

  String get humanReadableSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  AttachmentType static getTypeFromMime(String mimeType) {
    if (mimeType.startsWith('image/')) return AttachmentType.image;
    if (mimeType == 'application/pdf') return AttachmentType.pdf;
    if (mimeType.startsWith('application/') || mimeType.startsWith('text/')) {
      return AttachmentType.document;
    }
    return AttachmentType.other;
  }

  TaskAttachmentEntity copyWith({
    String? id,
    String? taskId,
    String? fileName,
    String? filePath,
    String? fileUrl,
    int? fileSize,
    AttachmentType? type,
    String? mimeType,
    DateTime? uploadedAt,
    String? uploadedBy,
    bool? isUploaded,
  }) {
    return TaskAttachmentEntity(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      type: type ?? this.type,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'file_name': fileName,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_size': fileSize,
      'type': type.name,
      'mime_type': mimeType,
      'uploaded_at': uploadedAt.toIso8601String(),
      'uploaded_by': uploadedBy,
      'is_uploaded': isUploaded,
    };
  }

  factory TaskAttachmentEntity.fromMap(Map<String, dynamic> map) {
    return TaskAttachmentEntity(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String?,
      fileUrl: map['file_url'] as String?,
      fileSize: map['file_size'] as int,
      type: AttachmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AttachmentType.other,
      ),
      mimeType: map['mime_type'] as String,
      uploadedAt: DateTime.parse(map['uploaded_at'] as String),
      uploadedBy: map['uploaded_by'] as String,
      isUploaded: map['is_uploaded'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        fileName,
        filePath,
        fileUrl,
        fileSize,
        type,
        mimeType,
        uploadedAt,
        uploadedBy,
        isUploaded,
      ];
}
