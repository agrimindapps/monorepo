import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' show GetIt, GoogleSignIn, SharedPreferences;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/data/services/auth_error_handling_service.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/services/auth_validation_service.dart';
import '../../../features/auth/domain/services/pet_data_sync_service.dart';
import '../../../features/auth/domain/services/rate_limit_service.dart';
import '../../../features/auth/domain/usecases/auth_usecases.dart';
import '../di_module.dart';

/// Authentication module following SOLID principles
///
/// Follows SRP: Single responsibility of auth services registration
/// Follows DIP: Depends on abstractions via DIModule interface
class AuthModule implements DIModule {
  @override
  Future<void> register(GetIt getIt) async {
    // Data Sources
    if (!getIt.isRegistered<AuthLocalDataSource>()) {
      getIt.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(
          sharedPreferences: getIt<SharedPreferences>(),
        ),
      );
    }

    if (!getIt.isRegistered<AuthRemoteDataSource>()) {
      getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
          firebaseAuth: getIt<FirebaseAuth>(),
          firestore: getIt<FirebaseFirestore>(),
          googleSignIn: getIt<GoogleSignIn>(),
        ),
      );
    }

    // Repository
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          localDataSource: getIt<AuthLocalDataSource>(),
          remoteDataSource: getIt<AuthRemoteDataSource>(),
          errorHandlingService: getIt<AuthErrorHandlingService>(),
        ),
      );
    }

    // Services
    // Note: AuthErrorHandlingService is registered via @lazySingleton but needs datasources first
    if (!getIt.isRegistered<AuthErrorHandlingService>()) {
      getIt.registerLazySingleton<AuthErrorHandlingService>(
        () => AuthErrorHandlingService(
          localDataSource: getIt<AuthLocalDataSource>(),
          remoteDataSource: getIt<AuthRemoteDataSource>(),
        ),
      );
    }

    if (!getIt.isRegistered<AuthValidationService>()) {
      getIt.registerLazySingleton<AuthValidationService>(
        AuthValidationService.new,
      );
    }

    if (!getIt.isRegistered<RateLimitService>()) {
      getIt.registerLazySingleton<RateLimitService>(RateLimitService.new);
    }

    if (!getIt.isRegistered<PetDataSyncService>()) {
      getIt.registerLazySingleton<PetDataSyncService>(PetDataSyncService.new);
    }

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

    if (!getIt.isRegistered<SignInWithGoogle>()) {
      getIt.registerLazySingleton<SignInWithGoogle>(
        () => SignInWithGoogle(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<SignInWithApple>()) {
      getIt.registerLazySingleton<SignInWithApple>(
        () => SignInWithApple(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<SignInWithFacebook>()) {
      getIt.registerLazySingleton<SignInWithFacebook>(
        () => SignInWithFacebook(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<SignInAnonymously>()) {
      getIt.registerLazySingleton<SignInAnonymously>(
        () => SignInAnonymously(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<SignOut>()) {
      getIt.registerLazySingleton<SignOut>(
        () => SignOut(getIt<AuthRepository>()),
      );
    }

    // CRITICAL: GetCurrentUser for GoRouter
    if (!getIt.isRegistered<GetCurrentUser>()) {
      getIt.registerLazySingleton<GetCurrentUser>(
        () => GetCurrentUser(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<SendEmailVerification>()) {
      getIt.registerLazySingleton<SendEmailVerification>(
        () => SendEmailVerification(getIt<AuthRepository>()),
      );
    }

    if (!getIt.isRegistered<SendPasswordResetEmail>()) {
      getIt.registerLazySingleton<SendPasswordResetEmail>(
        () => SendPasswordResetEmail(
          getIt<AuthRepository>(),
          getIt<AuthValidationService>(),
        ),
      );
    }

    if (!getIt.isRegistered<UpdateProfile>()) {
      getIt.registerLazySingleton<UpdateProfile>(
        () => UpdateProfile(
          getIt<AuthRepository>(),
          getIt<AuthValidationService>(),
        ),
      );
    }

    if (!getIt.isRegistered<DeleteAccount>()) {
      getIt.registerLazySingleton<DeleteAccount>(
        () => DeleteAccount(getIt<AuthRepository>()),
      );
    }
  }
}
