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
      final localSpaces = await localDatasource.getSpaces();
      if (await networkInfo.isConnected) {
        _syncSpacesInBackground(userId);
      }
      return Right(localSpaces);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        UnknownFailure('Erro inesperado ao buscar espaços: ${e.toString()}'),
      );
    }
  }
  void _syncSpacesInBackground(String userId) {
    remoteDatasource
        .getSpaces(userId)
        .then((remoteSpaces) {
          for (final space in remoteSpaces) {
            localDatasource.updateSpace(space);
          }
        })
        .catchError((e) {
        });
  }

  @override
  Future<Either<Failure, Space>> getSpaceById(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(ServerFailure('Usuário não autenticado'));
      }
      final localSpace = await localDatasource.getSpaceById(id);
      if (await networkInfo.isConnected) {
        _syncSingleSpaceInBackground(id, userId);
      }
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
  void _syncSingleSpaceInBackground(String spaceId, String userId) {
    remoteDatasource
        .getSpaceById(spaceId, userId)
        .then((remoteSpace) {
          localDatasource.updateSpace(remoteSpace);
        })
        .catchError((e) {
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
      await localDatasource.addSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          final remoteSpace = await remoteDatasource.addSpace(
            spaceModel,
            userId,
          );
          await localDatasource.updateSpace(remoteSpace);

          return Right(remoteSpace);
        } catch (e) {
          return Right(spaceModel);
        }
      } else {
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
      await localDatasource.updateSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          final remoteSpace = await remoteDatasource.updateSpace(
            spaceModel,
            userId,
          );
          await localDatasource.updateSpace(remoteSpace);

          return Right(remoteSpace);
        } catch (e) {
          return Right(spaceModel);
        }
      } else {
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
      await localDatasource.deleteSpace(id);

      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.deleteSpace(id, userId);
        } catch (e) {
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
      final localSpaces = await localDatasource.getSpaces();
      final spacesToSync = localSpaces.where((space) => space.isDirty).toList();

      if (spacesToSync.isNotEmpty) {
        try {
          await remoteDatasource.syncSpaces(spacesToSync, userId);
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
