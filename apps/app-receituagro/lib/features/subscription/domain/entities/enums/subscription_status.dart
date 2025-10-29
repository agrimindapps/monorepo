/// Subscription status enum
enum SubscriptionStatus {
  active, // Subscription is currently active
  expired, // Subscription has expired
  cancelled, // Subscription was cancelled
  paused, // Subscription is paused
  pending, // Subscription is pending activation
  unknown; // Status unknown (shouldn't happen)

  bool get isActive => this == SubscriptionStatus.active;
  bool get isExpired => this == SubscriptionStatus.expired;
  bool get isCancelled => this == SubscriptionStatus.cancelled;
  bool get isPaused => this == SubscriptionStatus.paused;

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Ativo';
      case SubscriptionStatus.expired:
        return 'Expirado';
      case SubscriptionStatus.cancelled:
        return 'Cancelado';
      case SubscriptionStatus.paused:
        return 'Pausado';
      case SubscriptionStatus.pending:
        return 'Pendente';
      case SubscriptionStatus.unknown:
        return 'Desconhecido';
    }
  }
}
