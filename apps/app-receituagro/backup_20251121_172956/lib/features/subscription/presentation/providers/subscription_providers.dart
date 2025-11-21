import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/usecases/get_available_products.dart';
import '../../domain/usecases/get_current_subscription.dart';
import '../../domain/usecases/get_user_premium_status.dart';
import '../../domain/usecases/manage_subscription.dart';
import '../../domain/usecases/purchase_product.dart';
import '../../domain/usecases/refresh_subscription_status.dart';
import '../../domain/usecases/restore_purchases.dart';

part 'subscription_providers.g.dart';

@riverpod
GetUserPremiumStatusUseCase getUserPremiumStatusUseCase(GetUserPremiumStatusUseCaseRef ref) {
  return di.sl<GetUserPremiumStatusUseCase>();
}

@riverpod
GetAvailableProductsUseCase getAvailableProductsUseCase(GetAvailableProductsUseCaseRef ref) {
  return di.sl<GetAvailableProductsUseCase>();
}

@riverpod
GetCurrentSubscriptionUseCase getCurrentSubscriptionUseCase(GetCurrentSubscriptionUseCaseRef ref) {
  return di.sl<GetCurrentSubscriptionUseCase>();
}

@riverpod
PurchaseProductUseCase purchaseProductUseCase(PurchaseProductUseCaseRef ref) {
  return di.sl<PurchaseProductUseCase>();
}

@riverpod
RestorePurchasesUseCase restorePurchasesUseCase(RestorePurchasesUseCaseRef ref) {
  return di.sl<RestorePurchasesUseCase>();
}

@riverpod
RefreshSubscriptionStatusUseCase refreshSubscriptionStatusUseCase(RefreshSubscriptionStatusUseCaseRef ref) {
  return di.sl<RefreshSubscriptionStatusUseCase>();
}

@riverpod
ManageSubscriptionUseCase manageSubscriptionUseCase(ManageSubscriptionUseCaseRef ref) {
  return di.sl<ManageSubscriptionUseCase>();
}
