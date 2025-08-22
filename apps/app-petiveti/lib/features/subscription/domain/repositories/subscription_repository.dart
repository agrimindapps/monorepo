import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/subscription_plan.dart';
import '../entities/user_subscription.dart';

abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlan>>> getAvailablePlans();
  Future<Either<Failure, UserSubscription?>> getCurrentSubscription(String userId);
  Future<Either<Failure, UserSubscription>> subscribeToPlan(String userId, String planId);
  Future<Either<Failure, void>> cancelSubscription(String userId);
  Future<Either<Failure, void>> pauseSubscription(String userId);
  Future<Either<Failure, void>> resumeSubscription(String userId);
  Future<Either<Failure, UserSubscription>> upgradePlan(String userId, String newPlanId);
  Future<Either<Failure, void>> restorePurchases(String userId);
  Future<Either<Failure, bool>> validateReceipt(String receiptData);
  Stream<Either<Failure, UserSubscription?>> watchSubscription(String userId);
}