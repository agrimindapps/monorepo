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
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      // ALWAYS return local data first for instant UI response
      final localSpaces = await localDatasource.getSpaces();

      // Start background sync immediately (fire and forget)
      // This ensures local-first approach with background updates
      if (await networkInfo.isConnected) {
        _syncSpacesInBackground(userId);
      }

      // Return local data immediately (empty list is fine)
      return Right(localSpaces);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao buscar espaços: ${e.toString()}'),
      );
    }
  }

  // Background sync method (fire and forget)
  void _syncSpacesInBackground(String userId) {
    remoteDatasource
        .getSpaces(userId)
        .then((remoteSpaces) {
          // Update local cache with remote data
          for (final space in remoteSpaces) {
            localDatasource.updateSpace(space);
          }
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, Space>> getSpaceById(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      // ALWAYS get from local first for instant response
      final localSpace = await localDatasource.getSpaceById(id);

      // Start background sync if connected (fire and forget)
      if (await networkInfo.isConnected) {
        _syncSingleSpaceInBackground(id, userId);
      }

      // Return local data immediately (or error if not found)
      if (localSpace != null) {
        return Right(localSpace);
      } else {
        return const Left(NotFoundFailure('Espaço não encontrado'));
      }
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao buscar espaço: ${e.toString()}'),
      );
    }
  }

  // Background sync method for single space (fire and forget)
  void _syncSingleSpaceInBackground(String spaceId, String userId) {
    remoteDatasource
        .getSpaceById(spaceId, userId)
        .then((remoteSpace) {
          // Update local cache with remote data
          localDatasource.updateSpace(remoteSpace);
        })
        .catchError((e) {
          // Ignore sync errors in background
        });
  }

  @override
  Future<Either<Failure, Space>> addSpace(Space space) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      final spaceModel = SpaceModel.fromEntity(space);

      // Always save locally first
      await localDatasource.addSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          // Try to save remotely
          final remoteSpace = await remoteDatasource.addSpace(
            spaceModel,
            userId,
          );

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
      return Left(
        UnknownFailure('Erro inesperado ao adicionar espaço: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Space>> updateSpace(Space space) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      final spaceModel = SpaceModel.fromEntity(space);

      // Always save locally first
      await localDatasource.updateSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          // Try to update remotely
          final remoteSpace = await remoteDatasource.updateSpace(
            spaceModel,
            userId,
          );

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
      return Left(
        UnknownFailure('Erro inesperado ao atualizar espaço: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteSpace(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
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
      return Left(
        UnknownFailure('Erro inesperado ao deletar espaço: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Space>>> searchSpaces(String query) async {
    try {
      final allSpaces = await getSpaces();
      return allSpaces.fold((failure) => Left(failure), (spaces) {
        final searchQuery = query.toLowerCase().trim();
        final filteredSpaces =
            spaces.where((space) {
              final name = space.name.toLowerCase();
              final description = (space.description ?? '').toLowerCase();
              return name.contains(searchQuery) ||
                  description.contains(searchQuery);
            }).toList();
        return Right(filteredSpaces);
      });
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao buscar espaços: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> canDeleteSpace(String spaceId) async {
    try {
      // For now, always allow deletion
      // In a real implementation, you'd check if the space has plants
      return const Right(true);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao verificar espaço: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<List<Space>> watchSpaces() {
    return Stream.fromFuture(
      getSpaces().then(
        (result) => result.fold((failure) => <Space>[], (spaces) => spaces),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> syncPendingChanges() async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }

      if (!(await networkInfo.isConnected)) {
        return const Left(NetworkFailure('Sem conexão com a internet'));
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
          return Left(
            ServerFailure('Erro ao sincronizar mudanças: ${e.toString()}'),
          );
        }
      }

      return const Right(null);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao sincronizar: ${e.toString()}'),
      );
    }
  }
}
