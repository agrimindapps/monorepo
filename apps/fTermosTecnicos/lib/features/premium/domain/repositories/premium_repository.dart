import 'package:dartz/dartz.dart';
import 'package:core/core.dart';

import '../entities/subscription_status.dart';

/// Repository interface for premium/subscription operations
/// Follows Repository Pattern from Clean Architecture
abstract class PremiumRepository {
  /// Check current subscription status
  Future<Either<Failure, SubscriptionStatus>> checkSubscriptionStatus();

  /// Restore purchases from store (Google Play / App Store)
  Future<Either<Failure, SubscriptionStatus>> restorePurchases();

  /// Get available subscription packages
  Future<Either<Failure, List<dynamic>>> getAvailablePackages();
}
