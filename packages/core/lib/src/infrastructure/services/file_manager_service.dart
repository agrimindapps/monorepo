import 'dart:async';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path_helper;
import 'package:path_provider/path_provider.dart' as path_provider;

import '../../domain/entities/file_entity.dart' as domain;
import '../../domain/repositories/i_file_repository.dart';

/// Implementação do serviço de gerenciamento de arquivos
class FileManagerService implements IFileRepository {
  static final FileManagerService _instance = FileManagerService._internal();
  /// Obtém a instância singleton do FileManagerService
  factory FileManagerService() => _instance;
  FileManagerService._internal();

  // static const MethodChannel _channel = MethodChannel('file_manager_service');
  // domain.CacheConfig? _cacheConfig;

  // ==========================================================================
  // OPERAÇÕES BÁSICAS DE ARQUIVO
  // ==========================================================================

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
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

  @override
  Future<domain.FileOperationResult> rename({
    required String path,
    required String newName,
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

  @override
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

  // ==========================================================================
  // NAVEGAÇÃO E BUSCA
  // ==========================================================================

  @override
  Future<List<domain.FileInfoEntity>> listDirectory({
    required String path,
    domain.FileFilter? filter,
    bool recursive = false,
  }) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) return [];

      final List<domain.FileInfoEntity> result = [];
      final entities = directory.listSync(recursive: recursive);

      for (final entity in entities) {
        final fileInfo = await getFileInfo(entity.path);
        if (fileInfo != null && _matchesFilter(fileInfo, filter)) {
          result.add(fileInfo);
        }
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error listing directory: $e');
      return [];
    }
  }

  @override
  Future<List<domain.FileInfoEntity>> searchFiles({
    required String searchPath,
    String? namePattern,
    domain.FileFilter? filter,
    bool recursive = true,
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

          // Verificar padrão do nome
          if (namePattern != null) {
            matches = matches && fileInfo.name.contains(namePattern);
          }

          // Verificar filtro
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

  @override
  String getParentDirectory(String path) {
    return path_helper.dirname(path);
  }

  @override
  String joinPaths(List<String> paths) {
    return path_helper.joinAll(paths);
  }

  @override
  String getFileName(String path) {
    return path_helper.basename(path);
  }

  @override
  String getFileExtension(String path) {
    return path_helper.extension(path);
  }

  @override
  String getFileNameWithoutExtension(String path) {
    return path_helper.basenameWithoutExtension(path);
  }

  // ==========================================================================
  // DIRETÓRIOS DO SISTEMA
  // ==========================================================================

  @override
  Future<String> getDocumentsDirectory() async {
    final directory = await path_provider.getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Future<String> getCacheDirectory() async {
    final directory = await path_provider.getTemporaryDirectory();
    return directory.path;
  }

  @override
  Future<String> getTemporaryDirectory() async {
    final directory = await path_provider.getTemporaryDirectory();
    return directory.path;
  }

  @override
  Future<String?> getDownloadsDirectory() async {
    try {
      final directory = await path_provider.getDownloadsDirectory();
      return directory?.path;
    } catch (e) {
      debugPrint('❌ Error getting downloads directory: $e');
      return null;
    }
  }

  @override
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

  @override
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

  // ==========================================================================
  // COMPRESSÃO E DESCOMPRESSÃO
  // ==========================================================================

  @override
  Future<domain.FileOperationResult> compress({
    required List<String> sourcePaths,
    required String destinationPath,
    domain.CompressionConfig? config,
  }) async {
    try {
      final archive = Archive();

      // Adicionar arquivos ao arquivo
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

      // Comprimir
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
          throw UnsupportedError('Compression type not supported: $compressionType');
      }

      // Salvar arquivo comprimido
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

  @override
  Future<domain.FileOperationResult> decompress({
    required String sourcePath,
    required String destinationPath,
    String? password,
  }) async {
    try {
      final file = File(sourcePath);
      final bytes = await file.readAsBytes();
      
      // Determinar tipo de arquivo pela extensão
      final extension = getFileExtension(sourcePath).toLowerCase();
      Archive? archive;

      switch (extension) {
        case '.zip':
          archive = ZipDecoder().decodeBytes(bytes, password: password);
          break;
        case '.gz':
          final decompressed = const GZipDecoder().decodeBytes(bytes);
          // Para arquivos gzip simples, criar um arquivo
          final outputPath = joinPaths([destinationPath, getFileNameWithoutExtension(sourcePath)]);
          await File(outputPath).writeAsBytes(decompressed);
          return domain.FileOperationResult(success: true, path: outputPath);
        default:
          throw UnsupportedError('Archive format not supported: $extension');
      }

      // Extrair arquivos
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

  @override
  Future<List<String>> listCompressedFiles(String archivePath) async {
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

  // ==========================================================================
  // CACHE E LIMPEZA
  // ==========================================================================

  @override
  Future<bool> configurateCache(domain.CacheConfig config) async {
    try {
      // _cacheConfig = config;
      return true;
    } catch (e) {
      debugPrint('❌ Error configuring cache: $e');
      return false;
    }
  }

  @override
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

  @override
  Future<int> getCacheSize({String? path}) async {
    try {
      final cacheDir = path ?? await getCacheDirectory();
      return await getDirectorySize(cacheDir);
    } catch (e) {
      debugPrint('❌ Error getting cache size: $e');
      return 0;
    }
  }

  @override
  Future<int> clearTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      return await clearCache(path: tempDir);
    } catch (e) {
      debugPrint('❌ Error clearing temporary files: $e');
      return 0;
    }
  }

  @override
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

  // ==========================================================================
  // UTILITÁRIOS
  // ==========================================================================

  @override
  Future<String> getMimeType(String path) async {
    try {
      return lookupMimeType(path) ?? 'application/octet-stream';
    } catch (e) {
      debugPrint('❌ Error getting mime type: $e');
      return 'application/octet-stream';
    }
  }

  @override
  Future<bool> isFile(String path) async {
    try {
      return FileSystemEntity.isFileSync(path);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isDirectory(String path) async {
    try {
      return FileSystemEntity.isDirectorySync(path);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<domain.FilePermissionsEntity?> getPermissions(String path) async {
    try {
      // Simulação básica de permissões - implementar lógica específica por plataforma
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

  @override
  Future<bool> setPermissions({
    required String path,
    required domain.FilePermissionsEntity permissions,
  }) async {
    try {
      // Implementar lógica específica por plataforma
      return true;
    } catch (e) {
      debugPrint('❌ Error setting permissions: $e');
      return false;
    }
  }

  @override
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

  @override
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

  // ==========================================================================
  // COMPARTILHAMENTO
  // ==========================================================================

  @override
  Future<bool> shareFiles({
    required List<String> filePaths,
    String? subject,
    String? text,
  }) async {
    try {
      // Implementar usando plugin de compartilhamento
      // Por enquanto, apenas log
      debugPrint('📤 Sharing files: $filePaths');
      return true;
    } catch (e) {
      debugPrint('❌ Error sharing files: $e');
      return false;
    }
  }

  @override
  Future<bool> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      // Implementar usando plugin de compartilhamento
      debugPrint('📤 Sharing text: $text');
      return true;
    } catch (e) {
      debugPrint('❌ Error sharing text: $e');
      return false;
    }
  }

  @override
  Future<bool> openFile(String path) async {
    try {
      // Implementar usando plugin de abertura de arquivos
      debugPrint('📂 Opening file: $path');
      return true;
    } catch (e) {
      debugPrint('❌ Error opening file: $e');
      return false;
    }
  }

  // ==========================================================================
  // BACKUP E RESTAURAÇÃO
  // ==========================================================================

  @override
  Future<domain.FileOperationResult> createBackup({
    required List<String> sourcePaths,
    required String backupPath,
    domain.BackupOptions? options,
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
      );
    } catch (e) {
      debugPrint('❌ Error creating backup: $e');
      return domain.FileOperationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<domain.FileOperationResult> restoreBackup({
    required String backupPath,
    required String destinationPath,
    String? password,
  }) async {
    return await decompress(
      sourcePath: backupPath,
      destinationPath: destinationPath,
      password: password,
    );
  }

  @override
  Future<bool> validateBackup(String backupPath) async {
    try {
      final files = await listCompressedFiles(backupPath);
      return files.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error validating backup: $e');
      return false;
    }
  }

  // ==========================================================================
  // MONITORAMENTO
  // ==========================================================================

  @override
  Stream<domain.FileInfoEntity> watchDirectory(String path) {
    final controller = StreamController<domain.FileInfoEntity>();
    
    // Implementar watcher de diretório
    // Por enquanto, retornar stream vazio
    controller.close();
    
    return controller.stream;
  }

  @override
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

  // ==========================================================================
  // MÉTODOS AUXILIARES PRIVADOS
  // ==========================================================================

  bool _matchesFilter(domain.FileInfoEntity fileInfo, domain.FileFilter? filter) {
    if (filter == null) return true;

    // Verificar extensões
    if (filter.extensions != null && filter.extensions!.isNotEmpty) {
      if (!filter.extensions!.contains(fileInfo.extension.toLowerCase())) {
        return false;
      }
    }

    // Verificar tipos MIME
    if (filter.mimeTypes != null && filter.mimeTypes!.isNotEmpty) {
      if (!filter.mimeTypes!.contains(fileInfo.mimeType)) {
        return false;
      }
    }

    // Verificar tamanho mínimo
    if (filter.minSize != null && fileInfo.size < filter.minSize!) {
      return false;
    }

    // Verificar tamanho máximo
    if (filter.maxSize != null && fileInfo.size > filter.maxSize!) {
      return false;
    }

    // Verificar data de modificação
    if (filter.modifiedAfter != null && fileInfo.lastModified.isBefore(filter.modifiedAfter!)) {
      return false;
    }

    if (filter.modifiedBefore != null && fileInfo.lastModified.isAfter(filter.modifiedBefore!)) {
      return false;
    }

    // Verificar arquivos ocultos
    if (!filter.includeHidden && fileInfo.isHidden) {
      return false;
    }

    // Verificar diretórios
    if (!filter.includeDirectories && fileInfo.isDirectory) {
      return false;
    }

    return true;
  }

  Future<void> _addDirectoryToArchive(Archive archive, String dirPath) async {
    final directory = Directory(dirPath);
    final entities = directory.listSync(recursive: true);

    for (final entity in entities) {
      if (entity is File) {
        final bytes = await entity.readAsBytes();
        final relativePath = path_helper.relative(entity.path, from: dirPath);
        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
      }
    }
  }
}