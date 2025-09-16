import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class FileService {
  Future<bool> saveFile(String content, String fileName);
  Future<String> getDownloadsDirectory();
  Future<bool> requestStoragePermission();
}

class FileServiceImpl implements FileService {
  @override
  Future<bool> saveFile(String content, String fileName) async {
    try {
      // Solicitar permissão de armazenamento
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        return false;
      }

      // Obter diretório de downloads
      final downloadsPath = await getDownloadsDirectory();
      final file = File('$downloadsPath/$fileName');

      // Escrever arquivo
      await file.writeAsString(content);
      return true;
    } catch (e) {
      print('Erro ao salvar arquivo: $e');
      return false;
    }
  }

  @override
  Future<String> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // No Android, usar o diretório de downloads público
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory.path;
      }
      // Fallback para diretório externo
      final externalDir = await getExternalStorageDirectory();
      return externalDir?.path ?? '';
    } else if (Platform.isIOS) {
      // No iOS, usar o diretório de documentos da aplicação
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }

    // Fallback para outros platforms
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  @override
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status != PermissionStatus.granted) {
        // Tentar permission mais específica para Android 11+
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus == PermissionStatus.granted;
      }
      return true;
    }

    // No iOS, não precisamos de permissão específica para escrever
    // no diretório de documentos da aplicação
    return true;
  }
}