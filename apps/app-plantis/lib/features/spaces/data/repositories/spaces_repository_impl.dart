import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../../domain/entities/space.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../datasources/local/spaces_local_datasource.dart';
import '../datasources/remote/spaces_remote_datasource.dart';
import '../models/space_model.dart';

class SpacesRepositoryImpl implements SpacesRepository {
  final SpacesLocalDatasource localDatasource;
  final SpacesRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;
  final AuthService authService;

  SpacesRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
    required this.authService,
  });

  @override
  Future<Either<Failure, List<Space>>> getSpaces() async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteSpaces = await remoteDatasource.getSpaces(user.uid);
          await localDatasource.cacheSpaces(remoteSpaces);
          return Right(remoteSpaces);
        } catch (e) {
          // If remote fails, fallback to local
          final localSpaces = await localDatasource.getSpaces();
          return Right(localSpaces);
        }
      } else {
        final localSpaces = await localDatasource.getSpaces();
        return Right(localSpaces);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Space>> getSpaceById(String id) async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteSpace = await remoteDatasource.getSpaceById(user.uid, id);
          await localDatasource.cacheSpace(remoteSpace);
          return Right(remoteSpace);
        } catch (e) {
          // If remote fails, fallback to local
          final localSpace = await localDatasource.getSpaceById(id);
          if (localSpace != null) {
            return Right(localSpace);
          } else {
            return const Left(NotFoundFailure('Espaço não encontrado'));
          }
        }
      } else {
        final localSpace = await localDatasource.getSpaceById(id);
        if (localSpace != null) {
          return Right(localSpace);
        } else {
          return const Left(NotFoundFailure('Espaço não encontrado'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Space>>> searchSpaces(String query) async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteSpaces = await remoteDatasource.searchSpaces(user.uid, query);
          return Right(remoteSpaces);
        } catch (e) {
          // If remote fails, fallback to local search
          final localSpaces = await localDatasource.searchSpaces(query);
          return Right(localSpaces);
        }
      } else {
        final localSpaces = await localDatasource.searchSpaces(query);
        return Right(localSpaces);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Space>> addSpace(Space space) async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final spaceModel = SpaceModel.fromEntity(space);

      // Always save locally first
      await localDatasource.cacheSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          final savedSpace = await remoteDatasource.addSpace(user.uid, spaceModel);
          await localDatasource.cacheSpace(savedSpace);
          return Right(savedSpace);
        } catch (e) {
          // If remote fails, return local version marked as dirty
          return Right(spaceModel.copyWith(isDirty: true));
        }
      } else {
        return Right(spaceModel.copyWith(isDirty: true));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Space>> updateSpace(Space space) async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      final spaceModel = SpaceModel.fromEntity(space);

      // Always save locally first
      await localDatasource.cacheSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          final updatedSpace = await remoteDatasource.updateSpace(user.uid, spaceModel);
          await localDatasource.cacheSpace(updatedSpace);
          return Right(updatedSpace);
        } catch (e) {
          // If remote fails, return local version marked as dirty
          return Right(spaceModel.copyWith(isDirty: true));
        }
      } else {
        return Right(spaceModel.copyWith(isDirty: true));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSpace(String id) async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      // Remove locally first
      await localDatasource.removeSpace(id);

      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.deleteSpace(user.uid, id);
        } catch (e) {
          // If remote fails, we already removed locally
          // The sync will handle this later
        }
      }

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getPlantCountBySpace(String spaceId) async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          final count = await remoteDatasource.getPlantCountBySpace(user.uid, spaceId);
          return Right(count);
        } catch (e) {
          // If remote fails, return 0 to allow deletion
          return const Right(0);
        }
      } else {
        // When offline, return 0 to allow deletion
        return const Right(0);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}