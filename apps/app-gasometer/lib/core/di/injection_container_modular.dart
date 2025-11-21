import 'package:core/core.dart' show GetIt, InjectionContainer;

import 'di_module.dart';
import 'injection.dart';
import 'modules/account_deletion_module.dart';
import 'modules/connectivity_module.dart';
import 'modules/core_module.dart';
import 'modules/data_integrity_module.dart';
import 'modules/fuel_services_module.dart';
import 'modules/sync_module.dart';

/// Modular Dependency Injection Container following SOLID principles
///
/// Follows SRP: Single responsibility of coordinating module registration
/// Follows OCP: Open for extension via new modules
/// Follows DIP: High-level coordination depending on abstraction
class ModularInjectionContainer {
  static final GetIt _getIt = GetIt.instance;

  static GetIt get instance => _getIt;

  /// Initialize all dependencies using modular approach
  static Future<void> init({bool firebaseEnabled = false}) async {
    try {
      print('🚀 Starting GasOMeter dependency initialization...');

      // ✅ IMPORTANTE: Inicializar core package DI PRIMEIRO
      // Isso registra serviços essenciais
      print('📦 Initializing core package DI...');
      await InjectionContainer.init();
      print('✅ Core package DI initialized');

      // Configure injectable dependencies FIRST
      // This registers all @injectable dependencies from build_runner
      print('📦 Configuring injectable dependencies...');
      await configureDependencies();

      // NOTE: database_module.dart is deprecated
      // All repositories now use @lazySingleton and are registered via injectable
      // Database and repositories are automatically registered by configureDependencies()

      print('📦 Registering core modules...');
      final modules = _createModules(firebaseEnabled: firebaseEnabled);
      for (final module in modules) {
        await module.register(_getIt);
      }

      print('📦 Initializing account deletion module...');
      AccountDeletionModule.init(_getIt);

      print('📦 Initializing data integrity module...');
      DataIntegrityModule.init(_getIt);

      print('✅ GasOMeter dependencies initialized successfully');
    } catch (e, stackTrace) {
      print('❌ Error during GasOMeter dependency initialization: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Create list of modules in dependency order
  ///
  /// Follows Dependency Inversion Principle - high level depends on abstraction
  static List<DIModule> _createModules({bool firebaseEnabled = false}) {
    return [
      CoreModule(
        firebaseEnabled: firebaseEnabled,
      ), // External services and core infrastructure
      ConnectivityModule(), // Connectivity monitoring services
      FuelServicesModule(), // Fuel domain services
      SyncModule(), // Sync services
    ];
  }

  /// Reset container (useful for testing)
  static Future<void> reset() async {
    await _getIt.reset();
  }

  /// Check if a type is registered
  static bool isRegistered<T extends Object>() {
    return _getIt.isRegistered<T>();
  }
}

/// Legacy support - maintains backward compatibility during transition
///
/// This allows existing code to continue working while we migrate
final getIt = ModularInjectionContainer.instance;

/// Service Locator alias - commonly used pattern
final sl = ModularInjectionContainer.instance;

/// Legacy initialization function - delegates to modular container
///
/// Maintains backward compatibility during Phase 1
Future<void> init({bool firebaseEnabled = false}) async {
  await ModularInjectionContainer.init(firebaseEnabled: firebaseEnabled);
}
