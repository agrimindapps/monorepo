import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path_helper;

import '../../../domain/entities/file_entity.dart' as domain;

/// Serviço especializado em metadados e informações de arquivos
///
/// Responsabilidades:
/// - Obter informações detalhadas de arquivos
/// - Manipulação de paths (parent, join, basename, extension)
/// - MIME type detection
/// - Permissões de arquivos
/// - Hashing e comparação de arquivos
class FileMetadataService {
  /// Obtém informações completas de um arquivo
  Future<domain.FileInfoEntity?> getFileInfo(String path) async {
    try {
      final entity = await FileSystemEntity.type(path);
      if (entity == FileSystemEntityType.notFound) {
        return null;
      }

      final stat = await FileStat.stat(path);
      final fileName = getFileName(path);
      final extension = getFileExtension(path);
      final mimeType = await getMimeType(path);
      final permissions = await getPermissions(path);

      return domain.FileInfoEntity(
        path: path,
        name: fileName,
        extension: extension,
        size: stat.size,
        mimeType: mimeType,
        lastModified: stat.modified,
        exists: true,
        isDirectory: entity == FileSystemEntityType.directory,
        isHidden: fileName.startsWith('.'),
        permissions: permissions,
      );
    } catch (e) {
      debugPrint('❌ Error getting file info: $e');
      return null;
    }
  }

  /// Obtém diretório pai
  String getParentDirectory(String path) {
    return path_helper.dirname(path);
  }

  /// Junta múltiplos paths
  String joinPaths(List<String> paths) {
    return path_helper.joinAll(paths);
  }

  /// Obtém nome do arquivo
  String getFileName(String path) {
    return path_helper.basename(path);
  }

  /// Obtém extensão do arquivo
  String getFileExtension(String path) {
    return path_helper.extension(path);
  }

  /// Obtém nome sem extensão
  String getFileNameWithoutExtension(String path) {
    return path_helper.basenameWithoutExtension(path);
  }

  /// Obtém MIME type do arquivo
  Future<String> getMimeType(String path) async {
    try {
      return lookupMimeType(path) ?? 'application/octet-stream';
    } catch (e) {
      debugPrint('❌ Error getting mime type: $e');
      return 'application/octet-stream';
    }
  }

  /// Obtém permissões do arquivo
  Future<domain.FilePermissionsEntity?> getPermissions(String path) async {
    try {
      // On most platforms, we return basic permissions
      // Real implementation would require platform-specific code
      return const domain.FilePermissionsEntity(
        readable: true,
        writable: true,
        executable: false,
      );
    } catch (e) {
      debugPrint('❌ Error getting permissions: $e');
      return null;
    }
  }

  /// Define permissões do arquivo
  Future<bool> setPermissions({
    required String path,
    required domain.FilePermissionsEntity permissions,
  }) async {
    try {
      // Implementation would require platform-specific code
      // On Unix systems: chmod, on Windows: icacls
      return true;
    } catch (e) {
      debugPrint('❌ Error setting permissions: $e');
      return false;
    }
  }

  /// Calcula hash de arquivo
  Future<String> calculateFileHash({
    required String path,
    String algorithm = 'sha256',
  }) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();

      switch (algorithm.toLowerCase()) {
        case 'md5':
          return md5.convert(bytes).toString();
        case 'sha1':
          return sha1.convert(bytes).toString();
        case 'sha256':
        default:
          return sha256.convert(bytes).toString();
      }
    } catch (e) {
      debugPrint('❌ Error calculating file hash: $e');
      return '';
    }
  }

  /// Compara dois arquivos
  Future<bool> compareFiles({
    required String path1,
    required String path2,
  }) async {
    try {
      final hash1 = await calculateFileHash(path: path1);
      final hash2 = await calculateFileHash(path: path2);
      return hash1 == hash2 && hash1.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error comparing files: $e');
      return false;
    }
  }

  /// Compartilha arquivos (placeholder - requer implementação de plataforma)
  Future<bool> shareFiles({
    required List<String> filePaths,
    String? subject,
    String? text,
  }) async {
    try {
      debugPrint('📤 Sharing files: $filePaths');
      // Implementation would use share_plus or similar package
      return true;
    } catch (e) {
      debugPrint('❌ Error sharing files: $e');
      return false;
    }
  }

  /// Compartilha texto (placeholder - requer implementação de plataforma)
  Future<bool> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      debugPrint('📤 Sharing text: $text');
      // Implementation would use share_plus or similar package
      return true;
    } catch (e) {
      debugPrint('❌ Error sharing text: $e');
      return false;
    }
  }

  /// Abre arquivo com app externo (placeholder - requer implementação de plataforma)
  Future<bool> openFile(String path) async {
    try {
      debugPrint('📂 Opening file: $path');
      // Implementation would use open_file or similar package
      return true;
    } catch (e) {
      debugPrint('❌ Error opening file: $e');
      return false;
    }
  }
}
