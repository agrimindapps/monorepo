import 'package:core/core.dart';

import '../../services/data_integrity_service.dart';

/// DI Module para Data Integrity Service
///
/// Registra o DataIntegrityService para uso em todo o app
class DataIntegrityModule {
  static void init(GetIt getIt) {
    // Register DataIntegrityService as singleton
    getIt.registerLazySingleton<DataIntegrityService>(
      () => DataIntegrityService(
        getIt<ILocalStorageRepository>(),
      ),
    );
  }
}
