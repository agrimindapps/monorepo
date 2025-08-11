import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import '../entities/space.dart';

abstract class SpacesRepository {
  Future<Either<Failure, List<Space>>> getSpaces();
  Future<Either<Failure, Space>> getSpaceById(String id);
  Future<Either<Failure, List<Space>>> searchSpaces(String query);
  Future<Either<Failure, Space>> addSpace(Space space);
  Future<Either<Failure, Space>> updateSpace(Space space);
  Future<Either<Failure, void>> deleteSpace(String id);
  Future<Either<Failure, int>> getPlantCountBySpace(String spaceId);
}