import 'package:core/core.dart';

import '../../../../core/interfaces/network_info.dart';
import '../../domain/entities/task_history.dart';
import '../../domain/repositories/task_history_repository.dart';
import '../datasources/local/task_history_local_datasource.dart';
import '../datasources/remote/task_history_remote_datasource.dart';
import '../models/task_history_model.dart';

class TaskHistoryRepositoryImpl implements TaskHistoryRepository {
  final TaskHistoryRemoteDataSource remoteDataSource;
  final TaskHistoryLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final IAuthRepository authService;

  TaskHistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authService,
  });

  Future<String?> get _currentUserId async {
    return await _getCurrentUserIdWithRetry();
  }

  /// Get current user ID with retry logic to handle auth race conditions
  Future<String?> _getCurrentUserIdWithRetry({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final timeoutDuration = Duration(seconds: 2 * attempt);
        final user =
            await authService.currentUser.timeout(timeoutDuration).first;

        if (user != null && user.id.isNotEmpty) {
          return user.id;
        }
        if (attempt < maxRetries) {
          await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
          continue;
        }

        return null;
      } catch (e) {
        print('Auth attempt $attempt/$maxRetries failed: $e');
      }
    }
    return null;
  }

  @override
  @override
  Future<Either<Failure, List<TaskHistory>>> getHistoryByPlantId(
    String plantId,
  ) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        // Try remote first, then sync local
        try {
          final remoteHistory = await remoteDataSource.getHistoryByPlantId(
            plantId,
            userId,
          );
          await localDataSource.cacheHistories(remoteHistory);
          return Right(remoteHistory);
        } catch (e) {
          // Fallback to local if remote fails
          final localHistory = await localDataSource.getHistoryByPlantId(
            plantId,
          );
          return Right(localHistory);
        }
      } else {
        // Offline: use local data
        final localHistory = await localDataSource.getHistoryByPlantId(plantId);
        return Right(localHistory);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar histórico: ${e.toString()}'));
    }
  }

  @override
  @override
  Future<Either<Failure, List<TaskHistory>>> getHistoryByTaskId(
    String taskId,
  ) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        try {
          final remoteHistory = await remoteDataSource.getHistoryByTaskId(
            taskId,
            userId,
          );
          await localDataSource.cacheHistories(remoteHistory);
          return Right(remoteHistory);
        } catch (e) {
          final localHistory = await localDataSource.getHistoryByTaskId(taskId);
          return Right(localHistory);
        }
      } else {
        final localHistory = await localDataSource.getHistoryByTaskId(taskId);
        return Right(localHistory);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar histórico: ${e.toString()}'));
    }
  }

  @override
  @override
  Future<Either<Failure, List<TaskHistory>>> getHistoryByUserId(
    String userId,
  ) async {
    try {
      final currentUserId = await _currentUserId;
      if (currentUserId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      // Ensure user can only access their own history
      if (currentUserId != userId) {
        return const Left(
          ServerFailure('Acesso negado ao histórico de outro usuário'),
        );
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        try {
          final remoteHistory = await remoteDataSource.getHistoryByUserId(
            userId,
          );
          await localDataSource.cacheHistories(remoteHistory);
          return Right(remoteHistory);
        } catch (e) {
          final localHistory = await localDataSource.getHistoryByUserId(userId);
          return Right(localHistory);
        }
      } else {
        final localHistory = await localDataSource.getHistoryByUserId(userId);
        return Right(localHistory);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar histórico: ${e.toString()}'));
    }
  }

  @override
  @override
  Future<Either<Failure, List<TaskHistory>>> getHistoryInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        try {
          final remoteHistory = await remoteDataSource.getHistoryInDateRange(
            startDate,
            endDate,
            userId,
          );
          await localDataSource.cacheHistories(remoteHistory);
          return Right(remoteHistory);
        } catch (e) {
          final localHistory = await localDataSource.getHistoryInDateRange(
            startDate,
            endDate,
          );
          return Right(localHistory);
        }
      } else {
        final localHistory = await localDataSource.getHistoryInDateRange(
          startDate,
          endDate,
        );
        return Right(localHistory);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar histórico: ${e.toString()}'));
    }
  }

  @override
  @override
  Future<Either<Failure, TaskHistory>> saveHistory(TaskHistory history) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      final model = TaskHistoryModel.fromEntity(history);
      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        try {
          final savedHistory = await remoteDataSource.saveHistory(
            model,
            userId,
          );
          await localDataSource.cacheHistory(savedHistory);
          return Right(savedHistory);
        } catch (e) {
          // Save locally even if remote fails
          await localDataSource.cacheHistory(model);
          return Right(model);
        }
      } else {
        // Offline: save locally
        await localDataSource.cacheHistory(model);
        return Right(model);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao salvar histórico: ${e.toString()}'));
    }
  }

  @override
  @override
  Future<Either<Failure, void>> deleteHistory(String id) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        try {
          await remoteDataSource.deleteHistory(id, userId);
          await localDataSource.deleteHistory(id);
          return const Right(null);
        } catch (e) {
          // Delete locally even if remote fails
          await localDataSource.deleteHistory(id);
          return const Right(null);
        }
      } else {
        await localDataSource.deleteHistory(id);
        return const Right(null);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar histórico: ${e.toString()}'));
    }
  }

  @override
  @override
  Future<Either<Failure, void>> deleteHistoryByTaskId(String taskId) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        try {
          await remoteDataSource.deleteHistoryByTaskId(taskId, userId);
          await localDataSource.deleteHistoryByTaskId(taskId);
          return const Right(null);
        } catch (e) {
          await localDataSource.deleteHistoryByTaskId(taskId);
          return const Right(null);
        }
      } else {
        await localDataSource.deleteHistoryByTaskId(taskId);
        return const Right(null);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar histórico: ${e.toString()}'));
    }
  }

  @override
  @override
  Future<Either<Failure, void>> deleteHistoryByPlantId(String plantId) async {
    try {
      final userId = await _currentUserId;
      if (userId == null) {
        return const Left(AuthenticationFailure('Usuário não autenticado'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        try {
          await remoteDataSource.deleteHistoryByPlantId(plantId, userId);
          await localDataSource.deleteHistoryByPlantId(plantId);
          return const Right(null);
        } catch (e) {
          await localDataSource.deleteHistoryByPlantId(plantId);
          return const Right(null);
        }
      } else {
        await localDataSource.deleteHistoryByPlantId(plantId);
        return const Right(null);
      }
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar histórico: ${e.toString()}'));
    }
  }
}
