import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/repositories/i_subscription_repository.dart';
import '../../domain/usecases/cancel_subscription.dart';
import '../../domain/usecases/get_available_products.dart';
import '../../domain/usecases/get_current_subscription.dart';
import '../../domain/usecases/get_user_premium_status.dart';
import '../../domain/usecases/manage_subscription.dart';
import '../../domain/usecases/purchase_product.dart';
import '../../domain/usecases/refresh_subscription_status.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../services/subscription_error_message_service.dart';

part 'subscription_providers.g.dart';

// Error Message Service Provider
@riverpod
SubscriptionErrorMessageService subscriptionErrorMessageService(
  Ref ref,
) {
  return SubscriptionErrorMessageService();
}

// Repository Provider
@riverpod
IAppSubscriptionRepository appSubscriptionRepository(
  Ref ref,
) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(localStorageRepositoryProvider),
    ref.watch(subscriptionErrorMessageServiceProvider),
  );
}

// Use Cases Providers
@riverpod
GetCurrentSubscriptionUseCase getCurrentSubscriptionUseCase(
  Ref ref,
) {
  return GetCurrentSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
}

@riverpod
ManageSubscriptionUseCase manageSubscriptionUseCase(
  Ref ref,
) {
  return ManageSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
}

@riverpod
CancelSubscriptionUseCase cancelSubscriptionUseCase(
  Ref ref,
) {
  return CancelSubscriptionUseCase(
    ref.watch(subscriptionRepositoryProvider),
  );
}

@riverpod
RefreshSubscriptionStatusUseCase refreshSubscriptionStatusUseCase(
  Ref ref,
) {
  return RefreshSubscriptionStatusUseCase(
    ref.watch(appSubscriptionRepositoryProvider),
  );
}

@riverpod
GetUserPremiumStatusUseCase getUserPremiumStatusUseCase(
  Ref ref,
) {
  return GetUserPremiumStatusUseCase(
    ref.watch(appSubscriptionRepositoryProvider),
  );
}

@riverpod
GetAvailableProductsUseCase getAvailableProductsUseCase(
  Ref ref,
) {
  return GetAvailableProductsUseCase(
    ref.watch(appSubscriptionRepositoryProvider),
  );
}

@riverpod
PurchaseProductUseCase purchaseProductUseCase(
  Ref ref,
) {
  return PurchaseProductUseCase(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionErrorMessageServiceProvider),
  );
}

@riverpod
RestorePurchasesUseCase restorePurchasesUseCase(
  Ref ref,
) {
  return RestorePurchasesUseCase(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(appSubscriptionRepositoryProvider),
  );
}
