import 'package:get_it/get_it.dart';

import '../presentation/services/pragas_cultura_error_message_service.dart';
import '../presentation/services/pragas_cultura_sort_strategy_service.dart';

/// Dependency Injection Configuration for Pragas por Cultura feature
///
/// Registers services that are not automatically registered by @injectable:
/// - PragasCulturaErrorMessageService: Centralized error message management
/// - PragasCulturaSortService: Sort strategy pattern implementation
///
/// All other dependencies (Repository, UseCases, DataSources) are registered
/// via @injectable annotation and build_runner generated code.
class PragasCulturaDI {
  static void registerDependencies(GetIt sl) {
    // Register Error Message Service
    if (!sl.isRegistered<PragasCulturaErrorMessageService>()) {
      sl.registerLazySingleton<PragasCulturaErrorMessageService>(
        () => PragasCulturaErrorMessageService(),
      );
    }

    // Register Sort Strategy Service (already registered via @lazySingleton)
    // PragasCulturaSortService is auto-registered by Injectable
  }
}
