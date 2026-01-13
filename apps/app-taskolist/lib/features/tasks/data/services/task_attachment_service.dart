import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:core/core.dart';

import '../../domain/task_attachment_entity.dart';

/// Service for handling file attachments
class TaskAttachmentService {
  final ImagePicker _imagePicker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Pick image from camera
  Future<Either<Failure, TaskAttachmentEntity>> pickImageFromCamera({
    required String taskId,
    required String userId,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        return Left(Failure('Nenhuma imagem capturada'));
      }

      return _createAttachmentFromFile(
        file: File(image.path),
        taskId: taskId,
        userId: userId,
      );
    } catch (e) {
      return Left(Failure('Erro ao capturar imagem: $e'));
    }
  }

  /// Pick image from gallery
  Future<Either<Failure, TaskAttachmentEntity>> pickImageFromGallery({
    required String taskId,
    required String userId,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        return Left(Failure('Nenhuma imagem selecionada'));
      }

      return _createAttachmentFromFile(
        file: File(image.path),
        taskId: taskId,
        userId: userId,
      );
    } catch (e) {
      return Left(Failure('Erro ao selecionar imagem: $e'));
    }
  }

  /// Pick any file (PDF, documents, etc.)
  Future<Either<Failure, List<TaskAttachmentEntity>>> pickFiles({
    required String taskId,
    required String userId,
    bool allowMultiple = false,
    List<String>? allowedExtensions,
  }) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result == null || result.files.isEmpty) {
        return Left(Failure('Nenhum arquivo selecionado'));
      }

      final List<TaskAttachmentEntity> attachments = [];

      for (final platformFile in result.files) {
        if (platformFile.path == null) continue;

        final fileResult = await _createAttachmentFromFile(
          file: File(platformFile.path!),
          taskId: taskId,
          userId: userId,
        );

        fileResult.fold(
          (failure) => null, // Skip failed files
          (attachment) => attachments.add(attachment),
        );
      }

      if (attachments.isEmpty) {
        return Left(Failure('Nenhum arquivo válido selecionado'));
      }

      return Right(attachments);
    } catch (e) {
      return Left(Failure('Erro ao selecionar arquivos: $e'));
    }
  }

  /// Create attachment entity from file
  Future<Either<Failure, TaskAttachmentEntity>> _createAttachmentFromFile({
    required File file,
    required String taskId,
    required String userId,
  }) async {
    try {
      // Validate file exists
      if (!await file.exists()) {
        return Left(Failure('Arquivo não encontrado'));
      }

      // Get file info
      final fileStat = await file.stat();
      final fileSize = fileStat.size;
      final fileName = file.path.split('/').last;

      // Check file size (25MB limit)
      if (fileSize > TaskAttachmentEntity.maxFileSizeBytes) {
        return Left(Failure(
          'Arquivo muito grande. Máximo: ${(TaskAttachmentEntity.maxFileSizeBytes / (1024 * 1024)).toStringAsFixed(0)}MB',
        ));
      }

      // Determine MIME type
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final attachmentType = TaskAttachmentEntity.getTypeFromMime(mimeType);

      // Copy file to app directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory('${appDir.path}/attachments/$taskId');
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }

      final newFileName = '${_uuid.v4()}_$fileName';
      final localFile = File('${attachmentsDir.path}/$newFileName');
      await file.copy(localFile.path);

      final attachment = TaskAttachmentEntity(
        id: _uuid.v4(),
        taskId: taskId,
        fileName: fileName,
        filePath: localFile.path,
        fileSize: fileSize,
        type: attachmentType,
        mimeType: mimeType,
        uploadedAt: DateTime.now(),
        uploadedBy: userId,
        isUploaded: false, // Will be uploaded to Firebase Storage later
      );

      return Right(attachment);
    } catch (e) {
      return Left(Failure('Erro ao processar arquivo: $e'));
    }
  }

  /// Delete attachment file from local storage
  Future<Either<Failure, void>> deleteLocalFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return const Right(null);
    } catch (e) {
      return Left(Failure('Erro ao deletar arquivo: $e'));
    }
  }

  /// Get file extension icon
  String getFileIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return '🖼️';
      case AttachmentType.pdf:
        return '📄';
      case AttachmentType.document:
        return '📝';
      case AttachmentType.other:
        return '📎';
    }
  }
}
