import 'package:core/core.dart' hide CacheFailure, Column;
import '../../errors/failures.dart';

/// Extension methods for Hive Box to provide batch operations with error handling
extension HiveBoxBatchOperations<T> on Box<T> {
  /// Put multiple entries safely with Either error handling
  Future<Either<Failure, void>> putAllSafe(Map<dynamic, T> entries) async {
    try {
      await putAll(entries);
      return const Right(null);
    } on HiveError catch (e) {
      return Left(CacheFailure('Batch put failed: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure('Batch put failed: $e'));
    }
  }

  /// Get all items that match a condition
  Either<Failure, List<T>> getAllWhere(bool Function(T) test) {
    try {
      final results = values.where(test).toList();
      return Right(results);
    } catch (e) {
      return Left(CacheFailure('Batch query failed: $e'));
    }
  }

  /// Delete all items that match a condition
  Future<Either<Failure, int>> deleteAllWhere(bool Function(T) test) async {
    try {
      final keysToDelete = <dynamic>[];

      for (final entry in toMap().entries) {
        if (test(entry.value)) {
          keysToDelete.add(entry.key);
        }
      }

      await deleteAll(keysToDelete);
      return Right(keysToDelete.length);
    } on HiveError catch (e) {
      return Left(CacheFailure('Batch delete failed: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure('Batch delete failed: $e'));
    }
  }

  /// Update all items that match a condition using a transformer function
  Future<Either<Failure, int>> updateAllWhere(
    bool Function(T) test,
    T Function(T) transform,
  ) async {
    try {
      final updates = <dynamic, T>{};

      for (final entry in toMap().entries) {
        if (test(entry.value)) {
          updates[entry.key] = transform(entry.value);
        }
      }

      await putAll(updates);
      return Right(updates.length);
    } on HiveError catch (e) {
      return Left(CacheFailure('Batch update failed: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure('Batch update failed: $e'));
    }
  }

  /// Clear box safely with error handling
  Future<Either<Failure, void>> clearSafe() async {
    try {
      await clear();
      return const Right(null);
    } on HiveError catch (e) {
      return Left(CacheFailure('Clear box failed: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure('Clear box failed: $e'));
    }
  }

  /// Count items that match a condition
  Either<Failure, int> countWhere(bool Function(T) test) {
    try {
      final count = values.where(test).length;
      return Right(count);
    } catch (e) {
      return Left(CacheFailure('Count query failed: $e'));
    }
  }

  /// Check if any item matches a condition
  Either<Failure, bool> anyWhere(bool Function(T) test) {
    try {
      final hasAny = values.any(test);
      return Right(hasAny);
    } catch (e) {
      return Left(CacheFailure('Query failed: $e'));
    }
  }

  /// Get first item that matches a condition
  Either<Failure, T?> firstWhereOrNull(bool Function(T) test) {
    try {
      final item = values.firstWhere(
        test,
        orElse: () => null as T,
      );
      return Right(item);
    } catch (e) {
      return Left(CacheFailure('Query failed: $e'));
    }
  }

  /// Get items in batches (for large datasets)
  Either<Failure, List<T>> getBatch({
    required int offset,
    required int limit,
    bool Function(T)? filter,
  }) {
    try {
      var items = values;

      if (filter != null) {
        items = items.where(filter);
      }

      final batch = items.skip(offset).take(limit).toList();
      return Right(batch);
    } catch (e) {
      return Left(CacheFailure('Batch query failed: $e'));
    }
  }

  /// Compact box safely (removes deleted entries and reduces file size)
  Future<Either<Failure, void>> compactSafe() async {
    try {
      await compact();
      return const Right(null);
    } on HiveError catch (e) {
      return Left(CacheFailure('Compact failed: ${e.message}'));
    } catch (e) {
      return Left(CacheFailure('Compact failed: $e'));
    }
  }

  /// Get box statistics
  Either<Failure, BoxStats> getStats() {
    try {
      return Right(BoxStats(
        name: name,
        length: length,
        isEmpty: isEmpty,
        isOpen: isOpen,
        path: path,
      ));
    } catch (e) {
      return Left(CacheFailure('Failed to get box stats: $e'));
    }
  }
}

/// Statistics about a Hive box
class BoxStats {
  final String name;
  final int length;
  final bool isEmpty;
  final bool isOpen;
  final String? path;

  const BoxStats({
    required this.name,
    required this.length,
    required this.isEmpty,
    required this.isOpen,
    this.path,
  });

  @override
  String toString() {
    return 'BoxStats(name: $name, length: $length, isEmpty: $isEmpty, '
        'isOpen: $isOpen, path: $path)';
  }
}
