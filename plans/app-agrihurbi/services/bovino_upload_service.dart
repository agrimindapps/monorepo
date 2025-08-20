// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import '../models/bovino_class.dart';
import '../services/storage_service.dart';
import '../services/upload_service.dart';

/// Serviço especializado para upload de imagens de bovinos
/// Extends UploadService with bovino-specific functionality and UI feedback
class BovinoUploadService extends UploadService {
  final RxDouble _progress = 0.0.obs;
  final RxString _currentStatus = ''.obs;
  final RxBool _isUploading = false.obs;
  CancellationToken? _cancellationToken;

  BovinoUploadService({
    super.storageService,
  });

  // Getters para observar o progresso
  double get progress => _progress.value;
  String get currentStatus => _currentStatus.value;
  bool get isUploading => _isUploading.value;

  /// Faz upload de múltiplas imagens para um bovino
  Future<BovinoUploadResult> uploadBovinoImages({
    required List<File> images,
    required BovinoClass bovino,
    void Function(double progress, String status)? onProgress,
  }) async {
    if (images.isEmpty) {
      return BovinoUploadResult.success(
        uploadedUrls: [],
        failedFiles: [],
        bovino: bovino,
      );
    }

    _isUploading.value = true;
    _progress.value = 0.0;
    _cancellationToken = CancellationToken();

    try {
      _updateProgress(
          0.0, '📤 Preparando upload de ${images.length} imagem(ns)...');
      onProgress?.call(0.0, _currentStatus.value);

      // Notificação inicial
      Get.snackbar(
        '📤 Upload Iniciado',
        'Fazendo upload de ${images.length} imagem(ns) do bovino "${bovino.nomeComum}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );

      final result = await uploadMultipleFiles(
        files: images,
        bucket: StorageBuckets.bovinos,
        folder: StorageFolders.bovinos,
        onProgress: (uploadProgress) {
          final currentProgress = uploadProgress.overallProgress;
          final status =
              'Enviando ${uploadProgress.currentFileName} (${uploadProgress.currentFile}/${uploadProgress.totalFiles})';

          _updateProgress(currentProgress, status);
          onProgress?.call(currentProgress, status);
        },
        cancellationToken: _cancellationToken,
      );

      if (result.isCancelled) {
        _updateProgress(0.0, 'Upload cancelado');
        return BovinoUploadResult.cancelled();
      }

      if (!result.isSuccess) {
        _updateProgress(0.0, 'Falha no upload');
        return BovinoUploadResult.error(
          message: result.errorMessage ?? 'Erro desconhecido no upload',
        );
      }

      // Atualizar o bovino com as URLs das imagens
      final updatedBovino = bovino;
      updatedBovino.imagens ??= [];
      updatedBovino.imagens!.addAll(result.urls!);

      _updateProgress(1.0, 'Upload concluído com sucesso!');

      // Notificação de sucesso
      final successMessage = result.failedFiles?.isEmpty == true
          ? '✅ Todas as ${result.urls!.length} imagens foram enviadas com sucesso!'
          : '⚠️ ${result.urls!.length} imagens enviadas, ${result.failedFiles!.length} falharam';

      Get.snackbar(
        result.failedFiles?.isEmpty == true
            ? '✅ Upload Concluído'
            : '⚠️ Upload Parcial',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: result.failedFiles?.isEmpty == true
            ? Colors.green.withValues(alpha: 0.8)
            : Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: Icon(
          result.failedFiles?.isEmpty == true
              ? Icons.check_circle
              : Icons.warning,
          color: Colors.white,
        ),
      );

      return BovinoUploadResult.success(
        uploadedUrls: result.urls!,
        failedFiles: result.failedFiles ?? [],
        bovino: updatedBovino,
      );
    } catch (e) {
      _updateProgress(0.0, 'Erro no upload');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        '❌ Erro no Upload',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => uploadBovinoImages(
            images: images,
            bovino: bovino,
            onProgress: onProgress,
          ),
          child: const Text('Tentar Novamente',
              style: TextStyle(color: Colors.white)),
        ),
      );

      return BovinoUploadResult.error(message: errorMessage);
    } finally {
      _isUploading.value = false;
      _cancellationToken = null;
    }
  }

  /// Faz upload de imagem de miniatura para um bovino
  Future<BovinoUploadResult> uploadBovinoMiniatura({
    required File miniatura,
    required BovinoClass bovino,
    void Function(double progress, String status)? onProgress,
  }) async {
    _isUploading.value = true;
    _progress.value = 0.0;
    _cancellationToken = CancellationToken();

    try {
      _updateProgress(0.0, '🖼️ Preparando upload da miniatura...');
      onProgress?.call(0.0, _currentStatus.value);

      // Notificação inicial
      Get.snackbar(
        '🖼️ Upload da Miniatura',
        'Fazendo upload da miniatura do bovino "${bovino.nomeComum}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.purple.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        showProgressIndicator: true,
      );

      final url = await uploadSingleFile(
        file: miniatura,
        bucket: StorageBuckets.bovinos,
        folder: StorageFolders.miniaturas,
        onProgress: (uploadProgress) {
          final currentProgress = uploadProgress.overallProgress;
          final status =
              'Enviando miniatura: ${(currentProgress * 100).toInt()}%';

          _updateProgress(currentProgress, status);
          onProgress?.call(currentProgress, status);
        },
        cancellationToken: _cancellationToken,
      );

      if (url == null) {
        _updateProgress(0.0, 'Falha no upload da miniatura');
        return BovinoUploadResult.error(
            message: 'Falha no upload da miniatura');
      }

      // Atualizar o bovino com a URL da miniatura
      final updatedBovino = bovino;
      updatedBovino.miniatura = url;

      _updateProgress(1.0, 'Upload da miniatura concluído!');

      // Notificação de sucesso
      Get.snackbar(
        '✅ Miniatura Enviada',
        'Miniatura do bovino "${bovino.nomeComum}" salva com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      return BovinoUploadResult.success(
        uploadedUrls: [url],
        failedFiles: [],
        bovino: updatedBovino,
      );
    } catch (e) {
      _updateProgress(0.0, 'Erro no upload da miniatura');

      String errorMessage = _getErrorMessage(e);

      Get.snackbar(
        '❌ Erro na Miniatura',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => uploadBovinoMiniatura(
            miniatura: miniatura,
            bovino: bovino,
            onProgress: onProgress,
          ),
          child: const Text('Tentar Novamente',
              style: TextStyle(color: Colors.white)),
        ),
      );

      return BovinoUploadResult.error(message: errorMessage);
    } finally {
      _isUploading.value = false;
      _cancellationToken = null;
    }
  }

  /// Faz upload completo de todas as imagens de um bovino
  Future<BovinoUploadResult> uploadAllBovinoMedia({
    required List<File> images,
    required File? miniatura,
    required BovinoClass bovino,
    void Function(double progress, String status)? onProgress,
  }) async {
    if (images.isEmpty && miniatura == null) {
      return BovinoUploadResult.success(
        uploadedUrls: [],
        failedFiles: [],
        bovino: bovino,
      );
    }

    var updatedBovino = bovino;
    final allUrls = <String>[];
    final allFailedFiles = <UploadFailure>[];
    double totalProgress = 0.0;

    try {
      // Upload das imagens principais (70% do progresso)
      if (images.isNotEmpty) {
        final imagesResult = await uploadBovinoImages(
          images: images,
          bovino: updatedBovino,
          onProgress: (progress, status) {
            totalProgress = progress * 0.7;
            onProgress?.call(totalProgress, status);
          },
        );

        if (!imagesResult.isSuccess && !imagesResult.isCancelled) {
          return imagesResult;
        }

        if (imagesResult.isSuccess) {
          updatedBovino = imagesResult.bovino!;
          allUrls.addAll(imagesResult.uploadedUrls);
          allFailedFiles.addAll(imagesResult.failedFiles);
        }
      }

      // Upload da miniatura (30% do progresso)
      if (miniatura != null) {
        final miniaturaResult = await uploadBovinoMiniatura(
          miniatura: miniatura,
          bovino: updatedBovino,
          onProgress: (progress, status) {
            totalProgress = 0.7 + (progress * 0.3);
            onProgress?.call(totalProgress, status);
          },
        );

        if (!miniaturaResult.isSuccess && !miniaturaResult.isCancelled) {
          return miniaturaResult;
        }

        if (miniaturaResult.isSuccess) {
          updatedBovino = miniaturaResult.bovino!;
          allUrls.addAll(miniaturaResult.uploadedUrls);
          allFailedFiles.addAll(miniaturaResult.failedFiles);
        }
      }

      onProgress?.call(1.0, 'Upload completo finalizado!');

      return BovinoUploadResult.success(
        uploadedUrls: allUrls,
        failedFiles: allFailedFiles,
        bovino: updatedBovino,
      );
    } catch (e) {
      return BovinoUploadResult.error(message: _getErrorMessage(e));
    }
  }

  /// Cancela o upload em andamento
  void cancelUpload() {
    _cancellationToken?.cancel();
    _updateProgress(0.0, 'Upload cancelado');

    Get.snackbar(
      '🛑 Upload Cancelado',
      'O upload de imagens foi cancelado pelo usuário',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateProgress(double progress, String status) {
    _progress.value = progress;
    _currentStatus.value = status;
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('network') || errorString.contains('timeout')) {
      return '🌐 Erro de conexão: Verifique sua internet e tente novamente';
    } else if (errorString.contains('storage') ||
        errorString.contains('bucket')) {
      return '☁️ Erro no armazenamento: Problema no servidor de imagens';
    } else if (errorString.contains('file') ||
        errorString.contains('invalid')) {
      return '📁 Arquivo inválido: Verifique se as imagens são válidas';
    } else if (errorString.contains('permission')) {
      return '🔒 Sem permissão: Verifique suas credenciais de acesso';
    } else if (errorString.contains('size') || errorString.contains('large')) {
      return '📏 Arquivo muito grande: Reduza o tamanho das imagens';
    } else {
      return '❌ Erro no upload: $errorString';
    }
  }

  void dispose() {
    _cancellationToken?.cancel();
  }
}

/// Resultado do upload de imagens de bovinos
class BovinoUploadResult {
  final bool isSuccess;
  final bool isCancelled;
  final List<String> uploadedUrls;
  final List<UploadFailure> failedFiles;
  final BovinoClass? bovino;
  final String? errorMessage;

  const BovinoUploadResult._({
    required this.isSuccess,
    required this.isCancelled,
    required this.uploadedUrls,
    required this.failedFiles,
    this.bovino,
    this.errorMessage,
  });

  factory BovinoUploadResult.success({
    required List<String> uploadedUrls,
    required List<UploadFailure> failedFiles,
    required BovinoClass bovino,
  }) {
    return BovinoUploadResult._(
      isSuccess: true,
      isCancelled: false,
      uploadedUrls: uploadedUrls,
      failedFiles: failedFiles,
      bovino: bovino,
    );
  }

  factory BovinoUploadResult.error({required String message}) {
    return BovinoUploadResult._(
      isSuccess: false,
      isCancelled: false,
      uploadedUrls: [],
      failedFiles: [],
      errorMessage: message,
    );
  }

  factory BovinoUploadResult.cancelled() {
    return const BovinoUploadResult._(
      isSuccess: false,
      isCancelled: true,
      uploadedUrls: [],
      failedFiles: [],
      errorMessage: 'Upload cancelado pelo usuário',
    );
  }

  bool get hasFailures => failedFiles.isNotEmpty;
  bool get hasPartialSuccess =>
      uploadedUrls.isNotEmpty && failedFiles.isNotEmpty;
  int get totalUploaded => uploadedUrls.length;
  int get totalFailed => failedFiles.length;
}
