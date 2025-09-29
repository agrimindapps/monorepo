import 'package:core/core.dart';

// ignore: avoid_classes_with_only_static_members
abstract class AuthModule {
  static void init(GetIt sl) {
    // Auth module is now handled in the main injection_container.dart
    // This ensures no duplicate registrations occur
    // Auth State Notifier and Auth Provider are registered there
  }
}

// ignore: avoid_classes_with_only_static_members
abstract class PlantsModule {
  static void init(GetIt sl) {
    // Implementation moved to dedicated module file
  }
}

// ignore: avoid_classes_with_only_static_members
abstract class SpacesModule {
  static void init(GetIt sl) {
    // Implementation moved to dedicated module file
  }
}

// ignore: avoid_classes_with_only_static_members
abstract class CommentsModule {
  static void init(GetIt sl) {
    // TODO: Implement comments module dependencies
    // Providers
    // Use cases
    // Repositories
    // Data sources
  }
}

// ignore: avoid_classes_with_only_static_members
abstract class PremiumModule {
  static void init(GetIt sl) {
    // TODO: Implement premium module dependencies
    // Providers
    // Use cases
    // Repositories
    // Data sources
  }
}

// ignore: avoid_classes_with_only_static_members
abstract class AppServicesModule {
  static void init(GetIt sl) {
    // TODO: Implement app-wide services
    // Navigation service
    // Image service
    // Notification service
  }
}
