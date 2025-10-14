import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/file_entity.dart' as domain;

/// Serviço especializado em compressão e descompressão de arquivos
///
/// Responsabilidades:
/// - Comprimir arquivos e diretórios (ZIP, GZIP)
/// - Descomprimir arquivos
/// - Listar conteúdo de arquivos comprimidos
/// - Criar e restaurar backups
class FileCompressionService {
  /// Comprime arquivos/diretórios
  Future<domain.FileOperationResult> compress({
    required List<String> sourcePaths,
    required String destinationPath,
    domain.CompressionConfig? config,
    required Future<bool> Function(String) isFile,
    required Future<bool> Function(String) isDirectory,
    required String Function(String) getFileName,
  }) async {
    try {
      final archive = Archive();

      for (String sourcePath in sourcePaths) {
        if (await isFile(sourcePath)) {
          final file = File(sourcePath);
          final bytes = await file.readAsBytes();
          final fileName = getFileName(sourcePath);
          archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
        } else if (await isDirectory(sourcePath)) {
          await _addDirectoryToArchive(archive, sourcePath);
        }
      }

      late List<int> compressedData;
      final compressionType = config?.type ?? domain.CompressionType.zip;

      switch (compressionType) {
        case domain.CompressionType.zip:
          final encoder = ZipEncoder();
          compressedData = encoder.encode(archive);
          break;
        case domain.CompressionType.gzip:
          const encoder = GZipEncoder();
          compressedData = encoder.encode(archive.files.first.content as List<int>);
          break;
        default:
          throw UnsupportedError('Compression type not supported: $compressionType. Supported types: zip, gzip');
      }

      final outputFile = File(destinationPath);
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsBytes(compressedData);

      return domain.FileOperationResult(
        success: true,
        path: destinationPath,
      );
    } catch (e) {
      debugPrint('❌ Error compressing files: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Descomprime arquivo
  Future<domain.FileOperationResult> decompress({
    required String sourcePath,
    required String destinationPath,
    String? password,
    required String Function(String) getFileExtension,
    required String Function(List<String>) joinPaths,
    required String Function(String) getFileNameWithoutExtension,
  }) async {
    try {
      final file = File(sourcePath);
      final bytes = await file.readAsBytes();
      final extension = getFileExtension(sourcePath).toLowerCase();
      Archive? archive;

      switch (extension) {
        case '.zip':
          archive = ZipDecoder().decodeBytes(bytes, password: password);
          break;
        case '.gz':
          final decompressed = const GZipDecoder().decodeBytes(bytes);
          final outputPath = joinPaths([destinationPath, getFileNameWithoutExtension(sourcePath)]);
          await File(outputPath).writeAsBytes(decompressed);
          return domain.FileOperationResult(success: true, path: outputPath);
        default:
          throw UnsupportedError('Archive format not supported: $extension. Supported formats: .zip, .gz');
      }

      if (archive.isNotEmpty) {
        await Directory(destinationPath).create(recursive: true);

        for (final file in archive.files) {
          final filePath = joinPaths([destinationPath, file.name]);

          if (file.isFile) {
            final outputFile = File(filePath);
            await outputFile.parent.create(recursive: true);
            await outputFile.writeAsBytes(file.content as List<int>);
          }
        }
      }

      return domain.FileOperationResult(
        success: true,
        path: destinationPath,
      );
    } catch (e) {
      debugPrint('❌ Error decompressing file: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Lista arquivos em um arquivo comprimido
  Future<List<String>> listCompressedFiles({
    required String archivePath,
    required String Function(String) getFileExtension,
  }) async {
    try {
      final file = File(archivePath);
      final bytes = await file.readAsBytes();

      final extension = getFileExtension(archivePath).toLowerCase();
      Archive? archive;

      switch (extension) {
        case '.zip':
          archive = ZipDecoder().decodeBytes(bytes);
          break;
        default:
          return [];
      }

      if (archive.isNotEmpty) {
        return archive.files.where((f) => f.isFile).map((f) => f.name).toList();
      }

      return [];
    } catch (e) {
      debugPrint('❌ Error listing compressed files: $e');
      return [];
    }
  }

  /// Cria backup comprimido
  Future<domain.FileOperationResult> createBackup({
    required List<String> sourcePaths,
    required String backupPath,
    domain.BackupOptions? options,
    required Future<bool> Function(String) isFile,
    required Future<bool> Function(String) isDirectory,
    required String Function(String) getFileName,
  }) async {
    try {
      final config = domain.CompressionConfig(
        type: domain.CompressionType.zip,
        password: options?.encryptionPassword,
      );

      return await compress(
        sourcePaths: sourcePaths,
        destinationPath: backupPath,
        config: config,
        isFile: isFile,
        isDirectory: isDirectory,
        getFileName: getFileName,
      );
    } catch (e) {
      debugPrint('❌ Error creating backup: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Restaura backup
  Future<domain.FileOperationResult> restoreBackup({
    required String backupPath,
    required String destinationPath,
    String? password,
    required String Function(String) getFileExtension,
    required String Function(List<String>) joinPaths,
    required String Function(String) getFileNameWithoutExtension,
  }) async {
    return await decompress(
      sourcePath: backupPath,
      destinationPath: destinationPath,
      password: password,
      getFileExtension: getFileExtension,
      joinPaths: joinPaths,
      getFileNameWithoutExtension: getFileNameWithoutExtension,
    );
  }

  /// Valida backup
  Future<bool> validateBackup({
    required String backupPath,
    required String Function(String) getFileExtension,
  }) async {
    try {
      final files = await listCompressedFiles(
        archivePath: backupPath,
        getFileExtension: getFileExtension,
      );
      return files.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error validating backup: $e');
      return false;
    }
  }

  /// Helper privado: Adiciona diretório ao archive
  Future<void> _addDirectoryToArchive(Archive archive, String dirPath) async {
    final directory = Directory(dirPath);
    final entities = directory.listSync(recursive: true);

    for (final entity in entities) {
      if (entity is File) {
        final bytes = await entity.readAsBytes();
        final relativePath = entity.path.substring(dirPath.length + 1);
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      }
    }
  }
}
