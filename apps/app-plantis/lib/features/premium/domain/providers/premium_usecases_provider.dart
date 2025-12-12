import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:core/core.dart' hide subscriptionRepositoryProvider;

import '../../../../core/providers/repository_providers.dart';
import '../../../../database/providers/database_providers.dart';
import '../../../../database/repositories/subscription_local_repository.dart';
import '../../data/repositories/premium_repository_impl.dart';
import '../repositories/premium_repository.dart';
import '../usecases/get_current_subscription_usecase.dart';
import '../usecases/load_available_products_usecase.dart';
import '../usecases/purchase_product_usecase.dart';
import '../usecases/restore_purchases_usecase.dart';

part 'premium_usecases_provider.g.dart';

// ============================================================================
// Repository Provider
// ============================================================================

@riverpod
PremiumRepository premiumRepository(Ref ref) {
  final database = ref.watch(plantisDatabaseProvider);
  return PremiumRepositoryImpl(
    coreSubscriptionRepository: ref.watch(subscriptionRepositoryProvider),
    localRepository: SubscriptionLocalRepository(database),
  );
}

// ============================================================================
// Use Case Providers
// ============================================================================

@riverpod
PurchaseProductUseCase purchaseProductUseCase(Ref ref) {
  return PurchaseProductUseCase(
    premiumRepository: ref.watch(premiumRepositoryProvider),
    analytics: ref.watch(firebaseAnalyticsServiceProvider),
  );
}

@riverpod
RestorePurchasesUseCase restorePurchasesUseCase(Ref ref) {
  return RestorePurchasesUseCase(
    premiumRepository: ref.watch(premiumRepositoryProvider),
  );
}

@riverpod
LoadAvailableProductsUseCase loadAvailableProductsUseCase(Ref ref) {
  return LoadAvailableProductsUseCase(
    premiumRepository: ref.watch(premiumRepositoryProvider),
  );
}

@riverpod
GetCurrentSubscriptionUseCase getCurrentSubscriptionUseCase(Ref ref) {
  return GetCurrentSubscriptionUseCase(
    premiumRepository: ref.watch(premiumRepositoryProvider),
  );
}
