// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço centralizado para gerenciar uploads de arquivos no Supabase Storage
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _supabase = Supabase.instance.client;

  /// Upload de arquivo único
  ///
  /// [bucket] - Nome do bucket (ex: 'agri-bovinos', 'agri-implementos')
  /// [file] - Arquivo a ser enviado
  /// [folder] - Pasta dentro do bucket (ex: 'bovinos', 'implementos')
  /// [customName] - Nome personalizado (opcional)
  Future<String?> uploadFile({
    required String bucket,
    required File file,
    required String folder,
    String? customName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = customName ?? '${timestamp}_${file.hashCode}.$extension';
      final path = '$folder/$fileName';

      final response = await _supabase.storage.from(bucket).upload(path, file);

      if (response.isNotEmpty) {
        return _supabase.storage.from(bucket).getPublicUrl(path);
      }

      return null;
    } catch (e) {
      debugPrint('Erro no upload: $e');
      return null;
    }
  }

  /// Upload de múltiplos arquivos
  ///
  /// [bucket] - Nome do bucket
  /// [files] - Lista de arquivos
  /// [folder] - Pasta dentro do bucket
  Future<List<String>> uploadMultipleFiles({
    required String bucket,
    required List<File> files,
    required String folder,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < files.length; i++) {
      final url = await uploadFile(
        bucket: bucket,
        file: files[i],
        folder: folder,
        customName: '${DateTime.now().millisecondsSinceEpoch}_$i',
      );

      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  /// Deletar arquivo
  ///
  /// [bucket] - Nome do bucket
  /// [path] - Caminho completo do arquivo
  Future<bool> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);

      return true;
    } catch (e) {
      debugPrint('Erro ao deletar arquivo: $e');
      return false;
    }
  }

  /// Deletar múltiplos arquivos
  ///
  /// [bucket] - Nome do bucket
  /// [paths] - Lista de caminhos dos arquivos
  Future<bool> deleteMultipleFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove(paths);

      return true;
    } catch (e) {
      debugPrint('Erro ao deletar arquivos: $e');
      return false;
    }
  }

  /// Extrair path do arquivo a partir da URL
  ///
  /// [url] - URL pública do arquivo
  /// Retorna o path relativo para uso em operações de delete
  String? extractPathFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;

      // Remove os primeiros segmentos que são da estrutura do Supabase
      // Formato: /storage/v1/object/public/[bucket]/[path]
      if (segments.length >= 5 && segments[0] == 'storage') {
        return segments.skip(4).join('/');
      }

      return null;
    } catch (e) {
      debugPrint('Erro ao extrair path da URL: $e');
      return null;
    }
  }

  /// Verificar se arquivo existe
  ///
  /// [bucket] - Nome do bucket
  /// [path] - Caminho do arquivo
  Future<bool> fileExists({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).download(path);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obter informações do arquivo
  ///
  /// [bucket] - Nome do bucket
  /// [path] - Caminho do arquivo
  Future<FileObject?> getFileInfo({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await _supabase.storage.from(bucket).list(
          path: path.split('/').take(path.split('/').length - 1).join('/'));

      final fileName = path.split('/').last;
      return response.cast<FileObject?>().firstWhere(
            (file) => file?.name == fileName,
            orElse: () => null,
          );
    } catch (e) {
      debugPrint('Erro ao obter informações do arquivo: $e');
      return null;
    }
  }

  /// Listar arquivos em uma pasta
  ///
  /// [bucket] - Nome do bucket
  /// [folder] - Pasta a ser listada
  Future<List<FileObject>> listFiles({
    required String bucket,
    required String folder,
  }) async {
    try {
      return await _supabase.storage.from(bucket).list(path: folder);
    } catch (e) {
      debugPrint('Erro ao listar arquivos: $e');
      return [];
    }
  }
}

/// Classe de constantes para buckets do Supabase Storage
class StorageBuckets {
  static const String bovinos = 'agri-bovinos';
  static const String implementos = 'agri-implementos';
  static const String equinos = 'agri-equinos';
  static const String bulas = 'agri-bulas';
}

/// Classe de constantes para pastas dentro dos buckets
class StorageFolders {
  static const String bovinos = 'bovinos';
  static const String miniaturas = 'miniaturas';
  static const String implementos = 'implementos';
  static const String equinos = 'equinos';
  static const String bulas = 'bulas';
  static const String documentos = 'documentos';
}
