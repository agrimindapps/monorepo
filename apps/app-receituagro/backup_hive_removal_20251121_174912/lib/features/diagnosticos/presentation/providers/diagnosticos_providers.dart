import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/services/failure_message_service.dart';
import '../../../../core/services/i_recommendation_service.dart';
import '../../../../database/repositories/diagnostico_repository.dart';
import '../../../favoritos/data/repositories/favoritos_repository_simplified.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../../domain/services/filtering/i_diagnosticos_filter_service.dart';
import '../../domain/services/metadata/i_diagnosticos_metadata_service.dart';
import '../../domain/services/search/i_diagnosticos_search_service.dart';
import '../../domain/services/stats/i_diagnosticos_stats_service.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';

part 'diagnosticos_providers.g.dart';

// Repositories
@riverpod
IDiagnosticosRepository iDiagnosticosRepository(IDiagnosticosRepositoryRef ref) {
  return di.sl<IDiagnosticosRepository>();
}

@riverpod
DiagnosticoRepository diagnosticoRepository(DiagnosticoRepositoryRef ref) {
  return di.sl<DiagnosticoRepository>();
}

@riverpod
FavoritosRepositorySimplified favoritosRepositorySimplified(FavoritosRepositorySimplifiedRef ref) {
  return di.sl<FavoritosRepositorySimplified>();
}

// Services
@riverpod
IDiagnosticosFilterService iDiagnosticosFilterService(IDiagnosticosFilterServiceRef ref) {
  return di.sl<IDiagnosticosFilterService>();
}

@riverpod
IDiagnosticosSearchService iDiagnosticosSearchService(IDiagnosticosSearchServiceRef ref) {
  return di.sl<IDiagnosticosSearchService>();
}

@riverpod
IDiagnosticosMetadataService iDiagnosticosMetadataService(IDiagnosticosMetadataServiceRef ref) {
  return di.sl<IDiagnosticosMetadataService>();
}

@riverpod
IDiagnosticosStatsService iDiagnosticosStatsService(IDiagnosticosStatsServiceRef ref) {
  return di.sl<IDiagnosticosStatsService>();
}

@riverpod
IRecommendationService iRecommendationService(IRecommendationServiceRef ref) {
  return di.sl<IRecommendationService>();
}

@riverpod
FailureMessageService failureMessageService(FailureMessageServiceRef ref) {
  return di.sl<FailureMessageService>();
}

// UseCases
@riverpod
GetDiagnosticosUseCase getDiagnosticosUseCase(GetDiagnosticosUseCaseRef ref) {
  return di.sl<GetDiagnosticosUseCase>();
}

@riverpod
GetDiagnosticoByIdUseCase getDiagnosticoByIdUseCase(GetDiagnosticoByIdUseCaseRef ref) {
  return di.sl<GetDiagnosticoByIdUseCase>();
}
