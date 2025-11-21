/// Purchase type enum
enum PurchaseType {
  subscription, // Regular subscription purchase
  trial, // Trial period
  renewal, // Subscription renewal
  upgrade, // Plan upgrade
  downgrade, // Plan downgrade
  refund, // Refund transaction
  restoration, // Restored purchase
  familySharing, // Family sharing purchase
  unknown; // Unknown purchase type

  bool get isSubscriptionRelated => [
    PurchaseType.subscription,
    PurchaseType.renewal,
    PurchaseType.upgrade,
    PurchaseType.downgrade,
    PurchaseType.familySharing,
  ].contains(this);

  bool get incrementsBalance =>
      ![PurchaseType.refund, PurchaseType.downgrade].contains(this);

  String get displayName {
    switch (this) {
      case PurchaseType.subscription:
        return 'Assinatura';
      case PurchaseType.trial:
        return 'Avaliação';
      case PurchaseType.renewal:
        return 'Renovação';
      case PurchaseType.upgrade:
        return 'Atualização';
      case PurchaseType.downgrade:
        return 'Downgrade';
      case PurchaseType.refund:
        return 'Reembolso';
      case PurchaseType.restoration:
        return 'Restauração';
      case PurchaseType.familySharing:
        return 'Compartilhamento Familiar';
      case PurchaseType.unknown:
        return 'Desconhecido';
    }
  }
}
