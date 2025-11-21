/// Billing issue type enum
enum BillingIssueType {
  paymentFailed, // Payment method declined
  paymentMethodExpired, // Credit card expired
  billingAddressInvalid, // Address validation failed
  accountHeld, // Account is on hold
  insufficientFunds, // Not enough funds
  fraudDetected, // Fraud detected
  taxIssue, // Tax calculation issue
  productNotFound, // Product not found
  unknown; // Unknown issue

  bool get requiresAction => [
    BillingIssueType.paymentFailed,
    BillingIssueType.paymentMethodExpired,
    BillingIssueType.billingAddressInvalid,
  ].contains(this);

  bool get isCritical => [
    BillingIssueType.accountHeld,
    BillingIssueType.fraudDetected,
  ].contains(this);

  String get displayName {
    switch (this) {
      case BillingIssueType.paymentFailed:
        return 'Pagamento recusado';
      case BillingIssueType.paymentMethodExpired:
        return 'Método de pagamento expirado';
      case BillingIssueType.billingAddressInvalid:
        return 'Endereço de cobrança inválido';
      case BillingIssueType.accountHeld:
        return 'Conta em espera';
      case BillingIssueType.insufficientFunds:
        return 'Fundos insuficientes';
      case BillingIssueType.fraudDetected:
        return 'Fraude detectada';
      case BillingIssueType.taxIssue:
        return 'Problema de imposto';
      case BillingIssueType.productNotFound:
        return 'Produto não encontrado';
      case BillingIssueType.unknown:
        return 'Problema desconhecido';
    }
  }
}
