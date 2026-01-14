import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide connectivityServiceProvider;
import '../../../../core/providers/core_providers.dart';
import '../../data/services/task_attachment_service.dart';
import '../../data/services/task_attachment_storage_service.dart';
import '../../data/services/task_attachment_sync_service.dart';
import '../../data/task_attachment_local_datasource.dart';
import '../../domain/task_attachment_entity.dart';

part 'task_attachment_notifier.g.dart';

/// Provider for attachment service
@riverpod
TaskAttachmentService taskAttachmentService(Ref ref) {
  return TaskAttachmentService();
}

/// Provider for storage service
@riverpod
TaskAttachmentStorageService taskAttachmentStorageService(Ref ref) {
  return TaskAttachmentStorageService();
}

/// Provider for sync service
@riverpod
TaskAttachmentSyncService taskAttachmentSyncService(Ref ref) {
  final storageService = ref.watch(taskAttachmentStorageServiceProvider);
  final localDataSource = ref.watch(taskAttachmentLocalDataSourceProvider);
  final connectivityService = ref.watch<ConnectivityService>(
    connectivityServiceProvider,
  );

  return TaskAttachmentSyncService(
    storageService: storageService,
    localDataSource: localDataSource,
    connectivityService: connectivityService,
  );
}

/// Provider for local datasource
@riverpod
TaskAttachmentLocalDataSource taskAttachmentLocalDataSource(Ref ref) {
  final database = ref.watch(taskolistDatabaseProvider);
  return TaskAttachmentLocalDataSource(database.taskAttachmentDao);
}

/// Notifier for managing task attachments
@riverpod
class TaskAttachmentNotifier extends _$TaskAttachmentNotifier {
  @override
  Future<List<TaskAttachmentEntity>> build(String taskId) async {
    final datasource = ref.read(taskAttachmentLocalDataSourceProvider);
    final result = await datasource.getAttachmentsByTaskId(taskId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (attachments) => attachments,
    );
  }

  /// Add attachment from camera
  Future<void> addFromCamera(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(taskAttachmentServiceProvider);
      final result = await service.pickImageFromCamera(
        taskId: taskId,
        userId: userId,
      );

      return result.fold((failure) => throw Exception(failure.message), (
        attachment,
      ) async {
        final datasource = ref.read(taskAttachmentLocalDataSourceProvider);
        await datasource.saveAttachment(attachment);
        await _uploadOrQueue(attachment, userId);

        final attachmentsResult = await datasource.getAttachmentsByTaskId(
          taskId,
        );
        return attachmentsResult.fold(
          (failure) => throw Exception(failure.message),
          (attachments) => attachments,
        );
      });
    });
  }

  /// Add attachment from gallery
  Future<void> addFromGallery(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(taskAttachmentServiceProvider);
      final result = await service.pickImageFromGallery(
        taskId: taskId,
        userId: userId,
      );

      return result.fold((failure) => throw Exception(failure.message), (
        attachment,
      ) async {
        final datasource = ref.read(taskAttachmentLocalDataSourceProvider);
        await datasource.saveAttachment(attachment);
        await _uploadOrQueue(attachment, userId);

        final attachmentsResult = await datasource.getAttachmentsByTaskId(
          taskId,
        );
        return attachmentsResult.fold(
          (failure) => throw Exception(failure.message),
          (attachments) => attachments,
        );
      });
    });
  }

  /// Add attachments from file picker
  Future<void> addFromFiles(String userId, {bool allowMultiple = false}) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final service = ref.read(taskAttachmentServiceProvider);
      final result = await service.pickFiles(
        taskId: taskId,
        userId: userId,
        allowMultiple: allowMultiple,
      );

      return result.fold((failure) => throw Exception(failure.message), (
        attachments,
      ) async {
        final datasource = ref.read(taskAttachmentLocalDataSourceProvider);
        for (final attachment in attachments) {
          await datasource.saveAttachment(attachment);
          await _uploadOrQueue(attachment, userId);
        }

        final attachmentsResult = await datasource.getAttachmentsByTaskId(
          taskId,
        );
        return attachmentsResult.fold(
          (failure) => throw Exception(failure.message),
          (attachments) => attachments,
        );
      });
    });
  }

  /// Remove attachment
  Future<void> removeAttachment(String attachmentId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final current = state.value ?? [];
      final attachment = current.firstWhere((a) => a.id == attachmentId);

      if (attachment.filePath != null) {
        final service = ref.read(taskAttachmentServiceProvider);
        await service.deleteLocalFile(attachment.filePath!);
      }

      if (attachment.fileUrl != null) {
        final storageService = ref.read(taskAttachmentStorageServiceProvider);
        await storageService.deleteAttachment(attachment.fileUrl!);
      }

      final datasource = ref.read(taskAttachmentLocalDataSourceProvider);
      await datasource.deleteAttachment(attachmentId);

      final attachmentsResult = await datasource.getAttachmentsByTaskId(taskId);
      return attachmentsResult.fold(
        (failure) => throw Exception(failure.message),
        (attachments) => attachments,
      );
    });
  }

  /// Upload or queue attachment based on connectivity
  Future<void> _uploadOrQueue(
    TaskAttachmentEntity attachment,
    String userId,
  ) async {
    final connectivityService = ref.read(connectivityServiceProvider);

    if (connectivityService.isOnlineSync) {
      final storageService = ref.read(taskAttachmentStorageServiceProvider);
      final datasource = ref.read(taskAttachmentLocalDataSourceProvider);

      if (attachment.filePath != null) {
        final uploadResult = await storageService.uploadAttachment(
          file: File(attachment.filePath!),
          userId: userId,
          taskId: taskId,
          attachmentId: attachment.id,
          fileName: attachment.fileName,
          mimeType: attachment.mimeType,
        );

        uploadResult.fold(
          (failure) => _addToQueue(attachment, userId),
          (downloadUrl) async =>
              await datasource.markAsUploaded(attachment.id, downloadUrl),
        );
      }
    } else {
      _addToQueue(attachment, userId);
    }
  }

  /// Add attachment to sync queue
  void _addToQueue(TaskAttachmentEntity attachment, String userId) {
    if (attachment.filePath == null) return;

    final syncService = ref.read(taskAttachmentSyncServiceProvider);
    syncService.addPendingUpload(
      attachmentId: attachment.id,
      taskId: taskId,
      userId: userId,
      localPath: attachment.filePath!,
      fileName: attachment.fileName,
      mimeType: attachment.mimeType,
    );
  }
}
