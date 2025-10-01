import 'package:get_it/get_it.dart';

import '../storage/hive_service.dart';
import 'di_module.dart';
import 'injection.dart';
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
    try {
      print('🚀 Starting GasOMeter dependency initialization...');
      
      // Initialize Hive with all adapters and boxes
      print('📦 Initializing Hive...');
      await HiveService.instance.init();
      print('✅ Hive initialized');

      // Register core modules FIRST (provides base services for injectable)
      print('📦 Registering core modules...');
      final modules = _createModules();
      for (final module in modules) {
        await module.register(_getIt);
      }

      // Initialize injectable dependencies AFTER core modules
      // (now EnhancedAnalyticsService is available for GasometerAnalyticsService)
      print('📦 Configuring injectable dependencies...');
      await configureDependencies();

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
  static List<DIModule> _createModules() {
    return [
      CoreModule(), // External services and core infrastructure
      // TODO: Add more modules in subsequent phases
      // AuthModule(),
      // VehiclesModule(),
      // FuelModule(),
      // MaintenanceModule(),
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

/// Service Locator alias - commonly used pattern
final sl = ModularInjectionContainer.instance;

/// Legacy initialization function - delegates to modular container
///
/// Maintains backward compatibility during Phase 1
Future<void> init() async {
  await ModularInjectionContainer.init();
}