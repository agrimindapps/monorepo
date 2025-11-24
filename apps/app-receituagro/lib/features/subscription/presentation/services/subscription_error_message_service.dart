

/// Service responsible for centralized error message management
/// Follows SRP - single source of truth for all error messages
/// Makes testing and localization easier

class SubscriptionErrorMessageService {
  /// Repository error messages
  static const Map<String, String> _repositoryErrors = {
    'verify_trial': 'Erro ao verificar trial',
    'cache_save': 'Erro ao salvar cache',
    'cache_read': 'Erro ao ler cache',
    'cache_clear': 'Erro ao limpar cache',
  };

  /// Use case validation messages
  static const Map<String, String> _validationMessages = {
    'empty_feature_key': 'Chave da feature não pode ser vazia',
    'empty_product_id': 'ID do produto não pode ser vazio',
  };

  /// Notifier error messages
  static const Map<String, String> _notifierErrors = {
    'load_status': 'Erro ao carregar status',
    'update_status': 'Erro ao atualizar',
    'upgrade_subscription': 'Erro ao fazer upgrade',
    'downgrade_subscription': 'Erro ao fazer downgrade',
    'cancel_subscription': 'Erro ao cancelar assinatura',
    'reactivate_subscription': 'Erro ao reativar assinatura',
    'load_billing_issues': 'Erro ao carregar problemas de cobrança',
    'update_billing_status': 'Erro ao atualizar status de cobrança',
    'retry_payment': 'Erro ao fazer retry',
    'load_purchase_history': 'Erro ao carregar histórico de compras',
    'sync_purchases': 'Erro ao sincronizar compras',
    'load_trial_info': 'Erro ao carregar informações do trial',
    'start_trial': 'Erro ao iniciar trial',
  };

  // Repository error methods
  String getVerifyTrialError(String details) =>
      '${_repositoryErrors['verify_trial']}: $details';

  String getCacheSaveError(String details) =>
      '${_repositoryErrors['cache_save']}: $details';

  String getCacheReadError(String details) =>
      '${_repositoryErrors['cache_read']}: $details';

  String getCacheClearError(String details) =>
      '${_repositoryErrors['cache_clear']}: $details';

  // Validation error methods
  String getEmptyFeatureKeyError() => _validationMessages['empty_feature_key']!;

  String getEmptyProductIdError() => _validationMessages['empty_product_id']!;

  // Notifier error methods
  String getLoadStatusError(String details) =>
      '${_notifierErrors['load_status']}: $details';

  String getUpdateStatusError(String details) =>
      '${_notifierErrors['update_status']}: $details';

  String getUpgradeSubscriptionError(String details) =>
      '${_notifierErrors['upgrade_subscription']}: $details';

  String getDowngradeSubscriptionError(String details) =>
      '${_notifierErrors['downgrade_subscription']}: $details';

  String getCancelSubscriptionError(String details) =>
      '${_notifierErrors['cancel_subscription']}: $details';

  String getReactivateSubscriptionError(String details) =>
      '${_notifierErrors['reactivate_subscription']}: $details';

  String getLoadBillingIssuesError(String details) =>
      '${_notifierErrors['load_billing_issues']}: $details';

  String getUpdateBillingStatusError(String details) =>
      '${_notifierErrors['update_billing_status']}: $details';

  String getRetryPaymentError(String details) =>
      '${_notifierErrors['retry_payment']}: $details';

  String getLoadPurchaseHistoryError(String details) =>
      '${_notifierErrors['load_purchase_history']}: $details';

  String getSyncPurchasesError(String details) =>
      '${_notifierErrors['sync_purchases']}: $details';

  String getLoadTrialInfoError(String details) =>
      '${_notifierErrors['load_trial_info']}: $details';

  String getStartTrialError(String details) =>
      '${_notifierErrors['start_trial']}: $details';
}
