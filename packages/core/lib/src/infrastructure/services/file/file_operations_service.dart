import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../domain/entities/file_entity.dart' as domain;

/// Serviço especializado em operações CRUD de arquivos
///
/// Responsabilidades:
/// - Verificar existência de arquivos
/// - Criar, ler, escrever arquivos
/// - Copiar, mover, renomear, deletar arquivos
class FileOperationsService {
  /// Verifica se um arquivo ou diretório existe
  Future<bool> exists(String path) async {
    try {
      final entity = FileSystemEntity.isFileSync(path)
          ? File(path)
          : Directory(path);
      return await entity.exists();
    } catch (e) {
      debugPrint('❌ Error checking if path exists: $e');
      return false;
    }
  }

  /// Cria um novo arquivo
  Future<domain.FileOperationResult> createFile({
    required String path,
    String? content,
    Uint8List? bytes,
    bool recursive = true,
  }) async {
    try {
      final file = File(path);

      if (recursive) {
        await file.parent.create(recursive: true);
      }

      if (content != null) {
        await file.writeAsString(content);
      } else if (bytes != null) {
        await file.writeAsBytes(bytes);
      } else {
        await file.create();
      }

      return domain.FileOperationResult(
        success: true,
        path: path,
      );
    } catch (e) {
      debugPrint('❌ Error creating file: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Lê arquivo como string
  Future<String?> readAsString(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsString();
    } catch (e) {
      debugPrint('❌ Error reading file as string: $e');
      return null;
    }
  }

  /// Lê arquivo como bytes
  Future<Uint8List?> readAsBytes(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('❌ Error reading file as bytes: $e');
      return null;
    }
  }

  /// Escreve string em arquivo
  Future<domain.FileOperationResult> writeAsString({
    required String path,
    required String content,
    bool append = false,
  }) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);

      if (append) {
        await file.writeAsString(content, mode: FileMode.append);
      } else {
        await file.writeAsString(content);
      }

      return domain.FileOperationResult(
        success: true,
        path: path,
      );
    } catch (e) {
      debugPrint('❌ Error writing file as string: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Escreve bytes em arquivo
  Future<domain.FileOperationResult> writeAsBytes({
    required String path,
    required Uint8List bytes,
    bool append = false,
  }) async {
    try {
      final file = File(path);
      await file.parent.create(recursive: true);

      if (append) {
        await file.writeAsBytes(bytes, mode: FileMode.append);
      } else {
        await file.writeAsBytes(bytes);
      }

      return domain.FileOperationResult(
        success: true,
        path: path,
      );
    } catch (e) {
      debugPrint('❌ Error writing file as bytes: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Copia arquivo
  Future<domain.FileOperationResult> copy({
    required String sourcePath,
    required String destinationPath,
    bool overwrite = false,
  }) async {
    try {
      final source = File(sourcePath);
      final destination = File(destinationPath);

      if (!overwrite && await destination.exists()) {
        return const domain.FileOperationResult(
          success: false,
          error: 'Destination file already exists',
        );
      }

      await destination.parent.create(recursive: true);
      await source.copy(destinationPath);

      return domain.FileOperationResult(
        success: true,
        path: destinationPath,
      );
    } catch (e) {
      debugPrint('❌ Error copying file: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Move arquivo
  Future<domain.FileOperationResult> move({
    required String sourcePath,
    required String destinationPath,
    bool overwrite = false,
  }) async {
    try {
      final copyResult = await copy(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
        overwrite: overwrite,
      );

      if (copyResult.success) {
        await delete(path: sourcePath);
      }

      return copyResult;
    } catch (e) {
      debugPrint('❌ Error moving file: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Renomeia arquivo ou diretório
  Future<domain.FileOperationResult> rename({
    required String path,
    required String newName,
    required String Function(String) getParentDirectory,
    required String Function(List<String>) joinPaths,
  }) async {
    try {
      final entity = await FileSystemEntity.type(path);
      final parentDir = getParentDirectory(path);
      final newPath = joinPaths([parentDir, newName]);

      if (entity == FileSystemEntityType.file) {
        await File(path).rename(newPath);
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(path).rename(newPath);
      } else {
        return const domain.FileOperationResult(
          success: false,
          error: 'Path not found',
        );
      }

      return domain.FileOperationResult(
        success: true,
        path: newPath,
      );
    } catch (e) {
      debugPrint('❌ Error renaming: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Deleta arquivo ou diretório
  Future<domain.FileOperationResult> delete({
    required String path,
    bool recursive = false,
  }) async {
    try {
      final entity = await FileSystemEntity.type(path);

      if (entity == FileSystemEntityType.file) {
        await File(path).delete();
      } else if (entity == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: recursive);
      } else {
        return const domain.FileOperationResult(
          success: false,
          error: 'Path not found',
        );
      }

      return domain.FileOperationResult(
        success: true,
        path: path,
      );
    } catch (e) {
      debugPrint('❌ Error deleting: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Verifica se é arquivo
  Future<bool> isFile(String path) async {
    try {
      return FileSystemEntity.isFileSync(path);
    } catch (e) {
      return false;
    }
  }

  /// Verifica se é diretório
  Future<bool> isDirectory(String path) async {
    try {
      return FileSystemEntity.isDirectorySync(path);
    } catch (e) {
      return false;
    }
  }
}
