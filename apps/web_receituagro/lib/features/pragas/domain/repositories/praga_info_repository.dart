import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/praga_info.dart';

/// PragaInfo repository interface - Domain layer
abstract class PragaInfoRepository {
  Future<Either<Failure, PragaInfo?>> getPragaInfoByPragaId(String pragaId);
  Future<Either<Failure, PragaInfo>> getPragaInfoById(String id);
  Future<Either<Failure, PragaInfo>> createPragaInfo(PragaInfo info);
  Future<Either<Failure, PragaInfo>> updatePragaInfo(PragaInfo info);
  Future<Either<Failure, PragaInfo>> savePragaInfo(PragaInfo info);
  Future<Either<Failure, void>> deletePragaInfo(String id);
  Future<Either<Failure, void>> deletePragaInfoByPragaId(String pragaId);
}
