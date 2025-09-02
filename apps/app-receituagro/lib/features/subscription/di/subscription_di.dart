import 'package:get_it/get_it.dart';

// Domain
import '../domain/repositories/i_subscription_repository.dart';
import '../domain/usecases/subscription_usecase.dart';

// Data  
import '../data/repositories/subscription_repository_impl.dart';

// Presentation
import '../presentation/providers/subscription_provider.dart';

/// Configuração de injeção de dependências para o módulo Subscription
/// Segue padrão Clean Architecture + GetIt para DI
/// Integra com RevenueCat service do core package
void configureSubscriptionDependencies() {
  final getIt = GetIt.instance;

  // Repository
  getIt.registerLazySingleton<ISubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      getIt(), // RevenueCatService do core
      getIt(), // HiveService para cache local
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetUserPremiumStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAvailableProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => PurchaseProductUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckFeatureAccessUseCase(getIt()));
  getIt.registerLazySingleton(() => RestorePurchasesUseCase(getIt()));
  getIt.registerLazySingleton(() => RefreshSubscriptionStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => CheckActiveTrialUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTrialInfoUseCase(getIt()));
  getIt.registerLazySingleton(() => ManageSubscriptionUseCase(getIt()));
  getIt.registerLazySingleton(() => CancelSubscriptionUseCase(getIt()));
  getIt.registerLazySingleton(() => GetPurchaseHistoryUseCase(getIt()));

  // Provider
  getIt.registerFactory(() => SubscriptionProvider(
    getUserPremiumStatusUseCase: getIt(),
    getAvailableProductsUseCase: getIt(),
    purchaseProductUseCase: getIt(),
    checkFeatureAccessUseCase: getIt(),
    restorePurchasesUseCase: getIt(),
    refreshSubscriptionStatusUseCase: getIt(),
    checkActiveTrialUseCase: getIt(),
    getTrialInfoUseCase: getIt(),
    manageSubscriptionUseCase: getIt(),
    cancelSubscriptionUseCase: getIt(),
    getPurchaseHistoryUseCase: getIt(),
  ));
}