// Dart imports:
import 'dart:io';
import 'dart:typed_data';

/// Interface para services de armazenamento
/// Define contratos para diferentes provedores de storage
abstract class IStorageService {
  /// Upload de arquivo
  Future<String?> uploadFile({
    required String bucket,
    required File file,
    required String folder,
    String? customName,
  });

  /// Upload de dados em bytes
  Future<String?> uploadBytes({
    required String bucket,
    required Uint8List bytes,
    required String folder,
    required String fileName,
  });

  /// Download de arquivo
  Future<Uint8List?> downloadFile(String url);

  /// Deleta arquivo
  Future<bool> deleteFile(String url);

  /// Lista arquivos em uma pasta
  Future<List<String>?> listFiles({
    required String bucket,
    required String folder,
  });

  /// Verifica se arquivo existe
  Future<bool> fileExists(String url);

  /// Obtém informações do arquivo
  Future<FileInfo?> getFileInfo(String url);

  /// Gera URL temporária para acesso
  Future<String?> generateTemporaryUrl(String url, Duration expiration);
}

/// Interface para configuração de storage
abstract class IStorageConfig {
  /// Bucket padrão
  String get defaultBucket;
  
  /// Pasta padrão
  String get defaultFolder;
  
  /// Tamanho máximo do arquivo
  int get maxFileSize;
  
  /// Tipos de arquivo permitidos
  List<String> get allowedFileTypes;
  
  /// Provedor de storage (Firebase, AWS, etc.)
  String get provider;
}

/// Interface para observar operações de storage
abstract class IStorageObserver {
  /// Notifica início de upload
  void onUploadStarted(String fileName);
  
  /// Notifica progresso do upload
  void onUploadProgress(String fileName, double progress);
  
  /// Notifica conclusão do upload
  void onUploadCompleted(String fileName, String url);
  
  /// Notifica erro no upload
  void onUploadError(String fileName, String error);
  
  /// Notifica início de download
  void onDownloadStarted(String url);
  
  /// Notifica conclusão do download
  void onDownloadCompleted(String url, Uint8List data);
  
  /// Notifica erro no download
  void onDownloadError(String url, String error);
}

/// Interface para cache de storage
abstract class IStorageCache {
  /// Salva arquivo no cache
  Future<void> cacheFile(String url, Uint8List data);
  
  /// Recupera arquivo do cache
  Future<Uint8List?> getCachedFile(String url);
  
  /// Remove arquivo do cache
  Future<void> removeCachedFile(String url);
  
  /// Limpa todo o cache
  Future<void> clearCache();
  
  /// Verifica se arquivo está em cache
  Future<bool> isFileCached(String url);
  
  /// Tamanho atual do cache
  Future<int> getCacheSize();
}

/// Interface para retry de operações de storage
abstract class IStorageRetryPolicy {
  /// Número máximo de tentativas
  int get maxRetries;
  
  /// Delay base entre tentativas
  Duration get baseDelay;
  
  /// Multiplicador para backoff exponencial
  double get backoffMultiplier;
  
  /// Verifica se deve tentar novamente
  bool shouldRetry(Exception error, int attemptNumber);
  
  /// Calcula delay para próxima tentativa
  Duration calculateDelay(int attemptNumber);
}

/// Informações sobre um arquivo no storage
class FileInfo {
  final String name;
  final String url;
  final int size;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String contentType;
  final Map<String, String>? metadata;

  const FileInfo({
    required this.name,
    required this.url,
    required this.size,
    required this.createdAt,
    required this.modifiedAt,
    required this.contentType,
    this.metadata,
  });
}

/// Resultado de operação de storage
class StorageOperationResult {
  final bool success;
  final String? data;
  final String? error;
  final Duration? duration;

  const StorageOperationResult({
    required this.success,
    this.data,
    this.error,
    this.duration,
  });

  factory StorageOperationResult.success(String data, {Duration? duration}) {
    return StorageOperationResult(
      success: true,
      data: data,
      duration: duration,
    );
  }

  factory StorageOperationResult.error(String error, {Duration? duration}) {
    return StorageOperationResult(
      success: false,
      error: error,
      duration: duration,
    );
  }
}