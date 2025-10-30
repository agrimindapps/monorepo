import '../../widgets/premium_feature_gate.dart';

/// Gerencia verificação de acesso a features premium
/// SRP: Isolates premium feature access validation logic
class PremiumFeatureAccessManager {
  final Map<PremiumFeature, bool> _featureAccessCache = {};

  /// Verifica se uma feature premium pode ser acessada
  bool canAccessFeature(PremiumFeature feature, bool isPremiumActive) {
    if (_featureAccessCache.containsKey(feature)) {
      return _featureAccessCache[feature] ?? false;
    }

    final hasAccess = _checkFeatureAccess(feature, isPremiumActive);
    _featureAccessCache[feature] = hasAccess;
    return hasAccess;
  }

  /// Verifica acesso com base no tipo de feature
  bool _checkFeatureAccess(PremiumFeature feature, bool isPremiumActive) {
    if (!isPremiumActive) return false;

    return switch (feature) {
      PremiumFeature.cloudSync => true,
      PremiumFeature.unlimitedPlants => true,
      PremiumFeature.premiumSupport => true,
      PremiumFeature.advancedNotifications => true,
      PremiumFeature.exportData => true,
      PremiumFeature.customThemes => true,
    };
  }

  /// Limpa cache de acesso
  void clearCache() {
    _featureAccessCache.clear();
  }
}
