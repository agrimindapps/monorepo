// Dart imports:
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../services/storage_service.dart';
import 'file_validation_service.dart';

/// Enhanced upload service with validation, retry, and progress tracking
/// Base service for all upload operations - use specialized services for specific contexts
class UploadService {
  final StorageService _storageService;

  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);
  static const Duration _uploadTimeout = Duration(minutes: 5);

  UploadService({
    StorageService? storageService,
  }) : _storageService = storageService ?? StorageService();

  /// Factory method for creating specialized upload services
  static T createSpecialized<T extends UploadService>(T Function(UploadService base) factory) {
    return factory(UploadService());
  }

  /// Uploads multiple files with validation and progress tracking
  Future<UploadResult> uploadMultipleFiles({
    required List<File> files,
    required String bucket,
    required String folder,
    required UploadProgressCallback onProgress,
    CancellationToken? cancellationToken,
  }) async {
    if (files.isEmpty) {
      return UploadResult.error('Nenhum arquivo selecionado');
    }

    try {
      // Validate files first
      final validationResult = await FileValidationService.validateFiles(files);
      if (!validationResult.isValid) {
        return UploadResult.error(validationResult.errorMessage!);
      }

      final validFiles = validationResult.validFiles!;
      final uploadedUrls = <String>[];
      final failedFiles = <UploadFailure>[];

      for (int i = 0; i < validFiles.length; i++) {
        if (cancellationToken?.isCancelled == true) {
          return UploadResult.cancelled();
        }

        final fileResult = validFiles[i];
        final file = files[i];

        try {
          // Update progress
          onProgress(UploadProgress(
            currentFile: i + 1,
            totalFiles: validFiles.length,
            currentFileProgress: 0.0,
            overallProgress: i / validFiles.length,
            currentFileName: fileResult.sanitizedName!,
            status: UploadStatus.uploading,
          ));

          // Upload with retry
          final url = await _uploadWithRetry(
            file: file,
            bucket: bucket,
            folder: folder,
            sanitizedName: fileResult.sanitizedName!,
            onFileProgress: (progress) {
              onProgress(UploadProgress(
                currentFile: i + 1,
                totalFiles: validFiles.length,
                currentFileProgress: progress,
                overallProgress: (i + progress) / validFiles.length,
                currentFileName: fileResult.sanitizedName!,
                status: UploadStatus.uploading,
              ));
            },
            cancellationToken: cancellationToken,
          );

          if (url != null) {
            uploadedUrls.add(url);
          } else {
            failedFiles.add(UploadFailure(
              fileName: fileResult.sanitizedName!,
              error: 'Upload falhou após todas as tentativas',
            ));
          }
        } catch (e) {
          failedFiles.add(UploadFailure(
            fileName: fileResult.sanitizedName!,
            error: e.toString(),
          ));
        }
      }

      // Update final progress
      onProgress(UploadProgress(
        currentFile: validFiles.length,
        totalFiles: validFiles.length,
        currentFileProgress: 1.0,
        overallProgress: 1.0,
        currentFileName: '',
        status:
            uploadedUrls.isEmpty ? UploadStatus.failed : UploadStatus.completed,
      ));

      if (uploadedUrls.isEmpty) {
        return UploadResult.error('Nenhum arquivo foi enviado com sucesso');
      }

      return UploadResult.success(
        urls: uploadedUrls,
        failedFiles: failedFiles,
        totalSize: validationResult.totalSize!,
      );
    } catch (e) {
      onProgress(UploadProgress(
        currentFile: 0,
        totalFiles: files.length,
        currentFileProgress: 0.0,
        overallProgress: 0.0,
        currentFileName: '',
        status: UploadStatus.failed,
      ));

      return UploadResult.error('Erro durante o upload: $e');
    }
  }

  /// Uploads a single file with validation
  Future<String?> uploadSingleFile({
    required File file,
    required String bucket,
    required String folder,
    UploadProgressCallback? onProgress,
    CancellationToken? cancellationToken,
  }) async {
    try {
      // Validate file
      final validationResult = await FileValidationService.validateFile(file);
      if (!validationResult.isValid) {
        throw Exception(validationResult.errorMessage);
      }

      onProgress?.call(UploadProgress(
        currentFile: 1,
        totalFiles: 1,
        currentFileProgress: 0.0,
        overallProgress: 0.0,
        currentFileName: validationResult.sanitizedName!,
        status: UploadStatus.uploading,
      ));

      final url = await _uploadWithRetry(
        file: file,
        bucket: bucket,
        folder: folder,
        sanitizedName: validationResult.sanitizedName!,
        onFileProgress: (progress) {
          onProgress?.call(UploadProgress(
            currentFile: 1,
            totalFiles: 1,
            currentFileProgress: progress,
            overallProgress: progress,
            currentFileName: validationResult.sanitizedName!,
            status: UploadStatus.uploading,
          ));
        },
        cancellationToken: cancellationToken,
      );

      onProgress?.call(UploadProgress(
        currentFile: 1,
        totalFiles: 1,
        currentFileProgress: 1.0,
        overallProgress: 1.0,
        currentFileName: validationResult.sanitizedName!,
        status: url != null ? UploadStatus.completed : UploadStatus.failed,
      ));

      return url;
    } catch (e) {
      onProgress?.call(const UploadProgress(
        currentFile: 1,
        totalFiles: 1,
        currentFileProgress: 0.0,
        overallProgress: 0.0,
        currentFileName: '',
        status: UploadStatus.failed,
      ));

      throw Exception('Erro ao fazer upload: $e');
    }
  }

  /// Uploads file with retry mechanism and exponential backoff
  Future<String?> _uploadWithRetry({
    required File file,
    required String bucket,
    required String folder,
    required String sanitizedName,
    required Function(double) onFileProgress,
    CancellationToken? cancellationToken,
  }) async {
    int retryCount = 0;
    Exception? lastException;

    while (retryCount < _maxRetries) {
      if (cancellationToken?.isCancelled == true) {
        return null;
      }

      try {
        // Generate secure filename
        final secureFilename =
            FileValidationService.generateSecureFilename(sanitizedName);

        // Upload with timeout
        final completer = Completer<String?>();
        final timer = Timer(_uploadTimeout, () {
          if (!completer.isCompleted) {
            completer.completeError(TimeoutException('Upload timeout'));
          }
        });

        // Perform upload
        final uploadFuture = _storageService.uploadFile(
          bucket: bucket,
          file: file,
          folder: folder,
          customName: secureFilename,
        );

        uploadFuture.then((url) {
          timer.cancel();
          if (!completer.isCompleted) {
            completer.complete(url);
          }
        }).catchError((error) {
          timer.cancel();
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        });

        final result = await completer.future;
        if (result != null) {
          onFileProgress(1.0);
          return result;
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        if (retryCount < _maxRetries - 1) {
          // Exponential backoff
          final delay = Duration(
            milliseconds: _baseRetryDelay.inMilliseconds *
                math.pow(2, retryCount).toInt(),
          );

          await Future.delayed(delay);
        }
      }

      retryCount++;
    }

    // All retries failed
    if (kDebugMode) {
      debugPrint('Upload failed after $retryCount attempts: $lastException');
    }

    return null;
  }
}

/// Upload progress information
class UploadProgress {
  final int currentFile;
  final int totalFiles;
  final double currentFileProgress;
  final double overallProgress;
  final String currentFileName;
  final UploadStatus status;

  const UploadProgress({
    required this.currentFile,
    required this.totalFiles,
    required this.currentFileProgress,
    required this.overallProgress,
    required this.currentFileName,
    required this.status,
  });

  /// Progress as percentage (0-100)
  double get overallProgressPercent => overallProgress * 100;
  double get currentFileProgressPercent => currentFileProgress * 100;
}

/// Upload status enumeration
enum UploadStatus {
  uploading,
  completed,
  failed,
  cancelled,
}

/// Result of upload operation
class UploadResult {
  final bool isSuccess;
  final List<String>? urls;
  final List<UploadFailure>? failedFiles;
  final int? totalSize;
  final String? errorMessage;
  final bool isCancelled;

  const UploadResult._({
    required this.isSuccess,
    this.urls,
    this.failedFiles,
    this.totalSize,
    this.errorMessage,
    this.isCancelled = false,
  });

  factory UploadResult.success({
    required List<String> urls,
    required List<UploadFailure> failedFiles,
    required int totalSize,
  }) {
    return UploadResult._(
      isSuccess: true,
      urls: urls,
      failedFiles: failedFiles,
      totalSize: totalSize,
    );
  }

  factory UploadResult.error(String message) {
    return UploadResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  factory UploadResult.cancelled() {
    return const UploadResult._(
      isSuccess: false,
      isCancelled: true,
      errorMessage: 'Upload cancelado',
    );
  }
}

/// Information about failed upload
class UploadFailure {
  final String fileName;
  final String error;

  const UploadFailure({
    required this.fileName,
    required this.error,
  });
}

/// Cancellation token for upload operations
class CancellationToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }
}

/// Callback for upload progress updates
typedef UploadProgressCallback = void Function(UploadProgress progress);
