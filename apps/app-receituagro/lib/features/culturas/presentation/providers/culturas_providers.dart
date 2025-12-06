import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/failure_message_service.dart';
import '../../../../database/providers/database_providers.dart';
import '../../data/repositories/culturas_repository_impl.dart';
import '../../data/services/culturas_query_service.dart';
import '../../data/services/culturas_search_service.dart';
import '../../domain/repositories/i_culturas_repository.dart';
import '../../domain/usecases/get_culturas_usecase.dart';

part 'culturas_providers.g.dart';

@riverpod
ICulturasQueryService culturasQueryService(Ref ref) {
  return CulturasQueryService();
}

@riverpod
ICulturasSearchService culturasSearchService(Ref ref) {
  return CulturasSearchService();
}

@riverpod
ICulturasRepository culturasRepositoryImpl(Ref ref) {
  final driftRepo = ref.watch(culturasRepositoryProvider);
  final queryService = ref.watch(culturasQueryServiceProvider);
  final searchService = ref.watch(culturasSearchServiceProvider);

  return CulturasRepositoryImpl(driftRepo, queryService, searchService);
}

@riverpod
GetCulturasUseCase getCulturasUseCase(Ref ref) {
  final repo = ref.watch(culturasRepositoryImplProvider);
  return GetCulturasUseCase(repo);
}

@riverpod
FailureMessageService failureMessageService(Ref ref) {
  return FailureMessageService();
}
