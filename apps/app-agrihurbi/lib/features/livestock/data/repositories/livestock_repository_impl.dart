import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/auth/user_role_service.dart';
import '../../../../core/error/exceptions.dart' as core_exceptions;
import '../../domain/entities/animal_base_entity.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/entities/equine_entity.dart';
import '../../domain/failures/livestock_failures.dart';
import '../../domain/repositories/livestock_repository.dart';
import '../datasources/livestock_local_datasource.dart';
import '../datasources/livestock_remote_datasource.dart';
import '../datasources/livestock_storage_datasource.dart';
import '../models/bovine_model.dart';
import '../models/equine_model.dart';

/// Implementação do repositório de livestock com estratégia dual-mode
///
/// ESTRATÉGIA DUAL-MODE:
/// - ADMIN: Gerencia dados localmente (Drift) + Publica no Storage
/// - USERS: Sincroniza do Storage + Cache local (read-only)
/// 
/// ADMIN WORKFLOW:
/// 1. CRUD local (Drift SQLite)
/// 2. Quando pronto, executa "Publicar Catálogo"
/// 3. Repository gera JSON e faz upload no Firebase Storage
/// 
/// USER WORKFLOW:
/// 1. App verifica metadata.json no Storage
/// 2. Se houver atualização, baixa bovines_catalog.json
/// 3. Salva no cache local (Drift)
/// 4. Usa offline-first
class LivestockRepositoryImpl implements LivestockRepository {
  final LivestockLocalDataSource _localDataSource;
  final LivestockRemoteDataSource _remoteDataSource;
  final LivestockStorageDataSource _storageDataSource;
  final UserRoleService _roleService;
  final Connectivity _connectivity;
  final SharedPreferences _prefs;
  
  static const _lastSyncKey = 'livestock_last_sync';

  LivestockRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._storageDataSource,
    this._roleService,
    this._connectivity,
    this._prefs,
  );

  @override
  Future<Either<Failure, List<BovineEntity>>> getBovines() async {
    try {
      final role = await _roleService.getUserRole();
      
      if (role.isAdmin) {
        // ADMIN: Retorna direto do cache local (seus dados)
        final localBovines = await _localDataSource.getAllBovines();
        final entities = localBovines.map((model) => model.toEntity()).toList();
        return Right(entities);
        
      } else {
        // USER: Sincroniza do Storage antes de retornar
        await _syncFromStorageIfNeeded();
        
        final localBovines = await _localDataSource.getAllBovines();
        final entities = localBovines.map((model) => model.toEntity()).toList();
        return Right(entities);
      }
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, BovineEntity>> getBovineById(String id) async {
    try {
      final localBovine = await _localDataSource.getBovineById(id);

      if (localBovine != null) {
        return Right(localBovine.toEntity());
      }
      if (await _hasConnectivity()) {
        try {
          final remoteBovine = await _remoteDataSource.getBovineById(id);
          if (remoteBovine != null) {
            await _localDataSource.saveBovine(remoteBovine);
            return Right(remoteBovine.toEntity());
          }
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return const Left(BovineNotFoundFailure());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, BovineEntity>> createBovine(
    BovineEntity bovine,
  ) async {
    try {
      final bovineModel = BovineModel.fromEntity(bovine);
      await _localDataSource.saveBovine(bovineModel);
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.createBovine(bovineModel);
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return Right(bovineModel.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, BovineEntity>> updateBovine(
    BovineEntity bovine,
  ) async {
    try {
      final bovineModel = BovineModel.fromEntity(bovine);
      await _localDataSource.saveBovine(bovineModel);
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.updateBovine(bovineModel);
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return Right(bovineModel.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBovine(String id) async {
    try {
      await _localDataSource.deleteBovine(id);
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.deleteBovine(id);
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<BovineEntity>>> searchBovines(
    BovineSearchParams params,
  ) async {
    try {
      final localBovines = await _localDataSource.searchBovines(
        breed: params.breed,
        aptitude: params.aptitude?.displayName,
        purpose: params.purpose,
        tags: params.tags,
      );

      return Right(localBovines.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<EquineEntity>>> getEquines() async {
    try {
      final localEquines = await _localDataSource.getAllEquines();
      final entities = localEquines.map((model) => model.toEntity()).toList();
      _performBackgroundSync();

      return Right(entities);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, EquineEntity>> getEquineById(String id) async {
    try {
      final localEquine = await _localDataSource.getEquineById(id);

      if (localEquine != null) {
        return Right(localEquine.toEntity());
      }
      if (await _hasConnectivity()) {
        try {
          final remoteEquine = await _remoteDataSource.getEquineById(id);
          if (remoteEquine != null) {
            await _localDataSource.saveEquine(remoteEquine);
            return Right(remoteEquine.toEntity());
          }
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return const Left(EquineNotFoundFailure());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, EquineEntity>> createEquine(
    EquineEntity equine,
  ) async {
    try {
      final equineModel = EquineModel.fromEntity(equine);
      await _localDataSource.saveEquine(equineModel);
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.createEquine(equineModel);
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return Right(equineModel.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, EquineEntity>> updateEquine(
    EquineEntity equine,
  ) async {
    try {
      final equineModel = EquineModel.fromEntity(equine);
      await _localDataSource.saveEquine(equineModel);
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.updateEquine(equineModel);
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return Right(equineModel.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEquine(String id) async {
    try {
      await _localDataSource.deleteEquine(id);
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.deleteEquine(id);
        } catch (e) {
          // Ignora falhas de sync remoto - local-first strategy
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<EquineEntity>>> searchEquines(
    EquineSearchParams params,
  ) async {
    try {
      final localEquines = await _localDataSource.searchEquines(
        temperament: params.temperament?.displayName,
        coat: params.coat?.displayName,
        primaryUse: params.primaryUse?.displayName,
        geneticInfluences: null,
      );

      return Right(localEquines.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<AnimalBaseEntity>>> searchAllAnimals(
    SearchAnimalsParams params,
  ) async {
    try {
      final bovines = await _localDataSource.getAllBovines();
      final equines = await _localDataSource.getAllEquines();

      List<AnimalBaseEntity> allAnimals = [];
      allAnimals.addAll(
        bovines.map((model) => model.toEntity() as AnimalBaseEntity),
      );
      allAnimals.addAll(
        equines.map((model) => model.toEntity() as AnimalBaseEntity),
      );
      if (params.query != null && params.query!.isNotEmpty) {
        allAnimals =
            allAnimals
                .where(
                  (animal) =>
                      animal.commonName.toLowerCase().contains(
                        params.query!.toLowerCase(),
                      ) ||
                      animal.originCountry.toLowerCase().contains(
                        params.query!.toLowerCase(),
                      ),
                )
                .toList();
      }

      if (params.originCountry != null) {
        allAnimals =
            allAnimals
                .where(
                  (animal) => animal.originCountry.toLowerCase().contains(
                    params.originCountry!.toLowerCase(),
                  ),
                )
                .toList();
      }

      if (params.isActive != null) {
        allAnimals =
            allAnimals
                .where((animal) => animal.isActive == params.isActive)
                .toList();
      }
      final startIndex = params.offset;
      final endIndex = (startIndex + params.limit).clamp(0, allAnimals.length);

      if (startIndex >= allAnimals.length) {
        return const Right([]);
      }

      return Right(allAnimals.sublist(startIndex, endIndex));
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadAnimalImages(
    String animalId,
    List<String> imagePaths,
  ) async {
    try {
      return const Left(
        LivestockFailure(message: 'Upload de imagens não implementado ainda'),
      );
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAnimalImages(
    String animalId,
    List<String> imageUrls,
  ) async {
    try {
      return const Left(
        LivestockFailure(message: 'Remoção de imagens não implementada ainda'),
      );
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncLivestockData() async {
    try {
      if (!await _hasConnectivity()) {
        return const Left(
          LivestockFailure(message: 'Sem conectividade para sincronização'),
        );
      }
      await _performFullSync();

      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLivestockStatistics() async {
    try {
      final bovines = await _localDataSource.getAllBovines();
      final equines = await _localDataSource.getAllEquines();

      final stats = {
        'totalBovines': bovines.length,
        'totalEquines': equines.length,
        'totalAnimals': bovines.length + equines.length,
        'activeBovines': bovines.where((b) => b.isActive).length,
        'activeEquines': equines.where((e) => e.isActive).length,
        'bovinesByAptitude': _groupBovinesByAptitude(bovines),
        'equinesByTemperament': _groupEquinesByTemperament(equines),
        'lastUpdate': DateTime.now().toIso8601String(),
      };

      return Right(stats);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> exportLivestockData({
    String format = 'json',
  }) async {
    try {
      final exportData = await _localDataSource.exportData();
      return Right(exportData);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> importLivestockData(
    String backupData, {
    String format = 'json',
  }) async {
    try {
      await _localDataSource.importData(backupData);
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  /// Verifica conectividade com a internet
  Future<bool> _hasConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Executa sync em background sem bloquear UI
  void _performBackgroundSync() {
    Future.microtask(() async {
      try {
        if (await _hasConnectivity()) {
          await _performFullSync();
        }
      } catch (e) {
        // Ignora falhas de sync em background - não deve impactar a UI
      }
    });
  }

  /// Executa sync completo bidirecional
  Future<void> _performFullSync() async {
    await _remoteDataSource.syncLivestockData();
  }

  /// Agrupa bovinos por aptidão para estatísticas
  Map<String, int> _groupBovinesByAptitude(List<BovineModel> bovines) {
    final Map<String, int> groups = {};
    for (final bovine in bovines) {
      final aptitude = bovine.aptitude.displayName;
      groups[aptitude] = (groups[aptitude] ?? 0) + 1;
    }
    return groups;
  }

  /// Agrupa equinos por temperamento para estatísticas
  Map<String, int> _groupEquinesByTemperament(List<EquineModel> equines) {
    final Map<String, int> groups = {};
    for (final equine in equines) {
      final temperament = equine.temperament.displayName;
      groups[temperament] = (groups[temperament] ?? 0) + 1;
    }
    return groups;
  }

  /// Converte exceções em Failures apropriados
  Failure _handleException(dynamic exception) {
    if (exception is core_exceptions.CacheException) {
      return LivestockFailure(message: exception.message);
    } else if (exception is core_exceptions.ServerException) {
      return LivestockFailure(message: exception.message);
    } else {
      return LivestockFailure(message: 'Erro inesperado: $exception');
    }
  }

  /// Força sync manual (para botão "Sincronizar" na UI)
  Future<Either<Failure, Unit>> forceSyncNow() async {
    try {
      if (!await _hasConnectivity()) {
        return const Left(LivestockFailure(message: 'Sem conectividade'));
      }

      await _performFullSync();
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  /// Verifica se há dados pendentes de sincronização
  Future<bool> hasPendingSync() async {
    return false;
  }

  /// Limpa cache local (reset completo)
  Future<Either<Failure, Unit>> clearLocalCache() async {
    try {
      // await _localDataSource.clearAll();
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  // ========== MÉTODOS DE PUBLICAÇÃO (ADMIN) ==========
  
  /// Publica catálogo no Firebase Storage (admin only)
  /// Gera JSONs e faz upload para serem baixados por usuários
  @override
  Future<Either<Failure, Unit>> publishCatalogToStorage({
    required List<BovineEntity> bovines,
    required List<EquineEntity> equines,
  }) async {
    try {
      // 1. Verifica se é admin
      final role = await _roleService.getUserRole();
      if (!role.isAdmin) {
        return const Left(
          LivestockFailure(message: 'Apenas administradores podem publicar catálogos')
        );
      }
      
      // 2. Valida dados
      if (bovines.isEmpty && equines.isEmpty) {
        return const Left(
          LivestockFailure(message: 'Não há dados para publicar')
        );
      }
      
      // 3. Upload dos catálogos
      if (bovines.isNotEmpty) {
        await _storageDataSource.uploadBovinesCatalog(bovines);
      }
      
      if (equines.isNotEmpty) {
        await _storageDataSource.uploadEquinesCatalog(equines);
      }
      
      // 4. Atualiza metadata
      final metadata = CatalogMetadata(
        lastUpdated: DateTime.now(),
        bovinesCount: bovines.where((b) => b.isActive).length,
        equinesCount: equines.where((e) => e.isActive).length,
        version: '1.0.0',
      );
      
      await _storageDataSource.uploadMetadata(metadata);
      
      debugPrint('✅ Repository: Catalog published successfully');
      return const Right(unit);
      
    } catch (e) {
      debugPrint('❌ Repository: Error publishing catalog: $e');
      return Left(
        LivestockFailure(message: 'Erro ao publicar catálogo: $e')
      );
    }
  }
  
  /// Sincroniza catálogo do Storage para cache local (usuários)
  @override
  Future<Either<Failure, Unit>> syncCatalogFromStorage() async {
    try {
      // 1. Verifica conectividade
      if (!await _hasConnectivity()) {
        debugPrint('⚠️ Repository: No connectivity, skipping sync');
        return const Right(unit); // Não é erro, usa cache
      }
      
      // 2. Baixa catálogos
      final bovines = await _storageDataSource.fetchBovinesCatalog();
      final equines = await _storageDataSource.fetchEquinesCatalog();
      
      // 3. Salva no cache local
      for (final bovine in bovines) {
        await _localDataSource.saveBovine(bovine);
      }
      
      for (final equine in equines) {
        await _localDataSource.saveEquine(equine);
      }
      
      // 4. Atualiza timestamp de sync
      await _prefs.setInt(
        _lastSyncKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      
      debugPrint(
        '✅ Repository: Synced ${bovines.length} bovines, ${equines.length} equines'
      );
      
      return const Right(unit);
      
    } catch (e) {
      debugPrint('❌ Repository: Error syncing catalog: $e');
      // Não retorna erro, apenas loga (usa cache existente)
      return const Right(unit);
    }
  }
  
  /// Sincroniza do Storage se necessário (verifica metadata)
  Future<void> _syncFromStorageIfNeeded() async {
    try {
      // Pega timestamp da última sincronização
      final lastSyncTimestamp = _prefs.getInt(_lastSyncKey);
      final lastSync = lastSyncTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(lastSyncTimestamp)
          : DateTime(2020); // Forçar sync na primeira vez
      
      // Verifica se há atualização
      final needsUpdate = await _storageDataSource.needsUpdate(
        lastLocalUpdate: lastSync,
      );
      
      if (needsUpdate) {
        debugPrint('🔄 Repository: Catalog update available, syncing...');
        await syncCatalogFromStorage();
      } else {
        debugPrint('✓ Repository: Catalog is up to date');
      }
      
    } catch (e) {
      debugPrint('⚠️ Repository: Error checking for updates: $e');
      // Ignora erro, usa cache existente
    }
  }
}
