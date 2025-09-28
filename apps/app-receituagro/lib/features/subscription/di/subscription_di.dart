import 'package:core/core.dart';

// Data  
import '../data/repositories/subscription_repository_impl.dart';
// Domain
import '../domain/repositories/i_subscription_repository.dart';
import '../domain/usecases/subscription_usecase.dart';
// Presentation
import '../presentation/providers/subscription_provider.dart';

/// Configuração de injeção de dependências para o módulo Subscription
/// Segue padrão Clean Architecture + GetIt para DI
/// Integra com RevenueCat service do core package
void configureSubscriptionDependencies() {
  final getIt = GetIt.instance;

  // Repository específico do app (implementa funcionalidades locais)
  getIt.registerLazySingleton<IAppSubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      getIt<ISubscriptionRepository>(), // Core subscription repository
      getIt<ILocalStorageRepository>(), // Local storage para cache
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetUserPremiumStatusUseCase(getIt<IAppSubscriptionRepository>()));
  getIt.registerLazySingleton(() => GetAvailableProductsUseCase(getIt<IAppSubscriptionRepository>()));
  getIt.registerLazySingleton(() => PurchaseProductUseCase(getIt<ISubscriptionRepository>()));
  getIt.registerLazySingleton(() => CheckFeatureAccessUseCase(getIt<IAppSubscriptionRepository>()));
  getIt.registerLazySingleton(() => RestorePurchasesUseCase(
    getIt<ISubscriptionRepository>(),
    getIt<IAppSubscriptionRepository>(),
  ));
  getIt.registerLazySingleton(() => RefreshSubscriptionStatusUseCase(getIt<IAppSubscriptionRepository>()));
  getIt.registerLazySingleton(() => CheckActiveTrialUseCase(getIt<IAppSubscriptionRepository>()));
  getIt.registerLazySingleton(() => GetTrialInfoUseCase(getIt<ISubscriptionRepository>()));
  getIt.registerLazySingleton(() => ManageSubscriptionUseCase(getIt<ISubscriptionRepository>()));
  getIt.registerLazySingleton(() => CancelSubscriptionUseCase(getIt<ISubscriptionRepository>()));
  getIt.registerLazySingleton(() => GetPurchaseHistoryUseCase(getIt<ISubscriptionRepository>()));

  // Provider - Será atualizado para usar os use cases corretos
  getIt.registerFactory(() => SubscriptionProvider());
}