import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Serviço para gerenciar assets remotos e reduzir tamanho do APK
/// 
/// Funcionalidades:
/// - Download de imagens sob demanda
/// - Cache persistente em disco
/// - Fallback para assets locais
/// - Compressão e otimização automática
/// - Sincronização em background
class RemoteAssetService {
  static final RemoteAssetService _instance = RemoteAssetService._internal();
  factory RemoteAssetService() => _instance;
  RemoteAssetService._internal();

  // Configurações
  static const String _configAssetPath = 'assets/remote_assets_config.json';
  static const Duration _cacheExpiration = Duration(hours: 24);
  static const int _maxConcurrentDownloads = 3;
  static const int _downloadTimeoutSeconds = 30;

  // State
  Map<String, dynamic>? _config;
  String? _cacheDirectory;
  final Map<String, Future<Uint8List?>> _downloadingAssets = {};
  final Set<String> _failedAssets = {};
  
  // Estatísticas
  int _downloadCount = 0;
  int _cacheHits = 0;
  int _downloadErrors = 0;
  int _totalBytesDownloaded = 0;

  /// Inicializa o serviço
  Future<void> initialize() async {
    await _loadConfig();
    await _initializeCacheDirectory();
    developer.log('RemoteAssetService initialized', name: 'RemoteAssetService');
  }

  /// Carrega configuração de assets remotos
  Future<void> _loadConfig() async {
    try {
      final String configJson = await rootBundle.loadString(_configAssetPath);
      _config = json.decode(configJson) as Map<String, dynamic>?;
      developer.log('Remote assets config loaded: ${_config?['assets']?.length ?? 0} assets', 
                   name: 'RemoteAssetService');
    } catch (e) {
      developer.log('Error loading remote assets config: $e', name: 'RemoteAssetService');
      _config = _getDefaultConfig();
    }
  }

  /// Configuração padrão quando arquivo não existe
  Map<String, dynamic> _getDefaultConfig() {
    return {
      'version': '1.0',
      'base_url': 'https://assets.receituagro.com/images/',
      'fallback_url': 'https://backup.receituagro.com/images/',
      'cache_duration_hours': 24,
      'critical_local_assets': ['a.jpg', 'Nao classificado.jpg'],
      'assets': []
    };
  }

  /// Inicializa diretório de cache
  Future<void> _initializeCacheDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = '${appDir.path}/remote_assets_cache';
    
    final Directory cacheDir = Directory(_cacheDirectory!);
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    // Limpa cache expirado
    await _cleanExpiredCache();
  }

  /// Obtém imagem (remota ou local)
  Future<Uint8List?> getImage(String imageName) async {
    if (_config == null) {
      await initialize();
    }

    // Verifica se é asset crítico (deve ficar local)
    final criticalAssets = List<String>.from(_config?['critical_local_assets'] as Iterable<dynamic>? ?? []);
    if (criticalAssets.contains(imageName)) {
      return await _getLocalAsset(imageName);
    }

    // Tenta cache primeiro
    final cachedData = await _getCachedAsset(imageName);
    if (cachedData != null) {
      _cacheHits++;
      return cachedData;
    }

    // Download remoto
    return await _downloadAsset(imageName);
  }

  /// Obtém asset local
  Future<Uint8List?> _getLocalAsset(String imageName) async {
    try {
      // Tenta WebP primeiro, depois JPG
      String assetPath = 'assets/imagens/bigsize/${imageName.replaceAll('.jpg', '.webp')}';
      
      try {
        final ByteData data = await rootBundle.load(assetPath);
        return data.buffer.asUint8List();
      } catch (e) {
        // Fallback para JPG
        assetPath = 'assets/imagens/bigsize/$imageName';
        final ByteData data = await rootBundle.load(assetPath);
        return data.buffer.asUint8List();
      }
    } catch (e) {
      developer.log('Error loading local asset $imageName: $e', name: 'RemoteAssetService');
      return null;
    }
  }

  /// Obtém asset do cache
  Future<Uint8List?> _getCachedAsset(String imageName) async {
    if (_cacheDirectory == null) return null;

    try {
      final String fileName = _getCacheFileName(imageName);
      final File cacheFile = File('$_cacheDirectory/$fileName');
      
      if (!await cacheFile.exists()) return null;

      // Verifica se cache não expirou
      final FileStat stat = await cacheFile.stat();
      final DateTime modified = stat.modified;
      if (DateTime.now().difference(modified) > _cacheExpiration) {
        await cacheFile.delete();
        return null;
      }

      return await cacheFile.readAsBytes();
    } catch (e) {
      developer.log('Error reading cached asset $imageName: $e', name: 'RemoteAssetService');
      return null;
    }
  }

  /// Faz download do asset remoto
  Future<Uint8List?> _downloadAsset(String imageName) async {
    // Evita downloads duplicados
    if (_downloadingAssets.containsKey(imageName)) {
      return await _downloadingAssets[imageName];
    }

    // Verifica se já falhou anteriormente
    if (_failedAssets.contains(imageName)) {
      return await _getLocalAsset(imageName); // Fallback
    }

    // Inicia download
    final downloadFuture = _performDownload(imageName);
    _downloadingAssets[imageName] = downloadFuture;

    try {
      final result = await downloadFuture;
      _downloadingAssets.remove(imageName);
      return result;
    } catch (e) {
      _downloadingAssets.remove(imageName);
      _failedAssets.add(imageName);
      developer.log('Download failed for $imageName: $e', name: 'RemoteAssetService');
      return await _getLocalAsset(imageName); // Fallback
    }
  }

  /// Realiza o download efetivo
  Future<Uint8List?> _performDownload(String imageName) async {
    final String baseUrl = _config?['base_url'] as String? ?? '';
    final String fallbackUrl = _config?['fallback_url'] as String? ?? '';
    
    // Converte nome para WebP se necessário
    final String remoteImageName = imageName.replaceAll('.jpg', '.webp');
    
    // Tenta URL principal primeiro
    Uint8List? data = await _downloadFromUrl('$baseUrl$remoteImageName');
    
    // Fallback URL se principal falhar
    if (data == null && fallbackUrl.isNotEmpty) {
      data = await _downloadFromUrl('$fallbackUrl$remoteImageName');
    }

    if (data != null) {
      await _cacheAsset(imageName, data);
      _downloadCount++;
      _totalBytesDownloaded += data.length;
      
      developer.log('Downloaded $imageName: ${data.length} bytes', 
                   name: 'RemoteAssetService');
    }

    return data;
  }

  /// Download de uma URL específica
  Future<Uint8List?> _downloadFromUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'ReceitaAgro-App/1.0',
          'Accept': 'image/webp,image/jpeg,image/*,*/*;q=0.8',
        },
      ).timeout(const Duration(seconds: _downloadTimeoutSeconds));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        developer.log('HTTP ${response.statusCode} for $url', name: 'RemoteAssetService');
        return null;
      }
    } catch (e) {
      _downloadErrors++;
      developer.log('Error downloading from $url: $e', name: 'RemoteAssetService');
      return null;
    }
  }

  /// Salva asset no cache
  Future<void> _cacheAsset(String imageName, Uint8List data) async {
    if (_cacheDirectory == null) return;

    try {
      final String fileName = _getCacheFileName(imageName);
      final File cacheFile = File('$_cacheDirectory/$fileName');
      await cacheFile.writeAsBytes(data);
    } catch (e) {
      developer.log('Error caching asset $imageName: $e', name: 'RemoteAssetService');
    }
  }

  /// Gera nome do arquivo de cache
  String _getCacheFileName(String imageName) {
    // Remove caracteres problemáticos e adiciona hash para evitar conflitos
    final cleanName = imageName.replaceAll(RegExp(r'[^\w\.]'), '_');
    return '${cleanName.hashCode.abs()}_$cleanName';
  }

  /// Remove cache expirado
  Future<void> _cleanExpiredCache() async {
    if (_cacheDirectory == null) return;

    try {
      final Directory cacheDir = Directory(_cacheDirectory!);
      final List<FileSystemEntity> files = await cacheDir.list().toList();
      
      int deletedFiles = 0;
      for (final file in files) {
        if (file is File) {
          final FileStat stat = await file.stat();
          if (DateTime.now().difference(stat.modified) > _cacheExpiration) {
            await file.delete();
            deletedFiles++;
          }
        }
      }
      
      if (deletedFiles > 0) {
        developer.log('Cleaned $deletedFiles expired cache files', 
                     name: 'RemoteAssetService');
      }
    } catch (e) {
      developer.log('Error cleaning cache: $e', name: 'RemoteAssetService');
    }
  }

  /// Pré-carrega assets importantes
  Future<void> preloadCriticalAssets() async {
    final criticalAssets = List<String>.from(_config?['critical_local_assets'] as Iterable<dynamic>? ?? []);
    
    final futures = criticalAssets.map((asset) => getImage(asset));
    await Future.wait(futures);
    
    developer.log('Preloaded ${criticalAssets.length} critical assets', 
                 name: 'RemoteAssetService');
  }

  /// Sincroniza assets em background
  Future<void> syncAssetsInBackground() async {
    if (_config == null) return;
    
    final assets = List<Map<String, dynamic>>.from(_config?['assets'] as Iterable<dynamic>? ?? []);
    if (assets.isEmpty) return;

    // Processa em lotes para não sobrecarregar
    const batchSize = 5;
    for (int i = 0; i < assets.length; i += batchSize) {
      final batch = assets.skip(i).take(batchSize);
      final futures = batch.map((asset) => getImage(asset['local_name'] as String));
      
      try {
        await Future.wait(futures, eagerError: false);
      } catch (e) {
        developer.log('Error in background sync batch: $e', name: 'RemoteAssetService');
      }
      
      // Pequena pausa entre lotes
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    developer.log('Background sync completed', name: 'RemoteAssetService');
  }

  /// Limpa todo o cache
  Future<void> clearCache() async {
    if (_cacheDirectory == null) return;

    try {
      final Directory cacheDir = Directory(_cacheDirectory!);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create(recursive: true);
      }
      
      _failedAssets.clear();
      developer.log('Cache cleared', name: 'RemoteAssetService');
    } catch (e) {
      developer.log('Error clearing cache: $e', name: 'RemoteAssetService');
    }
  }

  /// Verifica se asset está disponível localmente
  bool isAssetLocal(String imageName) {
    final criticalAssets = List<String>.from(_config?['critical_local_assets'] as Iterable<dynamic>? ?? []);
    return criticalAssets.contains(imageName);
  }

  /// Obtém estatísticas do serviço
  Map<String, dynamic> getStats() {
    final cacheDir = _cacheDirectory != null ? Directory(_cacheDirectory!) : null;
    
    return {
      'downloads': _downloadCount,
      'cacheHits': _cacheHits,
      'downloadErrors': _downloadErrors,
      'totalBytesDownloaded': _totalBytesDownloaded,
      'totalBytesDownloadedMB': (_totalBytesDownloaded / (1024 * 1024)).toStringAsFixed(2),
      'failedAssets': _failedAssets.length,
      'cacheDirectory': _cacheDirectory ?? 'Not initialized',
      'configLoaded': _config != null,
      'totalRemoteAssets': _config?['assets']?.length ?? 0,
      'criticalLocalAssets': _config?['critical_local_assets']?.length ?? 0,
    };
  }

  /// Obtém informações de cache
  Future<Map<String, dynamic>> getCacheInfo() async {
    if (_cacheDirectory == null) {
      return {'error': 'Cache not initialized'};
    }

    try {
      final Directory cacheDir = Directory(_cacheDirectory!);
      if (!await cacheDir.exists()) {
        return {'files': 0, 'totalSize': 0, 'totalSizeMB': '0.0'};
      }

      final List<FileSystemEntity> files = await cacheDir.list().toList();
      int totalSize = 0;
      int fileCount = 0;

      for (final file in files) {
        if (file is File) {
          final stat = await file.stat();
          totalSize += stat.size;
          fileCount++;
        }
      }

      return {
        'files': fileCount,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'directory': _cacheDirectory,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}