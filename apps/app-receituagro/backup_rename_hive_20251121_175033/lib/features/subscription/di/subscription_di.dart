import 'package:get_it/get_it.dart';

import '../presentation/services/subscription_error_message_service.dart';

/// Dependency Injection Configuration for Subscription feature
///
/// Registers services that are not automatically registered by @injectable:
/// - SubscriptionErrorMessageService: Centralized error message management
///
/// All other dependencies (Repository, UseCases) are registered
/// via @injectable/@LazySingleton annotation and build_runner generated code.
class SubscriptionDI {
  static void registerDependencies(GetIt sl) {
    // Register Error Message Service
    if (!sl.isRegistered<SubscriptionErrorMessageService>()) {
      sl.registerLazySingleton<SubscriptionErrorMessageService>(
        () => SubscriptionErrorMessageService(),
      );
    }
  }
}
