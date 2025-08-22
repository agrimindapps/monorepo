import 'package:dartz/dartz.dart';
import '../error/failures.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/subscription/domain/entities/user_subscription.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';

/// Central authentication and authorization service
class AuthService {
  final AuthRepository _authRepository;
  final SubscriptionRepository _subscriptionRepository;

  AuthService({
    required AuthRepository authRepository,
    required SubscriptionRepository subscriptionRepository,
  })  : _authRepository = authRepository,
        _subscriptionRepository = subscriptionRepository;

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser() async {
    return await _authRepository.getCurrentUser();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final result = await getCurrentUser();
    return result.fold(
      (failure) => false,
      (user) => user != null,
    );
  }

  /// Check if current user has premium subscription
  Future<bool> hasPremiumAccess() async {
    final userResult = await getCurrentUser();
    if (userResult.isLeft()) return false;
    
    final user = userResult.getOrElse(() => null);
    if (user == null) return false;

    // Check if user has premium status
    if (user.isPremium) {
      // Verify subscription is not expired
      if (user.premiumExpiresAt != null) {
        return user.premiumExpiresAt!.isAfter(DateTime.now());
      }
      return true; // Lifetime or no expiration
    }

    // Also check subscription repository for most up-to-date status
    final subscriptionResult = await _subscriptionRepository.getCurrentSubscription(user.id);
    return subscriptionResult.fold(
      (failure) => false,
      (subscription) => subscription?.isActive ?? false,
    );
  }

  /// Check if user can access a specific premium feature
  Future<bool> canAccessPremiumFeature(String featureName) async {
    // First check if user is authenticated
    if (!(await isAuthenticated())) return false;
    
    // Then check premium access
    return await hasPremiumAccess();
  }

  /// Get current subscription details
  Future<Either<Failure, UserSubscription?>> getCurrentSubscription() async {
    final userResult = await getCurrentUser();
    if (userResult.isLeft()) {
      return Left(AuthFailure(message: 'User not authenticated'));
    }
    
    final user = userResult.getOrElse(() => null);
    if (user == null) {
      return Left(AuthFailure(message: 'User not found'));
    }

    return await _subscriptionRepository.getCurrentSubscription(user.id);
  }

  /// Sign out user
  Future<Either<Failure, void>> signOut() async {
    return await _authRepository.signOut();
  }

  /// Watch authentication state changes
  Stream<Either<Failure, User?>> watchAuthState() {
    return _authRepository.watchAuthState();
  }

  /// Watch subscription state changes
  Stream<Either<Failure, UserSubscription?>> watchSubscription() async* {
    await for (final userResult in watchAuthState()) {
      if (userResult.isLeft()) {
        yield Left(userResult.swap().getOrElse(() => AuthFailure(message: 'Auth error')));
        continue;
      }

      final user = userResult.getOrElse(() => null);
      if (user == null) {
        yield const Right(null);
        continue;
      }

      yield* _subscriptionRepository.watchSubscription(user.id);
    }
  }

  /// Check feature availability based on subscription tier
  bool isFeatureAvailable(PremiumFeature feature) {
    // This could be expanded to check specific feature entitlements
    // For now, all premium features require premium subscription
    return true; // Base features are always available
  }

  /// Get user permission level
  Future<UserPermissionLevel> getUserPermissionLevel() async {
    if (!(await isAuthenticated())) {
      return UserPermissionLevel.guest;
    }

    if (await hasPremiumAccess()) {
      return UserPermissionLevel.premium;
    }

    return UserPermissionLevel.basic;
  }

  /// Validate if user can perform action
  Future<bool> canPerformAction(RequiredPermission permission) async {
    final userLevel = await getUserPermissionLevel();
    return permission.isAllowedForLevel(userLevel);
  }
}

/// Enum for different premium features
enum PremiumFeature {
  advancedCalculators,
  unlimitedAnimals,
  cloudBackup,
  exportData,
  advancedReports,
  prioritySupport,
  adFree,
}

/// User permission levels
enum UserPermissionLevel {
  guest,
  basic,
  premium,
}

/// Required permission for actions
class RequiredPermission {
  final String name;
  final UserPermissionLevel minimumLevel;
  final List<PremiumFeature>? requiredFeatures;

  const RequiredPermission({
    required this.name,
    required this.minimumLevel,
    this.requiredFeatures,
  });

  bool isAllowedForLevel(UserPermissionLevel userLevel) {
    return userLevel.index >= minimumLevel.index;
  }

  static const viewAnimals = RequiredPermission(
    name: 'view_animals',
    minimumLevel: UserPermissionLevel.basic,
  );

  static const addUnlimitedAnimals = RequiredPermission(
    name: 'add_unlimited_animals',
    minimumLevel: UserPermissionLevel.premium,
    requiredFeatures: [PremiumFeature.unlimitedAnimals],
  );

  static const useAdvancedCalculators = RequiredPermission(
    name: 'use_advanced_calculators',
    minimumLevel: UserPermissionLevel.premium,
    requiredFeatures: [PremiumFeature.advancedCalculators],
  );

  static const exportData = RequiredPermission(
    name: 'export_data',
    minimumLevel: UserPermissionLevel.premium,
    requiredFeatures: [PremiumFeature.exportData],
  );

  static const cloudBackup = RequiredPermission(
    name: 'cloud_backup',
    minimumLevel: UserPermissionLevel.premium,
    requiredFeatures: [PremiumFeature.cloudBackup],
  );
}