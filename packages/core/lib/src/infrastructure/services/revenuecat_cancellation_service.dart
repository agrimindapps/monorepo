import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../shared/utils/app_error.dart';
import '../../shared/utils/failure.dart';
import '../../shared/utils/result.dart';

/// Serviço para gerenciar cancelamento de assinaturas RevenueCat
/// durante exclusão de conta
class RevenueCatCancellationService {
  /// Verifica e processa cancelamento de assinaturas ativas
  ///
  /// NOTA: RevenueCat não cancela diretamente - ele trabalha com as stores.
  /// Este método registra a intenção de cancelamento e fornece instruções
  /// para o usuário cancelar manualmente nas lojas.
  Future<Result<SubscriptionCancellationResult>>
  handleSubscriptionCancellation() async {
    try {
      if (kDebugMode) {
        debugPrint(
          '💳 RevenueCatCancellationService: Checking for active subscriptions',
        );
      }

      // Get current customer info
      CustomerInfo customerInfo;
      try {
        customerInfo = await Purchases.getCustomerInfo();
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ RevenueCatCancellationService: Error getting customer info: $e',
          );
        }
        // If RevenueCat fails, we don't want to block account deletion
        return Result.success(
          SubscriptionCancellationResult(
            hadActiveSubscription: false,
            message: 'Não foi possível verificar assinaturas',
            error: e.toString(),
          ),
        );
      }

      final activeSubscriptions = customerInfo.activeSubscriptions;

      if (activeSubscriptions.isEmpty) {
        if (kDebugMode) {
          debugPrint('✅ No active subscriptions to cancel');
        }

        return Result.success(
          SubscriptionCancellationResult(
            hadActiveSubscription: false,
            message: 'Nenhuma assinatura ativa encontrada',
          ),
        );
      }

      if (kDebugMode) {
        debugPrint(
          '⚠️ Found ${activeSubscriptions.length} active subscription(s)',
        );
      }

      // Get entitlements info
      final entitlements = customerInfo.entitlements.active;
      final entitlementDetails = <String, Map<String, dynamic>>{};

      for (final entry in entitlements.entries) {
        final entitlement = entry.value;
        entitlementDetails[entry.key] = {
          'identifier': entitlement.identifier,
          'productIdentifier': entitlement.productIdentifier,
          'periodType': entitlement.periodType.name,
          'expiresDate': entitlement.expirationDate,
          'willRenew': entitlement.willRenew,
          'store': entitlement.store.name,
        };
      }

      // Get manual cancellation instructions
      final instructions = _getManualCancellationInstructions();

      if (kDebugMode) {
        debugPrint('📋 Subscription details:');
        for (final subscription in activeSubscriptions) {
          debugPrint('   - $subscription');
        }
        debugPrint('💡 User needs to cancel manually via store');
      }

      return Result.success(
        SubscriptionCancellationResult(
          hadActiveSubscription: true,
          activeSubscriptionIds: activeSubscriptions.toList(),
          entitlementDetails: entitlementDetails,
          requiresManualCancellation: true,
          manualCancellationInstructions: instructions,
          message:
              'Assinatura ativa encontrada. Cancelamento manual necessário.',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RevenueCatCancellationService: Unexpected error: $e');
      }

      return Result.error(
        AppErrorFactory.fromFailure(
          UnexpectedFailure('Erro ao processar cancelamento de assinatura: $e'),
        ),
      );
    }
  }

  /// Obtém instruções de cancelamento manual específicas da plataforma
  String _getManualCancellationInstructions() {
    if (Platform.isIOS) {
      return '''
Para cancelar completamente sua assinatura:

📱 iPhone/iPad:
1. Abra o app Configurações
2. Toque no seu nome no topo
3. Toque em "Assinaturas"
4. Selecione a assinatura deste app
5. Toque em "Cancelar Assinatura"

⚠️ IMPORTANTE:
• Você continuará com acesso até o fim do período pago
• Nenhum reembolso será feito automaticamente
• Para solicitar reembolso, acesse: reportaproblem.apple.com
''';
    } else if (Platform.isAndroid) {
      return '''
Para cancelar completamente sua assinatura:

📱 Android:
1. Abra o Google Play Store
2. Toque no ícone de perfil (canto superior direito)
3. Toque em "Pagamentos e assinaturas"
4. Toque em "Assinaturas"
5. Selecione a assinatura deste app
6. Toque em "Cancelar assinatura"

⚠️ IMPORTANTE:
• Você continuará com acesso até o fim do período pago
• Nenhum reembolso será feito automaticamente
• Para solicitar reembolso, acesse o histórico de pedidos no Play Store
''';
    }

    return '''
Para cancelar sua assinatura, acesse as configurações de assinatura
da loja onde você realizou a compra (App Store ou Google Play Store).
''';
  }

  /// Obtém informações detalhadas sobre assinaturas ativas
  /// Útil para exibir antes da exclusão
  Future<Result<Map<String, dynamic>>> getSubscriptionDetails() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      final details = <String, dynamic>{
        'hasActiveSubscription': customerInfo.activeSubscriptions.isNotEmpty,
        'activeSubscriptions': customerInfo.activeSubscriptions.toList(),
        'entitlements': {},
        'latestExpirationDate': null,
      };

      // Get entitlement details
      for (final entry in customerInfo.entitlements.active.entries) {
        final entitlement = entry.value;
        details['entitlements'][entry.key] = {
          'identifier': entitlement.identifier,
          'productId': entitlement.productIdentifier,
          'periodType': entitlement.periodType.name,
          'expiresDate':
              entitlement.expirationDate, // Already a String in ISO 8601 format
          'willRenew': entitlement.willRenew,
          'store': entitlement.store.name,
        };

        // Track latest expiration
        if (entitlement.expirationDate != null) {
          final currentString = details['latestExpirationDate'] as String?;
          final expirationDate = DateTime.parse(entitlement.expirationDate!);
          if (currentString == null ||
              expirationDate.isAfter(DateTime.parse(currentString))) {
            details['latestExpirationDate'] = entitlement.expirationDate;
          }
        }
      }

      return Result.success(details);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting subscription details: $e');
      }

      return Result.error(
        AppErrorFactory.fromFailure(
          UnexpectedFailure('Erro ao obter detalhes da assinatura: $e'),
        ),
      );
    }
  }

  /// Verifica se o usuário tem assinatura ativa
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.activeSubscriptions.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking active subscription: $e');
      }
      return false;
    }
  }
}

/// Resultado do processamento de cancelamento de assinatura
class SubscriptionCancellationResult {
  final bool hadActiveSubscription;
  final List<String>? activeSubscriptionIds;
  final Map<String, Map<String, dynamic>>? entitlementDetails;
  final bool requiresManualCancellation;
  final String? manualCancellationInstructions;
  final String message;
  final String? error;

  SubscriptionCancellationResult({
    required this.hadActiveSubscription,
    this.activeSubscriptionIds,
    this.entitlementDetails,
    this.requiresManualCancellation = false,
    this.manualCancellationInstructions,
    required this.message,
    this.error,
  });

  bool get isSuccess => error == null;

  Map<String, dynamic> toMap() {
    return {
      'hadActiveSubscription': hadActiveSubscription,
      'activeSubscriptionIds': activeSubscriptionIds,
      'entitlementDetails': entitlementDetails,
      'requiresManualCancellation': requiresManualCancellation,
      'manualCancellationInstructions': manualCancellationInstructions,
      'message': message,
      'error': error,
      'isSuccess': isSuccess,
    };
  }

  @override
  String toString() {
    return 'SubscriptionCancellationResult('
        'hadActive: $hadActiveSubscription, '
        'requiresManual: $requiresManualCancellation, '
        'message: $message)';
  }
}
