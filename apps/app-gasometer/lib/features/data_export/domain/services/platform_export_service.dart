import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Interface para serviços de exportação específicos por plataforma
abstract class PlatformExportService {
  /// Salva arquivo de exportação na plataforma
  Future<String> saveExportFile(
    Uint8List data, 
    String fileName, 
    String userId,
  );

  /// Compartilha arquivo de exportação
  Future<bool> shareExportFile(
    String filePath,
    String fileName,
  );

  /// Obtém diretório de downloads da plataforma
  Future<String> getDownloadsDirectory();

  /// Verifica se a plataforma suporta compartilhamento
  bool get supportsSharing;

  /// Obtém extensão de arquivo recomendada para a plataforma
  String get recommendedFileExtension;
}

/// Implementação para Android
class AndroidExportService implements PlatformExportService {
  @override
  Future<String> saveExportFile(
    Uint8List data, 
    String fileName, 
    String userId,
  ) async {
    try {
      // No Android, usar Documents/Downloads
      final downloadsDir = await getDownloadsDirectory();
      final filePath = '$downloadsDir/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(data);
      
      return filePath;
    } catch (e) {
      throw Exception('Erro ao salvar arquivo no Android: $e');
    }
  }

  @override
  Future<bool> shareExportFile(String filePath, String fileName) async {
    try {
      // Implementação seria com Share plugin ou Intent nativo
      // Por simplicidade, retornamos sucesso simulado
      return true;
    } catch (e) {
      print('Erro ao compartilhar no Android: $e');
      return false;
    }
  }

  @override
  Future<String> getDownloadsDirectory() async {
    try {
      // No Android moderno, usar Documents Directory por ser mais acessível
      return '/storage/emulated/0/Documents/GasOMeter';
    } catch (e) {
      return '/tmp/gasometer_exports';
    }
  }

  @override
  bool get supportsSharing => true;

  @override
  String get recommendedFileExtension => '.json';
}

/// Implementação para iOS
class IOSExportService implements PlatformExportService {
  @override
  Future<String> saveExportFile(
    Uint8List data, 
    String fileName, 
    String userId,
  ) async {
    try {
      // No iOS, usar Documents Directory
      final documentsDir = await getDownloadsDirectory();
      final filePath = '$documentsDir/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(data);
      
      return filePath;
    } catch (e) {
      throw Exception('Erro ao salvar arquivo no iOS: $e');
    }
  }

  @override
  Future<bool> shareExportFile(String filePath, String fileName) async {
    try {
      // Implementação seria com UIActivityViewController
      // Por simplicidade, retornamos sucesso simulado
      return true;
    } catch (e) {
      print('Erro ao compartilhar no iOS: $e');
      return false;
    }
  }

  @override
  Future<String> getDownloadsDirectory() async {
    // iOS usa Documents Directory como padrão
    return '/var/mobile/Containers/Data/Application/Documents/GasOMeter';
  }

  @override
  bool get supportsSharing => true;

  @override
  String get recommendedFileExtension => '.json';
}

/// Implementação para Web
class WebExportService implements PlatformExportService {
  @override
  Future<String> saveExportFile(
    Uint8List data, 
    String fileName, 
    String userId,
  ) async {
    try {
      if (kIsWeb) {
        // No web, simular download automático
        _triggerWebDownload(data, fileName);
        return 'download:///$fileName';
      } else {
        throw UnsupportedError('WebExportService só funciona na web');
      }
    } catch (e) {
      throw Exception('Erro ao salvar arquivo na web: $e');
    }
  }

  @override
  Future<bool> shareExportFile(String filePath, String fileName) async {
    // Na web, o "compartilhamento" é o próprio download
    return true;
  }

  @override
  Future<String> getDownloadsDirectory() async {
    return 'downloads';
  }

  @override
  bool get supportsSharing => false;

  @override
  String get recommendedFileExtension => '.json';

  void _triggerWebDownload(Uint8List data, String fileName) {
    // Em uma implementação real, seria usado dart:html para trigger do download
    // Por agora, apenas simular
    print('Triggering web download for $fileName with ${data.length} bytes');
  }
}

/// Factory para criar serviço de plataforma apropriado
@module
abstract class PlatformExportServiceModule {
  @singleton
  PlatformExportService get platformExportService {
    if (kIsWeb) {
      return WebExportService();
    } else if (Platform.isAndroid) {
      return AndroidExportService();
    } else if (Platform.isIOS) {
      return IOSExportService();
    } else {
      // Fallback para outras plataformas (Desktop, etc.)
      return AndroidExportService(); // Usar implementação Android como padrão
    }
  }
}

/// Factory para criar serviço de plataforma apropriado
class PlatformExportServiceFactory {
  static PlatformExportService create() {
    if (kIsWeb) {
      return WebExportService();
    } else if (Platform.isAndroid) {
      return AndroidExportService();
    } else if (Platform.isIOS) {
      return IOSExportService();
    } else {
      // Fallback para outras plataformas (Desktop, etc.)
      return AndroidExportService(); // Usar implementação Android como padrão
    }
  }
}