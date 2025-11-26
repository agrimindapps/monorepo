import 'package:core/core.dart' hide SubscriptionStatus, Column;

import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/premium_repository.dart';
import '../../domain/usecases/check_subscription_status.dart';
import '../../domain/usecases/restore_purchases.dart';
import '../../domain/usecases/get_available_packages.dart';
import '../../data/datasources/local/premium_local_datasource.dart';
import '../../data/repositories/premium_repository_impl.dart';

part 'premium_providers.g.dart';

// ============================================================================
// Data Source Provider
// ============================================================================

@riverpod
PremiumLocalDataSource premiumLocalDataSource(Ref ref) {
  return PremiumLocalDataSourceImpl();
}

// ============================================================================
// Repository Provider
// ============================================================================

@riverpod
PremiumRepository premiumRepository(Ref ref) {
  final dataSource = ref.watch(premiumLocalDataSourceProvider);
  return PremiumRepositoryImpl(dataSource);
}

// ============================================================================
// Use Case Providers
// ============================================================================

@riverpod
CheckSubscriptionStatus checkSubscriptionStatusUseCase(Ref ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return CheckSubscriptionStatus(repository);
}

@riverpod
RestorePurchases restorePurchasesUseCase(Ref ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return RestorePurchases(repository);
}

@riverpod
GetAvailablePackages getAvailablePackagesUseCase(Ref ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return GetAvailablePackages(repository);
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
bool isPremium(Ref ref) {
  final statusAsync = ref.watch(premiumStatusProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.isPremium,
    orElse: () => false,
  );
}

/// Provider for subscription type
@riverpod
String? subscriptionType(Ref ref) {
  final statusAsync = ref.watch(premiumStatusProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.subscriptionType,
    orElse: () => null,
  );
}

/// Provider for days remaining
@riverpod
int? daysRemaining(Ref ref) {
  final statusAsync = ref.watch(premiumStatusProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.daysRemaining,
    orElse: () => null,
  );
}

/// Provider for checking if subscription is about to expire
@riverpod
bool isAboutToExpire(Ref ref) {
  final statusAsync = ref.watch(premiumStatusProvider);

  return statusAsync.maybeWhen(
    data: (status) => status.isAboutToExpire,
    orElse: () => false,
  );
}
