import 'package:core/core.dart';

import '../entities/document_type.dart';
import '../entities/legal_document.dart';

/// Repository interface for legal documents
/// Follows the Repository pattern and returns Either<Failure, T>
abstract class LegalRepository {
  /// Get a legal document by its type
  ///
  /// Returns [Right(LegalDocument)] on success
  /// Returns [Left(Failure)] on error:
  /// - [CacheFailure] if document cannot be loaded
  /// - [DataParsingFailure] if document format is invalid
  Future<Either<Failure, LegalDocument>> getLegalDocument(
    DocumentType documentType,
  );

  /// Get the Privacy Policy document
  Future<Either<Failure, LegalDocument>> getPrivacyPolicy();

  /// Get the Terms of Service document
  Future<Either<Failure, LegalDocument>> getTermsOfService();

  /// Get the Account Deletion Policy document
  Future<Either<Failure, LegalDocument>> getAccountDeletionPolicy();

  /// Get all available legal documents
  Future<Either<Failure, List<LegalDocument>>> getAllDocuments();
}
