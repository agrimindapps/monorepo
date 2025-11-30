import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/premium_status.dart';
import 'premium_status_mapper.dart';

/// Service responsible for Firebase cache operations
/// Follows SRP by handling only cache-related Firebase operations

class PremiumFirebaseCacheService {
  PremiumFirebaseCacheService(this._firestore, this._statusMapper);

  final FirebaseFirestore _firestore;
  final PremiumStatusMapper _statusMapper;

  static const String _cacheCollection = 'premium_cache';
  static const Duration _defaultTtl = Duration(minutes: 30);

  /// Cache premium status with TTL
  Future<Either<Failure, void>> cacheStatus({
    required String userId,
    required PremiumStatus status,
    Duration ttl = _defaultTtl,
  }) async {
    try {
      final data = _statusMapper.statusToCachedMap(status, ttl);

      await _firestore
          .collection(_cacheCollection)
          .doc(userId)
          .set(data, SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao fazer cache: ${e.toString()}'));
    }
  }

  /// Get cached premium status
  Future<Either<Failure, PremiumStatus?>> getCachedStatus({
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection(_cacheCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }

      final data = doc.data() as Map<String, dynamic>;

      // Check if cache is still valid
      if (!_statusMapper.isCacheValid(data)) {
        // Cache expired - delete it
        await deleteCachedStatus(userId: userId);
        return const Right(null);
      }

      final status = _statusMapper.firebaseMapToStatus(data);
      return Right(status);
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar cache: ${e.toString()}'));
    }
  }

  /// Delete cached status
  Future<Either<Failure, void>> deleteCachedStatus({
    required String userId,
  }) async {
    try {
      await _firestore.collection(_cacheCollection).doc(userId).delete();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao deletar cache: ${e.toString()}'));
    }
  }

  /// Check if cache exists and is valid
  Future<Either<Failure, bool>> isCacheValid({required String userId}) async {
    try {
      final doc = await _firestore
          .collection(_cacheCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Right(false);
      }

      final data = doc.data() as Map<String, dynamic>;
      final isValid = _statusMapper.isCacheValid(data);

      return Right(isValid);
    } catch (e) {
      return Left(ServerFailure('Erro ao verificar cache: ${e.toString()}'));
    }
  }

  /// Get cache expiration date
  Future<Either<Failure, DateTime?>> getCacheExpiration({
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection(_cacheCollection)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Right(null);
      }

      final data = doc.data() as Map<String, dynamic>;
      final expiration = _statusMapper.getCacheExpiration(data);

      return Right(expiration);
    } catch (e) {
      return Left(ServerFailure('Erro ao obter expiração: ${e.toString()}'));
    }
  }

  /// Refresh cache (update TTL without changing data)
  Future<Either<Failure, void>> refreshCache({
    required String userId,
    Duration ttl = _defaultTtl,
  }) async {
    try {
      final cachedResult = await getCachedStatus(userId: userId);

      return cachedResult.fold((failure) => Left(failure), (status) async {
        if (status == null) {
          return const Left(CacheFailure('Cache not found'));
        }

        return cacheStatus(userId: userId, status: status, ttl: ttl);
      });
    } catch (e) {
      return Left(ServerFailure('Erro ao atualizar cache: ${e.toString()}'));
    }
  }

  /// Clean expired caches (batch operation)
  Future<Either<Failure, int>> cleanExpiredCaches() async {
    try {
      final snapshot = await _firestore.collection(_cacheCollection).get();

      var deletedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (!_statusMapper.isCacheValid(data)) {
          await doc.reference.delete();
          deletedCount++;
        }
      }

      return Right(deletedCount);
    } catch (e) {
      return Left(ServerFailure('Erro ao limpar caches: ${e.toString()}'));
    }
  }

  /// Get cache statistics
  Future<Either<Failure, CacheStatistics>> getCacheStatistics() async {
    try {
      final snapshot = await _firestore.collection(_cacheCollection).get();

      var validCount = 0;
      var expiredCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (_statusMapper.isCacheValid(data)) {
          validCount++;
        } else {
          expiredCount++;
        }
      }

      return Right(
        CacheStatistics(
          total: snapshot.docs.length,
          valid: validCount,
          expired: expiredCount,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao obter estatísticas: ${e.toString()}'));
    }
  }
}

/// Cache statistics model
class CacheStatistics {

  const CacheStatistics({
    required this.total,
    required this.valid,
    required this.expired,
  });
  final int total;
  final int valid;
  final int expired;

  double get validPercentage {
    if (total == 0) return 0.0;
    return (valid / total) * 100;
  }

  double get expiredPercentage {
    if (total == 0) return 0.0;
    return (expired / total) * 100;
  }
}
