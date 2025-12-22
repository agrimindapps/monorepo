import 'package:core/core.dart' as core;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user_subscription_info.dart';
import '../../domain/usecases/get_subscription_status.dart';
import '../../domain/usecases/purchase_subscription.dart';
import '../../domain/usecases/restore_purchases.dart';

part 'subscription_providers.g.dart';

// ========== Repository Provider ==========

/// Provides the subscription repository from core package
@riverpod
core.ISubscriptionRepository subscriptionRepository(Ref ref) {
  return core.RevenueCatService(); // From core package
}

// ========== UseCase Providers ==========

/// Provides the use case for getting subscription status
@riverpod
GetSubscriptionStatus getSubscriptionStatus(Ref ref) {
  return GetSubscriptionStatus(ref.watch(subscriptionRepositoryProvider));
}

/// Provides the use case for purchasing subscriptions
@riverpod
PurchaseSubscription purchaseSubscription(Ref ref) {
  return PurchaseSubscription(ref.watch(subscriptionRepositoryProvider));
}

/// Provides the use case for restoring purchases
@riverpod
RestorePurchases restorePurchases(Ref ref) {
  return RestorePurchases(ref.watch(subscriptionRepositoryProvider));
}

// ========== State Providers ==========

/// Stream provider for reactive subscription status updates
///
/// Emits new values whenever subscription status changes
/// (purchase, renewal, cancellation, expiration)
@riverpod
Stream<UserSubscriptionInfo> subscriptionStatus(Ref ref) {
  final useCase = ref.watch(getSubscriptionStatusProvider);
  return useCase.call();
}

/// Provider for checking if user is premium (one-time snapshot)
///
/// Use this for one-time checks. For reactive updates, use subscriptionStatus
@riverpod
Future<bool> isPremium(Ref ref) async {
  final useCase = ref.watch(getSubscriptionStatusProvider);
  return useCase.isPremium();
}

// ========== Purchase State ==========

/// State for purchase/restore operations
sealed class PurchaseState {
  const PurchaseState();
}

class PurchaseIdle extends PurchaseState {
  const PurchaseIdle();
}

class PurchaseLoading extends PurchaseState {
  const PurchaseLoading();
}

class PurchaseSuccess extends PurchaseState {
  final String message;
  const PurchaseSuccess(this.message);
}

class PurchaseError extends PurchaseState {
  final String message;
  const PurchaseError(this.message);
}

// ========== Notifier for Purchase Actions ==========

/// Notifier for handling purchase and restore actions
///
/// Manages the state of purchase operations including:
/// - Loading states
/// - Success/error messages
/// - Purchase execution
/// - Restore execution
@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  PurchaseState build() {
    return const PurchaseIdle();
  }

  /// Purchase a subscription plan
  ///
  /// [planId] - The plan ID from PremiumPlansWidget
  Future<void> purchasePlan(String planId) async {
    state = const PurchaseLoading();

    final useCase = ref.read(purchaseSubscriptionProvider);
    final result = await useCase.call(planId);

    state = result.fold(
      (failure) => PurchaseError(_getErrorMessage(failure)),
      (_) => const PurchaseSuccess('Compra realizada com sucesso! 🎉'),
    );
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    state = const PurchaseLoading();

    final useCase = ref.read(restorePurchasesProvider);
    final result = await useCase.call();

    state = result.fold(
      (failure) => PurchaseError(_getErrorMessage(failure)),
      (hasActiveSubscription) => hasActiveSubscription
          ? const PurchaseSuccess('Compras restauradas com sucesso! ✅')
          : const PurchaseError('Nenhuma compra anterior encontrada'),
    );
  }

  /// Clear current state (back to idle)
  void clearState() {
    state = const PurchaseIdle();
  }

  /// Get user-friendly error message from failure
  String _getErrorMessage(core.Failure failure) {
    if (failure is core.SubscriptionPaymentFailure) {
      return failure.message;
    } else if (failure is core.SubscriptionValidationFailure) {
      return failure.message;
    } else if (failure is core.SubscriptionAuthFailure) {
      return failure.message;
    } else if (failure is core.NetworkFailure) {
      return 'Sem conexão com a internet. Verifique sua rede e tente novamente.';
    } else if (failure is core.ServerFailure) {
      return 'Erro no servidor. Tente novamente mais tarde.';
    } else {
      return failure.message;
    }
  }
}
