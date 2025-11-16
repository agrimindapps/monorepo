import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../database/providers/database_providers.dart';
import '../../features/busca_avancada/data/datasources/busca_local_datasource.dart';
import '../../features/busca_avancada/data/repositories/busca_repository_impl.dart';
import '../../features/busca_avancada/data/services/busca_metadata_service.dart';
import '../../features/busca_avancada/data/services/busca_validation_service.dart';
import '../../features/busca_avancada/domain/repositories/i_busca_repository.dart';
import '../../features/busca_avancada/domain/services/i_busca_metadata_service.dart';
import '../../features/busca_avancada/domain/services/i_busca_validation_service.dart';
import '../../features/busca_avancada/domain/usecases/busca_usecase.dart';
import '../../features/comentarios/data/datasources/comentarios_local_datasource.dart';
import '../../features/comentarios/data/repositories/comentarios_repository_impl.dart';
import '../../features/comentarios/domain/repositories/i_comentarios_read_repository.dart';
import '../../features/comentarios/domain/repositories/i_comentarios_repository.dart';
import '../../features/comentarios/domain/repositories/i_comentarios_write_repository.dart';
import '../../features/comentarios/domain/usecases/add_comentario_usecase.dart';
import '../../features/comentarios/domain/usecases/delete_comentario_usecase.dart';
import '../../features/comentarios/domain/usecases/get_comentarios_usecase.dart';
import '../../features/diagnosticos/data/datasources/diagnostico_local_datasource.dart';
import '../../features/diagnosticos/data/repositories/diagnosticos_repository_impl.dart';
import '../../features/diagnosticos/domain/repositories/i_diagnosticos_repository.dart';
import '../../features/diagnosticos/domain/services/filtering/diagnosticos_filter_service.dart';
import '../../features/diagnosticos/domain/services/filtering/i_diagnosticos_filter_service.dart';
import '../../features/diagnosticos/domain/services/metadata/diagnosticos_metadata_service.dart';
import '../../features/diagnosticos/domain/services/metadata/i_diagnosticos_metadata_service.dart';
import '../../features/diagnosticos/domain/services/search/diagnosticos_search_service.dart';
import '../../features/diagnosticos/domain/services/search/i_diagnosticos_search_service.dart';
import '../../features/diagnosticos/domain/services/stats/diagnosticos_stats_service.dart';
import '../../features/diagnosticos/domain/services/stats/i_diagnosticos_stats_service.dart';
import '../../features/diagnosticos/domain/usecases/get_diagnosticos_usecase.dart';
import '../../features/pragas/data/services/pragas_query_service.dart';
import '../../features/pragas/data/services/pragas_search_service.dart';
import '../../features/pragas/data/services/pragas_stats_service.dart';
import '../services/failure_message_service.dart';
import '../services/filter_service.dart';
import '../services/i_recommendation_service.dart';
import '../services/recommendation_service.dart';
import '../services/stats_service.dart';
import 'core_providers.dart';

part 'domain_providers.g.dart';

// ========== BUSCA AVANCADA ==========

/// Provider do datasource local de busca
@riverpod
BuscaLocalDatasource buscaLocalDatasource(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return BuscaLocalDatasource(db);
}

/// Provider do repositório de busca
@riverpod
IBuscaRepository buscaRepository(Ref ref) {
  final datasource = ref.watch(buscaLocalDatasourceProvider);
  return BuscaRepositoryImpl(datasource);
}

/// Provider do serviço de metadados de busca
@riverpod
IBuscaMetadataService buscaMetadataService(Ref ref) {
  final db = ref.watch(receituagroDatabaseProvider);
  return BuscaMetadataService(db);
}

/// Provider do serviço de validação de busca
@riverpod
IBuscaValidationService buscaValidationService(Ref ref) {
  return BuscaValidationService();
}

/// Provider do use case de busca
@riverpod
BuscaUseCase buscaUseCase(Ref ref) {
  final repository = ref.watch(buscaRepositoryProvider);
  return BuscaUseCase(repository);
}

// ========== COMENTARIOS ==========

/// Provider do datasource local de comentários
@riverpod
ComentariosLocalDatasource comentariosLocalDatasource(Ref ref) {
  final comentarioRepo = ref.watch(comentarioRepositoryProvider);
  return ComentariosLocalDatasource(comentarioRepo);
}

/// Provider do repositório de comentários (implementação completa)
@riverpod
IComentariosRepository comentariosRepository(Ref ref) {
  final datasource = ref.watch(comentariosLocalDatasourceProvider);
  return ComentariosRepositoryImpl(datasource);
}

/// Provider do repositório de leitura de comentários
@riverpod
IComentariosReadRepository comentariosReadRepository(Ref ref) {
  final repo = ref.watch(comentariosRepositoryProvider);
  return repo; // ComentariosRepositoryImpl implements IComentariosReadRepository
}

/// Provider do repositório de escrita de comentários
@riverpod
IComentariosWriteRepository comentariosWriteRepository(Ref ref) {
  final repo = ref.watch(comentariosRepositoryProvider);
  return repo; // ComentariosRepositoryImpl implements IComentariosWriteRepository
}

/// Provider do use case de obter comentários
@riverpod
GetComentariosUseCase getComentariosUseCase(Ref ref) {
  final readRepo = ref.watch(comentariosReadRepositoryProvider);
  return GetComentariosUseCase(readRepo);
}

/// Provider do use case de adicionar comentário
@riverpod
AddComentarioUseCase addComentarioUseCase(Ref ref) {
  final writeRepo = ref.watch(comentariosWriteRepositoryProvider);
  return AddComentarioUseCase(writeRepo);
}

/// Provider do use case de deletar comentário
@riverpod
DeleteComentarioUseCase deleteComentarioUseCase(Ref ref) {
  final writeRepo = ref.watch(comentariosWriteRepositoryProvider);
  return DeleteComentarioUseCase(writeRepo);
}

// ========== DIAGNOSTICOS ==========

/// Provider do datasource local de diagnósticos
@riverpod
DiagnosticoLocalDatasource diagnosticoLocalDatasource(Ref ref) {
  final diagnosticoRepo = ref.watch(diagnosticoRepositoryProvider);
  return DiagnosticoLocalDatasource(diagnosticoRepo);
}

/// Provider do repositório de diagnósticos
@riverpod
IDiagnosticosRepository diagnosticosRepository(Ref ref) {
  final datasource = ref.watch(diagnosticoLocalDatasourceProvider);
  return DiagnosticosRepositoryImpl(datasource);
}

/// Provider do serviço de filtros de diagnósticos
@riverpod
IDiagnosticosFilterService diagnosticosFilterService(Ref ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return DiagnosticosFilterService(repository);
}

/// Provider do serviço de busca de diagnósticos
@riverpod
IDiagnosticosSearchService diagnosticosSearchService(Ref ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return DiagnosticosSearchService(repository);
}

/// Provider do serviço de metadados de diagnósticos
@riverpod
IDiagnosticosMetadataService diagnosticosMetadataService(Ref ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return DiagnosticosMetadataService(repository);
}

/// Provider do serviço de estatísticas de diagnósticos
@riverpod
IDiagnosticosStatsService diagnosticosStatsService(Ref ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return DiagnosticosStatsService(repository);
}

/// Provider do use case GetDiagnosticos
@riverpod
GetDiagnosticosUseCase getDiagnosticosUseCase(Ref ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return GetDiagnosticosUseCase(repository);
}

/// Provider do use case GetDiagnosticoById
@riverpod
GetDiagnosticoByIdUseCase getDiagnosticoByIdUseCase(Ref ref) {
  final repository = ref.watch(diagnosticosRepositoryProvider);
  return GetDiagnosticoByIdUseCase(repository);
}

// ========== PRAGAS ==========

/// Provider do serviço de query de pragas
@riverpod
PragasQueryService pragasQueryService(Ref ref) {
  final pragasRepo = ref.watch(pragasRepositoryProvider);
  return PragasQueryService(pragasRepo);
}

/// Provider do serviço de busca de pragas
@riverpod
PragasSearchService pragasSearchService(Ref ref) {
  final pragasRepo = ref.watch(pragasRepositoryProvider);
  return PragasSearchService(pragasRepo);
}

/// Provider do serviço de estatísticas de pragas
@riverpod
PragasStatsService pragasStatsService(Ref ref) {
  final pragasRepo = ref.watch(pragasRepositoryProvider);
  return PragasStatsService(pragasRepo);
}

// ========== SHARED SERVICES ==========

/// Provider do serviço de mensagens de falha
@riverpod
FailureMessageService failureMessageService(Ref ref) {
  return FailureMessageService();
}

/// Provider do serviço de recomendações
@riverpod
IRecommendationService recommendationService(Ref ref) {
  final diagnosticosRepo = ref.watch(diagnosticosRepositoryProvider);
  return RecommendationService(diagnosticosRepo);
}

/// Provider do serviço de filtros genérico
@riverpod
FilterService filterService(Ref ref) {
  return FilterService();
}

/// Provider do serviço de estatísticas genérico
@riverpod
StatsService statsService(Ref ref) {
  return StatsService();
}
