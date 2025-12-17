import 'package:core/core.dart' hide SignInWithApple;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_services_providers.dart'
    as core_providers;
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_error_handling_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_validation_service.dart';
import '../../domain/services/pet_data_sync_service.dart';
import '../../domain/services/rate_limit_service.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_provider.dart';

part 'auth_providers.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  return AuthLocalDataSourceImpl(
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  );
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(core_providers.firebaseAuthProvider),
    firestore: ref.watch(core_providers.firebaseFirestoreProvider),
    // GoogleSignIn apenas em mobile
    googleSignIn: kIsWeb ? null : ref.watch(core_providers.googleSignInProvider),
  );
}

@riverpod
AuthErrorHandlingService authErrorHandlingService(Ref ref) {
  return AuthErrorHandlingService(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

@riverpod
AuthValidationService authValidationService(Ref ref) {
  return const AuthValidationService();
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    errorHandlingService: ref.watch(authErrorHandlingServiceProvider),
    loggingService: ref.watch(core_providers.loggingServiceProvider),
  );
}

// Use Cases
@riverpod
SignInWithEmail signInWithEmail(Ref ref) {
  return SignInWithEmail(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

@riverpod
SignUpWithEmail signUpWithEmail(Ref ref) {
  return SignUpWithEmail(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

@riverpod
SignInWithGoogle signInWithGoogle(Ref ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithApple signInWithApple(Ref ref) {
  return SignInWithApple(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithFacebook signInWithFacebook(Ref ref) {
  return SignInWithFacebook(ref.watch(authRepositoryProvider));
}

@riverpod
SignInAnonymously signInAnonymously(Ref ref) {
  return SignInAnonymously(ref.watch(authRepositoryProvider));
}

@riverpod
SignOut signOut(Ref ref) {
  return SignOut(ref.watch(authRepositoryProvider));
}

@riverpod
GetCurrentUser getCurrentUser(Ref ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
}

@riverpod
SendEmailVerification sendEmailVerification(Ref ref) {
  return SendEmailVerification(ref.watch(authRepositoryProvider));
}

@riverpod
SendPasswordResetEmail sendPasswordResetEmail(Ref ref) {
  return SendPasswordResetEmail(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

@riverpod
UpdateProfile updateProfile(Ref ref) {
  return UpdateProfile(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

// Services
@riverpod
RateLimitService rateLimitService(Ref ref) {
  return RateLimitService();
}

@riverpod
PetDataSyncService petDataSyncService(Ref ref) {
  return PetDataSyncService();
}

@riverpod
EnhancedAccountDeletionService enhancedAccountDeletionService(Ref ref) {
  return EnhancedAccountDeletionService(
    authRepository: ref.watch(core_providers.externalAuthRepositoryProvider),
  );
}

@riverpod
LocalProfileImageService localProfileImageService(Ref ref) {
  return LocalProfileImageService(
    ref.watch(core_providers.analyticsRepositoryProvider),
  );
}

/// Provider para obter o userId do usuário autenticado atual
/// Retorna null se não houver usuário autenticado
@riverpod
String? currentUserId(Ref ref) {
  final authState = ref.watch(authProvider);
  return authState.user?.id;
}
