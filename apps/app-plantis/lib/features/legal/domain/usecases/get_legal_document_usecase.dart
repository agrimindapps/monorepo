import 'package:core/core.dart';

import '../entities/document_type.dart';
import '../entities/legal_document.dart';
import '../repositories/legal_repository.dart';

/// Use case to get a legal document by its type
class GetLegalDocumentUseCase {
  final LegalRepository _repository;

  const GetLegalDocumentUseCase(this._repository);

  /// Executes the use case
  ///
  /// [documentType] - The type of document to retrieve
  ///
  /// Returns [Right(LegalDocument)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, LegalDocument>> call(DocumentType documentType) async {
    return await _repository.getLegalDocument(documentType);
  }
}
