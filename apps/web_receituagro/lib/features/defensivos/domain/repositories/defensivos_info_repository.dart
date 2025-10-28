import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/defensivo_info.dart';

/// DefensivosInfo repository contract (interface)
/// Manages complementary information for defensivos (1:1 relationship)
abstract class DefensivosInfoRepository {
  /// Get defensivo info by defensivo ID (1:1 relationship)
  Future<Either<Failure, DefensivoInfo?>> getDefensivoInfoByDefensivoId(
    String defensivoId,
  );

  /// Get defensivo info by its own ID
  Future<Either<Failure, DefensivoInfo>> getDefensivoInfoById(String id);

  /// Create new defensivo info
  Future<Either<Failure, DefensivoInfo>> createDefensivoInfo(
    DefensivoInfo info,
  );

  /// Update existing defensivo info
  Future<Either<Failure, DefensivoInfo>> updateDefensivoInfo(
    DefensivoInfo info,
  );

  /// Delete defensivo info by ID
  Future<Either<Failure, Unit>> deleteDefensivoInfo(String id);

  /// Delete defensivo info by defensivo ID
  Future<Either<Failure, Unit>> deleteDefensivoInfoByDefensivoId(
    String defensivoId,
  );
}
