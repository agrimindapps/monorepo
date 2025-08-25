// Dart imports:
import 'dart:io';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// Project imports:
import '../../core/services/info_device_service.dart';

/// Service para integração Firebase específica do Gasometer
class GasometerFirebaseService {
  static const String _subscriptionsCollection = 'subscriptions';
  static const String _appId = 'gasometer';

  /// Salvar assinatura no Firebase
  static Future<void> saveSubscriptionToFirebase({
    required String userId,
    required CustomerInfo customerInfo,
  }) async {
    try {
      final docId = '${_appId}_$userId';

      final subscriptionData = {
        'appId': _appId,
        'userId': userId,
        'isActive': customerInfo.entitlements.active.isNotEmpty,
        'lastUpdated': FieldValue.serverTimestamp(),
        'customerInfo': {
          'originalAppUserId': customerInfo.originalAppUserId,
          'firstSeen': customerInfo.firstSeen,
          'entitlements': customerInfo.entitlements.active.map(
            (key, value) => MapEntry(key, {
              'identifier': value.identifier,
              'isActive': value.isActive,
              'willRenew': value.willRenew,
              'latestPurchaseDate': value.latestPurchaseDate,
              'expirationDate': value.expirationDate,
              'productIdentifier': value.productIdentifier,
              'store': value.store.toString(),
            }),
          ),
        },
        'platform': Platform.isIOS ? 'ios' : 'android',
        'appVersion': await InfoDeviceService.getAppVersion(),
        'deviceInfo': {
          'platform': Platform.operatingSystem,
          'platformVersion': Platform.operatingSystemVersion,
        },
      };

      await FirebaseFirestore.instance
          .collection(_subscriptionsCollection)
          .doc(docId)
          .set(subscriptionData, SetOptions(merge: true));

      print('✅ Assinatura Gasometer salva no Firebase: $docId');
    } catch (e, stackTrace) {
      print('❌ Erro ao salvar assinatura Gasometer no Firebase: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: false,
      );
    }
  }

  /// Verificar assinatura no Firebase
  static Future<bool> checkSubscriptionInFirebase(String userId) async {
    try {
      final docId = '${_appId}_$userId';

      final doc = await FirebaseFirestore.instance
          .collection(_subscriptionsCollection)
          .doc(docId)
          .get();

      if (!doc.exists) {
        print('📄 Documento de assinatura Gasometer não encontrado: $docId');
        return false;
      }

      final data = doc.data();
      final isActive = data['isActive'] as bool? ?? false;
      final lastUpdated = data['lastUpdated'] as Timestamp?;

      // Verificar se os dados não estão muito antigos (máximo 1 hora)
      if (lastUpdated != null) {
        final hourAgo = DateTime.now().subtract(const Duration(hours: 1));
        if (lastUpdated.toDate().isBefore(hourAgo)) {
          print(
              '⚠️ Dados de assinatura Gasometer no Firebase muito antigos, verificando RevenueCat');
          return false; // Forçar verificação no RevenueCat
        }
      }

      print(
          '✅ Status de assinatura Gasometer recuperado do Firebase: $isActive');
      return isActive;
    } catch (e, stackTrace) {
      print('❌ Erro ao verificar assinatura Gasometer no Firebase: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: false,
      );
      return false;
    }
  }

  /// Remover/cancelar assinatura do Firebase
  static Future<void> removeSubscriptionFromFirebase(String userId) async {
    try {
      final docId = '${_appId}_$userId';

      await FirebaseFirestore.instance
          .collection(_subscriptionsCollection)
          .doc(docId)
          .update({
        'isActive': false,
        'canceledAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('❌ Assinatura Gasometer cancelada no Firebase: $docId');
    } catch (e, stackTrace) {
      print('❌ Erro ao cancelar assinatura Gasometer no Firebase: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: false,
      );
    }
  }

  /// Obter histórico de assinaturas do usuário
  static Future<List<Map<String, dynamic>>> getSubscriptionHistory(
      String userId) async {
    try {
      final docId = '${_appId}_$userId';

      final doc = await FirebaseFirestore.instance
          .collection(_subscriptionsCollection)
          .doc(docId)
          .get();

      if (!doc.exists) return [];

      final data = doc.data();
      return [data]; // Por enquanto retorna apenas o documento atual
    } catch (e, stackTrace) {
      print('❌ Erro ao obter histórico de assinatura Gasometer: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: false,
      );
      return [];
    }
  }

  /// Verificar se existe conflito de assinatura entre apps
  static Future<Map<String, bool>> checkCrossAppSubscriptions(
      String userId) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection(_subscriptionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      final activeSubscriptions = <String, bool>{};

      for (final doc in query.docs) {
        final data = doc.data();
        final appId = data['appId'] as String? ?? 'unknown';
        activeSubscriptions[appId] = true;
      }

      return activeSubscriptions;
    } catch (e, stackTrace) {
      print('❌ Erro ao verificar assinaturas cross-app: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: false,
      );
      return {};
    }
  }

  /// Limpar dados antigos de assinatura (para manutenção)
  static Future<void> cleanupOldSubscriptionData(String userId) async {
    try {
      final docId = '${_appId}_$userId';

      final doc = await FirebaseFirestore.instance
          .collection(_subscriptionsCollection)
          .doc(docId)
          .get();

      if (!doc.exists) return;

      final data = doc.data();
      final lastUpdated = data['lastUpdated'] as Timestamp?;

      if (lastUpdated != null) {
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));

        if (lastUpdated.toDate().isBefore(monthAgo)) {
          final isActive = data['isActive'] as bool? ?? false;

          if (!isActive) {
            // Remover dados de assinaturas inativas com mais de 30 dias
            await FirebaseFirestore.instance
                .collection(_subscriptionsCollection)
                .doc(docId)
                .delete();

            print('🧹 Dados antigos de assinatura Gasometer removidos: $docId');
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao limpar dados antigos de assinatura: $e');
      FirebaseCrashlytics.instance.recordError(
        e,
        stackTrace,
        fatal: false,
      );
    }
  }

  /// Sincronizar status local com Firebase
  static Future<bool> syncSubscriptionStatus({
    required String userId,
    required bool isActive,
    CustomerInfo? customerInfo,
  }) async {
    try {
      if (isActive && customerInfo != null) {
        await saveSubscriptionToFirebase(
          userId: userId,
          customerInfo: customerInfo,
        );
      } else if (!isActive) {
        await removeSubscriptionFromFirebase(userId);
      }

      return true;
    } catch (e) {
      print('❌ Erro ao sincronizar status de assinatura: $e');
      return false;
    }
  }

  /// Obter estatísticas da assinatura para analytics
  static Future<Map<String, dynamic>> getSubscriptionStats(
      String userId) async {
    try {
      final docId = '${_appId}_$userId';

      final doc = await FirebaseFirestore.instance
          .collection(_subscriptionsCollection)
          .doc(docId)
          .get();

      if (!doc.exists) {
        return {
          'hasSubscription': false,
          'isActive': false,
        };
      }

      final data = doc.data();
      final isActive = data['isActive'] as bool? ?? false;
      final lastUpdated = data['lastUpdated'] as Timestamp?;
      final customerInfo = data['customerInfo'] as Map<String, dynamic>?;

      return {
        'hasSubscription': true,
        'isActive': isActive,
        'lastUpdated': lastUpdated?.toDate().toIso8601String(),
        'platform': data['platform'],
        'appVersion': data['appVersion'],
        'entitlementsCount': customerInfo?['entitlements']?.length ?? 0,
      };
    } catch (e) {
      print('❌ Erro ao obter estatísticas de assinatura: $e');
      return {
        'hasSubscription': false,
        'isActive': false,
        'error': e.toString(),
      };
    }
  }
}
