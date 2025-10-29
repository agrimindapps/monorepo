/// Subscription tier/plan enum
enum SubscriptionTier {
  free, // Free tier - no subscription
  basic, // Basic plan
  premium, // Premium plan
  ultimate, // Ultimate plan
  lifetime, // Lifetime purchase
  trial, // Trial version
  unknown; // Unknown tier

  bool get isFree => this == SubscriptionTier.free;
  bool get isPaid => [
    SubscriptionTier.basic,
    SubscriptionTier.premium,
    SubscriptionTier.ultimate,
    SubscriptionTier.lifetime,
  ].contains(this);
  bool get isTrial => this == SubscriptionTier.trial;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Gratuito';
      case SubscriptionTier.basic:
        return 'Básico';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.ultimate:
        return 'Máximo';
      case SubscriptionTier.lifetime:
        return 'Vitalício';
      case SubscriptionTier.trial:
        return 'Avaliação';
      case SubscriptionTier.unknown:
        return 'Desconhecido';
    }
  }

  int get sortOrder {
    switch (this) {
      case SubscriptionTier.free:
        return 0;
      case SubscriptionTier.trial:
        return 1;
      case SubscriptionTier.basic:
        return 2;
      case SubscriptionTier.premium:
        return 3;
      case SubscriptionTier.ultimate:
        return 4;
      case SubscriptionTier.lifetime:
        return 5;
      case SubscriptionTier.unknown:
        return -1;
    }
  }
}
