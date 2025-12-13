import 'package:core/core.dart' hide SubscriptionState, subscriptionProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'subscription_state.dart';

part 'subscription_notifier.g.dart';

@riverpod
class Subscription extends _$Subscription {
  @override
  SubscriptionState build() {
    _initialize();
    return const SubscriptionState();
  }

  void _initialize() {
    loadAvailablePlans();
    loadCurrentSubscription();
  }

  Future<void> loadAvailablePlans() async {
    state = state.copyWith(isLoadingPlans: true, errorMessage: null);
    
    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.getAvailableProducts(productIds: [
      'petiveti_monthly_premium',
      'petiveti_yearly_premium',
      'petiveti_lifetime',
    ]);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingPlans: false,
        errorMessage: 'Erro ao carregar planos: ${failure.message}',
      ),
      (plans) => state = state.copyWith(
        isLoadingPlans: false,
        availablePlans: plans,
      ),
    );
  }

  Future<void> loadCurrentSubscription() async {
    state = state.copyWith(isLoadingCurrentSubscription: true, errorMessage: null);
    
    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.getCurrentSubscription();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingCurrentSubscription: false,
        errorMessage: 'Erro ao carregar assinatura: ${failure.message}',
      ),
      (subscription) => state = state.copyWith(
        isLoadingCurrentSubscription: false,
        currentSubscription: subscription,
      ),
    );
  }

  Future<bool> subscribeToPlan(String productId) async {
    state = state.copyWith(isProcessingPurchase: true, errorMessage: null);
    
    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.purchaseProduct(productId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isProcessingPurchase: false,
          errorMessage: 'Erro ao processar compra: ${failure.message}',
        );
        return false;
      },
      (success) {
        state = state.copyWith(isProcessingPurchase: false);
        loadCurrentSubscription();
        return true;
      },
    );
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(isRestoringPurchases: true, errorMessage: null);
    
    final repo = ref.read(subscriptionRepositoryProvider);
    final result = await repo.restorePurchases();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isRestoringPurchases: false,
          errorMessage: 'Erro ao restaurar compras: ${failure.message}',
        );
        return false;
      },
      (success) {
        state = state.copyWith(isRestoringPurchases: false);
        loadCurrentSubscription();
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
