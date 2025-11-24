import 'package:core/core.dart' hide SignInWithApple;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_services_providers.dart' as core_providers;
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/services/auth_error_handling_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_validation_service.dart';
import '../../domain/services/pet_data_sync_service.dart';
import '../../domain/services/rate_limit_service.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_providers.g.dart';

@riverpod
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) {
  return AuthLocalDataSourceImpl(sharedPreferences: ref.watch(sharedPreferencesProvider));
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(core_providers.firebaseAuthProvider),
    firestore: ref.watch(core_providers.firebaseFirestoreProvider),
    googleSignIn: ref.watch(core_providers.googleSignInProvider),
  );
}

@riverpod
AuthErrorHandlingService authErrorHandlingService(AuthErrorHandlingServiceRef ref) {
  return AuthErrorHandlingService(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

@riverpod
AuthValidationService authValidationService(AuthValidationServiceRef ref) {
  return AuthValidationService();
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    errorHandlingService: ref.watch(authErrorHandlingServiceProvider),
    loggingService: ref.watch(core_providers.loggingServiceProvider),
  );
}

// Use Cases
@riverpod
SignInWithEmail signInWithEmail(SignInWithEmailRef ref) {
  return SignInWithEmail(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

@riverpod
SignUpWithEmail signUpWithEmail(SignUpWithEmailRef ref) {
  return SignUpWithEmail(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

@riverpod
SignInWithGoogle signInWithGoogle(SignInWithGoogleRef ref) {
  return SignInWithGoogle(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithApple signInWithApple(SignInWithAppleRef ref) {
  return SignInWithApple(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithFacebook signInWithFacebook(SignInWithFacebookRef ref) {
  return SignInWithFacebook(ref.watch(authRepositoryProvider));
}

@riverpod
SignInAnonymously signInAnonymously(SignInAnonymouslyRef ref) {
  return SignInAnonymously(ref.watch(authRepositoryProvider));
}

@riverpod
SignOut signOut(SignOutRef ref) {
  return SignOut(ref.watch(authRepositoryProvider));
}

@riverpod
GetCurrentUser getCurrentUser(GetCurrentUserRef ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
}

@riverpod
SendEmailVerification sendEmailVerification(SendEmailVerificationRef ref) {
  return SendEmailVerification(ref.watch(authRepositoryProvider));
}

@riverpod
SendPasswordResetEmail sendPasswordResetEmail(SendPasswordResetEmailRef ref) {
  return SendPasswordResetEmail(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

@riverpod
UpdateProfile updateProfile(UpdateProfileRef ref) {
  return UpdateProfile(
    ref.watch(authRepositoryProvider),
    ref.watch(authValidationServiceProvider),
  );
}

// Services
@riverpod
RateLimitService rateLimitService(RateLimitServiceRef ref) {
  return RateLimitService();
}

@riverpod
PetDataSyncService petDataSyncService(PetDataSyncServiceRef ref) {
  return PetDataSyncService();
}

@riverpod
EnhancedAccountDeletionService enhancedAccountDeletionService(EnhancedAccountDeletionServiceRef ref) {
  return EnhancedAccountDeletionService(
    authRepository: ref.watch(core_providers.externalAuthRepositoryProvider),
  );
}
