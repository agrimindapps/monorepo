import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart' as core;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/subscription_plan.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPlanModel>> getAvailablePlans();
  Future<UserSubscriptionModel?> getCurrentSubscription(String userId);
  Future<UserSubscriptionModel> subscribeToPlan(String userId, String planId);
  Future<void> cancelSubscription(String userId);
  Future<void> pauseSubscription(String userId);
  Future<void> resumeSubscription(String userId);
  Future<UserSubscriptionModel> upgradePlan(String userId, String newPlanId);
  Future<void> restorePurchases(String userId);
  Future<bool> validateReceipt(String receiptData);
  Stream<UserSubscriptionModel?> watchSubscription(String userId);

  /// Get management URL to direct user to store subscription settings
  Future<String?> getSubscriptionManagementUrl();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final FirebaseFirestore firestore;
  final core.ISubscriptionRepository subscriptionRepository;

  SubscriptionRemoteDataSourceImpl({
    required this.firestore,
    required this.subscriptionRepository,
  });
  SubscriptionPlanModel _mapProductInfoToPlan(core.ProductInfo productInfo) {
    return SubscriptionPlanModel(
      id: productInfo.productId,
      productId: productInfo.productId,
      title: productInfo.title,
      description: productInfo.description,
      price: productInfo.price,
      currency: productInfo.currencyCode,
      type: _mapSubscriptionPeriodToPlanType(productInfo.subscriptionPeriod),
      durationInDays: _getDurationInDays(productInfo.subscriptionPeriod),
      features: _getFeaturesForProduct(productInfo.productId),
      isPopular: productInfo.productId.contains('yearly'),
      originalPrice: null, // Not provided by core
      trialDays: productInfo.freeTrialPeriod != null
          ? _parseTrialDays(productInfo.freeTrialPeriod!)
          : null,
      metadata: {
        'hasIntroPrice': productInfo.hasIntroPrice,
        'hasTrial': productInfo.hasFreeTrial,
      },
    );
  }

  UserSubscriptionModel _mapSubscriptionEntityToUserSubscription(
    core.SubscriptionEntity entity,
    String userId,
  ) {
    final planModel = SubscriptionPlanModel(
      id: entity.productId,
      productId: entity.productId,
      title: 'Premium Plan',
      description: 'Premium subscription',
      price: 0.0,
      currency: 'BRL',
      type: _mapTierToPlanType(entity.tier),
      features: const ['Premium features'],
    );

    return UserSubscriptionModel(
      id: entity.id,
      userId: userId,
      planId: entity.productId,
      plan: planModel,
      status: _mapSubscriptionStatusToPlanStatus(entity.status),
      startDate: entity.purchaseDate ?? entity.createdAt ?? DateTime.now(),
      expirationDate: entity.expirationDate,
      cancelledAt: null, // Not available in SubscriptionEntity
      pausedAt: null, // Not available in SubscriptionEntity
      autoRenew: !entity.isExpired,
      trialEndDate: entity.trialEndDate,
      receiptData: entity.id, // Using subscription ID as receipt
      metadata: const {},
      createdAt: entity.createdAt ?? DateTime.now(),
      updatedAt: entity.updatedAt ?? DateTime.now(),
    );
  }

  PlanType _mapSubscriptionPeriodToPlanType(String? period) {
    if (period == null) return PlanType.free;

    final periodLower = period.toLowerCase();
    if (periodLower.contains('month')) return PlanType.monthly;
    if (periodLower.contains('year') || periodLower.contains('annual')) {
      return PlanType.yearly;
    }
    if (periodLower.contains('lifetime')) return PlanType.lifetime;

    return PlanType.monthly;
  }

  int? _getDurationInDays(String? period) {
    if (period == null) return null;

    final periodLower = period.toLowerCase();
    if (periodLower.contains('month')) return 30;
    if (periodLower.contains('year') || periodLower.contains('annual')) {
      return 365;
    }
    if (periodLower.contains('lifetime')) return null;

    return 30;
  }

  PlanType _mapTierToPlanType(core.SubscriptionTier tier) {
    switch (tier) {
      case core.SubscriptionTier.free:
        return PlanType.free;
      case core.SubscriptionTier.basic:
        return PlanType.free;
      case core.SubscriptionTier.premium:
        return PlanType.monthly;
      case core.SubscriptionTier.pro:
        return PlanType.yearly;
      case core.SubscriptionTier.ultimate:
        return PlanType.lifetime;
      case core.SubscriptionTier.lifetime:
        return PlanType.lifetime;
      case core.SubscriptionTier.trial:
        return PlanType.monthly;
    }
  }

  PlanStatus _mapSubscriptionStatusToPlanStatus(
    core.SubscriptionStatus status,
  ) {
    switch (status) {
      case core.SubscriptionStatus.active:
        return PlanStatus.active;
      case core.SubscriptionStatus.expired:
        return PlanStatus.expired;
      case core.SubscriptionStatus.cancelled:
        return PlanStatus.cancelled;
      case core.SubscriptionStatus.paused:
        return PlanStatus.paused;
      case core.SubscriptionStatus.pending:
        return PlanStatus.pending;
      case core.SubscriptionStatus.gracePeriod:
        return PlanStatus.active; // Grace period is still active
      case core.SubscriptionStatus.unknown:
        return PlanStatus.pending;
    }
  }

  int? _parseTrialDays(String period) {
    final match = RegExp(r'(\d+)').firstMatch(period);
    if (match != null) {
      final days = int.tryParse(match.group(1)!);
      if (period.toLowerCase().contains('week') && days != null) {
        return days * 7;
      }
      return days;
    }
    return null;
  }

  List<String> _getFeaturesForProduct(String productId) {
    return [
      'Acesso ilimitado a todas as calculadoras',
      'Lembretes inteligentes',
      'Backup na nuvem',
      'Suporte prioritário',
      'Sem anúncios',
    ];
  }

  @override
  Future<List<SubscriptionPlanModel>> getAvailablePlans() async {
    try {
      final result = await subscriptionRepository.getAvailableProducts(
        productIds: [
          'petiveti_monthly',
          'petiveti_yearly',
        ], // Configure as needed
      );

      return result.fold(
        (failure) => throw ServerException(message: failure.message),
        (products) => products.map(_mapProductInfoToPlan).toList(),
      );
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar planos: $e');
    }
  }

  @override
  Future<UserSubscriptionModel?> getCurrentSubscription(String userId) async {
    try {
      final result = await subscriptionRepository.getCurrentSubscription();

      return result.fold(
        (failure) => throw ServerException(message: failure.message),
        (subscriptionEntity) {
          if (subscriptionEntity == null) return null;
          return _mapSubscriptionEntityToUserSubscription(
            subscriptionEntity,
            userId,
          );
        },
      );
    } catch (e) {
      throw ServerException(message: 'Erro ao buscar assinatura: $e');
    }
  }

  @override
  Future<UserSubscriptionModel> subscribeToPlan(
    String userId,
    String planId,
  ) async {
    try {
      final result = await subscriptionRepository.purchaseProduct(
        productId: planId,
      );

      return result.fold(
        (failure) => throw ServerException(message: failure.message),
        (subscriptionEntity) async {
          final subscriptionData = {
            'userId': userId,
            'planId': planId,
            'status': subscriptionEntity.status.name,
            'startedAt':
                subscriptionEntity.purchaseDate?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch,
            'expiresAt':
                subscriptionEntity.expirationDate?.millisecondsSinceEpoch,
            'autoRenew': !subscriptionEntity.isExpired,
            'receiptData': subscriptionEntity.id,
            'metadata': {
              'entitlementId': subscriptionEntity.id,
              'productId': subscriptionEntity.productId,
            },
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          };

          await firestore
              .collection('users')
              .doc(userId)
              .collection('subscriptions')
              .add(subscriptionData);
          await firestore.collection('users').doc(userId).update({
            'isPremium': subscriptionEntity.isActive,
            'premiumExpiresAt':
                subscriptionEntity.expirationDate?.millisecondsSinceEpoch,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });

          return _mapSubscriptionEntityToUserSubscription(
            subscriptionEntity,
            userId,
          );
        },
      );
    } catch (e) {
      throw ServerException(message: 'Erro na compra: $e');
    }
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get()
          .then((snapshot) async {
            if (snapshot.docs.isNotEmpty) {
              await snapshot.docs.first.reference.update({
                'cancelledAt': DateTime.now().millisecondsSinceEpoch,
                'autoRenew': false,
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              });
            }
          });
    } catch (e) {
      throw ServerException(message: 'Erro ao cancelar assinatura: $e');
    }
  }

  @override
  Future<void> pauseSubscription(String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get()
          .then((snapshot) async {
            if (snapshot.docs.isNotEmpty) {
              await snapshot.docs.first.reference.update({
                'pausedAt': DateTime.now().millisecondsSinceEpoch,
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              });
            }
          });
    } catch (e) {
      throw ServerException(message: 'Erro ao pausar assinatura: $e');
    }
  }

  @override
  Future<void> resumeSubscription(String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get()
          .then((snapshot) async {
            if (snapshot.docs.isNotEmpty) {
              await snapshot.docs.first.reference.update({
                'pausedAt': null,
                'updatedAt': DateTime.now().millisecondsSinceEpoch,
              });
            }
          });
    } catch (e) {
      throw ServerException(message: 'Erro ao retomar assinatura: $e');
    }
  }

  @override
  Future<UserSubscriptionModel> upgradePlan(
    String userId,
    String newPlanId,
  ) async {
    return await subscribeToPlan(userId, newPlanId);
  }

  @override
  Future<void> restorePurchases(String userId) async {
    try {
      final result = await subscriptionRepository.restorePurchases();

      return result.fold(
        (failure) => throw ServerException(message: failure.message),
        (subscriptions) async {
          final hasPremium = subscriptions.isNotEmpty;
          DateTime? expiresAt;

          if (hasPremium) {
            final latestSubscription = subscriptions.first;
            expiresAt = latestSubscription.expirationDate;
          }

          await firestore.collection('users').doc(userId).update({
            'isPremium': hasPremium,
            'premiumExpiresAt': expiresAt?.millisecondsSinceEpoch,
            'updatedAt': DateTime.now().millisecondsSinceEpoch,
          });
        },
      );
    } catch (e) {
      throw ServerException(message: 'Erro ao restaurar compras: $e');
    }
  }

  @override
  Future<bool> validateReceipt(String receiptData) async {
    try {
      final result = await subscriptionRepository.getCurrentSubscription();

      return result.fold(
        (failure) => throw ServerException(message: failure.message),
        (subscription) => subscription?.isActive ?? false,
      );
    } catch (e) {
      throw ServerException(message: 'Erro ao validar recibo: $e');
    }
  }

  @override
  Stream<UserSubscriptionModel?> watchSubscription(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('subscriptions')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            return null;
          }

          final doc = snapshot.docs.first;
          final data = doc.data();
          try {
            final result = await subscriptionRepository
                .getCurrentSubscription();

            return result.fold(
              (_) => null, // On failure, return null
              (subscriptionEntity) {
                if (subscriptionEntity == null) return null;

                return _mapSubscriptionEntityToUserSubscription(
                  subscriptionEntity,
                  userId,
                );
              },
            );
          } catch (e) {
            return UserSubscriptionModel(
              id: doc.id,
              userId: userId,
              planId: (data['planId'] as String?) ?? '',
              plan: SubscriptionPlanModel(
                id: (data['planId'] as String?) ?? 'default',
                productId: (data['planId'] as String?) ?? 'default',
                title: 'Plano Básico',
                description: 'Plano básico temporário',
                price: 0.0,
                currency: 'BRL',
                type: PlanType.free,
                features: const [],
              ),
              status: PlanStatus.values.firstWhere(
                (s) => s.name == data['status'],
                orElse: () => PlanStatus.expired,
              ),
              startDate: DateTime.fromMillisecondsSinceEpoch(
                data['startedAt'] as int,
              ),
              expirationDate: data['expiresAt'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      data['expiresAt'] as int,
                    )
                  : null,
              cancelledAt: data['cancelledAt'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      data['cancelledAt'] as int,
                    )
                  : null,
              pausedAt: data['pausedAt'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(data['pausedAt'] as int)
                  : null,
              autoRenew: (data['autoRenew'] as bool?) ?? false,
              trialEndDate: null,
              receiptData: (data['receiptData'] as String?) ?? '',
              metadata: Map<String, dynamic>.from(
                data['metadata'] as Map<dynamic, dynamic>? ?? {},
              ),
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                data['createdAt'] as int,
              ),
              updatedAt: DateTime.now(),
            );
          }
        });
  }

  @override
  Future<String?> getSubscriptionManagementUrl() async {
    try {
      final result = await subscriptionRepository.getManagementUrl();

      return result.fold((failure) {
        return null;
      }, (url) => url);
    } catch (e) {
      return null;
    }
  }
}
