import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/legal_document_entity.dart';

abstract class ILegalRepository {
  Future<Either<Failure, LegalDocumentEntity>> getLegalDocument(
    LegalDocumentType type,
  );
  Future<Either<Failure, String>> getLatestVersion(LegalDocumentType type);
  Future<Either<Failure, Unit>> acceptLegalDocument(
    String documentId,
    String version,
  );
  Future<Either<Failure, bool>> hasAcceptedLatestVersion(
    LegalDocumentType type,
  );
}
