import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_services_providers.dart';
import '../../data/datasources/noop_subscription_repository.dart';
import '../../data/datasources/subscription_local_datasource.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../data/services/subscription_error_handling_service.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../domain/services/subscription_validation_service.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/usecases/subscription_usecases.dart';

part 'subscription_providers.g.dart';

// ============================================================================
// SERVICES
// ============================================================================

@riverpod
SubscriptionValidationService subscriptionValidationService(
  Ref ref,
) {
  return SubscriptionValidationService();
}

@riverpod
SubscriptionErrorHandlingService subscriptionErrorHandlingService(
  Ref ref,
) {
  return SubscriptionErrorHandlingService();
}

// ============================================================================
// DATA SOURCES
// ============================================================================

@riverpod
SubscriptionLocalDataSource subscriptionLocalDataSource(
  Ref ref,
) {
  return SubscriptionLocalDataSourceImpl();
}

@riverpod
SubscriptionRemoteDataSource subscriptionRemoteDataSource(
  Ref ref,
) {
  return SubscriptionRemoteDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    // TODO: Remove circular dependency or use proper core ISubscriptionRepository
    subscriptionRepository: const NoOpSubscriptionRepository(),
  );
}

// ============================================================================
// REPOSITORY
// ============================================================================

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) {
  return SubscriptionRepositoryImpl(
    localDataSource: ref.watch(subscriptionLocalDataSourceProvider),
    remoteDataSource: ref.watch(subscriptionRemoteDataSourceProvider),
    errorHandlingService: ref.watch(subscriptionErrorHandlingServiceProvider),
  );
}

// ============================================================================
// USE CASES (Read)
// ============================================================================

@riverpod
GetAvailablePlans getAvailablePlans(Ref ref) {
  return GetAvailablePlans(ref.watch(subscriptionRepositoryProvider));
}

@riverpod
GetCurrentSubscription getCurrentSubscription(
  Ref ref,
) {
  return GetCurrentSubscription(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionValidationServiceProvider),
  );
}

// ============================================================================
// USE CASES (Write)
// ============================================================================

@riverpod
SubscribeToPlan subscribeToPlan(Ref ref) {
  return SubscribeToPlan(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionValidationServiceProvider),
  );
}

@riverpod
CancelSubscription cancelSubscription(Ref ref) {
  return CancelSubscription(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionValidationServiceProvider),
  );
}

@riverpod
PauseSubscription pauseSubscription(Ref ref) {
  return PauseSubscription(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionValidationServiceProvider),
  );
}

@riverpod
ResumeSubscription resumeSubscription(Ref ref) {
  return ResumeSubscription(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionValidationServiceProvider),
  );
}

@riverpod
UpgradePlan upgradePlan(Ref ref) {
  return UpgradePlan(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionValidationServiceProvider),
  );
}

@riverpod
RestorePurchases restorePurchases(Ref ref) {
  return RestorePurchases(
    ref.watch(subscriptionRepositoryProvider),
    ref.watch(subscriptionValidationServiceProvider),
  );
}

// ============================================================================
// NOTIFIER & STATE
// ============================================================================

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
