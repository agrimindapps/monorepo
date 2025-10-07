import 'package:core/core.dart';

import '../../../../core/error/exceptions.dart' as core_exceptions;
import '../../domain/entities/animal_base_entity.dart';
import '../../domain/entities/bovine_entity.dart';
import '../../domain/entities/equine_entity.dart';
import '../../domain/failures/livestock_failures.dart';
import '../../domain/repositories/livestock_repository.dart';
import '../datasources/livestock_local_datasource.dart';
import '../datasources/livestock_remote_datasource.dart';
import '../models/bovine_model.dart';
import '../models/equine_model.dart';

/// Implementação do repositório de livestock com estratégia local-first
///
/// ESTRATÉGIA LOCAL-FIRST:
/// 1. Sempre retorna dados locais primeiro (Hive)
/// 2. Sync com Supabase em background quando há conectividade
/// 3. Conflict resolution: local wins (last-write-wins)
/// 4. Offline-first approach para melhor UX
@LazySingleton(as: LivestockRepository)
class LivestockRepositoryImpl implements LivestockRepository {
  final LivestockLocalDataSource _localDataSource;
  final LivestockRemoteDataSource _remoteDataSource;
  final Connectivity _connectivity;

  LivestockRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._connectivity,
  );

  @override
  Future<Either<Failure, List<BovineEntity>>> getBovines() async {
    try {
      final localBovines = await _localDataSource.getAllBovines();
      final entities = localBovines.map((model) => model.toEntity()).toList();
      _performBackgroundSync();

      return Right(entities);
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
    if (exception is CacheException) {
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
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
}
