import 'package:core/core.dart';

/// Adaptador para converter e manter compatibilidade com SubscriptionEntity
/// Fornece métodos utilitários para lógica de negócio específica do ReceitaAgro
abstract class SubscriptionAdapter {

  /// Mapeia status string para SubscriptionStatus enum
  static SubscriptionStatus mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'trial':
        return SubscriptionStatus.active; // Trial é considerado ativo
      case 'pending':
        return SubscriptionStatus.pending;
      default:
        return SubscriptionStatus.unknown;
    }
  }

  /// Mapeia tier enum para lista de features (compatibilidade)
  static List<String> mapTierToFeatures(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return [];
      case SubscriptionTier.premium:
        return [
          'unlimited_favorites',
          'sync_data',
          'premium_content',
          'priority_support',
        ];
      case SubscriptionTier.pro:
        return [
          'unlimited_favorites',
          'sync_data',
          'premium_content',
          'priority_support',
          'advanced_search',
          'export_data',
          'offline_mode',
        ];
    }
  }

  /// Mapeia features para tier enum
  static SubscriptionTier mapTier(List<String> features) {
    if (features.isEmpty) {
      return SubscriptionTier.free;
    }
    final proFeatures = ['advanced_search', 'export_data', 'offline_mode'];
    if (features.any((f) => proFeatures.contains(f))) {
      return SubscriptionTier.pro;
    }
    final premiumFeatures = [
      'unlimited_favorites',
      'sync_data',
      'premium_content',
      'priority_support'
    ];
    if (features.any((f) => premiumFeatures.contains(f))) {
      return SubscriptionTier.premium;
    }

    return SubscriptionTier.free;
  }

  /// Mapeia platform string para Store enum
  static Store mapStore(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
      case 'appstore':
        return Store.appStore;
      case 'android':
      case 'playstore':
        return Store.playStore;
      case 'web':
      case 'stripe':
        return Store.stripe;
      case 'promotional':
        return Store.promotional;
      default:
        return Store.unknown;
    }
  }

  /// Utilitários para manter compatibilidade com métodos do SubscriptionDataModel

  /// Equivalente ao hasFeature() do SubscriptionDataModel
  static bool hasFeature(SubscriptionEntity entity, String feature) {
    if (!entity.isActive) return false;
    
    final features = mapTierToFeatures(entity.tier);
    return features.contains(feature);
  }

  /// Equivalente ao timeRemaining do SubscriptionDataModel
  static Duration? getTimeRemaining(SubscriptionEntity entity) {
    if (entity.expirationDate == null) return null;
    final now = DateTime.now();
    if (entity.expirationDate!.isBefore(now)) return null;
    return entity.expirationDate!.difference(now);
  }

  /// Equivalente ao isActive do SubscriptionDataModel (com lógica específica)
  static bool isActiveWithLegacyLogic(SubscriptionEntity entity) {
    if (entity.status != SubscriptionStatus.active) return false;
    if (entity.expirationDate == null) return false;
    return entity.expirationDate!.isAfter(DateTime.now());
  }

  /// Equivalente ao isTrial do SubscriptionDataModel
  static bool isTrial(SubscriptionEntity entity) {
    return entity.isInTrial && 
           (entity.trialEndDate?.isAfter(DateTime.now()) ?? false);
  }

  /// Equivalente ao isExpired do SubscriptionDataModel
  static bool isExpired(SubscriptionEntity entity) {
    return entity.status == SubscriptionStatus.expired ||
           (entity.expirationDate != null && 
            entity.expirationDate!.isBefore(DateTime.now()));
  }
}
