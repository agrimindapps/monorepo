import 'package:get_it/get_it.dart';

/// Interface for DI modules following Interface Segregation Principle
/// 
/// Follows ISP: Each module implements only what it needs
/// Follows DIP: High-level modules depend on abstraction
abstract class DIModule {
  /// Register dependencies for this module
  Future<void> register(GetIt getIt);
}

/// Factory for creating DI modules
/// 
/// Follows Factory Pattern for module instantiation
class DIModuleFactory {
  static const Map<String, DIModule Function()> _modules = {};
  
  /// Register a module factory
  static void registerModule(String name, DIModule Function() factory) {
    // This would be implemented if we need dynamic module loading
  }
  
  /// Create all standard modules
  static List<DIModule> createStandardModules() {
    // Return standard modules - will be implemented in main injection container
    return [];
  }
}