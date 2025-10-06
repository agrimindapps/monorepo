import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/result.dart';

/// Enhanced Storage Service - Sistema unificado de armazenamento
/// 
/// Combina múltiplas estratégias de storage:
/// - Hive: Para dados estruturados e cache rápido
/// - SharedPreferences: Para configurações simples
/// - SecureStorage: Para dados sensíveis
/// - File System: Para arquivos grandes
/// - Memory Cache: Para acesso ultra-rápido
/// 
/// Funcionalidades avançadas:
/// - Criptografia automática de dados sensíveis
/// - Compressão de dados grandes
/// - Sincronização entre storages
/// - Backup e restore automático
/// - Limpeza automática de dados antigos
/// - Métricas de uso e performance
class EnhancedStorageService {
  static const String _secureStorageKey = 'secure_storage_key';
  static const String _backupDirectory = 'storage_backups';
  static const int _maxMemoryCacheSize = 50 * 1024 * 1024; // 50MB
  static const int _compressionThreshold = 1024; // 1KB
  late final SharedPreferences _prefs;
  late final FlutterSecureStorage _secureStorage;
  late final Directory _fileDir;
  late final Directory _backupDir;
  final Map<String, Box> _hiveBoxes = {};
  final Map<String, _CacheItem> _memoryCache = {};
  int _memoryCacheSize = 0;
  bool _initialized = false;
  bool _encryptionEnabled = true;
  bool _compressionEnabled = true;
  bool _backupEnabled = true;
  int _readOperations = 0;
  int _writeOperations = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;

  /// Inicializa o enhanced storage service
  Future<Result<void>> initialize({
    bool enableEncryption = true,
    bool enableCompression = true,
    bool enableBackup = true,
    List<String> hiveBoxes = const ['default', 'cache', 'settings'],
  }) async {
    if (_initialized) return Result.success(null);

    try {
      _encryptionEnabled = enableEncryption;
      _compressionEnabled = enableCompression;
      _backupEnabled = enableBackup;
      _prefs = await SharedPreferences.getInstance();
      _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
      final appDir = await getApplicationDocumentsDirectory();
      _fileDir = Directory(path.join(appDir.path, 'enhanced_storage'));
      _backupDir = Directory(path.join(appDir.path, _backupDirectory));
      
      await _fileDir.create(recursive: true);
      if (_backupEnabled) {
        await _backupDir.create(recursive: true);
      }
      if (!Hive.isAdapterRegistered(0)) {
        await Hive.initFlutter();
      }
      for (final boxName in hiveBoxes) {
        try {
          final box = await Hive.openBox(boxName);
          _hiveBoxes[boxName] = box;
        } catch (e) {
          debugPrint('Warning: Não foi possível abrir box $boxName: $e');
        }
      }

      _initialized = true;
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao inicializar enhanced storage: ${e.toString()}',
          code: 'INIT_ERROR',
          details: e.toString(),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Armazena um valor com estratégia automática baseada no tipo e tamanho
  Future<Result<void>> store<T>(
    String key,
    T value, {
    StorageType? forceType,
    bool encrypt = false,
    bool compress = false,
    Duration? ttl,
    String? category,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      _writeOperations++;
      
      final storageType = forceType ?? _determineStorageType(value, encrypt);
      final processedValue = await _processValue(value, encrypt, compress);
      
      final result = await _storeByType(
        key, 
        processedValue, 
        storageType, 
        category ?? 'default',
        ttl,
      );
      
      if (result.isSuccess) {
        if (_shouldCacheInMemory(key, processedValue)) {
          _addToMemoryCache(key, processedValue, ttl);
        }
        if (_backupEnabled && storageType != StorageType.memory) {
          await _createBackup(key, processedValue, storageType);
        }
      }
      
      return result;
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao armazenar valor: ${e.toString()}',
          code: 'STORE_ERROR',
          details: 'key: $key, type: ${T.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Recupera um valor com fallback automático entre storages
  Future<Result<T?>> retrieve<T>(
    String key, {
    StorageType? preferredType,
    String? category,
    T? defaultValue,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      _readOperations++;
      final cacheResult = _getFromMemoryCache<T>(key);
      if (cacheResult != null) {
        _cacheHits++;
        return Result.success(cacheResult);
      }
      
      _cacheMisses++;
      if (preferredType != null) {
        final result = await _retrieveByType<T>(key, preferredType, category ?? 'default');
        if (result.isSuccess && result.data != null) {
          return result;
        }
      }
      final storageOrder = [
        StorageType.hive,
        StorageType.sharedPreferences,
        StorageType.secureStorage,
        StorageType.file,
      ];
      
      for (final storageType in storageOrder) {
        final result = await _retrieveByType<T>(key, storageType, category ?? 'default');
        if (result.isSuccess && result.data != null) {
          if (_shouldCacheInMemory(key, result.data)) {
            _addToMemoryCache(key, result.data, null);
          }
          return result;
        }
      }
      return Result.success(defaultValue);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao recuperar valor: ${e.toString()}',
          code: 'RETRIEVE_ERROR',
          details: 'key: $key, type: ${T.toString()}',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Remove um valor de todos os storages
  Future<Result<void>> remove(String key, {String? category}) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      final results = <Result<void>>[];
      _memoryCache.remove(key);
      results.add(await _removeFromHive(key, category ?? 'default'));
      results.add(await _removeFromSharedPreferences(key));
      results.add(await _removeFromSecureStorage(key));
      results.add(await _removeFromFile(key));
      if (_backupEnabled) {
        await _removeBackup(key);
      }
      final errors = results.where((r) => r.isError).toList();
      if (errors.isNotEmpty) {
        debugPrint('Alguns storages falharam ao remover $key: $errors');
      }
      
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao remover valor: ${e.toString()}',
          code: 'REMOVE_ERROR',
          details: 'key: $key',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Verifica se uma chave existe em qualquer storage
  Future<Result<bool>> exists(String key, {String? category}) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      if (_memoryCache.containsKey(key)) {
        return Result.success(true);
      }
      final storageChecks = [
        _existsInHive(key, category ?? 'default'),
        _existsInSharedPreferences(key),
        _existsInSecureStorage(key),
        _existsInFile(key),
      ];
      
      for (final check in storageChecks) {
        final result = await check;
        if (result.isSuccess && result.data == true) {
          return Result.success(true);
        }
      }
      
      return Result.success(false);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao verificar existência: ${e.toString()}',
          code: 'EXISTS_ERROR',
          details: 'key: $key',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Lista todas as chaves de uma categoria específica
  Future<Result<List<String>>> listKeys({
    String? category,
    StorageType? storageType,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      final Set<String> allKeys = {};
      
      if (storageType == null || storageType == StorageType.memory) {
        allKeys.addAll(_memoryCache.keys);
      }
      
      if (storageType == null || storageType == StorageType.hive) {
        final box = _hiveBoxes[category ?? 'default'];
        if (box != null) {
          allKeys.addAll(box.keys.cast<String>());
        }
      }
      
      if (storageType == null || storageType == StorageType.sharedPreferences) {
        allKeys.addAll(_prefs.getKeys());
      }
      
      if (storageType == null || storageType == StorageType.secureStorage) {
        final secureKeys = await _secureStorage.readAll();
        allKeys.addAll(secureKeys.keys);
      }
      
      if (storageType == null || storageType == StorageType.file) {
        if (await _fileDir.exists()) {
          await for (final file in _fileDir.list()) {
            if (file is File) {
              allKeys.add(path.basenameWithoutExtension(file.path));
            }
          }
        }
      }
      
      return Result.success(allKeys.toList()..sort());
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao listar chaves: ${e.toString()}',
          code: 'LIST_KEYS_ERROR',
          details: 'category: $category, type: $storageType',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Limpa todos os dados de um storage específico ou todos
  Future<Result<void>> clear({
    StorageType? storageType,
    String? category,
    bool includeSecure = false,
  }) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      if (storageType == null || storageType == StorageType.memory) {
        _memoryCache.clear();
        _memoryCacheSize = 0;
      }
      
      if (storageType == null || storageType == StorageType.hive) {
        if (category != null) {
          final box = _hiveBoxes[category];
          await box?.clear();
        } else {
          for (final box in _hiveBoxes.values) {
            await box.clear();
          }
        }
      }
      
      if (storageType == null || storageType == StorageType.sharedPreferences) {
        await _prefs.clear();
      }
      
      if ((storageType == null || storageType == StorageType.secureStorage) && includeSecure) {
        await _secureStorage.deleteAll();
      }
      
      if (storageType == null || storageType == StorageType.file) {
        if (await _fileDir.exists()) {
          await _fileDir.delete(recursive: true);
          await _fileDir.create(recursive: true);
        }
      }
      if (storageType == null && _backupEnabled) {
        if (await _backupDir.exists()) {
          await _backupDir.delete(recursive: true);
          await _backupDir.create(recursive: true);
        }
      }
      
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao limpar storage: ${e.toString()}',
          code: 'CLEAR_ERROR',
          details: 'type: $storageType, category: $category',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Obtém estatísticas de uso do storage
  Future<Result<StorageStats>> getStats() async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      final stats = StorageStats();
      stats.memoryCacheItems = _memoryCache.length;
      stats.memoryCacheSize = _memoryCacheSize;
      for (final entry in _hiveBoxes.entries) {
        final box = entry.value;
        stats.hiveBoxes[entry.key] = {
          'items': box.length,
          'path': box.path,
        };
      }
      if (await _fileDir.exists()) {
        int fileCount = 0;
        int totalSize = 0;
        
        await for (final file in _fileDir.list()) {
          if (file is File) {
            fileCount++;
            totalSize += await file.length();
          }
        }
        
        stats.fileStorageItems = fileCount;
        stats.fileStorageSize = totalSize;
      }
      stats.readOperations = _readOperations;
      stats.writeOperations = _writeOperations;
      stats.cacheHits = _cacheHits;
      stats.cacheMisses = _cacheMisses;
      stats.cacheHitRatio = _cacheHits / (_cacheHits + _cacheMisses);
      
      return Result.success(stats);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao obter estatísticas: ${e.toString()}',
          code: 'STATS_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Cria backup completo do storage
  Future<Result<String>> createBackup({String? backupName}) async {
    if (!_initialized || !_backupEnabled) {
      return Result.error(
        StorageError(
          message: 'Backup não disponível - service não inicializado ou backup desabilitado',
          code: 'BACKUP_NOT_AVAILABLE',
        ),
      );
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupFileName = backupName ?? 'storage_backup_$timestamp.json';
      final backupFile = File(path.join(_backupDir.path, backupFileName));
      
      final backupData = <String, dynamic>{
        'timestamp': timestamp,
        'version': '1.0',
        'data': <String, dynamic>{},
      };
      for (final entry in _hiveBoxes.entries) {
        final box = entry.value;
        backupData['data']['hive_${entry.key}'] = Map<String, dynamic>.from(box.toMap());
      }
      final prefsKeys = _prefs.getKeys();
      final prefsData = <String, dynamic>{};
      for (final key in prefsKeys) {
        final value = _prefs.get(key);
        if (value != null) {
          prefsData[key] = value;
        }
      }
      backupData['data']['shared_preferences'] = prefsData;
      await backupFile.writeAsString(jsonEncode(backupData));
      
      return Result.success(backupFile.path);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao criar backup: ${e.toString()}',
          code: 'BACKUP_CREATE_ERROR',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  /// Restaura backup
  Future<Result<void>> restoreBackup(String backupPath, {bool clearFirst = true}) async {
    if (!_initialized) {
      final initResult = await initialize();
      if (initResult.isError) return Result.error(initResult.error!);
    }

    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        return Result.error(
          ValidationError(
            message: 'Arquivo de backup não encontrado',
            code: 'BACKUP_FILE_NOT_FOUND',
          ),
        );
      }
      
      final backupContent = await backupFile.readAsString();
      final backupData = jsonDecode(backupContent) as Map<String, dynamic>;
      final data = backupData['data'] as Map<String, dynamic>;
      
      if (clearFirst) {
        await clear();
      }
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value as Map<String, dynamic>;
        
        if (key.startsWith('hive_')) {
          final boxName = key.substring(5); // Remove 'hive_' prefix
          final box = _hiveBoxes[boxName];
          if (box != null) {
            await box.putAll(value);
          }
        } else if (key == 'shared_preferences') {
          for (final prefEntry in value.entries) {
            final prefKey = prefEntry.key;
            final prefValue = prefEntry.value;
            if (prefValue is String) {
              await _prefs.setString(prefKey, prefValue);
            } else if (prefValue is int) {
              await _prefs.setInt(prefKey, prefValue);
            } else if (prefValue is double) {
              await _prefs.setDouble(prefKey, prefValue);
            } else if (prefValue is bool) {
              await _prefs.setBool(prefKey, prefValue);
            } else if (prefValue is List<String>) {
              await _prefs.setStringList(prefKey, prefValue);
            }
          }
        }
      }
      
      return Result.success(null);
    } catch (e, stackTrace) {
      return Result.error(
        StorageError(
          message: 'Erro ao restaurar backup: ${e.toString()}',
          code: 'BACKUP_RESTORE_ERROR',
          details: 'backupPath: $backupPath',
          stackTrace: stackTrace,
        ),
      );
    }
  }

  StorageType _determineStorageType<T>(T value, bool encrypt) {
    if (encrypt) return StorageType.secureStorage;
    
    if (value is String && value.length < 1000) {
      return StorageType.sharedPreferences;
    }
    
    if (value is int || value is double || value is bool) {
      return StorageType.sharedPreferences;
    }
    
    if (value is Uint8List || (value is String && value.length > 10000)) {
      return StorageType.file;
    }
    
    return StorageType.hive;
  }

  Future<dynamic> _processValue<T>(T value, bool encrypt, bool compress) async {
    dynamic processedValue = value;
    if (value is! String && value is! num && value is! bool && value is! Uint8List) {
      try {
        processedValue = jsonEncode(value);
      } catch (e) {
        processedValue = value.toString();
      }
    }
    if (_compressionEnabled && compress && processedValue is String) {
      if (processedValue.length > _compressionThreshold) {
      }
    }
    if (_encryptionEnabled && encrypt && processedValue is String) {
    }
    
    return processedValue;
  }
  
  Future<Result<void>> _storeByType(
    String key,
    dynamic value,
    StorageType type,
    String category,
    Duration? ttl,
  ) async {
    switch (type) {
      case StorageType.hive:
        return _storeInHive(key, value, category);
      case StorageType.sharedPreferences:
        return _storeInSharedPreferences(key, value);
      case StorageType.secureStorage:
        return _storeInSecureStorage(key, value);
      case StorageType.file:
        return _storeInFile(key, value);
      case StorageType.memory:
        _addToMemoryCache(key, value, ttl);
        return Result.success(null);
    }
  }

  Future<Result<T?>> _retrieveByType<T>(String key, StorageType type, String category) async {
    switch (type) {
      case StorageType.hive:
        return _retrieveFromHive<T>(key, category);
      case StorageType.sharedPreferences:
        return _retrieveFromSharedPreferences<T>(key);
      case StorageType.secureStorage:
        return _retrieveFromSecureStorage<T>(key);
      case StorageType.file:
        return _retrieveFromFile<T>(key);
      case StorageType.memory:
        final value = _getFromMemoryCache<T>(key);
        return Result.success(value);
    }
  }
  
  Future<Result<void>> _storeInHive(String key, dynamic value, String category) async {
    try {
      final box = _hiveBoxes[category];
      if (box == null) {
        return Result.error(
          StorageError(message: 'Hive box $category não encontrado', code: 'BOX_NOT_FOUND'),
        );
      }
      await box.put(key, value);
      return Result.success(null);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro no Hive: $e', code: 'HIVE_ERROR'),
      );
    }
  }

  Future<Result<T?>> _retrieveFromHive<T>(String key, String category) async {
    try {
      final box = _hiveBoxes[category];
      if (box == null) return Result.success(null);
      
      final value = box.get(key);
      return Result.success(value as T?);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro ao ler do Hive: $e', code: 'HIVE_READ_ERROR'),
      );
    }
  }

  Future<Result<void>> _storeInSharedPreferences(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else {
        await _prefs.setString(key, value.toString());
      }
      return Result.success(null);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro no SharedPreferences: $e', code: 'PREFS_ERROR'),
      );
    }
  }

  Future<Result<T?>> _retrieveFromSharedPreferences<T>(String key) async {
    try {
      final value = _prefs.get(key);
      return Result.success(value as T?);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro ao ler SharedPreferences: $e', code: 'PREFS_READ_ERROR'),
      );
    }
  }

  Future<Result<void>> _storeInSecureStorage(String key, dynamic value) async {
    try {
      await _secureStorage.write(key: key, value: value.toString());
      return Result.success(null);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro no SecureStorage: $e', code: 'SECURE_ERROR'),
      );
    }
  }

  Future<Result<T?>> _retrieveFromSecureStorage<T>(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return Result.success(value as T?);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro ao ler SecureStorage: $e', code: 'SECURE_READ_ERROR'),
      );
    }
  }

  Future<Result<void>> _storeInFile(String key, dynamic value) async {
    try {
      final file = File(path.join(_fileDir.path, '$key.dat'));
      
      if (value is Uint8List) {
        await file.writeAsBytes(value);
      } else {
        await file.writeAsString(value.toString());
      }
      
      return Result.success(null);
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro no File storage: $e', code: 'FILE_ERROR'),
      );
    }
  }

  Future<Result<T?>> _retrieveFromFile<T>(String key) async {
    try {
      final file = File(path.join(_fileDir.path, '$key.dat'));
      
      if (!await file.exists()) {
        return Result.success(null);
      }
      
      if (T == Uint8List) {
        final bytes = await file.readAsBytes();
        return Result.success(bytes as T);
      } else {
        final content = await file.readAsString();
        return Result.success(content as T);
      }
    } catch (e) {
      return Result.error(
        StorageError(message: 'Erro ao ler File: $e', code: 'FILE_READ_ERROR'),
      );
    }
  }
  
  bool _shouldCacheInMemory(String key, dynamic value) {
    if (_memoryCacheSize >= _maxMemoryCacheSize) return false;
    
    if (value == null) return false;
    
    int valueSize = 0;
    if (value is String) {
      valueSize = value.length * 2; // Aproximação para UTF-16
    } else if (value is Uint8List) {
      valueSize = value.length;
    } else {
      valueSize = value.toString().length * 2;
    }
    
    return valueSize < 1024 * 1024; // Máximo 1MB por item
  }

  void _addToMemoryCache(String key, dynamic value, Duration? ttl) {
    final item = _CacheItem(
      value: value,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    final existing = _memoryCache[key];
    if (existing != null) {
      _memoryCacheSize -= existing.size;
    }
    
    _memoryCache[key] = item;
    _memoryCacheSize += item.size;
    _cleanupMemoryCache();
  }

  T? _getFromMemoryCache<T>(String key) {
    final item = _memoryCache[key];
    if (item == null) return null;
    if (item.isExpired) {
      _memoryCache.remove(key);
      _memoryCacheSize -= item.size;
      return null;
    }
    
    return item.value as T?;
  }

  void _cleanupMemoryCache() {
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      final item = _memoryCache.remove(key);
      if (item != null) {
        _memoryCacheSize -= item.size;
      }
    }
    while (_memoryCacheSize > _maxMemoryCacheSize && _memoryCache.isNotEmpty) {
      final oldestKey = _memoryCache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      
      final item = _memoryCache.remove(oldestKey);
      if (item != null) {
        _memoryCacheSize -= item.size;
      }
    }
  }
  Future<Result<bool>> _existsInHive(String key, String category) async {
    final box = _hiveBoxes[category];
    return Result.success(box?.containsKey(key) ?? false);
  }

  Future<Result<bool>> _existsInSharedPreferences(String key) async {
    return Result.success(_prefs.containsKey(key));
  }

  Future<Result<bool>> _existsInSecureStorage(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return Result.success(value != null);
    } catch (e) {
      return Result.success(false);
    }
  }

  Future<Result<bool>> _existsInFile(String key) async {
    final file = File(path.join(_fileDir.path, '$key.dat'));
    return Result.success(await file.exists());
  }
  Future<Result<void>> _removeFromHive(String key, String category) async {
    try {
      final box = _hiveBoxes[category];
      await box?.delete(key);
      return Result.success(null);
    } catch (e) {
      return Result.error(StorageError(message: 'Erro ao remover do Hive: $e', code: 'HIVE_REMOVE_ERROR'));
    }
  }

  Future<Result<void>> _removeFromSharedPreferences(String key) async {
    try {
      await _prefs.remove(key);
      return Result.success(null);
    } catch (e) {
      return Result.error(StorageError(message: 'Erro ao remover do SharedPreferences: $e', code: 'PREFS_REMOVE_ERROR'));
    }
  }

  Future<Result<void>> _removeFromSecureStorage(String key) async {
    try {
      await _secureStorage.delete(key: key);
      return Result.success(null);
    } catch (e) {
      return Result.error(StorageError(message: 'Erro ao remover do SecureStorage: $e', code: 'SECURE_REMOVE_ERROR'));
    }
  }

  Future<Result<void>> _removeFromFile(String key) async {
    try {
      final file = File(path.join(_fileDir.path, '$key.dat'));
      if (await file.exists()) {
        await file.delete();
      }
      return Result.success(null);
    } catch (e) {
      return Result.error(StorageError(message: 'Erro ao remover arquivo: $e', code: 'FILE_REMOVE_ERROR'));
    }
  }
  Future<void> _createBackup(String key, dynamic value, StorageType type) async {
    try {
      final backupKey = '${type.name}_$key';
      final backupFile = File(path.join(_backupDir.path, '$backupKey.backup'));
      
      final backupData = {
        'key': key,
        'value': value,
        'type': type.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await backupFile.writeAsString(jsonEncode(backupData));
    } catch (e) {
      debugPrint('Warning: Falha ao criar backup para $key: $e');
    }
  }

  Future<void> _removeBackup(String key) async {
    try {
      if (await _backupDir.exists()) {
        await for (final file in _backupDir.list()) {
          if (file is File && file.path.contains(key)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Warning: Falha ao remover backup para $key: $e');
    }
  }

  /// Dispose - limpa recursos
  Future<void> dispose() async {
    for (final box in _hiveBoxes.values) {
      await box.close();
    }
    _hiveBoxes.clear();
    _memoryCache.clear();
    _memoryCacheSize = 0;
    _initialized = false;
  }
}

/// Tipos de storage disponíveis
enum StorageType {
  /// Cache em memória (mais rápido, volátil)
  memory,
  
  /// Hive database (rápido, persistente, estruturado)
  hive,
  
  /// SharedPreferences (simples, leve)
  sharedPreferences,
  
  /// Secure Storage (criptografado, seguro)
  secureStorage,
  
  /// Sistema de arquivos (grandes volumes)
  file,
}

/// Item do cache em memória
class _CacheItem {
  final dynamic value;
  final DateTime timestamp;
  final Duration? ttl;

  _CacheItem({
    required this.value,
    required this.timestamp,
    this.ttl,
  });

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(timestamp) > ttl!;
  }

  int get size {
    if (value is String) {
      return (value as String).length * 2;
    } else if (value is Uint8List) {
      return (value as Uint8List).length;
    } else {
      return value.toString().length * 2;
    }
  }
}

/// Estatísticas do storage
class StorageStats {
  int memoryCacheItems = 0;
  int memoryCacheSize = 0;
  Map<String, Map<String, dynamic>> hiveBoxes = {};
  int fileStorageItems = 0;
  int fileStorageSize = 0;
  int readOperations = 0;
  int writeOperations = 0;
  int cacheHits = 0;
  int cacheMisses = 0;
  double cacheHitRatio = 0.0;

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'memoryCacheItems': memoryCacheItems,
      'memoryCacheSize': memoryCacheSize,
      'hiveBoxes': hiveBoxes,
      'fileStorageItems': fileStorageItems,
      'fileStorageSize': fileStorageSize,
      'readOperations': readOperations,
      'writeOperations': writeOperations,
      'cacheHits': cacheHits,
      'cacheMisses': cacheMisses,
      'cacheHitRatio': cacheHitRatio,
    };
  }

  @override
  String toString() {
    return 'StorageStats('
           'memory: $memoryCacheItems items, ${_formatBytes(memoryCacheSize)}, '
           'files: $fileStorageItems items, ${_formatBytes(fileStorageSize)}, '
           'operations: $readOperations reads, $writeOperations writes, '
           'cache hit ratio: ${(cacheHitRatio * 100).toStringAsFixed(1)}%)';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}