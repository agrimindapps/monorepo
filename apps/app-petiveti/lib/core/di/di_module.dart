import 'package:get_it/get_it.dart';

/// Interface for DI modules following Interface Segregation Principle
/// 
/// Follows ISP: Each module implements only what it needs
/// Follows DIP: High-level modules depend on abstraction
abstract class DIModule {
  /// Register dependencies for this module
  Future<void> register(GetIt getIt);
}

