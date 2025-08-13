import 'package:equatable/equatable.dart';

/// Informações sobre um arquivo
class FileInfoEntity extends Equatable {
  const FileInfoEntity({
    required this.path,
    required this.name,
    required this.extension,
    required this.size,
    required this.mimeType,
    required this.lastModified,
    required this.exists,
    this.isDirectory = false,
    this.isHidden = false,
    this.permissions,
  });

  final String path;
  final String name;
  final String extension;
  final int size;
  final String mimeType;
  final DateTime lastModified;
  final bool exists;
  final bool isDirectory;
  final bool isHidden;
  final FilePermissionsEntity? permissions;

  @override
  List<Object?> get props => [
    path, name, extension, size, mimeType, lastModified, 
    exists, isDirectory, isHidden, permissions
  ];
}

/// Permissões de arquivo
class FilePermissionsEntity extends Equatable {
  const FilePermissionsEntity({
    required this.readable,
    required this.writable,
    required this.executable,
  });

  final bool readable;
  final bool writable;
  final bool executable;

  @override
  List<Object?> get props => [readable, writable, executable];
}

/// Resultado de operação de arquivo
class FileOperationResult extends Equatable {
  const FileOperationResult({
    required this.success,
    this.path,
    this.error,
    this.data,
  });

  final bool success;
  final String? path;
  final String? error;
  final dynamic data;

  @override
  List<Object?> get props => [success, path, error, data];
}

/// Resultado de upload/download
class FileTransferResult extends Equatable {
  const FileTransferResult({
    required this.success,
    required this.bytesTransferred,
    required this.totalBytes,
    this.path,
    this.url,
    this.error,
  });

  final bool success;
  final int bytesTransferred;
  final int totalBytes;
  final String? path;
  final String? url;
  final String? error;

  double get progress => totalBytes > 0 ? bytesTransferred / totalBytes : 0.0;

  @override
  List<Object?> get props => [
    success, bytesTransferred, totalBytes, path, url, error
  ];
}

/// Configuração de compressão
class CompressionConfig extends Equatable {
  const CompressionConfig({
    required this.type,
    this.level = 6,
    this.password,
  });

  final CompressionType type;
  final int level; // 1-9, onde 9 é máxima compressão
  final String? password;

  @override
  List<Object?> get props => [type, level, password];
}

/// Filtro para busca de arquivos
class FileFilter extends Equatable {
  const FileFilter({
    this.extensions,
    this.mimeTypes,
    this.minSize,
    this.maxSize,
    this.modifiedAfter,
    this.modifiedBefore,
    this.includeHidden = false,
    this.includeDirectories = false,
  });

  final List<String>? extensions;
  final List<String>? mimeTypes;
  final int? minSize;
  final int? maxSize;
  final DateTime? modifiedAfter;
  final DateTime? modifiedBefore;
  final bool includeHidden;
  final bool includeDirectories;

  @override
  List<Object?> get props => [
    extensions, mimeTypes, minSize, maxSize, 
    modifiedAfter, modifiedBefore, includeHidden, includeDirectories
  ];
}

/// Configuração de cache
class CacheConfig extends Equatable {
  const CacheConfig({
    required this.maxSize,
    required this.maxAge,
    this.compressionEnabled = true,
  });

  final int maxSize; // em bytes
  final Duration maxAge;
  final bool compressionEnabled;

  @override
  List<Object?> get props => [maxSize, maxAge, compressionEnabled];
}

/// Tipos de compressão suportados
enum CompressionType {
  zip('zip'),
  gzip('gzip'),
  tar('tar'),
  sevenZ('7z');

  const CompressionType(this.value);
  final String value;
}

/// Tipos de diretório do sistema
enum SystemDirectory {
  documents('documents'),
  downloads('downloads'),
  cache('cache'),
  temporary('temporary'),
  external('external'),
  applicationSupport('applicationSupport');

  const SystemDirectory(this.value);
  final String value;
}

/// Tipos de compartilhamento
enum ShareType {
  text('text'),
  file('file'),
  image('image'),
  url('url');

  const ShareType(this.value);
  final String value;
}

/// Opções de backup
class BackupOptions extends Equatable {
  const BackupOptions({
    required this.includeCache,
    required this.includeUserData,
    required this.compressionEnabled,
    this.encryptionPassword,
  });

  final bool includeCache;
  final bool includeUserData;
  final bool compressionEnabled;
  final String? encryptionPassword;

  @override
  List<Object?> get props => [
    includeCache, includeUserData, compressionEnabled, encryptionPassword
  ];
}