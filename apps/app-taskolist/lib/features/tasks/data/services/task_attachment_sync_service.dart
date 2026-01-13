import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../../domain/task_attachment_entity.dart';
import '../task_attachment_local_datasource.dart';
import 'task_attachment_storage_service.dart';

/// Model for pending attachment upload
class PendingAttachmentUpload {
  final String id;
  final String attachmentId;
  final String taskId;
  final String userId;
  final String localPath;
  final String fileName;
  final String mimeType;
  final int createdAtMs;
  int retryCount;
  String? lastError;
  int? lastAttemptMs;

  PendingAttachmentUpload({
    required this.id,
    required this.attachmentId,
    required this.taskId,
    required this.userId,
    required this.localPath,
    required this.fileName,
    required this.mimeType,
    required this.createdAtMs,
    this.retryCount = 0,
    this.lastError,
    this.lastAttemptMs,
  });

  bool get hasMaxedRetries => retryCount >= 3;

  bool get shouldWaitBeforeRetry {
    if (lastAttemptMs == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceLastAttempt = now - lastAttemptMs!;
    
    // Exponential backoff: 1min, 5min, 15min
    final waitTime = retryCount == 1 
        ? 60 * 1000 // 1 minute
        : retryCount == 2 
            ? 5 * 60 * 1000 // 5 minutes
            : 15 * 60 * 1000; // 15 minutes
    
    return timeSinceLastAttempt < waitTime;
  }
}

/// Sync progress model
class AttachmentSyncProgress {
  final int current;
  final int total;
  final String? currentItemId;
  final bool isCompleted;
  final String? errorMessage;

  const AttachmentSyncProgress({
    required this.current,
    required this.total,
    this.currentItemId,
    this.isCompleted = false,
    this.errorMessage,
  });

  double get progress => total > 0 ? current / total : 0.0;
}

/// Attachment sync service - handles offline queue and background uploads
/// Pattern based on app-gasometer's ImageSyncService
class TaskAttachmentSyncService {
  final TaskAttachmentStorageService _storageService;
  final TaskAttachmentLocalDataSource _localDataSource;
  final ConnectivityService _connectivityService;

  // In-memory queue (can migrate to Drift table for persistence)
  final Map<String, PendingAttachmentUpload> _pendingUploads = {};

  // Progress stream
  final _progressController = StreamController<AttachmentSyncProgress>.broadcast();
  Stream<AttachmentSyncProgress> get progressStream => _progressController.stream;

  bool _isSyncing = false;

  TaskAttachmentSyncService({
    required TaskAttachmentStorageService storageService,
    required TaskAttachmentLocalDataSource localDataSource,
    required ConnectivityService connectivityService,
  })  : _storageService = storageService,
        _localDataSource = localDataSource,
        _connectivityService = connectivityService;

  /// Add attachment to pending upload queue
  void addPendingUpload({
    required String attachmentId,
    required String taskId,
    required String userId,
    required String localPath,
    required String fileName,
    required String mimeType,
  }) {
    final upload = PendingAttachmentUpload(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      attachmentId: attachmentId,
      taskId: taskId,
      userId: userId,
      localPath: localPath,
      fileName: fileName,
      mimeType: mimeType,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    _pendingUploads[upload.id] = upload;
    
    // Auto-sync if online
    if (_connectivityService.isOnline) {
      syncPendingUploads();
    }
  }

  /// Get pending upload count
  int get pendingCount => _pendingUploads.length;

  /// Check if has pending uploads
  bool get hasPendingUploads => _pendingUploads.isNotEmpty;

  /// Sync all pending uploads
  Future<void> syncPendingUploads() async {
    if (_isSyncing) return;
    if (!_connectivityService.isOnline) return;
    if (_pendingUploads.isEmpty) return;

    _isSyncing = true;

    try {
      final uploads = _pendingUploads.values.toList();
      final total = uploads.length;
      int current = 0;

      for (final upload in uploads) {
        // Skip if should wait before retry
        if (upload.shouldWaitBeforeRetry) {
          continue;
        }

        // Skip if maxed retries
        if (upload.hasMaxedRetries) {
          _pendingUploads.remove(upload.id);
          continue;
        }

        // Emit progress
        _progressController.add(AttachmentSyncProgress(
          current: current,
          total: total,
          currentItemId: upload.attachmentId,
        ));

        // Attempt upload
        final result = await _uploadPendingAttachment(upload);

        result.fold(
          (failure) {
            // Update retry info
            upload.retryCount++;
            upload.lastError = failure.message;
            upload.lastAttemptMs = DateTime.now().millisecondsSinceEpoch;

            // Remove if maxed retries
            if (upload.hasMaxedRetries) {
              _pendingUploads.remove(upload.id);
            }
          },
          (_) {
            // Success - remove from queue
            _pendingUploads.remove(upload.id);
            current++;
          },
        );
      }

      // Emit completion
      _progressController.add(AttachmentSyncProgress(
        current: current,
        total: total,
        isCompleted: true,
      ));
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload a single pending attachment
  Future<Either<Failure, void>> _uploadPendingAttachment(
    PendingAttachmentUpload upload,
  ) async {
    try {
      // Check if file still exists
      final file = File(upload.localPath);
      if (!await file.exists()) {
        return Left(Failure('Local file not found'));
      }

      // Upload to Firebase Storage
      final uploadResult = await _storageService.uploadAttachment(
        file: file,
        userId: upload.userId,
        taskId: upload.taskId,
        attachmentId: upload.attachmentId,
        fileName: upload.fileName,
        mimeType: upload.mimeType,
      );

      return uploadResult.fold(
        (failure) => Left(failure),
        (downloadUrl) async {
          // Update database with download URL
          final updateResult = await _localDataSource.markAsUploaded(
            upload.attachmentId,
            downloadUrl,
          );

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
          );
        },
      );
    } catch (e) {
      return Left(Failure('Upload error: $e'));
    }
  }

  /// Clear all pending uploads (use with caution)
  void clearPendingUploads() {
    _pendingUploads.clear();
  }

  /// Dispose resources
  void dispose() {
    _progressController.close();
  }
}
