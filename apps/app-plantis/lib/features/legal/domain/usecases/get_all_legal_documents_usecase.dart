import 'package:core/core.dart';

import '../entities/legal_document.dart';
import '../repositories/legal_repository.dart';

/// Use case to get all legal documents
class GetAllLegalDocumentsUseCase {
  final LegalRepository _repository;

  const GetAllLegalDocumentsUseCase(this._repository);

  /// Executes the use case
  ///
  /// Returns [Right(List<LegalDocument>)] on success
  /// Returns [Left(Failure)] on error
  Future<Either<Failure, List<LegalDocument>>> call() async {
    return await _repository.getAllDocuments();
  }
}
