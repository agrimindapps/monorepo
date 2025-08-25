import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

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
  
  // === OPERAÇÕES BOVINOS ===
  
  @override
  Future<Either<Failure, List<BovineEntity>>> getBovines() async {
    try {
      // SEMPRE retorna dados locais primeiro (local-first)
      final localBovines = await _localDataSource.getAllBovines();
      final entities = localBovines.map((model) => model.toEntity()).toList();
      
      // Tenta sync em background se houver conectividade
      _performBackgroundSync();
      
      return Right(entities);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, BovineEntity>> getBovineById(String id) async {
    try {
      // Local-first: sempre busca local primeiro
      final localBovine = await _localDataSource.getBovineById(id);
      
      if (localBovine != null) {
        return Right(localBovine.toEntity());
      }
      
      // Se não achou localmente E tem conectividade, tenta buscar remotamente
      if (await _hasConnectivity()) {
        try {
          final remoteBovine = await _remoteDataSource.getBovineById(id);
          if (remoteBovine != null) {
            // Salva localmente para próximas consultas
            await _localDataSource.saveBovine(remoteBovine);
            return Right(remoteBovine.toEntity());
          }
        } catch (e) {
          // Se der erro no remote, ignora e continua com local
        }
      }
      
      return const Left(BovineNotFoundFailure());
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, BovineEntity>> createBovine(BovineEntity bovine) async {
    try {
      final bovineModel = BovineModel.fromEntity(bovine);
      
      // Salva localmente SEMPRE (local-first)
      await _localDataSource.saveBovine(bovineModel);
      
      // Tenta salvar remotamente se houver conectividade
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.createBovine(bovineModel);
        } catch (e) {
          // Se der erro no remote, ainda considera sucesso local
          // Será sincronizado posteriormente
        }
      }
      
      return Right(bovineModel.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, BovineEntity>> updateBovine(BovineEntity bovine) async {
    try {
      final bovineModel = BovineModel.fromEntity(bovine);
      
      // Atualiza localmente SEMPRE (local-first)
      await _localDataSource.saveBovine(bovineModel);
      
      // Tenta atualizar remotamente se houver conectividade
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.updateBovine(bovineModel);
        } catch (e) {
          // Se der erro no remote, ainda considera sucesso local
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
      // Deleta localmente SEMPRE (soft delete)
      await _localDataSource.deleteBovine(id);
      
      // Tenta deletar remotamente se houver conectividade
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.deleteBovine(id);
        } catch (e) {
          // Se der erro no remote, ainda considera sucesso local
        }
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, List<BovineEntity>>> searchBovines(BovineSearchParams params) async {
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
  
  // === OPERAÇÕES EQUINOS ===
  
  @override
  Future<Either<Failure, List<EquineEntity>>> getEquines() async {
    try {
      // SEMPRE retorna dados locais primeiro (local-first)
      final localEquines = await _localDataSource.getAllEquines();
      final entities = localEquines.map((model) => model.toEntity()).toList();
      
      // Tenta sync em background se houver conectividade
      _performBackgroundSync();
      
      return Right(entities);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, EquineEntity>> getEquineById(String id) async {
    try {
      // Local-first: sempre busca local primeiro
      final localEquine = await _localDataSource.getEquineById(id);
      
      if (localEquine != null) {
        return Right(localEquine.toEntity());
      }
      
      // Se não achou localmente E tem conectividade, tenta buscar remotamente
      if (await _hasConnectivity()) {
        try {
          final remoteEquine = await _remoteDataSource.getEquineById(id);
          if (remoteEquine != null) {
            // Salva localmente para próximas consultas
            await _localDataSource.saveEquine(remoteEquine);
            return Right(remoteEquine.toEntity());
          }
        } catch (e) {
          // Se der erro no remote, ignora e continua com local
        }
      }
      
      return const Left(EquineNotFoundFailure());
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, EquineEntity>> createEquine(EquineEntity equine) async {
    try {
      final equineModel = EquineModel.fromEntity(equine);
      
      // Salva localmente SEMPRE (local-first)
      await _localDataSource.saveEquine(equineModel);
      
      // Tenta salvar remotamente se houver conectividade
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.createEquine(equineModel);
        } catch (e) {
          // Se der erro no remote, ainda considera sucesso local
        }
      }
      
      return Right(equineModel.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, EquineEntity>> updateEquine(EquineEntity equine) async {
    try {
      final equineModel = EquineModel.fromEntity(equine);
      
      // Atualiza localmente SEMPRE (local-first)
      await _localDataSource.saveEquine(equineModel);
      
      // Tenta atualizar remotamente se houver conectividade
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.updateEquine(equineModel);
        } catch (e) {
          // Se der erro no remote, ainda considera sucesso local
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
      // Deleta localmente SEMPRE (soft delete)
      await _localDataSource.deleteEquine(id);
      
      // Tenta deletar remotamente se houver conectividade
      if (await _hasConnectivity()) {
        try {
          await _remoteDataSource.deleteEquine(id);
        } catch (e) {
          // Se der erro no remote, ainda considera sucesso local
        }
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, List<EquineEntity>>> searchEquines(EquineSearchParams params) async {
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
  
  // === OPERAÇÕES UNIFICADAS ===
  
  @override
  Future<Either<Failure, List<AnimalBaseEntity>>> searchAllAnimals(SearchAnimalsParams params) async {
    try {
      final bovines = await _localDataSource.getAllBovines();
      final equines = await _localDataSource.getAllEquines();
      
      List<AnimalBaseEntity> allAnimals = [];
      
      // Adiciona bovinos convertidos para AnimalBaseEntity
      allAnimals.addAll(bovines.map((model) => model.toEntity() as AnimalBaseEntity));
      
      // Adiciona equinos convertidos para AnimalBaseEntity
      allAnimals.addAll(equines.map((model) => model.toEntity() as AnimalBaseEntity));
      
      // Aplica filtros se especificados
      if (params.query != null && params.query!.isNotEmpty) {
        allAnimals = allAnimals.where((animal) => 
          animal.commonName.toLowerCase().contains(params.query!.toLowerCase()) ||
          animal.originCountry.toLowerCase().contains(params.query!.toLowerCase())
        ).toList();
      }
      
      if (params.originCountry != null) {
        allAnimals = allAnimals.where((animal) => 
          animal.originCountry.toLowerCase().contains(params.originCountry!.toLowerCase())
        ).toList();
      }
      
      if (params.isActive != null) {
        allAnimals = allAnimals.where((animal) => animal.isActive == params.isActive).toList();
      }
      
      // Aplica paginação
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
  Future<Either<Failure, List<String>>> uploadAnimalImages(String animalId, List<String> imagePaths) async {
    try {
      // TODO: Implementar upload de imagens
      // 1. Upload para storage (Supabase Storage ou similar)
      // 2. Atualizar URLs no modelo do animal
      // 3. Sincronizar com local storage
      
      return const Left(LivestockFailure(message: 'Upload de imagens não implementado ainda'));
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> deleteAnimalImages(String animalId, List<String> imageUrls) async {
    try {
      // TODO: Implementar remoção de imagens
      // 1. Remover do storage remoto
      // 2. Atualizar URLs no modelo do animal
      // 3. Sincronizar com local storage
      
      return const Left(LivestockFailure(message: 'Remoção de imagens não implementada ainda'));
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  // === OPERAÇÕES DE SINCRONIZAÇÃO ===
  
  @override
  Future<Either<Failure, Unit>> syncLivestockData() async {
    try {
      if (!await _hasConnectivity()) {
        return const Left(LivestockFailure(message: 'Sem conectividade para sincronização'));
      }
      
      // Sync bidirecional: local -> remote e remote -> local
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
  Future<Either<Failure, String>> exportLivestockData({String format = 'json'}) async {
    try {
      final exportData = await _localDataSource.exportData();
      return Right(exportData);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> importLivestockData(String backupData, {String format = 'json'}) async {
    try {
      await _localDataSource.importData(backupData);
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
  
  // === MÉTODOS PRIVADOS PARA LOCAL-FIRST STRATEGY ===
  
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
    // Executa em background sem aguardar
    Future.microtask(() async {
      try {
        if (await _hasConnectivity()) {
          await _performFullSync();
        }
      } catch (e) {
        // Falha silenciosa no background sync
      }
    });
  }
  
  /// Executa sync completo bidirecional
  Future<void> _performFullSync() async {
    // TODO: Implementar sync inteligente
    // 1. Buscar dados remotos modificados desde ultima sincronização
    // 2. Buscar dados locais modificados desde ultima sincronização 
    // 3. Resolver conflitos (local wins por padrão)
    // 4. Aplicar mudanças em ambas as direções
    // 5. Atualizar timestamp de ultima sincronização
    
    // Por enquanto, apenas verifica conectividade
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
  
  // === MÉTODOS ADICIONAIS PARA SYNC AVANÇADO ===
  
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
    // TODO: Implementar verificação de dados pendentes
    // Verificar timestamps locais vs remotos
    return false;
  }
  
  /// Limpa cache local (reset completo)
  Future<Either<Failure, Unit>> clearLocalCache() async {
    try {
      // TODO: Implementar limpeza do cache Hive
      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
  }
}