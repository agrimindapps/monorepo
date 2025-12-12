import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/legal_document_entity.dart';
import '../../domain/repositories/i_legal_repository.dart';
import '../datasources/legal_local_datasource.dart';
import '../datasources/legal_remote_datasource.dart';

class LegalRepositoryImpl implements ILegalRepository {

  LegalRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  final ILegalRemoteDataSource remoteDataSource;
  final ILegalLocalDataSource localDataSource;

  @override
  Future<Either<Failure, LegalDocumentEntity>> getLegalDocument(
    LegalDocumentType type,
  ) async {
    try {
      // Try cache first
      try {
        final cachedDoc = await localDataSource.getCachedDocument(type);
        return Right(cachedDoc);
      } catch (_) {
        // If cache fails, fetch from remote
      }

      final document = await remoteDataSource.getLegalDocument(type);
      await localDataSource.cacheDocument(document);
      return Right(document);
    } on ServerException {
      return const Left(ServerFailure('Failed to fetch legal document'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getLatestVersion(
    LegalDocumentType type,
  ) async {
    try {
      final version = await remoteDataSource.getLatestVersion(type);
      return Right(version);
    } on ServerException {
      return const Left(ServerFailure('Failed to fetch version'));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptLegalDocument(
    String documentId,
    String version,
  ) async {
    try {
      await localDataSource.saveAcceptance(documentId, version);
      return const Right(unit);
    } catch (e) {
      return const Left(CacheFailure('Failed to save acceptance'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasAcceptedLatestVersion(
    LegalDocumentType type,
  ) async {
    try {
      final latestVersion = await remoteDataSource.getLatestVersion(type);
      final acceptedVersion = await localDataSource.getAcceptedVersion(type);
      return Right(acceptedVersion == latestVersion);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
