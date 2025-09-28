import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';

/// Data source responsável por processar webhooks do RevenueCat
///
/// Processa eventos de webhook para sincronização em tempo real
/// do status de assinatura entre dispositivos
@injectable
class PremiumWebhookDataSource {

  PremiumWebhookDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  final StreamController<Map<String, dynamic>> _webhookController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get webhookEvents => _webhookController.stream;

  /// Processa webhook do RevenueCat
  Future<Either<Failure, void>> processWebhook({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final eventType = payload['event_type'] as String?;
      final appUserId = payload['app_user_id'] as String?;

      if (eventType == null || appUserId == null) {
        return const Left(ServerFailure('Payload de webhook inválido'));
      }

      // Processa diferentes tipos de eventos
      switch (eventType) {
        case 'INITIAL_PURCHASE':
        case 'NON_RENEWING_PURCHASE':
        case 'RENEWAL':
          await _handleSubscriptionActivated(payload);
          break;

        case 'CANCELLATION':
        case 'EXPIRATION':
          await _handleSubscriptionDeactivated(payload);
          break;

        case 'UNCANCELLATION':
          await _handleSubscriptionReactivated(payload);
          break;

        case 'BILLING_ISSUE':
          await _handleBillingIssue(payload);
          break;

        case 'SUBSCRIBER_ALIAS':
          await _handleSubscriberAlias(payload);
          break;

        default:
          debugPrint('[WebhookDataSource] Evento não tratado: $eventType');
      }

      // Emite evento para listeners
      _webhookController.add({
        'event_type': eventType,
        'app_user_id': appUserId,
        'processed_at': DateTime.now().toIso8601String(),
        'payload': payload,
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao processar webhook: ${e.toString()}'));
    }
  }

  /// Trata ativação de assinatura
  Future<void> _handleSubscriptionActivated(Map<String, dynamic> payload) async {
    try {
      final appUserId = payload['app_user_id'] as String;
      final productId = _extractProductId(payload);
      final expirationDate = _extractExpirationDate(payload);

      await _updateFirebaseSubscriptionStatus(
        userId: appUserId,
        isActive: true,
        productId: productId,
        expirationDate: expirationDate,
        eventType: payload['event_type'] as String,
      );

      debugPrint('[WebhookDataSource] Assinatura ativada para $appUserId');
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro ao ativar assinatura: $e');
    }
  }

  /// Trata desativação de assinatura
  Future<void> _handleSubscriptionDeactivated(Map<String, dynamic> payload) async {
    try {
      final appUserId = payload['app_user_id'] as String;

      await _updateFirebaseSubscriptionStatus(
        userId: appUserId,
        isActive: false,
        eventType: payload['event_type'] as String,
      );

      debugPrint('[WebhookDataSource] Assinatura desativada para $appUserId');
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro ao desativar assinatura: $e');
    }
  }

  /// Trata reativação de assinatura
  Future<void> _handleSubscriptionReactivated(Map<String, dynamic> payload) async {
    try {
      final appUserId = payload['app_user_id'] as String;
      final productId = _extractProductId(payload);
      final expirationDate = _extractExpirationDate(payload);

      await _updateFirebaseSubscriptionStatus(
        userId: appUserId,
        isActive: true,
        productId: productId,
        expirationDate: expirationDate,
        eventType: payload['event_type'] as String,
      );

      debugPrint('[WebhookDataSource] Assinatura reativada para $appUserId');
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro ao reativar assinatura: $e');
    }
  }

  /// Trata problemas de cobrança
  Future<void> _handleBillingIssue(Map<String, dynamic> payload) async {
    try {
      final appUserId = payload['app_user_id'] as String;

      await _updateFirebaseSubscriptionStatus(
        userId: appUserId,
        isActive: false,
        hasBillingIssue: true,
        eventType: payload['event_type'] as String,
      );

      debugPrint('[WebhookDataSource] Problema de cobrança para $appUserId');
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro ao tratar problema de cobrança: $e');
    }
  }

  /// Trata alias de assinante
  Future<void> _handleSubscriberAlias(Map<String, dynamic> payload) async {
    try {
      final oldAppUserId = payload['original_app_user_id'] as String?;
      final newAppUserId = payload['new_app_user_id'] as String?;

      if (oldAppUserId != null && newAppUserId != null) {
        await _migrateSubscriptionData(
          oldUserId: oldAppUserId,
          newUserId: newAppUserId,
        );

        debugPrint('[WebhookDataSource] Migração de $oldAppUserId para $newAppUserId');
      }
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro ao tratar alias: $e');
    }
  }

  /// Atualiza status da assinatura no Firebase
  Future<void> _updateFirebaseSubscriptionStatus({
    required String userId,
    required bool isActive,
    required String eventType,
    String? productId,
    DateTime? expirationDate,
    bool hasBillingIssue = false,
  }) async {
    final data = {
      'app_name': 'gasometer',
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
      'event_type': eventType,
      'has_billing_issue': hasBillingIssue,
    };

    if (productId != null) {
      data['product_id'] = productId;
    }

    if (expirationDate != null) {
      data['expiration_date'] = expirationDate.toIso8601String();
    }

    await _firestore
        .collection('user_subscriptions')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// Migra dados de assinatura entre usuários
  Future<void> _migrateSubscriptionData({
    required String oldUserId,
    required String newUserId,
  }) async {
    try {
      // Busca dados do usuário antigo
      final oldDoc = await _firestore
          .collection('user_subscriptions')
          .doc(oldUserId)
          .get();

      final oldDataResult = oldDoc.exists && oldDoc.data() != null
          ? Right<Failure, Map<String, dynamic>?>(oldDoc.data() as Map<String, dynamic>)
          : const Right<Failure, Map<String, dynamic>?>(null);

      oldDataResult.fold(
        (failure) => debugPrint('[WebhookDataSource] Erro ao buscar dados antigos: $failure'),
        (oldData) async {
          if (oldData != null) {
            // Copia para novo usuário
            await _firestore
                .collection('user_subscriptions')
                .doc(newUserId)
                .set({
                  ...oldData,
                  'migrated_from': oldUserId,
                  'updated_at': DateTime.now().toIso8601String(),
                });

            // Remove dados antigos
            await _firestore
                .collection('user_subscriptions')
                .doc(oldUserId)
                .delete();
          }
        },
      );
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro na migração: $e');
    }
  }

  /// Extrai product ID do payload
  String? _extractProductId(Map<String, dynamic> payload) {
    try {
      final event = payload['event'] as Map<String, dynamic>?;
      final productIdentifier = event?['product_identifier'] as String?;
      return productIdentifier;
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro ao extrair product ID: $e');
      return null;
    }
  }

  /// Extrai data de expiração do payload
  DateTime? _extractExpirationDate(Map<String, dynamic> payload) {
    try {
      final event = payload['event'] as Map<String, dynamic>?;
      final expirationMs = event?['expiration_at_ms'] as int?;

      if (expirationMs != null) {
        return DateTime.fromMillisecondsSinceEpoch(expirationMs);
      }

      return null;
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro ao extrair data de expiração: $e');
      return null;
    }
  }

  /// Verifica se webhook é válido (para segurança)
  bool validateWebhook({
    required Map<String, dynamic> payload,
    String? signature,
    String? secret,
  }) {
    if (signature == null || secret == null) {
      return true; // Skip validation in development
    }

    try {
      // Em produção, validar assinatura do webhook
      // TODO: Implementar validação HMAC com secret do RevenueCat
      // final payloadString = json.encode(payload);
      return true;
    } catch (e) {
      debugPrint('[WebhookDataSource] Erro na validação: $e');
      return false;
    }
  }

  void dispose() {
    _webhookController.close();
  }
}