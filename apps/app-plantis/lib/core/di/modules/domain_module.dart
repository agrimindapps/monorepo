import 'package:get_it/get_it.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

class AuthModule {
  static void init(GetIt sl) {
    // Providers
    sl.registerFactory(() => AuthProvider(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      authRepository: sl(),
    ));
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

class TasksModule {
  static void init(GetIt sl) {
    // TODO: Implement tasks module dependencies when needed
    // Providers
    // Use cases
    // Repositories
    // Data sources
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