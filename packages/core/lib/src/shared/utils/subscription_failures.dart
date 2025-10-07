import 'failure.dart';

/// A collection of specific [Failure] types for subscription-related operations.
/// These allow for granular error handling in the UI.

/// A failure indicating a network error during a subscription operation.
class SubscriptionNetworkFailure extends Failure {
  const SubscriptionNetworkFailure([String? message])
      : super(
            message: message ?? 'Erro de conexão. Verifique sua internet.');
}

/// A failure indicating an authentication or authorization error.
class SubscriptionAuthFailure extends Failure {
  const SubscriptionAuthFailure([String? message])
      : super(
            message:
                message ?? 'Erro de autenticação. Faça login novamente.');
}

/// A failure related to a payment or transaction error.
class SubscriptionPaymentFailure extends Failure {
  const SubscriptionPaymentFailure([String? message])
      : super(
            message:
                message ?? 'Erro no pagamento. Verifique seus dados de pagamento.');

  /// A failure indicating the user canceled the purchase.
  const SubscriptionPaymentFailure.userCancelled()
      : super(message: 'Compra cancelada pelo usuário.');

  /// A failure indicating the requested product is unavailable.
  const SubscriptionPaymentFailure.productUnavailable()
      : super(message: 'Produto não disponível no momento.');

  /// A failure indicating the user already owns the product.
  const SubscriptionPaymentFailure.alreadyPurchased()
      : super(message: 'Você já possui este produto.');

  /// A failure indicating that purchases are not allowed on the device.
  const SubscriptionPaymentFailure.notAllowed()
      : super(message: 'Compras não permitidas neste dispositivo.');
}

/// A failure related to validation or business logic errors.
class SubscriptionValidationFailure extends Failure {
  const SubscriptionValidationFailure([String? message])
      : super(message: message ?? 'Erro de validação.');

  /// A failure indicating that the purchase receipt is invalid.
  const SubscriptionValidationFailure.invalidReceipt()
      : super(message: 'Recibo de compra inválido.');

  /// A failure indicating that the receipt is already in use by another account.
  const SubscriptionValidationFailure.receiptInUse()
      : super(message: 'Este recibo já está em uso em outra conta.');

  /// A failure indicating the user is not eligible for a trial.
  const SubscriptionValidationFailure.notEligibleForTrial()
      : super(message: 'Você não é elegível para o período de teste.');
}

/// A failure related to the configuration of the subscription service (e.g., RevenueCat).
class SubscriptionConfigFailure extends Failure {
  const SubscriptionConfigFailure([String? message])
      : super(
            message:
                message ?? 'Erro de configuração do sistema de assinaturas.');

  /// A failure indicating a missing API key.
  const SubscriptionConfigFailure.missingApiKey()
      : super(message: 'API key do RevenueCat não configurada.');

  /// A failure indicating invalid credentials for the subscription service.
  const SubscriptionConfigFailure.invalidCredentials()
      : super(message: 'Credenciais do RevenueCat inválidas.');

  /// A failure indicating the subscription system is not available on the current platform.
  const SubscriptionConfigFailure.notAvailable()
      : super(
            message: 'Sistema de assinaturas não disponível nesta plataforma.');
}

/// A failure related to synchronizing subscription status.
class SubscriptionSyncFailure extends Failure {
  const SubscriptionSyncFailure([String? message])
      : super(message: message ?? 'Erro ao sincronizar assinatura.');

  /// A failure indicating a conflict was detected between devices.
  const SubscriptionSyncFailure.conflictDetected()
      : super(
            message:
                'Conflito detectado entre dispositivos. Tentando resolver...');

  /// A failure indicating that the maximum number of sync retries has been reached.
  const SubscriptionSyncFailure.maxRetriesReached()
      : super(
            message: 'Não foi possível sincronizar após várias tentativas.');
}

/// A failure related to a server-side error.
class SubscriptionServerFailure extends Failure {
  const SubscriptionServerFailure([String? message])
      : super(message: message ?? 'Erro no servidor. Tente novamente mais tarde.');

  /// A failure indicating an unexpected response from the server.
  const SubscriptionServerFailure.unexpectedResponse()
      : super(message: 'Resposta inesperada do servidor.');

  /// A failure indicating a backend error from the subscription service.
  const SubscriptionServerFailure.backendError()
      : super(message: 'Erro no servidor RevenueCat.');
}

/// A failure indicating that a subscription operation is already in progress.
class SubscriptionOperationInProgressFailure extends Failure {
  const SubscriptionOperationInProgressFailure()
      : super(message: 'Operação já em andamento. Aguarde a conclusão.');
}

/// A failure for any other unknown subscription-related error.
class SubscriptionUnknownFailure extends Failure {
  const SubscriptionUnknownFailure([String? message])
      : super(message: message ?? 'Erro desconhecido na assinatura.');
}

/// An extension to map platform-specific error codes to domain-specific [Failure] types.
///
/// This helps create a unified error handling strategy by abstracting away
/// platform differences.
extension SubscriptionFailureMapper on String {
  /// Converts a platform error code string into a [SubscriptionFailure].
  Failure toSubscriptionFailure([String? customMessage]) {
    switch (this) {
      case 'user_cancelled':
        return const SubscriptionPaymentFailure.userCancelled();
      case 'network_error':
        return const SubscriptionNetworkFailure();
      case 'purchase_not_allowed':
        return const SubscriptionPaymentFailure.notAllowed();
      case 'purchase_invalid':
        return const SubscriptionPaymentFailure();
      case 'product_not_available':
        return const SubscriptionPaymentFailure.productUnavailable();
      case 'product_already_purchased':
        return const SubscriptionPaymentFailure.alreadyPurchased();
      case 'invalid_receipt':
      case 'missing_receipt_file':
        return const SubscriptionValidationFailure.invalidReceipt();
      case 'receipt_already_in_use':
        return const SubscriptionValidationFailure.receiptInUse();
      case 'invalid_credentials':
        return const SubscriptionConfigFailure.invalidCredentials();
      case 'invalid_app_user_id':
        return const SubscriptionAuthFailure();
      case 'NOT_AVAILABLE':
        return const SubscriptionConfigFailure.notAvailable();
      case 'MISSING_API_KEY':
      case 'INITIALIZATION_ERROR':
        return const SubscriptionConfigFailure.missingApiKey();
      case 'store_problem':
      case 'unexpected_backend_response':
      case 'unknown_backend_error':
        return const SubscriptionServerFailure();
      case 'operation_already_in_progress':
        return const SubscriptionOperationInProgressFailure();
      default:
        return SubscriptionUnknownFailure(customMessage ?? 'Erro: $this');
    }
  }
}