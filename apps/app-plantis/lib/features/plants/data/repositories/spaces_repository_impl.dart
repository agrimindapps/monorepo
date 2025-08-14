import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../../../core/interfaces/network_info.dart';
import '../../domain/entities/space.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../datasources/local/spaces_local_datasource.dart';
import '../datasources/remote/spaces_remote_datasource.dart';
import '../models/space_model.dart';

class SpacesRepositoryImpl implements SpacesRepository {
  final SpacesLocalDatasource localDatasource;
  final SpacesRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;

  SpacesRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.authService,
  });

  Future<String?> get _currentUserId async {
    try {
      final user = await authService.currentUser.first;
      return user?.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, List<Space>>> getSpaces() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          // Try to get from remote first
          final remoteSpaces = await remoteDatasource.getSpaces(userId);
          
          // Cache locally
          for (final space in remoteSpaces) {
            await localDatasource.updateSpace(space);
          }
          
          return Right(remoteSpaces);
        } catch (e) {
          // If remote fails, fallback to local
          final localSpaces = await localDatasource.getSpaces();
          return Right(localSpaces);
        }
      } else {
        // Offline - get from local
        final localSpaces = await localDatasource.getSpaces();
        return Right(localSpaces);
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao buscar espaços: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Space>> getSpaceById(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          // Try to get from remote first
          final remoteSpace = await remoteDatasource.getSpaceById(id, userId);
          
          // Cache locally
          await localDatasource.updateSpace(remoteSpace);
          
          return Right(remoteSpace);
        } catch (e) {
          // If remote fails, fallback to local
          final localSpace = await localDatasource.getSpaceById(id);
          if (localSpace != null) {
            return Right(localSpace);
          }
          return Left(NotFoundFailure('Espaço não encontrado'));
        }
      } else {
        // Offline - get from local
        final localSpace = await localDatasource.getSpaceById(id);
        if (localSpace != null) {
          return Right(localSpace);
        }
        return Left(NotFoundFailure('Espaço não encontrado'));
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao buscar espaço: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Space>> addSpace(Space space) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      final spaceModel = SpaceModel.fromEntity(space);
      
      // Always save locally first
      await localDatasource.addSpace(spaceModel);
      
      if (await networkInfo.isConnected) {
        try {
          // Try to save remotely
          final remoteSpace = await remoteDatasource.addSpace(spaceModel, userId);
          
          // Update local with remote ID and sync status
          await localDatasource.updateSpace(remoteSpace);
          
          return Right(remoteSpace);
        } catch (e) {
          // If remote fails, return local version (will sync later)
          return Right(spaceModel);
        }
      } else {
        // Offline - return local version
        return Right(spaceModel);
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao adicionar espaço: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Space>> updateSpace(Space space) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      final spaceModel = SpaceModel.fromEntity(space);
      
      // Always save locally first
      await localDatasource.updateSpace(spaceModel);
      
      if (await networkInfo.isConnected) {
        try {
          // Try to update remotely
          final remoteSpace = await remoteDatasource.updateSpace(spaceModel, userId);
          
          // Update local with sync status
          await localDatasource.updateSpace(remoteSpace);
          
          return Right(remoteSpace);
        } catch (e) {
          // If remote fails, return local version (will sync later)
          return Right(spaceModel);
        }
      } else {
        // Offline - return local version
        return Right(spaceModel);
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao atualizar espaço: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSpace(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      // Always delete locally first
      await localDatasource.deleteSpace(id);
      
      if (await networkInfo.isConnected) {
        try {
          // Try to delete remotely
          await remoteDatasource.deleteSpace(id, userId);
        } catch (e) {
          // If remote fails, the local soft delete will sync later
        }
      }
      
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao deletar espaço: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Space>>> searchSpaces(String query) async {
    try {
      final allSpaces = await getSpaces();
      return allSpaces.fold(
        (failure) => Left(failure),
        (spaces) {
          final searchQuery = query.toLowerCase().trim();
          final filteredSpaces = spaces.where((space) {
            final name = space.name.toLowerCase();
            final description = (space.description ?? '').toLowerCase();
            return name.contains(searchQuery) || description.contains(searchQuery);
          }).toList();
          return Right(filteredSpaces);
        },
      );
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao buscar espaços: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> canDeleteSpace(String spaceId) async {
    try {
      // For now, always allow deletion
      // In a real implementation, you'd check if the space has plants
      return const Right(true);
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao verificar espaço: ${e.toString()}'));
    }
  }

  @override
  Stream<List<Space>> watchSpaces() {
    return Stream.fromFuture(getSpaces().then((result) => 
        result.fold((failure) => <Space>[], (spaces) => spaces)));
  }

  @override
  Future<Either<Failure, void>> syncPendingChanges() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      if (!(await networkInfo.isConnected)) {
        return Left(NetworkFailure('Sem conexão com a internet'));
      }

      // Get all local spaces that need sync
      final localSpaces = await localDatasource.getSpaces();
      final spacesToSync = localSpaces.where((space) => space.isDirty).toList();
      
      if (spacesToSync.isNotEmpty) {
        try {
          await remoteDatasource.syncSpaces(spacesToSync, userId);
          
          // Update local spaces to mark as synced
          for (final space in spacesToSync) {
            final syncedSpace = space.copyWith(isDirty: false);
            await localDatasource.updateSpace(syncedSpace);
          }
        } catch (e) {
          return Left(ServerFailure('Erro ao sincronizar mudanças: ${e.toString()}'));
        }
      }
      
      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado ao sincronizar: ${e.toString()}'));
    }
  }
}