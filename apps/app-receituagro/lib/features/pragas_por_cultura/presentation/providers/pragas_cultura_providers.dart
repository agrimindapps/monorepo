import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../data/services/pragas_cultura_data_service.dart';
import '../../data/services/pragas_cultura_query_service.dart';
import '../../data/services/pragas_cultura_sort_service.dart';
import '../../data/services/pragas_cultura_statistics_service.dart';
import '../services/pragas_cultura_error_message_service.dart';
import 'pragas_cultura_page_view_model.dart';

part 'pragas_cultura_providers.g.dart';

/// Provider para o Query Service
@riverpod
IPragasCulturaQueryService pragasCulturaQueryService(PragasCulturaQueryServiceRef ref) {
  return di.sl<IPragasCulturaQueryService>();
}

/// Provider para o Sort Service
@riverpod
IPragasCulturaSortService pragasCulturaSortService(PragasCulturaSortServiceRef ref) {
  return di.sl<IPragasCulturaSortService>();
}

/// Provider para o Statistics Service
@riverpod
IPragasCulturaStatisticsService pragasCulturaStatisticsService(PragasCulturaStatisticsServiceRef ref) {
  return di.sl<IPragasCulturaStatisticsService>();
}

/// Provider para o Data Service
@riverpod
IPragasCulturaDataService pragasCulturaDataService(PragasCulturaDataServiceRef ref) {
  return di.sl<IPragasCulturaDataService>();
}

/// Provider para o Error Message Service
@riverpod
PragasCulturaErrorMessageService pragasCulturaErrorService(PragasCulturaErrorServiceRef ref) {
  return di.sl<PragasCulturaErrorMessageService>();
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
