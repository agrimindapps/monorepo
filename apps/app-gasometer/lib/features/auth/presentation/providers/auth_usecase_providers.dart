import 'package:core/core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/dependency_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../features/data_management/domain/services/data_cleaner_service.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/firebase_error_handler.dart';
import '../../data/datasources/firestore_user_repository.dart';
import '../../data/datasources/user_converter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_rate_limiter.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_anonymously.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/watch_auth_state.dart';

part 'auth_usecase_providers.g.dart';

// Infrastructure
@riverpod
UserConverter userConverter(Ref ref) {
  return UserConverter();
}

@riverpod
FirestoreUserRepository firestoreUserRepository(Ref ref) {
  return FirestoreUserRepository(
    FirebaseFirestore.instance,
    ref.watch(userConverterProvider),
  );
}

@riverpod
FirebaseErrorHandler firebaseErrorHandler(Ref ref) {
  return FirebaseErrorHandler();
}

@riverpod
DataCleanerService dataCleanerService(Ref ref) {
  return DataCleanerService(
    ref.watch(gasometerDatabaseProvider),
  );
}

// Data Sources
@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) {
  final SharedPreferences prefs = ref.watch(gasometerSharedPreferencesProvider);
  return GasometerAuthLocalDataSourceImpl(
    prefs,
    const FlutterSecureStorage(),
  );
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSourceImpl(
    FirebaseAuth.instance,
    FirebaseAuthService(),
    ref.watch(userConverterProvider),
    ref.watch(firestoreUserRepositoryProvider),
    ref.watch(firebaseErrorHandlerProvider),
  );
}

// Repository
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    dataCleanerService: ref.watch(dataCleanerServiceProvider),
  );
}

// Services
@riverpod
AuthRateLimiter authRateLimiter(Ref ref) {
  return AuthRateLimiter(const FlutterSecureStorage());
}

@riverpod
EnhancedAccountDeletionService enhancedAccountDeletionService(Ref ref) {
  return EnhancedAccountDeletionService(
    authRepository: ref.watch(firebaseAuthServiceProvider),
  );
}

// Use Cases
@riverpod
GetCurrentUser getCurrentUser(Ref ref) {
  return GetCurrentUser(ref.watch(authRepositoryProvider));
}

@riverpod
WatchAuthState watchAuthState(Ref ref) {
  return WatchAuthState(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithEmail signInWithEmail(Ref ref) {
  return SignInWithEmail(ref.watch(authRepositoryProvider));
}

@riverpod
SignUpWithEmail signUpWithEmail(Ref ref) {
  return SignUpWithEmail(ref.watch(authRepositoryProvider));
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
SendPasswordReset sendPasswordReset(Ref ref) {
  return SendPasswordReset(ref.watch(authRepositoryProvider));
}

@riverpod
UpdateProfile updateProfile(Ref ref) {
  return UpdateProfile(ref.watch(authRepositoryProvider));
}
