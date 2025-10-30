import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../data/services/pragas_cultura_data_service.dart';
import '../../data/services/pragas_cultura_query_service.dart';
import '../../data/services/pragas_cultura_sort_service.dart';
import '../../data/services/pragas_cultura_statistics_service.dart';
import '../services/pragas_cultura_error_message_service.dart';
import 'pragas_cultura_page_view_model.dart';

final sl = GetIt.instance;

/// Provider para o Query Service
final pragasCulturaQueryServiceProvider = Provider<IPragasCulturaQueryService>((
  ref,
) {
  return sl<IPragasCulturaQueryService>();
});

/// Provider para o Sort Service
final pragasCulturaSortServiceProvider = Provider<IPragasCulturaSortService>((
  ref,
) {
  return sl<IPragasCulturaSortService>();
});

/// Provider para o Statistics Service
final pragasCulturaStatisticsServiceProvider =
    Provider<IPragasCulturaStatisticsService>((ref) {
      return sl<IPragasCulturaStatisticsService>();
    });

/// Provider para o Data Service
final pragasCulturaDataServiceProvider = Provider<IPragasCulturaDataService>((
  ref,
) {
  return sl<IPragasCulturaDataService>();
});

/// Provider para o Error Message Service
final pragasCulturaErrorServiceProvider =
    Provider<PragasCulturaErrorMessageService>((ref) {
      return sl<PragasCulturaErrorMessageService>();
    });

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
