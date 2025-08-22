import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/interfaces/usecase.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/usecases/subscription_usecases.dart';

class SubscriptionState {
  final List<SubscriptionPlan> availablePlans;
  final UserSubscription? currentSubscription;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.availablePlans = const [],
    this.currentSubscription,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    List<SubscriptionPlan>? availablePlans,
    UserSubscription? currentSubscription,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      availablePlans: availablePlans ?? this.availablePlans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasPremium => 
      currentSubscription != null && currentSubscription!.isValidPremium;
  
  bool get isInTrial => 
      currentSubscription != null && currentSubscription!.isInTrialPeriod;
  
  bool get willExpireSoon => 
      currentSubscription != null && currentSubscription!.willExpireSoon;

  SubscriptionPlan? get freePlan => 
      availablePlans.where((p) => p.type == PlanType.free).firstOrNull;
  
  SubscriptionPlan? get monthlyPlan => 
      availablePlans.where((p) => p.type == PlanType.monthly).firstOrNull;
  
  SubscriptionPlan? get yearlyPlan => 
      availablePlans.where((p) => p.type == PlanType.yearly).firstOrNull;
  
  SubscriptionPlan? get lifetimePlan => 
      availablePlans.where((p) => p.type == PlanType.lifetime).firstOrNull;
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final GetAvailablePlans _getAvailablePlans;
  final GetCurrentSubscription _getCurrentSubscription;
  final SubscribeToPlan _subscribeToPlan;
  final CancelSubscription _cancelSubscription;
  final PauseSubscription _pauseSubscription;
  final ResumeSubscription _resumeSubscription;
  final UpgradePlan _upgradePlan;
  final RestorePurchases _restorePurchases;

  SubscriptionNotifier(
    this._getAvailablePlans,
    this._getCurrentSubscription,
    this._subscribeToPlan,
    this._cancelSubscription,
    this._pauseSubscription,
    this._resumeSubscription,
    this._upgradePlan,
    this._restorePurchases,
  ) : super(const SubscriptionState());

  Future<void> loadAvailablePlans() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAvailablePlans(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (plans) => state = state.copyWith(
        availablePlans: plans,
        isLoading: false,
      ),
    );
  }

  Future<void> loadCurrentSubscription(String userId) async {
    final result = await _getCurrentSubscription(userId);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (subscription) => state = state.copyWith(currentSubscription: subscription),
    );
  }

  Future<bool> subscribeToPlan(String userId, String planId) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = SubscribeToPlanParams(userId: userId, planId: planId);
    final result = await _subscribeToPlan(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        state = state.copyWith(
          currentSubscription: subscription,
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> cancelSubscription(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _cancelSubscription(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadCurrentSubscription(userId);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> pauseSubscription(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _pauseSubscription(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadCurrentSubscription(userId);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> resumeSubscription(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _resumeSubscription(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadCurrentSubscription(userId);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> upgradePlan(String userId, String newPlanId) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = UpgradePlanParams(userId: userId, newPlanId: newPlanId);
    final result = await _upgradePlan(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        state = state.copyWith(
          currentSubscription: subscription,
          isLoading: false,
        );
        return true;
      },
    );
  }

  Future<bool> restorePurchases(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _restorePurchases(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadCurrentSubscription(userId);
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(
    sl<GetAvailablePlans>(),
    sl<GetCurrentSubscription>(),
    sl<SubscribeToPlan>(),
    sl<CancelSubscription>(),
    sl<PauseSubscription>(),
    sl<ResumeSubscription>(),
    sl<UpgradePlan>(),
    sl<RestorePurchases>(),
  );
});