import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/failure_message_service.dart';
import '../services/filter_service.dart';
import '../services/stats_service.dart';

part 'domain_providers.g.dart';

// ========== BUSCA AVANCADA ==========
// Commented out due to missing implementations
/*
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
*/

// ========== COMENTARIOS ==========
// Commented out due to constructor issues
/*
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
*/

// ========== DIAGNOSTICOS ==========
// Commented out due to missing implementations
/*
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
*/

// ========== PRAGAS ==========
// Commented out due to constructor issues
/*
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
*/

// ========== SHARED SERVICES ==========

/// Provider do serviço de mensagens de falha
@riverpod
FailureMessageService failureMessageService(Ref ref) {
  return FailureMessageService();
}

/// Provider do serviço de recomendações
// Commented out due to missing diagnosticosRepositoryProvider
/*@riverpod
IRecommendationService recommendationService(Ref ref) {
  final diagnosticosRepo = ref.watch(diagnosticosRepositoryProvider);
  return RecommendationService(diagnosticosRepo);
}*/

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
