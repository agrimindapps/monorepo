import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:path_provider/path_provider.dart';

/// Gerenciador de arquivos de exportação
///
/// Responsabilidade: Gerenciar operações de I/O de arquivos de exportação
/// Aplica SRP (Single Responsibility Principle)
@LazySingleton()
class ExportFileManager {
  /// Salva dados de exportação em arquivo
  Future<String> saveExportFile(Uint8List data, String userId) async {
    try {
      final directory = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'gasometer_export_${userId}_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(data);

      return filePath;
    } catch (e) {
      throw Exception('Erro ao salvar arquivo de exportação: $e');
    }
  }

  /// Obtém diretório de exportação
  Future<Directory> getExportDirectory() async {
    return _getExportDirectory();
  }

  /// Calcula tamanho de arquivo em MB
  Future<int> getFileSizeMb(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.length();
      return (bytes / (1024 * 1024)).ceil();
    } catch (e) {
      throw Exception('Erro ao calcular tamanho do arquivo: $e');
    }
  }

  /// Limpa arquivos temporários antigos
  Future<void> cleanupTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final exportTempDir = Directory('${tempDir.path}/exports');

      if (await exportTempDir.exists()) {
        final files = await exportTempDir.list().toList();
        final now = DateTime.now();

        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            final age = now.difference(stat.modified);

            // Remove arquivos com mais de 1 hora
            if (age.inHours >= 1) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      SecureLogger.warning('Erro ao limpar arquivos temporários', error: e);
    }
  }

  /// Verifica se arquivo existe
  Future<bool> fileExists(String filePath) async {
    try {
      return File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Deleta arquivo de exportação
  Future<void> deleteExportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Erro ao deletar arquivo: $e');
    }
  }

  Future<Directory> _getExportDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${documentsDir.path}/exports');

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }
}
