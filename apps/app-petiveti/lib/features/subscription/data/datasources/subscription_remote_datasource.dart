import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/exceptions.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';
import '../../domain/entities/subscription_plan.dart';

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
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final FirebaseFirestore firestore;
  final Purchases revenuecat;

  SubscriptionRemoteDataSourceImpl({
    required this.firestore,
    required this.revenuecat,
  });

  @override
  Future<List<SubscriptionPlanModel>> getAvailablePlans() async {
    try {
      // Get offerings from RevenueCat
      final offerings = await revenuecat.getOfferings();
      
      if (offerings.current == null) {
        return [];
      }

      final List<SubscriptionPlanModel> plans = [];
      
      // Convert RevenueCat offerings to our models
      final currentOffering = offerings.current!;
      
      for (final package in currentOffering.availablePackages) {
        final product = package.storeProduct;
        
        plans.add(SubscriptionPlanModel(
          id: package.identifier,
          productId: product.identifier,
          title: product.title,
          description: product.description,
          price: product.price,
          currency: product.currencyCode,
          type: _mapPackageTypeToPlanType(package.packageType),
          durationInDays: _getDurationInDays(package.packageType),
          features: _getFeaturesForPackage(package.identifier),
          isPopular: package.identifier.contains('yearly'),
          originalPrice: null, // RevenueCat doesn't provide original price directly
          trialDays: null, // Can be extracted from product.introPrice if available
          metadata: {
            'packageType': package.packageType.name,
            'offeringId': currentOffering.identifier,
          },
        ));
      }

      return plans;
    } on PlatformException catch (e) {
      throw ServerException(message: 'Erro ao buscar planos: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Erro inesperado ao buscar planos: $e');
    }
  }

  @override
  Future<UserSubscriptionModel?> getCurrentSubscription(String userId) async {
    try {
      // Get customer info from RevenueCat
      final customerInfo = await revenuecat.getCustomerInfo();
      
      // Also get from Firestore for additional metadata
      final userDoc = await firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (customerInfo.entitlements.active.isEmpty) {
        return null;
      }

      // Get the first active entitlement (should be primary subscription)
      final entitlementInfo = customerInfo.entitlements.active.values.first;
      
      Map<String, dynamic>? firestoreData;
      if (userDoc.docs.isNotEmpty) {
        firestoreData = userDoc.docs.first.data();
      }

      return UserSubscriptionModel(
        id: entitlementInfo.identifier,
        userId: userId,
        planId: entitlementInfo.productIdentifier,
        status: _mapEntitlementToPlanStatus(entitlementInfo),
        startedAt: entitlementInfo.originalPurchaseDate,
        expiresAt: entitlementInfo.expirationDate,
        cancelledAt: null, // RevenueCat doesn't provide cancellation date directly
        pausedAt: null,
        autoRenew: entitlementInfo.willRenew,
        trialEndsAt: null, // Can be derived from entitlementInfo if needed
        receiptData: customerInfo.originalPurchaseDate.toString(),
        metadata: firestoreData?['metadata'] ?? {},
        createdAt: firestoreData?['createdAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(firestoreData!['createdAt'])
            : entitlementInfo.originalPurchaseDate,
        updatedAt: DateTime.now(),
      );
    } on PlatformException catch (e) {
      throw ServerException(message: 'Erro ao buscar assinatura: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Erro inesperado ao buscar assinatura: $e');
    }
  }

  @override
  Future<UserSubscriptionModel> subscribeToPlan(String userId, String planId) async {
    try {
      // Get the package from offerings
      final offerings = await revenuecat.getOfferings();
      final currentOffering = offerings.current;
      
      if (currentOffering == null) {
        throw ServerException(message: 'Nenhum plano disponível');
      }

      final package = currentOffering.availablePackages
          .where((p) => p.identifier == planId)
          .firstOrNull;

      if (package == null) {
        throw ServerException(message: 'Plano não encontrado: $planId');
      }

      // Make the purchase
      final customerInfo = await revenuecat.purchasePackage(package);
      
      // Verify the purchase was successful
      if (customerInfo.entitlements.active.isEmpty) {
        throw ServerException(message: 'Falha na compra do plano');
      }

      final entitlementInfo = customerInfo.entitlements.active.values.first;

      // Save to Firestore for additional tracking
      final subscriptionData = {
        'userId': userId,
        'planId': planId,
        'status': _mapEntitlementToPlanStatus(entitlementInfo).name,
        'startedAt': entitlementInfo.originalPurchaseDate.millisecondsSinceEpoch,
        'expiresAt': entitlementInfo.expirationDate?.millisecondsSinceEpoch,
        'autoRenew': entitlementInfo.willRenew,
        'receiptData': customerInfo.originalPurchaseDate.toString(),
        'metadata': {
          'entitlementId': entitlementInfo.identifier,
          'productId': entitlementInfo.productIdentifier,
        },
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await firestore
          .collection('users')
          .doc(userId)
          .collection('subscriptions')
          .add(subscriptionData);

      // Also update user premium status
      await firestore.collection('users').doc(userId).update({
        'isPremium': true,
        'premiumExpiresAt': entitlementInfo.expirationDate?.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      return UserSubscriptionModel(
        id: entitlementInfo.identifier,
        userId: userId,
        planId: planId,
        status: _mapEntitlementToPlanStatus(entitlementInfo),
        startedAt: entitlementInfo.originalPurchaseDate,
        expiresAt: entitlementInfo.expirationDate,
        cancelledAt: null,
        pausedAt: null,
        autoRenew: entitlementInfo.willRenew,
        trialEndsAt: null,
        receiptData: customerInfo.originalPurchaseDate.toString(),
        metadata: subscriptionData['metadata'] as Map<String, dynamic>,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } on PlatformException catch (e) {
      throw ServerException(message: 'Erro na compra: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Erro inesperado na compra: $e');
    }
  }

  @override
  Future<void> cancelSubscription(String userId) async {
    try {
      // Note: RevenueCat doesn't provide direct cancellation
      // This typically needs to be done through the app store
      // We update our records to reflect the intention
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
      // Similar to cancellation, pausing might need to be done through app store
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
  Future<UserSubscriptionModel> upgradePlan(String userId, String newPlanId) async {
    // For RevenueCat, upgrading is similar to subscribing to a new plan
    return await subscribeToPlan(userId, newPlanId);
  }

  @override
  Future<void> restorePurchases(String userId) async {
    try {
      final customerInfo = await revenuecat.restorePurchases();
      
      // Update user premium status based on restored purchases
      final hasPremium = customerInfo.entitlements.active.isNotEmpty;
      DateTime? expiresAt;
      
      if (hasPremium) {
        final entitlement = customerInfo.entitlements.active.values.first;
        expiresAt = entitlement.expirationDate;
      }

      await firestore.collection('users').doc(userId).update({
        'isPremium': hasPremium,
        'premiumExpiresAt': expiresAt?.millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      throw ServerException(message: 'Erro ao restaurar compras: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Erro inesperado ao restaurar compras: $e');
    }
  }

  @override
  Future<bool> validateReceipt(String receiptData) async {
    try {
      // RevenueCat handles receipt validation automatically
      final customerInfo = await revenuecat.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      throw ServerException(message: 'Erro ao validar recibo: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Erro inesperado ao validar recibo: $e');
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

      // Also get latest customer info from RevenueCat
      try {
        final customerInfo = await revenuecat.getCustomerInfo();
        final hasActiveEntitlement = customerInfo.entitlements.active.isNotEmpty;
        
        if (!hasActiveEntitlement) {
          return null;
        }

        final entitlement = customerInfo.entitlements.active.values.first;

        return UserSubscriptionModel(
          id: doc.id,
          userId: userId,
          planId: data['planId'] ?? entitlement.productIdentifier,
          status: _mapEntitlementToPlanStatus(entitlement),
          startedAt: DateTime.fromMillisecondsSinceEpoch(data['startedAt']),
          expiresAt: entitlement.expirationDate,
          cancelledAt: data['cancelledAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['cancelledAt'])
              : null,
          pausedAt: data['pausedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['pausedAt'])
              : null,
          autoRenew: entitlement.willRenew,
          trialEndsAt: null,
          receiptData: data['receiptData'] ?? '',
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
          updatedAt: DateTime.now(),
        );
      } catch (e) {
        // If RevenueCat fails, return data from Firestore only
        return UserSubscriptionModel(
          id: doc.id,
          userId: userId,
          planId: data['planId'] ?? '',
          status: PlanStatus.values.firstWhere(
            (s) => s.name == data['status'],
            orElse: () => PlanStatus.expired,
          ),
          startedAt: DateTime.fromMillisecondsSinceEpoch(data['startedAt']),
          expiresAt: data['expiresAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['expiresAt'])
              : null,
          cancelledAt: data['cancelledAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['cancelledAt'])
              : null,
          pausedAt: data['pausedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(data['pausedAt'])
              : null,
          autoRenew: data['autoRenew'] ?? false,
          trialEndsAt: null,
          receiptData: data['receiptData'] ?? '',
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  // Helper methods
  PlanType _mapPackageTypeToPlanType(PackageType packageType) {
    switch (packageType) {
      case PackageType.monthly:
        return PlanType.monthly;
      case PackageType.annual:
        return PlanType.yearly;
      case PackageType.lifetime:
        return PlanType.lifetime;
      default:
        return PlanType.monthly;
    }
  }

  int? _getDurationInDays(PackageType packageType) {
    switch (packageType) {
      case PackageType.monthly:
        return 30;
      case PackageType.annual:
        return 365;
      case PackageType.lifetime:
        return null;
      default:
        return 30;
    }
  }

  List<String> _getFeaturesForPackage(String packageId) {
    // This would typically come from your backend or be configured
    return [
      'Acesso ilimitado a todas as calculadoras',
      'Lembretes inteligentes',
      'Backup na nuvem',
      'Suporte prioritário',
      'Sem anúncios',
    ];
  }

  PlanStatus _mapEntitlementToPlanStatus(EntitlementInfo entitlementInfo) {
    if (entitlementInfo.isActive) {
      return PlanStatus.active;
    } else if (entitlementInfo.expirationDate != null && 
               entitlementInfo.expirationDate!.isBefore(DateTime.now())) {
      return PlanStatus.expired;
    } else {
      return PlanStatus.cancelled;
    }
  }
}