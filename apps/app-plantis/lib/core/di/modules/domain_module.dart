import 'package:get_it/get_it.dart';

class AuthModule {
  static void init(GetIt sl) {
    // Auth module is now handled in the main injection_container.dart
    // This ensures no duplicate registrations occur
    // Auth State Notifier and Auth Provider are registered there
  }
}

class PlantsModule {
  static void init(GetIt sl) {
    // Implementation moved to dedicated module file
  }
}

class SpacesModule {
  static void init(GetIt sl) {
    // Implementation moved to dedicated module file
  }
}

class CommentsModule {
  static void init(GetIt sl) {
    // TODO: Implement comments module dependencies
    // Providers
    // Use cases
    // Repositories
    // Data sources
  }
}

class PremiumModule {
  static void init(GetIt sl) {
    // TODO: Implement premium module dependencies
    // Providers
    // Use cases
    // Repositories
    // Data sources
  }
}

class AppServicesModule {
  static void init(GetIt sl) {
    // TODO: Implement app-wide services
    // Navigation service
    // Image service
    // Notification service
  }
}
