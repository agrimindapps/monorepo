import 'package:core/core.dart' hide SubscriptionStatus, Column;

import '../../../../core/di/di_providers.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/check_subscription_status.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../domain/usecases/get_available_packages.dart';
import '../../data/datasources/local/premium_local_datasource.dart';

part 'premium_providers.g.dart';

// ============================================================================
// Data Source Provider
// ============================================================================

@riverpod
PremiumLocalDataSource premiumLocalDataSource(
  PremiumLocalDataSourceRef ref,
) {
  return ref.watch(getItProvider).get<PremiumLocalDataSource>();
}

// ============================================================================
// Repository Provider
// ============================================================================

@riverpod
PremiumRepository premiumRepository(PremiumRepositoryRef ref) {
  return ref.watch(getItProvider).get<PremiumRepository>();
}

// ============================================================================
// Use Case Providers
// ============================================================================

@riverpod
CheckSubscriptionStatus checkSubscriptionStatusUseCase(
  CheckSubscriptionStatusUseCaseRef ref,
) {
  return CheckSubscriptionStatus(ref.watch(premiumRepositoryProvider));
}

@riverpod
RestorePurchases restorePurchasesUseCase(RestorePurchasesUseCaseRef ref) {
  return RestorePurchases(ref.watch(premiumRepositoryProvider));
}

@riverpod
GetAvailablePackages getAvailablePackagesUseCase(
  GetAvailablePackagesUseCaseRef ref,
) {
  return GetAvailablePackages(ref.watch(premiumRepositoryProvider));
}

// ============================================================================
// Premium Status State Notifier
// ============================================================================

@riverpod
class PremiumStatusNotifier extends _$PremiumStatusNotifier {
  @override
  Future<SubscriptionStatus> build() async {
    final useCase = ref.read(checkSubscriptionStatusUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (status) => status,
    );
  }

  /// Restore purchases from app store
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(restorePurchasesUseCaseProvider);
      final result = await useCase();

      return result.fold(
        (failure) => throw Exception(failure.message),
        (status) => status,
      );
    });
  }

  /// Refresh subscription status
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(checkSubscriptionStatusUseCaseProvider);
      final result = await useCase();

      return result.fold(
        (failure) => throw Exception(failure.message),
        (status) => status,
      );
    });
  }
}

// ============================================================================
// Available Packages Provider
// ============================================================================

@riverpod
class AvailablePackagesNotifier extends _$AvailablePackagesNotifier {
  @override
  Future<List<Package>> build() async {
    final useCase = ref.read(getAvailablePackagesUseCaseProvider);
    final result = await useCase();

    return result.fold(
      (failure) => throw Exception(failure.message),
      (packages) => packages.cast<Package>(),
    );
  }

  /// Refresh available packages
  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final useCase = ref.read(getAvailablePackagesUseCaseProvider);
      final result = await useCase();

      return result.fold(
        (failure) => throw Exception(failure.message),
        (packages) => packages.cast<Package>(),
      );
    });
  }
}

// ============================================================================
// Derived State Providers
// ============================================================================

/// Provider for checking if user is premium
@riverpod
bool isPremium(IsPremiumRef ref) {
  final statusAsync = ref.watch(premiumStatusNotifierProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.isPremium,
    orElse: () => false,
  );
}

/// Provider for subscription type
@riverpod
String? subscriptionType(SubscriptionTypeRef ref) {
  final statusAsync = ref.watch(premiumStatusNotifierProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.subscriptionType,
    orElse: () => null,
  );
}

/// Provider for days remaining
@riverpod
int? daysRemaining(DaysRemainingRef ref) {
  final statusAsync = ref.watch(premiumStatusNotifierProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.daysRemaining,
    orElse: () => null,
  );
}

/// Provider for checking if subscription is about to expire
@riverpod
bool isAboutToExpire(IsAboutToExpireRef ref) {
  final statusAsync = ref.watch(premiumStatusNotifierProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.isAboutToExpire,
    orElse: () => false,
  );
}
