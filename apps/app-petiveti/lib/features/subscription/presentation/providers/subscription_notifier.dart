import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/subscription_plan.dart';

part 'subscription_notifier.g.dart';

class SubscriptionState {
  final bool isLoadingCurrentSubscription;
  final bool isLoadingPlans;
  final SubscriptionPlan? currentSubscription;
  final List<SubscriptionPlan> availablePlans;
  final String? errorMessage;

  const SubscriptionState({
    this.isLoadingCurrentSubscription = false,
    this.isLoadingPlans = false,
    this.currentSubscription,
    this.availablePlans = const [],
    this.errorMessage,
  });

  bool get hasAnyLoading => isLoadingCurrentSubscription || isLoadingPlans;

  SubscriptionState copyWith({
    bool? isLoadingCurrentSubscription,
    bool? isLoadingPlans,
    SubscriptionPlan? currentSubscription,
    List<SubscriptionPlan>? availablePlans,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isLoadingCurrentSubscription:
          isLoadingCurrentSubscription ?? this.isLoadingCurrentSubscription,
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availablePlans: availablePlans ?? this.availablePlans,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  SubscriptionState build() {
    return const SubscriptionState();
  }
}
