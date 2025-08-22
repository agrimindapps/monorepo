import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:app_agrihurbi/core/error/failures.dart';
import 'package:app_agrihurbi/core/error/exceptions.dart';
import 'package:app_agrihurbi/core/network/network_info.dart';
import 'package:app_agrihurbi/features/subscription/domain/entities/subscription_entity.dart';
import 'package:app_agrihurbi/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:app_agrihurbi/features/subscription/data/datasources/subscription_remote_datasource.dart';
import 'package:app_agrihurbi/features/subscription/data/datasources/subscription_local_datasource.dart';
import 'package:app_agrihurbi/features/subscription/data/models/subscription_model.dart';

@LazySingleton(as: SubscriptionRepository)
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;
  final SubscriptionLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const SubscriptionRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, SubscriptionEntity?>> getCurrentSubscription() async {
    try {
      if (await _networkInfo.isConnected) {
        final subscription = await _remoteDataSource.getCurrentSubscription('current_user');
        if (subscription != null) {
          await _localDataSource.cacheSubscription(subscription);
        }
        return Right(subscription);
      } else {
        final cached = await _localDataSource.getCachedSubscription();
        return Right(cached);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> createSubscription({
    required SubscriptionTier tier,
    required BillingPeriod billingPeriod,
    required PaymentMethod paymentMethod,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final data = {
          'tier': tier.name,
          'billingPeriod': billingPeriod.name,
          'paymentMethod': PaymentMethodModel.fromEntity(paymentMethod).toJson(),
        };
        final subscription = await _remoteDataSource.createSubscription(data);
        await _localDataSource.cacheSubscription(subscription);
        return Right(subscription);
      } else {
        return Left(ServerFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> upgradeSubscription({
    required SubscriptionTier newTier,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final subscription = await _remoteDataSource.updateSubscription('current', {'tier': newTier.name});
        await _localDataSource.cacheSubscription(subscription);
        return Right(subscription);
      } else {
        return Left(ServerFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> downgradeSubscription({
    required SubscriptionTier newTier,
  }) async {
    return upgradeSubscription(newTier: newTier);
  }

  @override
  Future<Either<Failure, void>> cancelSubscription({
    bool cancelImmediately = false,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.cancelSubscription('current');
        await _localDataSource.clearSubscriptionCache();
        return const Right(null);
      } else {
        return Left(ServerFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> reactivateSubscription() async {
    try {
      if (await _networkInfo.isConnected) {
        final subscription = await _remoteDataSource.updateSubscription('current', {'status': 'active'});
        await _localDataSource.cacheSubscription(subscription);
        return Right(subscription);
      } else {
        return Left(ServerFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasFeatureAccess(PremiumFeature feature) async {
    try {
      final subscription = await _localDataSource.getCachedSubscription();
      if (subscription == null) return const Right(false);
      
      final featureModel = PremiumFeatureModel.fromEntity(feature);
      return Right(subscription.features.contains(featureModel));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PremiumFeature>>> getAvailableFeatures() async {
    try {
      final subscription = await _localDataSource.getCachedSubscription();
      if (subscription == null) return const Right([]);
      
      return Right(subscription.features.map((f) => f.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, FeatureUsage>> getFeatureUsage(PremiumFeature feature) async {
    try {
      final featureModel = PremiumFeatureModel.fromEntity(feature);
      final usage = await _localDataSource.getFeatureUsage(featureModel);
      
      if (usage == null) {
        return Right(FeatureUsage(
          feature: feature,
          currentUsage: 0,
          limit: _getFeatureLimit(feature),
          resetDate: DateTime.now().add(const Duration(days: 30)),
        ));
      }
      
      return Right(FeatureUsage(
        feature: feature,
        currentUsage: usage['usage'] ?? 0,
        limit: _getFeatureLimit(feature),
        resetDate: DateTime.parse(usage['resetDate'] ?? DateTime.now().toIso8601String()),
      ));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordFeatureUsage({
    required PremiumFeature feature,
    int usage = 1,
  }) async {
    try {
      final featureModel = PremiumFeatureModel.fromEntity(feature);
      await _localDataSource.recordFeatureUsage(featureModel, usage);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(GeneralFailure('Unexpected error: $e'));
    }
  }

  int _getFeatureLimit(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.advancedCalculators:
        return 100;
      case PremiumFeature.exportData:
        return 10;
      case PremiumFeature.customReports:
        return 5;
      default:
        return 1000;
    }
  }

  // Simplified implementations for other methods...
  @override
  Future<Either<Failure, List<SubscriptionEntity>>> getSubscriptionHistory() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices({int limit = 20, int offset = 0}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, String>> downloadInvoice(String invoiceId) async {
    return const Right('');
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, PaymentMethod>> addPaymentMethod({
    required PaymentType type,
    required String token,
  }) async {
    return Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, PaymentMethod>> updatePaymentMethod({
    required String paymentMethodId,
    required DateTime expiryDate,
  }) async {
    return Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> removePaymentMethod(String paymentMethodId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setDefaultPaymentMethod(String paymentMethodId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getSubscriptionPlans() async {
    try {
      if (await _networkInfo.isConnected) {
        final plans = await _remoteDataSource.getSubscriptionPlans();
        return Right(plans.map((p) => SubscriptionPlan(
          tier: SubscriptionTier.values.firstWhere((t) => t.name == p['tier']),
          name: p['name'],
          description: p['description'],
          monthlyPrice: p['monthlyPrice'].toDouble(),
          yearlyPrice: p['yearlyPrice'].toDouble(),
          features: (p['features'] as List).map((f) => PremiumFeature.values.firstWhere((pf) => pf.name == f)).toList(),
          benefits: List<String>.from(p['benefits'] ?? []),
          isPopular: p['isPopular'] ?? false,
        )).toList());
      }
      return const Right([]);
    } catch (e) {
      return Left(ServerFailure('Failed to get subscription plans'));
    }
  }

  @override
  Future<Either<Failure, SubscriptionPlan>> getPlanDetails(SubscriptionTier tier) async {
    final plansResult = await getSubscriptionPlans();
    return plansResult.fold(
      (failure) => Left(failure),
      (plans) {
        final plan = plans.firstWhere((p) => p.tier == tier, orElse: () => plans.first);
        return Right(plan);
      },
    );
  }

  @override
  Future<Either<Failure, List<PlanComparison>>> comparePlans() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> startFreeTrial({
    required SubscriptionTier tier,
    int trialDays = 7,
  }) async {
    return Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, bool>> isTrialEligible() async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, TrialStatus?>> getTrialStatus() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, PromoCodeResult>> applyPromoCode(String code) async {
    try {
      if (await _networkInfo.isConnected) {
        final result = await _remoteDataSource.applyPromoCode(code);
        return Right(PromoCodeResult(
          code: code,
          discountPercent: result['discountPercent'].toDouble(),
          discountAmount: result['discountAmount'].toDouble(),
          expiresAt: DateTime.parse(result['expiresAt']),
          isValid: result['isValid'],
          errorMessage: result['errorMessage'],
        ));
      }
      return Left(ServerFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('Failed to apply promo code'));
    }
  }

  @override
  Future<Either<Failure, void>> removePromoCode() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Discount>>> getActiveDiscounts() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<SubscriptionNotification>>> getNotifications() async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateNotificationPreferences({
    required bool renewalReminders,
    required bool paymentFailures,
    required bool trialExpiry,
    required bool newFeatures,
  }) async {
    return const Right(null);
  }
}