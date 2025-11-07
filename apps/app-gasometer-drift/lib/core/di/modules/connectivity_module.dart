import 'package:core/core.dart' show ConnectivityService, GetIt;
import 'package:flutter/foundation.dart';

import '../../services/auto_sync_service.dart';
import '../../services/connectivity_state_manager.dart';
import '../di_module.dart';

/// Connectivity module responsible for connectivity monitoring services
///
/// Follows SRP: Single responsibility of connectivity services registration
/// Follows OCP: Open for extension via DI module interface
class ConnectivityModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    await _registerConnectivityServices(getIt);
  }

  Future<void> _registerConnectivityServices(GetIt getIt) async {
    try {
      // Note: ConnectivityService is registered via @injectable in injection.config.dart
      // Commenting out manual registration to avoid duplicate registration error

      // Register ConnectivityStateManager for state persistence
      getIt.registerLazySingleton<ConnectivityStateManager>(
        () => ConnectivityStateManager(),
      );

      // Register AutoSyncService for periodic background sync
      getIt.registerLazySingleton<AutoSyncService>(
        () => AutoSyncService(
          connectivityService: getIt<ConnectivityService>(),
        ),
      );

      debugPrint('✅ Connectivity services registered successfully');
    } catch (e) {
      debugPrint('⚠️ Warning: Could not register connectivity services: $e');
      rethrow;
    }
  }
}
