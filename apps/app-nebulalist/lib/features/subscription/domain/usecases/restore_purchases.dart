import 'package:core/core.dart' as core;
import 'package:flutter/foundation.dart';

/// UseCase for restoring previous purchases
///
/// This use case handles restoring purchases made on other devices
/// or after reinstalling the app.
class RestorePurchases {
  final core.ISubscriptionRepository _repository;

  RestorePurchases(this._repository);

  /// Restore previous purchases
  ///
  /// Returns:
  /// - Right(true) if active subscription was found and restored
  /// - Right(false) if no active subscription was found
  /// - Left(Failure) if restore operation failed
  Future<core.Either<core.Failure, bool>> call() async {
    try {
      debugPrint('[RestorePurchases] Starting restore purchases...');

      final result = await _repository.restorePurchases();

      return result.fold(
        (failure) {
          debugPrint('[RestorePurchases] Restore failed: $failure');
          return core.Left(failure);
        },
        (subscriptions) {
          if (subscriptions.isEmpty) {
            debugPrint('[RestorePurchases] No subscriptions found');
            return const core.Right(false);
          }

          // Check if any subscription is active
          final hasActiveSubscription = subscriptions.any((sub) => sub.isActive);

          if (hasActiveSubscription) {
            debugPrint('[RestorePurchases] Active subscription found!');
            final activeSub = subscriptions.firstWhere((sub) => sub.isActive);
            debugPrint('[RestorePurchases] Product: ${activeSub.productId}');
            return const core.Right(true);
          } else {
            debugPrint('[RestorePurchases] No active subscription found');
            return const core.Right(false);
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('[RestorePurchases] Unexpected error: $e');
      debugPrint('[RestorePurchases] Stack: $stackTrace');
      return core.Left(core.UnexpectedFailure('Erro ao restaurar compras: $e'));
    }
  }
}
