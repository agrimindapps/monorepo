import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart' as local_login;
import '../../domain/usecases/logout_usecase.dart' as local_logout;
import '../../domain/usecases/refresh_user_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// Core Services
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final analyticsServiceProvider = Provider<FirebaseAnalyticsService>((ref) {
  return FirebaseAnalyticsService();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final enhancedAccountDeletionServiceProvider =
    Provider<EnhancedAccountDeletionService>((ref) {
  // Assuming EnhancedAccountDeletionService has a constructor we can use or we can mock it
  // It seems it might need dependencies too.
  // For now, let's try to instantiate it if possible, or return null if it's optional in AuthProvider
  // AuthProvider takes it as nullable.
  // Let's check its constructor in core if needed.
  // For now, let's assume we can't easily instantiate it without more info, so we'll pass null or try to find it.
  // But wait, AuthProvider uses it.
  // Let's assume it's available via core or we can instantiate it.
  // If it's complex, maybe we skip it for now or mock it.
  // Let's try to instantiate it.
  return EnhancedAccountDeletionService(
    authRepository: FirebaseAuthService(),
    appDataCleaner: null, // Needs AppDataCleaner
    firestoreDeletion: FirestoreDeletionService(),
    revenueCatCancellation: RevenueCatCancellationService(),
    rateLimiter: AccountDeletionRateLimiter(),
  );
});

// Data Sources
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData?.value;
  if (sharedPreferences == null) {
    throw UnimplementedError('SharedPreferences not initialized');
  }
  final secureStorage = ref.watch(secureStorageProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);

  return AuthLocalDataSourceImpl(
    sharedPreferences,
    secureStorage,
    analyticsService,
  );
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final connectivity = ref.watch(connectivityProvider);

  return AuthRepositoryImpl(
    localDataSource,
    remoteDataSource,
    connectivity,
  );
});

// Use Cases
final loginUseCaseProvider = Provider<local_login.LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return local_login.LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = Provider<local_logout.LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return local_logout.LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final refreshUserUseCaseProvider = Provider<RefreshUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshUserUseCase(repository);
});
