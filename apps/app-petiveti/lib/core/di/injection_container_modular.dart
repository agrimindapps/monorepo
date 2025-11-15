import 'package:core/core.dart' show GetIt;

import 'di_module.dart';
import 'injectable_config.dart';
import 'modules/animals_module.dart';
import 'modules/appointments_module.dart';
import 'modules/core_module.dart';
import 'modules/home_module.dart';
// import 'modules/expenses_module.dart'; // TEMP DISABLED - 30+ errors
// import 'modules/medications_module.dart'; // TEMP DISABLED - 20+ errors (missing datasource methods)
import 'modules/subscription_module.dart';
// import 'modules/vaccines_module.dart'; // TEMP DISABLED - 7 errors
// import 'modules/weights_module.dart'; // TEMP DISABLED - 4 errors

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
    // Hive removed - using Drift for all persistence
    configureDependencies();
    final modules = _createModules();

    for (final module in modules) {
      await module.register(_getIt);
    }
    await CoreModule.initializeLoggingService(_getIt);
  }

  /// Create list of modules in dependency order
  ///
  /// Follows Dependency Inversion Principle - high level depends on abstraction
  static List<DIModule> _createModules() {
    return [
      CoreModule(), // External services and core infrastructure
      HomeModule(), // Home/Dashboard feature ✅ NEW PHASE 3
      SubscriptionModule(), // Subscription services (uses core ISubscriptionRepository)
      AnimalsModule(), // Animals feature ✅ PRIORITY 1 - CORE MVP
      AppointmentsModule(), // Appointments feature ✅ PRIORITY 2 - CORE MVP
      // ExpensesModule(), // TEMP DISABLED - 30+ errors (ambiguous imports, missing methods)
      // MedicationsModule(), // TEMP DISABLED - 20+ errors (missing datasource methods: searchMedications, getMedicationHistory, hardDeleteMedication, discontinueMedication, watchMedications, watchActiveMedications, checkMedicationConflicts, getActiveMedicationsCount)
      // VaccinesModule(), // TEMP DISABLED - 7 errors (userId parameter issues)
      // WeightsModule(), // TEMP DISABLED - 4 errors (missing datasource methods)
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
