import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/usecases/cancel_subscription.dart';
import '../../domain/usecases/get_current_subscription.dart';
import '../../domain/usecases/get_user_premium_status.dart';
import '../../domain/usecases/get_available_products.dart';
import '../../domain/usecases/purchase_product.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../domain/usecases/manage_subscription.dart';
import '../../domain/usecases/refresh_subscription_status.dart';
import '../services/subscription_error_message_service.dart';

part 'subscription_providers.g.dart';

// Error Message Service Provider
@Riverpod(keepAlive: true)
SubscriptionErrorMessageService subscriptionErrorMessageService(
  SubscriptionErrorMessageServiceRef ref,
) {
  return SubscriptionErrorMessageService();
}

// Repository Provider
@Riverpod(keepAlive: true)
IAppSubscriptionRepository appSubscriptionRepository(
  AppSubscriptionRepositoryRef ref,
) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(localStorageRepositoryProvider),
    ref.watch(subscriptionErrorMessageServiceProvider),
  );
}

// Use Cases Providers
@Riverpod(keepAlive: true)
GetCurrentSubscriptionUseCase getCurrentSubscriptionUseCase(
  GetCurrentSubscriptionUseCaseRef ref,
) {
  return GetCurrentSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
ManageSubscriptionUseCase manageSubscriptionUseCase(
  ManageSubscriptionUseCaseRef ref,
) {
  return ManageSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
CancelSubscriptionUseCase cancelSubscriptionUseCase(
  CancelSubscriptionUseCaseRef ref,
) {
  return CancelSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
RefreshSubscriptionStatusUseCase refreshSubscriptionStatusUseCase(
  RefreshSubscriptionStatusUseCaseRef ref,
) {
  return RefreshSubscriptionStatusUseCase(
    ref.watch(appSubscriptionRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
GetUserPremiumStatusUseCase getUserPremiumStatusUseCase(
  GetUserPremiumStatusUseCaseRef ref,
) {
  return GetUserPremiumStatusUseCase(
    ref.watch(appSubscriptionRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
GetAvailableProductsUseCase getAvailableProductsUseCase(
  GetAvailableProductsUseCaseRef ref,
) {
  return GetAvailableProductsUseCase(
    ref.watch(appSubscriptionRepositoryProvider),
  );
}

@Riverpod(keepAlive: true)
PurchaseProductUseCase purchaseProductUseCase(
  PurchaseProductUseCaseRef ref,
) {
  return PurchaseProductUseCase(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionErrorMessageServiceProvider),
  );
}

@Riverpod(keepAlive: true)
RestorePurchasesUseCase restorePurchasesUseCase(
  RestorePurchasesUseCaseRef ref,
) {
  return RestorePurchasesUseCase(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(appSubscriptionRepositoryProvider),
  );
}
