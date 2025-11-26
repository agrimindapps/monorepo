import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/interfaces/usecase.dart' as local;
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/user_subscription.dart';
import '../../domain/usecases/subscription_usecases.dart';
import 'subscription_di_providers.dart';

class SubscriptionState {
  final List<SubscriptionPlan> availablePlans;
  final UserSubscription? currentSubscription;
  final bool isLoading;
  final bool isLoadingPlans;
  final bool isLoadingCurrentSubscription;
  final bool isProcessingPurchase;
  final bool isRestoringPurchases;
  final bool isCancelling;
  final bool isResuming;
  final String? purchasingPlanId;
  final String? error;

  const SubscriptionState({
    this.availablePlans = const [],
    this.currentSubscription,
    this.isLoading = false,
    this.isLoadingPlans = false,
    this.isLoadingCurrentSubscription = false,
    this.isProcessingPurchase = false,
    this.isRestoringPurchases = false,
    this.isCancelling = false,
    this.isResuming = false,
    this.purchasingPlanId,
    this.error,
  });

  SubscriptionState copyWith({
    List<SubscriptionPlan>? availablePlans,
    UserSubscription? currentSubscription,
    bool? isLoading,
    bool? isLoadingPlans,
    bool? isLoadingCurrentSubscription,
    bool? isProcessingPurchase,
    bool? isRestoringPurchases,
    bool? isCancelling,
    bool? isResuming,
    String? purchasingPlanId,
    String? error,
  }) {
    return SubscriptionState(
      availablePlans: availablePlans ?? this.availablePlans,
      currentSubscription: currentSubscription ?? this.currentSubscription,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      isLoadingCurrentSubscription:
          isLoadingCurrentSubscription ?? this.isLoadingCurrentSubscription,
      isProcessingPurchase: isProcessingPurchase ?? this.isProcessingPurchase,
      isRestoringPurchases: isRestoringPurchases ?? this.isRestoringPurchases,
      isCancelling: isCancelling ?? this.isCancelling,
      isResuming: isResuming ?? this.isResuming,
      purchasingPlanId: purchasingPlanId,
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
  bool get hasAnyLoading =>
      isLoading ||
      isLoadingPlans ||
      isLoadingCurrentSubscription ||
      isProcessingPurchase ||
      isRestoringPurchases ||
      isCancelling ||
      isResuming;

  bool isPurchasing(String planId) =>
      isProcessingPurchase && purchasingPlanId == planId;

  String get loadingMessage {
    if (isLoadingPlans) return 'Carregando planos...';
    if (isLoadingCurrentSubscription) return 'Verificando assinatura...';
    if (isProcessingPurchase) return 'Processando compra...';
    if (isRestoringPurchases) return 'Restaurando compras...';
    if (isCancelling) return 'Cancelando assinatura...';
    if (isResuming) return 'Retomando assinatura...';
    if (isLoading) return 'Carregando...';
    return '';
  }

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
    state = state.copyWith(isLoadingPlans: true, error: null);

    final result = await _getAvailablePlans(const local.NoParams());

    result.fold(
      (failure) =>
          state = state.copyWith(isLoadingPlans: false, error: failure.message),
      (plans) =>
          state = state.copyWith(availablePlans: plans, isLoadingPlans: false),
    );
  }

  Future<void> loadCurrentSubscription(String userId) async {
    state = state.copyWith(isLoadingCurrentSubscription: true, error: null);

    final result = await _getCurrentSubscription(userId);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoadingCurrentSubscription: false,
            error: failure.message,
          ),
      (subscription) =>
          state = state.copyWith(
            currentSubscription: subscription,
            isLoadingCurrentSubscription: false,
          ),
    );
  }

  Future<bool> subscribeToPlan(String userId, String planId) async {
    state = state.copyWith(
      isProcessingPurchase: true,
      purchasingPlanId: planId,
      error: null,
    );

    final params = SubscribeToPlanParams(userId: userId, planId: planId);
    final result = await _subscribeToPlan(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isProcessingPurchase: false,
          purchasingPlanId: null,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        state = state.copyWith(
          currentSubscription: subscription,
          isProcessingPurchase: false,
          purchasingPlanId: null,
        );
        return true;
      },
    );
  }

  Future<bool> cancelSubscription(String userId) async {
    state = state.copyWith(isCancelling: true, error: null);

    final result = await _cancelSubscription(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(isCancelling: false, error: failure.message);
        return false;
      },
      (_) {
        loadCurrentSubscription(userId);
        state = state.copyWith(isCancelling: false);
        return true;
      },
    );
  }

  Future<bool> pauseSubscription(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _pauseSubscription(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
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
    state = state.copyWith(isResuming: true, error: null);

    final result = await _resumeSubscription(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(isResuming: false, error: failure.message);
        return false;
      },
      (_) {
        loadCurrentSubscription(userId);
        state = state.copyWith(isResuming: false);
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
        state = state.copyWith(isLoading: false, error: failure.message);
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
    state = state.copyWith(isRestoringPurchases: true, error: null);

    final result = await _restorePurchases(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isRestoringPurchases: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        loadCurrentSubscription(userId);
        state = state.copyWith(isRestoringPurchases: false);
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
      final getAvailablePlans = ref.watch(getAvailablePlansProvider);
      final getCurrentSubscription = ref.watch(getCurrentSubscriptionProvider);
      final subscribeToPlan = ref.watch(subscribeToPlanProvider);
      final cancelSubscription = ref.watch(cancelSubscriptionProvider);
      final pauseSubscription = ref.watch(pauseSubscriptionProvider);
      final resumeSubscription = ref.watch(resumeSubscriptionProvider);
      final upgradePlan = ref.watch(upgradePlanProvider);
      final restorePurchases = ref.watch(restorePurchasesProvider);

      return SubscriptionNotifier(
        getAvailablePlans,
        getCurrentSubscription,
        subscribeToPlan,
        cancelSubscription,
        pauseSubscription,
        resumeSubscription,
        upgradePlan,
        restorePurchases,
      );
    });
