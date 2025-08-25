import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../shared/utils/result.dart';
import '../exceptions/storage_exceptions.dart';
import '../interfaces/i_hive_manager.dart';
import '../utils/result_adapter.dart';

/// Implementação do gerenciador centralizado do Hive
/// Responsável por inicialização, gestão de boxes e adapters
class HiveManager implements IHiveManager {
  static HiveManager? _instance;
  static HiveManager get instance => _instance ??= HiveManager._();
  
  HiveManager._();

  final Map<String, Box> _openBoxes = {};
  final Map<Type, int> _registeredAdapters = {};
  bool _isInitialized = false;
  String? _appName;

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<String> get openBoxNames => _openBoxes.keys.toList();

  @override
  Future<Result<void>> initialize(String appName) async {
    if (_isInitialized) {
      debugPrint('HiveManager: Already initialized for app: $_appName');
      return Result.success(null);
    }

    try {
      _appName = appName;
      
      // Inicializa Hive com path específico do app
      await Hive.initFlutter('${appName}_storage');
      
      _isInitialized = true;
      
      debugPrint('HiveManager: Successfully initialized for app: $appName');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('HiveManager: Failed to initialize - $e');
      return ResultAdapter.failure(
        HiveInitializationException(
          'Failed to initialize Hive for app: $appName',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<Box<T>>> getBox<T>(String boxName) async {
    if (!_isInitialized) {
      return ResultAdapter.failure(
        HiveBoxException(
          'HiveManager not initialized. Call initialize() first.',
          boxName,
        ),
      );
    }

    try {
      // Retorna box se já estiver aberta
      if (_openBoxes.containsKey(boxName)) {
        final box = _openBoxes[boxName] as Box<T>;
        return Result.success(box);
      }

      // Abre nova box
      final Box<T> box;
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box<T>(boxName);
      } else {
        box = await Hive.openBox<T>(boxName);
      }

      _openBoxes[boxName] = box;
      
      debugPrint('HiveManager: Opened box: $boxName (${box.length} items)');
      return Result.success(box);
      
    } catch (e, stackTrace) {
      debugPrint('HiveManager: Failed to open box: $boxName - $e');
      return ResultAdapter.failure(
        HiveBoxException(
          'Failed to open box: $boxName',
          boxName,
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> closeBox(String boxName) async {
    try {
      if (_openBoxes.containsKey(boxName)) {
        final box = _openBoxes[boxName]!;
        await box.close();
        _openBoxes.remove(boxName);
        debugPrint('HiveManager: Closed box: $boxName');
      }
      
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('HiveManager: Failed to close box: $boxName - $e');
      return ResultAdapter.failure(
        HiveBoxException(
          'Failed to close box: $boxName',
          boxName,
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> closeAllBoxes() async {
    final boxNames = List<String>.from(_openBoxes.keys);
    final List<String> failedBoxes = [];

    for (final boxName in boxNames) {
      final result = await closeBox(boxName);
      if (result.isFailure) {
        failedBoxes.add(boxName);
      }
    }

    if (failedBoxes.isNotEmpty) {
      return ResultAdapter.failure(
        HiveBoxException(
          'Failed to close boxes: ${failedBoxes.join(", ")}',
          failedBoxes.first,
        ),
      );
    }

    debugPrint('HiveManager: Closed all boxes successfully');
    return Result.success(null);
  }

  @override
  bool isBoxOpen(String boxName) {
    return _openBoxes.containsKey(boxName) || Hive.isBoxOpen(boxName);
  }

  @override
  Future<Result<void>> registerAdapter<T>(TypeAdapter<T> adapter) async {
    try {
      final typeId = adapter.typeId;
      
      // Verifica se já está registrado
      if (Hive.isAdapterRegistered(typeId)) {
        debugPrint('HiveManager: Adapter already registered for typeId: $typeId');
        return Result.success(null);
      }

      Hive.registerAdapter<T>(adapter);
      _registeredAdapters[T] = typeId;
      
      debugPrint('HiveManager: Registered adapter for type: $T (typeId: $typeId)');
      return Result.success(null);
      
    } catch (e, stackTrace) {
      debugPrint('HiveManager: Failed to register adapter for type: $T - $e');
      return ResultAdapter.failure(
        HiveAdapterException(
          'Failed to register adapter for type: $T',
          adapterType: T,
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  bool isAdapterRegistered<T>() {
    return _registeredAdapters.containsKey(T);
  }

  @override
  Future<Result<void>> clearAllData() async {
    if (!_isInitialized) {
      return ResultAdapter.failure(
        const HiveInitializationException('HiveManager not initialized'),
      );
    }

    try {
      // Fecha todas as boxes primeiro
      await closeAllBoxes();

      // Deleta todos os dados
      await Hive.deleteFromDisk();
      
      // Reinicializa se necessário
      if (_appName != null) {
        _isInitialized = false;
        final reinitResult = await initialize(_appName!);
        if (reinitResult.isFailure) {
          return reinitResult;
        }
      }

      debugPrint('HiveManager: Cleared all data successfully');
      return Result.success(null);
      
    } catch (e) {
      debugPrint('HiveManager: Failed to clear all data - $e');
      return ResultAdapter.error(
        Exception('Failed to clear all Hive data: $e'),
      );
    }
  }

  @override
  Map<String, int> getBoxStatistics() {
    final statistics = <String, int>{};
    
    for (final entry in _openBoxes.entries) {
      statistics[entry.key] = entry.value.length;
    }
    
    return statistics;
  }

  /// Obtém informações detalhadas sobre o estado do HiveManager
  Map<String, dynamic> getDetailedInfo() {
    return {
      'isInitialized': _isInitialized,
      'appName': _appName,
      'openBoxes': _openBoxes.length,
      'registeredAdapters': _registeredAdapters.length,
      'boxStatistics': getBoxStatistics(),
      'registeredTypes': _registeredAdapters.keys.map((t) => t.toString()).toList(),
    };
  }

  /// Valida o estado atual do HiveManager
  Result<void> validateState() {
    if (!_isInitialized) {
      return ResultAdapter.failure(
        const HiveInitializationException('HiveManager not initialized'),
      );
    }

    if (_appName == null) {
      return ResultAdapter.failure(
        const HiveInitializationException('App name not set'),
      );
    }

    return Result.success(null);
  }
}