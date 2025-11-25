import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../database/providers/database_providers.dart';
import '../../data/datasources/pragas_cultura_integration_datasource.dart';
import '../../data/datasources/pragas_cultura_local_datasource.dart';
import '../../data/repositories/pragas_cultura_repository_impl.dart';
import '../../data/services/pragas_cultura_data_service.dart';
import '../../data/services/pragas_cultura_query_service.dart';
import '../../data/services/pragas_cultura_sort_service.dart';
import '../../data/services/pragas_cultura_statistics_service.dart';
import '../../domain/repositories/i_pragas_cultura_repository.dart';
import '../services/pragas_cultura_error_message_service.dart';
import 'pragas_cultura_page_view_model.dart';

part 'pragas_cultura_providers.g.dart';

/// Provider para o Local DataSource
@riverpod
PragasCulturaLocalDataSource pragasCulturaLocalDataSource(Ref ref) {
  return PragasCulturaLocalDataSource();
}

/// Provider para o Integration DataSource
@riverpod
PragasCulturaIntegrationDataSource pragasCulturaIntegrationDataSource(Ref ref) {
  return PragasCulturaIntegrationDataSource(
    ref.watch(pragasRepositoryProvider),
    ref.watch(diagnosticoRepositoryProvider),
    ref.watch(fitossanitariosRepositoryProvider),
  );
}

/// Provider para o Repository
@riverpod
IPragasCulturaRepository iPragasCulturaRepository(Ref ref) {
  return PragasCulturaRepositoryImpl(
    integrationDataSource: ref.watch(pragasCulturaIntegrationDataSourceProvider),
    localDataSource: ref.watch(pragasCulturaLocalDataSourceProvider),
    culturaRepository: ref.watch(culturasRepositoryProvider),
    fitossanitarioRepository: ref.watch(fitossanitariosRepositoryProvider),
    errorService: ref.watch(pragasCulturaErrorServiceProvider),
  );
}

/// Provider para o Query Service
@riverpod
IPragasCulturaQueryService pragasCulturaQueryService(Ref ref) {
  return PragasCulturaQueryService();
}

/// Provider para o Sort Service
@riverpod
IPragasCulturaSortService pragasCulturaSortService(Ref ref) {
  return PragasCulturaSortService();
}

/// Provider para o Statistics Service
@riverpod
IPragasCulturaStatisticsService pragasCulturaStatisticsService(Ref ref) {
  return PragasCulturaStatisticsService();
}

/// Provider para o Data Service
@riverpod
IPragasCulturaDataService pragasCulturaDataService(Ref ref) {
  return PragasCulturaDataService(
    repository: ref.watch(iPragasCulturaRepositoryProvider),
  );
}

/// Provider para o Error Message Service
@riverpod
PragasCulturaErrorMessageService pragasCulturaErrorService(Ref ref) {
  return PragasCulturaErrorMessageService();
}

/// StateNotifierProvider para o ViewModel
final pragasCulturaPageViewModelProvider =
    StateNotifierProvider<PragasCulturaPageViewModel, PragasCulturaPageState>((
      ref,
    ) {
      final queryService = ref.watch(pragasCulturaQueryServiceProvider);
      final sortService = ref.watch(pragasCulturaSortServiceProvider);
      final statisticsService = ref.watch(
        pragasCulturaStatisticsServiceProvider,
      );
      final dataService = ref.watch(pragasCulturaDataServiceProvider);
      final errorService = ref.watch(pragasCulturaErrorServiceProvider);

      return PragasCulturaPageViewModel(
        dataService: dataService,
        queryService: queryService,
        sortService: sortService,
        statisticsService: statisticsService,
        errorService: errorService,
      );
    });
