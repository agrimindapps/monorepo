import 'package:core/core.dart' show GetIt;

import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/services/auth_validation_service.dart';
import '../../../features/auth/domain/usecases/auth_usecases.dart';
import '../di_module.dart';

/// Authentication module following SOLID principles
///
/// Follows SRP: Single responsibility of auth services registration
/// Follows DIP: Depends on abstractions via DIModule interface
class AuthModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Services
    // Note: AuthErrorHandlingService is registered via @lazySingleton
    // Note: Auth datasources, repository and use cases are registered via @lazySingleton
    getIt.registerLazySingleton<AuthValidationService>(
      () => AuthValidationService(),
    );

    // Register use cases manually (fix for build_runner issue)
    if (!getIt.isRegistered<SignInWithEmail>()) {
      getIt.registerLazySingleton<SignInWithEmail>(
        () => SignInWithEmail(
          getIt<AuthRepository>(),
          getIt<AuthValidationService>(),
        ),
      );
    }

    if (!getIt.isRegistered<SignUpWithEmail>()) {
      getIt.registerLazySingleton<SignUpWithEmail>(
        () => SignUpWithEmail(
          getIt<AuthRepository>(),
          getIt<AuthValidationService>(),
        ),
      );
    }
  }
}
