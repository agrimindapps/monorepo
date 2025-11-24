import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/water_achievement.dart';
import '../../domain/entities/water_record.dart';
import '../../domain/repositories/water_repository.dart';
import '../datasources/water_local_datasource.dart';
import '../datasources/water_remote_datasource.dart';
import '../models/water_achievement_model.dart';
import '../models/water_record_model.dart';

/// Repository implementation for water intake data
/// Follows offline-first strategy: local operations first, then sync to remote when connected
class WaterRepositoryImpl implements WaterRepository {
  final WaterLocalDataSource _localDataSource;
  final WaterRemoteDataSource _remoteDataSource;
  final FirebaseAuth _firebaseAuth;
  final Logger _logger;

  const WaterRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._firebaseAuth,
    this._logger,
  );

  /// Get current user ID from Firebase Auth
  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  /// Check if user is authenticated
  bool get _isAuthenticated => _currentUserId != null;

  @override
  Future<Either<Failure, WaterRecord>> addWaterRecord(
      WaterRecord record) async {
    try {
      // Convert entity to model
      final model = WaterRecordModel.fromEntity(record);

      // 1. Save locally first (offline-first)
      final savedModel = await _localDataSource.addRecord(model);

      // 2. Sync to remote if user is authenticated
      if (_isAuthenticated) {
        try {
          await _remoteDataSource.addRecord(savedModel, _currentUserId!);
          _logger.d('Water record synced to Firestore: ${savedModel.id}');
        } catch (e) {
          // Log but don't fail - will sync later
          _logger.w('Failed to sync water record to remote: $e');
        }
      }

      return Right(savedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar registro de água: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaterRecord>>> getWaterRecords() async {
    try {
      // Always get from local cache first
      final localRecords = await _localDataSource.getRecords();

      // Try to sync with remote if authenticated
      if (_isAuthenticated) {
        try {
          final remoteRecords =
              await _remoteDataSource.getRecords(_currentUserId!);

          // Merge remote records into local cache
          for (final remoteRecord in remoteRecords) {
            try {
              await _localDataSource.addRecord(remoteRecord);
            } catch (e) {
              // Record might already exist, try update
              try {
                await _localDataSource.updateRecord(remoteRecord);
              } catch (e) {
                _logger.w('Failed to merge remote record: $e');
              }
            }
          }

          // Return fresh local data after merge
          final updatedRecords = await _localDataSource.getRecords();
          return Right(
              updatedRecords.map((model) => model.toEntity()).toList());
        } catch (e) {
          _logger.w('Failed to fetch from remote, using local cache: $e');
        }
      }

      // Return local cache
      return Right(localRecords.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar registros de água: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaterRecord>>> getWaterRecordsByDate(
      DateTime date) async {
    try {
      final localRecords = await _localDataSource.getRecordsByDate(date);
      return Right(localRecords.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar registros por data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaterRecord>>> getWaterRecordsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final localRecords = await _localDataSource.getRecordsInRange(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(localRecords.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar registros no intervalo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWaterRecord(String id) async {
    try {
      // 1. Delete locally first
      await _localDataSource.deleteRecord(id);

      // 2. Delete from remote if authenticated
      if (_isAuthenticated) {
        try {
          await _remoteDataSource.deleteRecord(id, _currentUserId!);
          _logger.d('Water record deleted from Firestore: $id');
        } catch (e) {
          _logger.w('Failed to delete water record from remote: $e');
        }
      }

      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao deletar registro de água: $e'));
    }
  }

  @override
  Future<Either<Failure, WaterRecord>> updateWaterRecord(
      WaterRecord record) async {
    try {
      final model = WaterRecordModel.fromEntity(record);

      // 1. Update locally first
      final updatedModel = await _localDataSource.updateRecord(model);

      // 2. Sync to remote if authenticated
      if (_isAuthenticated) {
        try {
          await _remoteDataSource.updateRecord(updatedModel, _currentUserId!);
          _logger.d('Water record updated in Firestore: ${updatedModel.id}');
        } catch (e) {
          _logger.w('Failed to update water record in remote: $e');
        }
      }

      return Right(updatedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar registro de água: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getDailyGoal() async {
    try {
      final goal = await _localDataSource.getDailyGoal();
      return Right(goal);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar meta diária: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> updateDailyGoal(int goalAmount) async {
    try {
      // 1. Update locally first
      await _localDataSource.setDailyGoal(goalAmount);

      // 2. Sync to remote if authenticated
      if (_isAuthenticated) {
        try {
          await _remoteDataSource.updateDailyGoal(_currentUserId!, goalAmount);
          _logger.d('Daily goal updated in Firestore: $goalAmount ml');
        } catch (e) {
          _logger.w('Failed to update daily goal in remote: $e');
        }
      }

      return Right(goalAmount);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao atualizar meta diária: $e'));
    }
  }

  @override
  Future<Either<Failure, List<WaterAchievement>>> getAchievements() async {
    try {
      // Get from local cache first
      final localAchievements = await _localDataSource.getAchievements();

      // Try to sync with remote if authenticated
      if (_isAuthenticated) {
        try {
          final remoteAchievements =
              await _remoteDataSource.getAchievements(_currentUserId!);

          // Merge remote achievements into local cache
          for (final remoteAchievement in remoteAchievements) {
            try {
              await _localDataSource.addAchievement(remoteAchievement);
            } catch (e) {
              // Achievement might already exist
              _logger.w('Achievement already exists locally: $e');
            }
          }

          // Return fresh local data after merge
          final updatedAchievements = await _localDataSource.getAchievements();
          return Right(
              updatedAchievements.map((model) => model.toEntity()).toList());
        } catch (e) {
          _logger.w('Failed to fetch achievements from remote: $e');
        }
      }

      // Return local cache
      return Right(localAchievements.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar conquistas: $e'));
    }
  }

  @override
  Future<Either<Failure, WaterAchievement>> addAchievement(
      WaterAchievement achievement) async {
    try {
      final model = WaterAchievementModel.fromEntity(achievement);

      // 1. Save locally first
      final savedModel = await _localDataSource.addAchievement(model);

      // 2. Sync to remote if authenticated
      if (_isAuthenticated) {
        try {
          await _remoteDataSource.addAchievement(savedModel, _currentUserId!);
          _logger.d('Achievement synced to Firestore: ${savedModel.id}');
        } catch (e) {
          _logger.w('Failed to sync achievement to remote: $e');
        }
      }

      return Right(savedModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao adicionar conquista: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasAchievement(AchievementType type) async {
    try {
      final achievements = await _localDataSource.getAchievements();
      final hasIt = achievements.any((a) => a.type == type);
      return Right(hasIt);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao verificar conquista: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalForDate(DateTime date) async {
    try {
      final records = await _localDataSource.getRecordsByDate(date);
      final total = records.fold<int>(0, (sum, record) => sum + record.amount);
      return Right(total);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao calcular total do dia: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getCurrentStreak() async {
    try {
      final streak = await _localDataSource.getCurrentStreak();
      return Right(streak);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Erro ao buscar sequência atual: $e'));
    }
  }
}
