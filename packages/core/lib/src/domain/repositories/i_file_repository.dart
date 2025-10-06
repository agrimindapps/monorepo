import 'dart:typed_data';
import '../entities/file_entity.dart';

/// Interface para operações de gerenciamento de arquivos
abstract class IFileRepository {

  /// Verificar se um arquivo ou diretório existe
  Future<bool> exists(String path);

  /// Obter informações sobre um arquivo ou diretório
  Future<FileInfoEntity?> getFileInfo(String path);

  /// Criar um arquivo
  Future<FileOperationResult> createFile({
    required String path,
    String? content,
    Uint8List? bytes,
    bool recursive = true,
  });

  /// Criar um diretório
  Future<FileOperationResult> createDirectory({
    required String path,
    bool recursive = true,
  });

  /// Ler conteúdo de um arquivo como texto
  Future<String?> readAsString(String path);

  /// Ler conteúdo de um arquivo como bytes
  Future<Uint8List?> readAsBytes(String path);

  /// Escrever texto em um arquivo
  Future<FileOperationResult> writeAsString({
    required String path,
    required String content,
    bool append = false,
  });

  /// Escrever bytes em um arquivo
  Future<FileOperationResult> writeAsBytes({
    required String path,
    required Uint8List bytes,
    bool append = false,
  });

  /// Copiar um arquivo ou diretório
  Future<FileOperationResult> copy({
    required String sourcePath,
    required String destinationPath,
    bool overwrite = false,
  });

  /// Mover um arquivo ou diretório
  Future<FileOperationResult> move({
    required String sourcePath,
    required String destinationPath,
    bool overwrite = false,
  });

  /// Renomear um arquivo ou diretório
  Future<FileOperationResult> rename({
    required String path,
    required String newName,
  });

  /// Deletar um arquivo ou diretório
  Future<FileOperationResult> delete({
    required String path,
    bool recursive = false,
  });

  /// Listar conteúdo de um diretório
  Future<List<FileInfoEntity>> listDirectory({
    required String path,
    FileFilter? filter,
    bool recursive = false,
  });

  /// Buscar arquivos por padrão
  Future<List<FileInfoEntity>> searchFiles({
    required String searchPath,
    String? namePattern,
    FileFilter? filter,
    bool recursive = true,
  });

  /// Obter o diretório pai de um caminho
  String getParentDirectory(String path);

  /// Combinar caminhos
  String joinPaths(List<String> paths);

  /// Obter nome do arquivo (sem caminho)
  String getFileName(String path);

  /// Obter extensão do arquivo
  String getFileExtension(String path);

  /// Obter nome do arquivo sem extensão
  String getFileNameWithoutExtension(String path);

  /// Obter caminho do diretório de documentos
  Future<String> getDocumentsDirectory();

  /// Obter caminho do diretório de cache
  Future<String> getCacheDirectory();

  /// Obter caminho do diretório temporário
  Future<String> getTemporaryDirectory();

  /// Obter caminho do diretório de downloads
  Future<String?> getDownloadsDirectory();

  /// Obter caminho do diretório externo (Android)
  Future<String?> getExternalStorageDirectory();

  /// Obter caminho de diretório específico
  Future<String?> getSystemDirectory(SystemDirectory type);

  /// Comprimir arquivos/diretórios
  Future<FileOperationResult> compress({
    required List<String> sourcePaths,
    required String destinationPath,
    CompressionConfig? config,
  });

  /// Descomprimir arquivo
  Future<FileOperationResult> decompress({
    required String sourcePath,
    required String destinationPath,
    String? password,
  });

  /// Obter lista de arquivos em um arquivo comprimido
  Future<List<String>> listCompressedFiles(String archivePath);

  /// Configurar cache de arquivos
  Future<bool> configurateCache(CacheConfig config);

  /// Limpar cache de arquivos
  Future<int> clearCache({String? path});

  /// Obter tamanho do cache
  Future<int> getCacheSize({String? path});

  /// Limpar arquivos temporários
  Future<int> clearTemporaryFiles();

  /// Obter tamanho total de um diretório
  Future<int> getDirectorySize(String path);

  /// Obter tipo MIME de um arquivo
  Future<String> getMimeType(String path);

  /// Verificar se um caminho é um arquivo
  Future<bool> isFile(String path);

  /// Verificar se um caminho é um diretório
  Future<bool> isDirectory(String path);

  /// Obter permissões de um arquivo
  Future<FilePermissionsEntity?> getPermissions(String path);

  /// Definir permissões de um arquivo
  Future<bool> setPermissions({
    required String path,
    required FilePermissionsEntity permissions,
  });

  /// Calcular hash de um arquivo
  Future<String> calculateFileHash({
    required String path,
    String algorithm = 'sha256',
  });

  /// Comparar dois arquivos
  Future<bool> compareFiles({
    required String path1,
    required String path2,
  });

  /// Compartilhar arquivo(s)
  Future<bool> shareFiles({
    required List<String> filePaths,
    String? subject,
    String? text,
  });

  /// Compartilhar texto
  Future<bool> shareText({
    required String text,
    String? subject,
  });

  /// Abrir arquivo com aplicativo padrão
  Future<bool> openFile(String path);

  /// Criar backup de arquivos
  Future<FileOperationResult> createBackup({
    required List<String> sourcePaths,
    required String backupPath,
    BackupOptions? options,
  });

  /// Restaurar backup
  Future<FileOperationResult> restoreBackup({
    required String backupPath,
    required String destinationPath,
    String? password,
  });

  /// Validar integridade do backup
  Future<bool> validateBackup(String backupPath);

  /// Monitorar mudanças em um diretório
  Stream<FileInfoEntity> watchDirectory(String path);

  /// Obter estatísticas de uso de armazenamento
  Future<Map<String, int>> getStorageStats();
}