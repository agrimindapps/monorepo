import 'failure.dart';

/// Failures específicos para operações de subscription
/// Permite tratamento granular de erros na UI

/// Erro de rede durante operação de subscription
class SubscriptionNetworkFailure extends Failure {
  const SubscriptionNetworkFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro de conexão. Verifique sua internet.');
}

/// Erro de autenticação/autorização
class SubscriptionAuthFailure extends Failure {
  const SubscriptionAuthFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro de autenticação. Faça login novamente.');
}

/// Erro de pagamento/transação
class SubscriptionPaymentFailure extends Failure {
  const SubscriptionPaymentFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro no pagamento. Verifique seus dados de pagamento.');

  const SubscriptionPaymentFailure.userCancelled()
      : super(message: 'Compra cancelada pelo usuário.');

  const SubscriptionPaymentFailure.productUnavailable()
      : super(message: 'Produto não disponível no momento.');

  const SubscriptionPaymentFailure.alreadyPurchased()
      : super(message: 'Você já possui este produto.');

  const SubscriptionPaymentFailure.notAllowed()
      : super(message: 'Compras não permitidas neste dispositivo.');
}

/// Erro de validação/regras de negócio
class SubscriptionValidationFailure extends Failure {
  const SubscriptionValidationFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro de validação.');

  const SubscriptionValidationFailure.invalidReceipt()
      : super(message: 'Recibo de compra inválido.');

  const SubscriptionValidationFailure.receiptInUse()
      : super(message: 'Este recibo já está em uso em outra conta.');

  const SubscriptionValidationFailure.notEligibleForTrial()
      : super(message: 'Você não é elegível para o período de teste.');
}

/// Erro de configuração do RevenueCat
class SubscriptionConfigFailure extends Failure {
  const SubscriptionConfigFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro de configuração do sistema de assinaturas.');

  const SubscriptionConfigFailure.missingApiKey()
      : super(message: 'API key do RevenueCat não configurada.');

  const SubscriptionConfigFailure.invalidCredentials()
      : super(message: 'Credenciais do RevenueCat inválidas.');

  const SubscriptionConfigFailure.notAvailable()
      : super(message: 'Sistema de assinaturas não disponível nesta plataforma.');
}

/// Erro de sincronização
class SubscriptionSyncFailure extends Failure {
  const SubscriptionSyncFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro ao sincronizar assinatura.');

  const SubscriptionSyncFailure.conflictDetected()
      : super(message: 'Conflito detectado entre dispositivos. Tentando resolver...');

  const SubscriptionSyncFailure.maxRetriesReached()
      : super(message: 'Não foi possível sincronizar após várias tentativas.');
}

/// Erro de servidor/backend
class SubscriptionServerFailure extends Failure {
  const SubscriptionServerFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro no servidor. Tente novamente mais tarde.');

  const SubscriptionServerFailure.unexpectedResponse()
      : super(message: 'Resposta inesperada do servidor.');

  const SubscriptionServerFailure.backendError()
      : super(message: 'Erro no servidor RevenueCat.');
}

/// Erro de operação já em andamento
class SubscriptionOperationInProgressFailure extends Failure {
  const SubscriptionOperationInProgressFailure()
      : super(message: 'Operação já em andamento. Aguarde a conclusão.');
}

/// Erro desconhecido
class SubscriptionUnknownFailure extends Failure {
  const SubscriptionUnknownFailure([String? customMessage])
      : super(message: customMessage ?? 'Erro desconhecido na assinatura.');
}

/// Extension para converter PlatformException codes em Failures específicos
extension SubscriptionFailureMapper on String {
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
        return const SubscriptionValidationFailure.invalidReceipt();
      case 'receipt_already_in_use':
        return const SubscriptionValidationFailure.receiptInUse();
      case 'missing_receipt_file':
        return const SubscriptionValidationFailure.invalidReceipt();
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