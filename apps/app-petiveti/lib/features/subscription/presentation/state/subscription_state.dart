import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_state.freezed.dart';

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(false) bool isLoadingPlans,
    @Default(false) bool isLoadingCurrentSubscription,
    @Default(false) bool isProcessingPurchase,
    @Default(false) bool isRestoringPurchases,
    @Default([]) List<ProductInfo> availablePlans,
    SubscriptionInfo? currentSubscription,
    String? errorMessage,
  }) = _SubscriptionState;

  const SubscriptionState._();

  bool get hasAnyLoading =>
      isLoadingPlans ||
      isLoadingCurrentSubscription ||
      isProcessingPurchase ||
      isRestoringPurchases;

  bool get hasPremium => currentSubscription?.isActive ?? false;
}
