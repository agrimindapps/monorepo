import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../domain/entities/box_sync_config.dart';
import '../../shared/utils/failure.dart';
import 'connectivity_service.dart';
import 'hive_storage_service.dart';

/// Serviço responsável por gerenciar sincronização seletiva de boxes do Hive
class SelectiveSyncService {
  SelectiveSyncService({
    required HiveStorageService hiveStorage,
  }) : _hiveStorage = hiveStorage;

  final HiveStorageService _hiveStorage;
  final ConnectivityService _connectivity = ConnectivityService.instance;
  final Map<String, BoxSyncConfig> _boxConfigs = {};

  /// Registra configurações de sincronização para boxes
  void registerBoxConfigs(List<BoxSyncConfig> configs) {
    for (final config in configs) {
      _boxConfigs[config.boxName] = config;
    }
  }

  /// Verifica se uma box deve sincronizar
  bool shouldSyncBox(String boxName) {
    final config = _boxConfigs[boxName];
    return config?.shouldSync ?? false;
  }

  /// Verifica se uma box é somente local
  bool isLocalOnlyBox(String boxName) {
    final config = _boxConfigs[boxName];
    return config?.localOnly ?? false;
  }

  /// Obtém a configuração de uma box
  BoxSyncConfig? getBoxConfig(String boxName) {
    return _boxConfigs[boxName];
  }

  /// Lista todas as boxes configuradas para sincronização
  List<String> getSyncableBoxes() {
    return _boxConfigs.values
        .where((config) => config.shouldSync && !config.localOnly)
        .map((config) => config.boxName)
        .toList();
  }

  /// Lista todas as boxes somente locais
  List<String> getLocalOnlyBoxes() {
    return _boxConfigs.values
        .where((config) => config.localOnly)
        .map((config) => config.boxName)
        .toList();
  }

  /// Sincroniza uma box específica (respeitando a configuração)
  Future<Either<Failure, void>> syncBox(String boxName) async {
    try {
      final config = _boxConfigs[boxName];
      
      if (config == null) {
        return Left(SyncFailure('Box "$boxName" não possui configuração de sincronização'));
      }

      if (config.localOnly || !config.shouldSync) {
        return Left(SyncFailure('Box "$boxName" configurada como somente local'));
      }
      switch (config.syncStrategy) {
        case BoxSyncStrategy.automatic:
          return _syncBoxAutomatic(boxName);
        case BoxSyncStrategy.manual:
          return _syncBoxManual(boxName);
        case BoxSyncStrategy.periodic:
          return _syncBoxPeriodic(boxName);
        case BoxSyncStrategy.onlineOnly:
          return _syncBoxOnlineOnly(boxName);
      }
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar box "$boxName": $e'));
    }
  }

  /// Sincroniza todas as boxes configuradas para sincronização
  Future<Either<Failure, void>> syncAllSyncableBoxes() async {
    try {
      final syncableBoxes = getSyncableBoxes();
      
      for (final boxName in syncableBoxes) {
        final result = await syncBox(boxName);
        if (result.isLeft()) {
          developer.log('Erro ao sincronizar box "$boxName": ${result.fold((l) => l.message, (r) => "")}', name: 'SelectiveSyncService');
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro ao sincronizar boxes: $e'));
    }
  }

  /// Inicializa dados estáticos em boxes locais
  Future<Either<Failure, void>> initializeStaticContent({
    required String boxName,
    required Map<String, dynamic> staticData,
    required String appVersion,
  }) async {
    try {
      final config = _boxConfigs[boxName];
      
      if (config == null || !config.localOnly) {
        return Left(CacheFailure('Box "$boxName" não é configurada como conteúdo estático'));
      }
      final versionKey = '_app_version_$boxName';
      final storedVersionResult = await _hiveStorage.get<String>(
        key: versionKey,
        box: boxName,
      );

      final storedVersion = storedVersionResult.fold(
        (failure) => null,
        (version) => version,
      );
      if (storedVersion == appVersion) {
        return const Right(null);
      }
      await _hiveStorage.clear(box: boxName);
      for (final entry in staticData.entries) {
        await _hiveStorage.save(
          key: entry.key,
          data: entry.value,
          box: boxName,
        );
      }
      await _hiveStorage.save(
        key: versionKey,
        data: appVersion,
        box: boxName,
      );

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Erro ao inicializar conteúdo estático: $e'));
    }
  }

  /// Força sincronização manual de uma box
  Future<Either<Failure, void>> forceSyncBox(String boxName) async {
    final config = _boxConfigs[boxName];
    
    if (config?.localOnly == true) {
      return Left(SyncFailure('Não é possível sincronizar box somente local: $boxName'));
    }

    return _syncBoxManual(boxName);
  }

  Future<Either<Failure, void>> _syncBoxAutomatic(String boxName) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Simula operação
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro na sincronização automática: $e'));
    }
  }

  Future<Either<Failure, void>> _syncBoxManual(String boxName) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Simula operação
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro na sincronização manual: $e'));
    }
  }

  Future<Either<Failure, void>> _syncBoxPeriodic(String boxName) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Simula operação
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro na sincronização periódica: $e'));
    }
  }

  Future<Either<Failure, void>> _syncBoxOnlineOnly(String boxName) async {
    try {
      final connectivityResult = await _connectivity.isOnline();
      final isOnline = connectivityResult.getOrElse(() => false);
      
      if (!isOnline) {
        return const Left(NetworkFailure('Não é possível sincronizar: offline'));
      }
      
      await Future.delayed(const Duration(milliseconds: 100)); // Simula operação
      return const Right(null);
    } catch (e) {
      return Left(SyncFailure('Erro na sincronização online: $e'));
    }
  }

  /// Obtém estatísticas de sincronização
  Map<String, dynamic> getSyncStats() {
    final syncableCount = getSyncableBoxes().length;
    final localOnlyCount = getLocalOnlyBoxes().length;
    final totalConfigured = _boxConfigs.length;

    return {
      'total_boxes_configured': totalConfigured,
      'syncable_boxes': syncableCount,
      'local_only_boxes': localOnlyCount,
      'boxes_by_strategy': _getBoxesByStrategy(),
    };
  }

  Map<String, int> _getBoxesByStrategy() {
    final stats = <String, int>{};
    
    for (final config in _boxConfigs.values) {
      if (config.localOnly) {
        stats['local_only'] = (stats['local_only'] ?? 0) + 1;
      } else if (config.shouldSync) {
        final strategy = config.syncStrategy.toString().split('.').last;
        stats[strategy] = (stats[strategy] ?? 0) + 1;
      }
    }
    
    return stats;
  }
}
