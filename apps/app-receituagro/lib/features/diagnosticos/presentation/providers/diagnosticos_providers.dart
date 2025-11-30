import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/failure_message_service.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/diagnosticos_repository.dart';
import '../../data/repositories/diagnosticos_repository_impl.dart';
import '../../domain/repositories/i_diagnosticos_repository.dart';
import '../../domain/services/filtering/diagnosticos_filter_service.dart';
import '../../domain/services/filtering/i_diagnosticos_filter_service.dart';
import '../../domain/services/metadata/diagnosticos_metadata_service.dart';
import '../../domain/services/metadata/i_diagnosticos_metadata_service.dart';
import '../../domain/services/search/diagnosticos_search_service.dart';
import '../../domain/services/search/i_diagnosticos_search_service.dart';
import '../../domain/services/stats/diagnosticos_stats_service.dart';
import '../../domain/services/stats/i_diagnosticos_stats_service.dart';
import '../../domain/usecases/get_diagnosticos_usecase.dart';

part 'diagnosticos_providers.g.dart';

// Services
@Riverpod(keepAlive: true)
IDiagnosticosFilterService diagnosticosFilterService(
    Ref ref) {
  return DiagnosticosFilterService(ref.watch(iDiagnosticosRepositoryProvider));
}

@Riverpod(keepAlive: true)
IDiagnosticosSearchService diagnosticosSearchService(
    Ref ref) {
  return DiagnosticosSearchService(ref.watch(iDiagnosticosRepositoryProvider));
}

@Riverpod(keepAlive: true)
IDiagnosticosMetadataService diagnosticosMetadataService(
    Ref ref) {
  return DiagnosticosMetadataService(
      ref.watch(iDiagnosticosRepositoryProvider));
}

@Riverpod(keepAlive: true)
IDiagnosticosStatsService diagnosticosStatsService(
    Ref ref) {
  return DiagnosticosStatsService(ref.watch(iDiagnosticosRepositoryProvider));
}

@Riverpod(keepAlive: true)
FailureMessageService failureMessageService(Ref ref) {
  return FailureMessageService();
}

// Repository
@Riverpod(keepAlive: true)
IDiagnosticosRepository iDiagnosticosRepository(
    Ref ref) {
  final baseRepo = ref.watch(diagnosticoRepositoryProvider);
  final wrapperRepo = DiagnosticosRepository(baseRepo);

  return DiagnosticosRepositoryImpl(
    wrapperRepo,
    ref.watch(fitossanitariosRepositoryProvider),
    ref.watch(culturasRepositoryProvider),
    ref.watch(pragasRepositoryProvider),
  );
}

// UseCases
@Riverpod(keepAlive: true)
GetDiagnosticosUseCase getDiagnosticosUseCase(Ref ref) {
  return GetDiagnosticosUseCase(ref.watch(iDiagnosticosRepositoryProvider));
}

@Riverpod(keepAlive: true)
GetDiagnosticoByIdUseCase getDiagnosticoByIdUseCase(
    Ref ref) {
  return GetDiagnosticoByIdUseCase(ref.watch(iDiagnosticosRepositoryProvider));
}
