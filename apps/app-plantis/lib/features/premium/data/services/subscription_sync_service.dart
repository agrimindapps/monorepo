import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

/// Serviço para sincronizar dados de assinatura com Firebase
class SubscriptionSyncService {
  final FirebaseFirestore _firestore;
  final IAuthRepository _authRepository;

  SubscriptionSyncService({
    FirebaseFirestore? firestore,
    required IAuthRepository authRepository,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _authRepository = authRepository;

  /// Salva ou atualiza informações da assinatura no Firebase
  Future<void> syncSubscriptionToFirebase(
    SubscriptionEntity subscription,
  ) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) return;

      final subscriptionData = {
        'userId': currentUser.id,
        'productId': subscription.productId,
        'status': subscription.status.name,
        'tier': subscription.tier.name,
        'isActive': subscription.isActive,
        'isInTrial': subscription.isInTrial,
        'expirationDate': subscription.expirationDate?.toIso8601String(),
        'purchaseDate': subscription.purchaseDate?.toIso8601String(),
        'originalPurchaseDate':
            subscription.originalPurchaseDate?.toIso8601String(),
        'store': subscription.store.name,
        'isSandbox': subscription.isSandbox,
        'lastSyncedAt': FieldValue.serverTimestamp(),
        'appName': 'plantis',
      };

      // Salva na coleção de usuários
      await _firestore
          .collection('users')
          .doc(currentUser.id)
          .collection('subscriptions')
          .doc('current')
          .set(subscriptionData, SetOptions(merge: true));

      // Também salva um histórico
      await _firestore.collection('subscriptions_history').add({
        ...subscriptionData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Assinatura sincronizada com Firebase');
    } catch (e) {
      debugPrint('Erro ao sincronizar assinatura: $e');
    }
  }

  /// Remove informações de assinatura quando expira ou é cancelada
  Future<void> removeSubscriptionFromFirebase() async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.id)
          .collection('subscriptions')
          .doc('current')
          .update({
            'isActive': false,
            'status': 'expired',
            'lastSyncedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('Assinatura removida do Firebase');
    } catch (e) {
      debugPrint('Erro ao remover assinatura: $e');
    }
  }

  /// Recupera informações de assinatura do Firebase
  Future<SubscriptionEntity?> getSubscriptionFromFirebase() async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) return null;

      final doc =
          await _firestore
              .collection('users')
              .doc(currentUser.id)
              .collection('subscriptions')
              .doc('current')
              .get();

      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;

      // Verifica se a assinatura ainda está ativa
      if (data['isActive'] != true) return null;

      return SubscriptionEntity(
        id: data['productId'] ?? '',
        userId: data['userId'] ?? '',
        productId: data['productId'] ?? '',
        status: _parseSubscriptionStatus(data['status']),
        tier: _parseSubscriptionTier(data['tier']),
        expirationDate:
            data['expirationDate'] != null
                ? DateTime.parse(data['expirationDate'])
                : null,
        purchaseDate:
            data['purchaseDate'] != null
                ? DateTime.parse(data['purchaseDate'])
                : null,
        originalPurchaseDate:
            data['originalPurchaseDate'] != null
                ? DateTime.parse(data['originalPurchaseDate'])
                : null,
        store: _parseStore(data['store']),
        isInTrial: data['isInTrial'] ?? false,
        isSandbox: data['isSandbox'] ?? false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Erro ao recuperar assinatura do Firebase: $e');
      return null;
    }
  }

  /// Stream de mudanças na assinatura
  Stream<SubscriptionEntity?> subscriptionStream() {
    return _authRepository.currentUser.asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      }

      return _firestore
          .collection('users')
          .doc(user.id)
          .collection('subscriptions')
          .doc('current')
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists || snapshot.data() == null) return null;

            final data = snapshot.data()!;
            if (data['isActive'] != true) return null;

            return SubscriptionEntity(
              id: data['productId'] ?? '',
              userId: data['userId'] ?? '',
              productId: data['productId'] ?? '',
              status: _parseSubscriptionStatus(data['status']),
              tier: _parseSubscriptionTier(data['tier']),
              expirationDate:
                  data['expirationDate'] != null
                      ? DateTime.parse(data['expirationDate'])
                      : null,
              purchaseDate:
                  data['purchaseDate'] != null
                      ? DateTime.parse(data['purchaseDate'])
                      : null,
              originalPurchaseDate:
                  data['originalPurchaseDate'] != null
                      ? DateTime.parse(data['originalPurchaseDate'])
                      : null,
              store: _parseStore(data['store']),
              isInTrial: data['isInTrial'] ?? false,
              isSandbox: data['isSandbox'] ?? false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          });
    });
  }

  /// Salva evento de compra para analytics
  Future<void> logPurchaseEvent({
    required String productId,
    required double price,
    required String currency,
  }) async {
    try {
      final currentUser = await _getCurrentUser();
      if (currentUser == null) return;

      await _firestore.collection('purchase_events').add({
        'userId': currentUser.id,
        'productId': productId,
        'price': price,
        'currency': currency,
        'appName': 'plantis',
        'timestamp': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      debugPrint('Erro ao logar evento de compra: $e');
    }
  }

  Future<UserEntity?> _getCurrentUser() async {
    final userStream = _authRepository.currentUser.first;
    return await userStream;
  }

  SubscriptionStatus _parseSubscriptionStatus(String? status) {
    switch (status) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.unknown;
    }
  }

  SubscriptionTier _parseSubscriptionTier(String? tier) {
    switch (tier) {
      case 'free':
        return SubscriptionTier.free;
      case 'premium':
        return SubscriptionTier.premium;
      case 'pro':
        return SubscriptionTier.pro;
      default:
        return SubscriptionTier.free;
    }
  }

  Store _parseStore(String? store) {
    switch (store) {
      case 'appStore':
        return Store.appStore;
      case 'playStore':
        return Store.playStore;
      case 'stripe':
        return Store.stripe;
      case 'promotional':
        return Store.promotional;
      default:
        return Store.unknown;
    }
  }
}
