import 'package:core/core.dart' hide Column;

import '../../domain/entities/document_type.dart';
import '../../domain/entities/legal_document.dart';
import '../../domain/repositories/legal_repository.dart';
import '../datasources/account_deletion_datasource.dart';
import '../datasources/privacy_policy_datasource.dart';
import '../datasources/terms_of_service_datasource.dart';

/// Implementation of [LegalRepository]
/// Coordinates between data sources and domain layer
class LegalRepositoryImpl implements LegalRepository {
  final PrivacyPolicyDataSource _privacyPolicyDataSource;
  final TermsOfServiceDataSource _termsOfServiceDataSource;
  final AccountDeletionDataSource _accountDeletionDataSource;

  const LegalRepositoryImpl({
    required PrivacyPolicyDataSource privacyPolicyDataSource,
    required TermsOfServiceDataSource termsOfServiceDataSource,
    required AccountDeletionDataSource accountDeletionDataSource,
  }) : _privacyPolicyDataSource = privacyPolicyDataSource,
       _termsOfServiceDataSource = termsOfServiceDataSource,
       _accountDeletionDataSource = accountDeletionDataSource;

  @override
  Future<Either<Failure, LegalDocument>> getLegalDocument(
    DocumentType documentType,
  ) async {
    try {
      switch (documentType) {
        case DocumentType.privacyPolicy:
          return await getPrivacyPolicy();
        case DocumentType.termsOfService:
          return await getTermsOfService();
        case DocumentType.accountDeletion:
          return await getAccountDeletionPolicy();
      }
    } on FormatException catch (e) {
      return Left(
        ParseFailure('Erro ao processar documento legal: ${e.message}'),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar documento legal: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, LegalDocument>> getPrivacyPolicy() async {
    try {
      final model = _privacyPolicyDataSource.getPrivacyPolicy();
      return Right(model.toEntity());
    } on FormatException catch (e) {
      return Left(
        ParseFailure('Erro ao processar documento legal: ${e.message}'),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar documento legal: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, LegalDocument>> getTermsOfService() async {
    try {
      final model = _termsOfServiceDataSource.getTermsOfService();
      return Right(model.toEntity());
    } on FormatException catch (e) {
      return Left(
        ParseFailure('Erro ao processar Termos de Serviço: ${e.message}'),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar Termos de Serviço: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, LegalDocument>> getAccountDeletionPolicy() async {
    try {
      final model = _accountDeletionDataSource.getAccountDeletionPolicy();
      return Right(model.toEntity());
    } on FormatException catch (e) {
      return Left(
        ParseFailure('Erro ao processar Política de Exclusão: ${e.message}'),
      );
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar Política de Exclusão: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<LegalDocument>>> getAllDocuments() async {
    try {
      final results = await Future.wait([
        getPrivacyPolicy(),
        getTermsOfService(),
        getAccountDeletionPolicy(),
      ]);

      final documents = <LegalDocument>[];

      for (final result in results) {
        result.fold(
          (failure) => throw Exception(failure.message),
          (document) => documents.add(document),
        );
      }

      return Right(documents);
    } catch (e) {
      return Left(
        CacheFailure('Erro ao carregar documentos legais: ${e.toString()}'),
      );
    }
  }
}
