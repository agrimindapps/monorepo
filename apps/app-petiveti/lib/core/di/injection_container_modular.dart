import 'package:get_it/get_it.dart';

import '../storage/hive_service.dart';
import 'di_module.dart';
import 'injectable_config.dart';
import 'modules/core_module.dart';

/// Modular Dependency Injection Container following SOLID principles
/// 
/// Follows SRP: Single responsibility of coordinating module registration
/// Follows OCP: Open for extension via new modules
/// Follows DIP: High-level coordination depending on abstraction
class ModularInjectionContainer {
  static final GetIt _getIt = GetIt.instance;
  
  static GetIt get instance => _getIt;

  /// Initialize all dependencies using modular approach
  static Future<void> init() async {
    // Initialize Hive with all adapters and boxes
    await HiveService.instance.init();

    // Initialize injectable dependencies (includes SharedPreferences, Firebase services, etc.)
    configureDependencies();

    // Register additional modules in dependency order
    final modules = _createModules();
    
    for (final module in modules) {
      await module.register(_getIt);
    }

    // Initialize logging service after all dependencies are registered
    await CoreModule.initializeLoggingService(_getIt);
  }

  /// Create list of modules in dependency order
  /// 
  /// Follows Dependency Inversion Principle - high level depends on abstraction
  static List<DIModule> _createModules() {
    return [
      CoreModule(),        // External services and core infrastructure
      // AuthModule(),     // Auth services now registered via @injectable
      // TODO: Add more modules in Phase 2
      // AnimalsModule(),
      // CalculatorsModule(),
      // ExpensesModule(),
      // etc.
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

/// Legacy initialization function - delegates to modular container
/// 
/// Maintains backward compatibility during Phase 1
Future<void> init() async {
  await ModularInjectionContainer.init();
}