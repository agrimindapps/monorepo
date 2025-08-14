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
          final remoteSpaces = await remoteDatasource.getSpaces(userId);
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
    } catch (e) {
      if (e.toString().contains('server') || e.toString().contains('network')) {
        return Left(ServerFailure(e.toString()));
      } else {
        return Left(CacheFailure(e.toString()));
      }
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
          final remoteSpace = await remoteDatasource.getSpaceById(userId, id);
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
    } catch (e) {
      if (e.toString().contains('server') || e.toString().contains('network')) {
        return Left(ServerFailure(e.toString()));
      } else {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Space>>> searchSpaces(String query) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteSpaces = await remoteDatasource.searchSpaces(
            userId,
            query,
          );
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
    } catch (e) {
      if (e.toString().contains('server') || e.toString().contains('network')) {
        return Left(ServerFailure(e.toString()));
      } else {
        return Left(CacheFailure(e.toString()));
      }
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
      await localDatasource.cacheSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          final savedSpace = await remoteDatasource.addSpace(
            userId,
            spaceModel,
          );
          await localDatasource.cacheSpace(savedSpace);
          return Right(savedSpace);
        } catch (e) {
          // If remote fails, return local version marked as dirty
          return Right(spaceModel.copyWith(isDirty: true));
        }
      } else {
        return Right(spaceModel.copyWith(isDirty: true));
      }
    } catch (e) {
      if (e.toString().contains('server') || e.toString().contains('network')) {
        return Left(ServerFailure(e.toString()));
      } else {
        return Left(CacheFailure(e.toString()));
      }
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
      await localDatasource.cacheSpace(spaceModel);

      if (await networkInfo.isConnected) {
        try {
          final updatedSpace = await remoteDatasource.updateSpace(
            userId,
            spaceModel,
          );
          await localDatasource.cacheSpace(updatedSpace);
          return Right(updatedSpace);
        } catch (e) {
          // If remote fails, return local version marked as dirty
          return Right(spaceModel.copyWith(isDirty: true));
        }
      } else {
        return Right(spaceModel.copyWith(isDirty: true));
      }
    } catch (e) {
      if (e.toString().contains('server') || e.toString().contains('network')) {
        return Left(ServerFailure(e.toString()));
      } else {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteSpace(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      // Remove locally first
      await localDatasource.removeSpace(id);

      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.deleteSpace(userId, id);
        } catch (e) {
          // If remote fails, we already removed locally
          // The sync will handle this later
        }
      }

      return const Right(null);
    } catch (e) {
      if (e.toString().contains('server') || e.toString().contains('network')) {
        return Left(ServerFailure(e.toString()));
      } else {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, int>> getPlantCountBySpace(String spaceId) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return Left(ServerFailure('Usuário não autenticado'));
      }

      if (await networkInfo.isConnected) {
        try {
          final count = await remoteDatasource.getPlantCountBySpace(
            userId,
            spaceId,
          );
          return Right(count);
        } catch (e) {
          // If remote fails, return 0 to allow deletion
          return const Right(0);
        }
      } else {
        // When offline, return 0 to allow deletion
        return const Right(0);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
