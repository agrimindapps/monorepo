import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

import '../../domain/repositories/i_analytics_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_crashlytics_repository.dart';
import '../../domain/repositories/i_local_storage_repository.dart';
import '../../domain/repositories/i_storage_repository.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../infrastructure/services/firebase_analytics_service.dart';
import '../../infrastructure/services/firebase_auth_service.dart';
import '../../infrastructure/services/firebase_crashlytics_service.dart';
import '../../infrastructure/services/firebase_storage_service.dart';
import '../../infrastructure/services/hive_storage_service.dart';
import '../../infrastructure/services/mock_analytics_service.dart';
import '../../infrastructure/services/revenue_cat_service.dart';
import '../../shared/config/environment_config.dart';

final GetIt getIt = GetIt.instance;

class InjectionContainer {
  static Future<void> init() async {
    // Initialize Firebase
    await Firebase.initializeApp();
    
    // Register Services (Singletons)
    getIt.registerLazySingleton<IAuthRepository>(
      () => FirebaseAuthService(),
    );
    
    // Analytics - usa Mock em debug, Firebase em produção
    getIt.registerLazySingleton<IAnalyticsRepository>(
      () => EnvironmentConfig.isDebugMode 
        ? MockAnalyticsService()
        : FirebaseAnalyticsService(),
    );
    
    // Firebase Crashlytics para crash reporting
    getIt.registerLazySingleton<ICrashlyticsRepository>(
      () => FirebaseCrashlyticsService(),
    );
    
    // Firebase Storage para upload de arquivos
    getIt.registerLazySingleton<IStorageRepository>(
      () => FirebaseStorageService(),
    );
    
    // Hive para storage local/offline
    getIt.registerLazySingleton<ILocalStorageRepository>(
      () => HiveStorageService(),
    );
    
    // RevenueCat para gerenciar assinaturas
    getIt.registerLazySingleton<ISubscriptionRepository>(
      () => RevenueCatService(),
    );
    
    // Register Use Cases
    getIt.registerLazySingleton(() => LoginUseCase(getIt(), getIt()));
    getIt.registerLazySingleton(() => LogoutUseCase(getIt(), getIt()));
  }
  
  static void reset() {
    getIt.reset();
  }
}