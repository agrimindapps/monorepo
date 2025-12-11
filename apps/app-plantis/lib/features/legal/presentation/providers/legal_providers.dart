import 'package:core/core.dart' hide Column;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/account_deletion_datasource.dart';
import '../../data/datasources/privacy_policy_datasource.dart';
import '../../data/datasources/terms_of_service_datasource.dart';
import '../../data/repositories/legal_repository_impl.dart';
import '../../domain/entities/document_type.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/repositories/legal_repository.dart';
import '../../domain/usecases/get_all_legal_documents_usecase.dart';
import '../../domain/usecases/get_legal_document_usecase.dart';

part 'legal_providers.g.dart';

// ===================================================================
// Data Sources
// ===================================================================

@riverpod
PrivacyPolicyDataSource privacyPolicyDataSource(Ref ref) {
  return PrivacyPolicyDataSource();
}

@riverpod
TermsOfServiceDataSource termsOfServiceDataSource(Ref ref) {
  return TermsOfServiceDataSource();
}

@riverpod
AccountDeletionDataSource accountDeletionDataSource(Ref ref) {
  return AccountDeletionDataSource();
}

// ===================================================================
// Repository
// ===================================================================

@riverpod
LegalRepository legalRepository(Ref ref) {
  return LegalRepositoryImpl(
    privacyPolicyDataSource: ref.watch(privacyPolicyDataSourceProvider),
    termsOfServiceDataSource: ref.watch(termsOfServiceDataSourceProvider),
    accountDeletionDataSource: ref.watch(accountDeletionDataSourceProvider),
  );
}

// ===================================================================
// Use Cases
// ===================================================================

@riverpod
GetLegalDocumentUseCase getLegalDocumentUseCase(Ref ref) {
  return GetLegalDocumentUseCase(ref.watch(legalRepositoryProvider));
}

@riverpod
GetAllLegalDocumentsUseCase getAllLegalDocumentsUseCase(Ref ref) {
  return GetAllLegalDocumentsUseCase(ref.watch(legalRepositoryProvider));
}

// ===================================================================
// State Notifiers
// ===================================================================

/// State for a legal document
@riverpod
Future<LegalDocument> legalDocument(Ref ref, DocumentType documentType) async {
  final useCase = ref.watch(getLegalDocumentUseCaseProvider);
  final result = await useCase(documentType);

  return result.fold(
    (Failure failure) => throw Exception(failure.message),
    (LegalDocument document) => document,
  );
}

/// State for all legal documents
@riverpod
Future<List<LegalDocument>> allLegalDocuments(Ref ref) async {
  final useCase = ref.watch(getAllLegalDocumentsUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (Failure failure) => throw Exception(failure.message),
    (List<LegalDocument> documents) => documents,
  );
}
