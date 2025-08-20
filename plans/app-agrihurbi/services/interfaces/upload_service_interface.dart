// Dart imports:
import 'dart:io';

// Project imports:
import '../upload_service.dart';

/// Interface para services de upload
/// Define contratos comuns para diferentes tipos de upload
abstract class IUploadService {
  /// Upload de múltiplos arquivos
  Future<UploadResult> uploadMultipleFiles({
    required List<File> files,
    required String bucket,
    required String folder,
    required UploadProgressCallback onProgress,
    CancellationToken? cancellationToken,
  });

  /// Upload de arquivo único
  Future<String?> uploadSingleFile({
    required File file,
    required String bucket,
    required String folder,
    UploadProgressCallback? onProgress,
    CancellationToken? cancellationToken,
  });
}

/// Interface para upload especializado
abstract class ISpecializedUploadService<T> extends IUploadService {
  /// Upload específico do tipo T
  Future<T> uploadSpecific({
    required List<File> files,
    required dynamic context,
    void Function(double progress, String status)? onProgress,
  });

  /// Cancela upload em andamento
  void cancelUpload();

  /// Status atual do upload
  bool get isUploading;
  double get progress;
  String get currentStatus;
}

/// Interface para validação de upload
abstract class IUploadValidator {
  /// Valida arquivos antes do upload
  Future<bool> validateFiles(List<File> files);
  
  /// Mensagem de erro da validação
  String? get validationError;
}

/// Interface para observar progresso de upload
abstract class IUploadProgressObserver {
  /// Notifica mudança no progresso
  void onProgressChanged(double progress, String status);
  
  /// Notifica conclusão do upload
  void onUploadCompleted(bool success, List<String> urls);
  
  /// Notifica erro no upload
  void onUploadError(String error);
}