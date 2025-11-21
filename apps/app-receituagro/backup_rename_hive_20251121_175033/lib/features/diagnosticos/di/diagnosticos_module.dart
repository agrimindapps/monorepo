import 'package:injectable/injectable.dart';
import '../domain/repositories/i_diagnosticos_repository.dart';
import '../domain/repositories/i_diagnosticos_read_repository.dart';
import '../domain/repositories/i_diagnosticos_query_repository.dart';
import '../domain/repositories/i_diagnosticos_search_repository.dart';
import '../domain/repositories/i_diagnosticos_stats_repository.dart';
import '../domain/repositories/i_diagnosticos_metadata_repository.dart';
import '../domain/repositories/i_diagnosticos_validation_repository.dart';
import '../domain/repositories/i_diagnosticos_recommendation_repository.dart';

@module
abstract class DiagnosticosModule {
  @lazySingleton
  IDiagnosticosReadRepository readRepository(
          IDiagnosticosRepository repository) =>
      repository as IDiagnosticosReadRepository;

  @lazySingleton
  IDiagnosticosQueryRepository queryRepository(
          IDiagnosticosRepository repository) =>
      repository as IDiagnosticosQueryRepository;

  @lazySingleton
  IDiagnosticosSearchRepository searchRepository(
          IDiagnosticosRepository repository) =>
      repository as IDiagnosticosSearchRepository;

  @lazySingleton
  IDiagnosticosStatsRepository statsRepository(
          IDiagnosticosRepository repository) =>
      repository as IDiagnosticosStatsRepository;

  @lazySingleton
  IDiagnosticosMetadataRepository metadataRepository(
          IDiagnosticosRepository repository) =>
      repository as IDiagnosticosMetadataRepository;

  @lazySingleton
  IDiagnosticosValidationRepository validationRepository(
          IDiagnosticosRepository repository) =>
      repository as IDiagnosticosValidationRepository;

  @lazySingleton
  IDiagnosticosRecommendationRepository recommendationRepository(
          IDiagnosticosRepository repository) =>
      repository as IDiagnosticosRecommendationRepository;
}
