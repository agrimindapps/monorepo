import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../../../domain/entities/file_entity.dart' as domain;

/// Serviço especializado em gerenciamento de diretórios
///
/// Responsabilidades:
/// - Criar e gerenciar diretórios
/// - Listar e buscar arquivos em diretórios
/// - Obter diretórios do sistema (documents, cache, etc)
/// - Gerenciar cache e storage
class DirectoryManagerService {
  /// Cria um diretório
  Future<domain.FileOperationResult> createDirectory({
    required String path,
    bool recursive = true,
  }) async {
    try {
      final directory = Directory(path);
      await directory.create(recursive: recursive);

      return domain.FileOperationResult(
        success: true,
        path: path,
      );
    } catch (e) {
      debugPrint('❌ Error creating directory: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Lista arquivos em um diretório
  Future<List<domain.FileInfoEntity>> listDirectory({
    required String path,
    domain.FileFilter? filter,
    bool recursive = false,
    required Future<domain.FileInfoEntity?> Function(String) getFileInfo,
    required bool Function(domain.FileInfoEntity, domain.FileFilter?) matchesFilter,
  }) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) return [];

      final List<domain.FileInfoEntity> result = [];
      final entities = directory.listSync(recursive: recursive);

      for (final entity in entities) {
        final fileInfo = await getFileInfo(entity.path);
        if (fileInfo != null && matchesFilter(fileInfo, filter)) {
          result.add(fileInfo);
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error listing directory: $e');
      return [];
    }
  }

  /// Busca arquivos em um diretório
  Future<List<domain.FileInfoEntity>> searchFiles({
    required String searchPath,
    String? namePattern,
    domain.FileFilter? filter,
    bool recursive = true,
    required Future<domain.FileInfoEntity?> Function(String) getFileInfo,
  }) async {
    try {
      final List<domain.FileInfoEntity> result = [];
      final directory = Directory(searchPath);

      if (!await directory.exists()) return result;

      final entities = directory.listSync(recursive: recursive);

      for (final entity in entities) {
        final fileInfo = await getFileInfo(entity.path);
        if (fileInfo != null) {
          bool matches = true;
          if (namePattern != null) {
            matches = matches && fileInfo.name.contains(namePattern);
          }
          if (filter != null) {
            matches = matches && _matchesFilter(fileInfo, filter);
          }

          if (matches) {
            result.add(fileInfo);
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error searching files: $e');
      return [];
    }
  }

  /// Obtém diretório de documentos
  Future<String> getDocumentsDirectory() async {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Obtém diretório de cache
  Future<String> getCacheDirectory() async {
    final directory = await path_provider.getTemporaryDirectory();
    return directory.path;
  }

  /// Obtém diretório temporário
  Future<String> getTemporaryDirectory() async {
    final directory = await path_provider.getTemporaryDirectory();
    return directory.path;
  }

  /// Obtém diretório de downloads
  Future<String?> getDownloadsDirectory() async {
    try {
      final directory = await path_provider.getDownloadsDirectory();
      return directory?.path;
    } catch (e) {
      debugPrint('❌ Error getting downloads directory: $e');
      return null;
    }
  }

  /// Obtém diretório de armazenamento externo (Android)
  Future<String?> getExternalStorageDirectory() async {
    try {
      if (Platform.isAndroid) {
        final directory = await path_provider.getExternalStorageDirectory();
        return directory?.path;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting external storage directory: $e');
      return null;
    }
  }

  /// Obtém diretório do sistema
  Future<String?> getSystemDirectory(domain.SystemDirectory type) async {
    try {
      switch (type) {
        case domain.SystemDirectory.documents:
          return await getDocumentsDirectory();
        case domain.SystemDirectory.cache:
          return await getCacheDirectory();
        case domain.SystemDirectory.temporary:
          return await getTemporaryDirectory();
        case domain.SystemDirectory.downloads:
          return await getDownloadsDirectory();
        case domain.SystemDirectory.external:
          return await getExternalStorageDirectory();
        case domain.SystemDirectory.applicationSupport:
          final directory = await path_provider.getApplicationSupportDirectory();
          return directory.path;
      }
    } catch (e) {
      debugPrint('❌ Error getting system directory: $e');
      return null;
    }
  }

  /// Obtém tamanho de um diretório
  Future<int> getDirectorySize(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) return 0;

      int totalSize = 0;
      final entities = directory.listSync(recursive: true);

      for (final entity in entities) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('❌ Error getting directory size: $e');
      return 0;
    }
  }

  /// Configura cache
  Future<bool> configurateCache(domain.CacheConfig config) async {
    try {
      // Implementation would depend on specific cache requirements
      return true;
    } catch (e) {
      debugPrint('❌ Error configuring cache: $e');
      return false;
    }
  }

  /// Limpa cache
  Future<int> clearCache({String? path}) async {
    try {
      final cacheDir = path ?? await getCacheDirectory();
      final directory = Directory(cacheDir);

      if (!await directory.exists()) return 0;

      int totalSize = 0;
      final entities = directory.listSync(recursive: true);

      for (final entity in entities) {
        if (entity is File) {
          final size = await entity.length();
          totalSize += size;
          await entity.delete();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
      return 0;
    }
  }

  /// Obtém tamanho do cache
  Future<int> getCacheSize({String? path}) async {
    try {
      final cacheDir = path ?? await getCacheDirectory();
      return await getDirectorySize(cacheDir);
    } catch (e) {
      debugPrint('❌ Error getting cache size: $e');
      return 0;
    }
  }

  /// Limpa arquivos temporários
  Future<int> clearTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      return await clearCache(path: tempDir);
    } catch (e) {
      debugPrint('❌ Error clearing temporary files: $e');
      return 0;
    }
  }

  /// Obtém estatísticas de armazenamento
  Future<Map<String, int>> getStorageStats() async {
    try {
      final docs = await getDocumentsDirectory();
      final cache = await getCacheDirectory();
      final temp = await getTemporaryDirectory();

      return {
        'documents': await getDirectorySize(docs),
        'cache': await getDirectorySize(cache),
        'temporary': await getDirectorySize(temp),
      };
    } catch (e) {
      debugPrint('❌ Error getting storage stats: $e');
      return {};
    }
  }

  /// Helper: Verifica se arquivo corresponde ao filtro
  bool _matchesFilter(domain.FileInfoEntity fileInfo, domain.FileFilter? filter) {
    if (filter == null) return true;

    if (filter.extensions != null && filter.extensions!.isNotEmpty) {
      if (!filter.extensions!.contains(fileInfo.extension.toLowerCase())) {
        return false;
      }
    }

    if (filter.mimeTypes != null && filter.mimeTypes!.isNotEmpty) {
      if (!filter.mimeTypes!.contains(fileInfo.mimeType)) {
        return false;
      }
    }

    if (filter.minSize != null && fileInfo.size < filter.minSize!) {
      return false;
    }

    if (filter.maxSize != null && fileInfo.size > filter.maxSize!) {
      return false;
    }

    if (filter.modifiedAfter != null && fileInfo.lastModified.isBefore(filter.modifiedAfter!)) {
      return false;
    }

    if (filter.modifiedBefore != null && fileInfo.lastModified.isAfter(filter.modifiedBefore!)) {
      return false;
    }

    if (!filter.includeHidden && fileInfo.isHidden) {
      return false;
    }

    if (!filter.includeDirectories && fileInfo.isDirectory) {
      return false;
    }

    return true;
  }
}
