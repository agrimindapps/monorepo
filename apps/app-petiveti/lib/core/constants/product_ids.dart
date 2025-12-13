/// Product IDs do Petiveti no RevenueCat
///
/// Configure estes IDs no dashboard do RevenueCat:
/// https://app.revenuecat.com/
///
/// Lembre-se de também configurar no App Store Connect e Google Play Console
class PetivetiProducts {
  PetivetiProducts._();

  // MARK: - Subscription Products

  /// Assinatura mensal premium - R$ 9,90/mês
  /// Features: unlimited animals, cloud sync, advanced reports, no ads
  static const String monthlyPremium = 'petiveti_premium_monthly';

  /// Assinatura anual premium - R$ 99,90/ano (economia de 17%)
  /// Features: unlimited animals, cloud sync, advanced reports, no ads
  static const String yearlyPremium = 'petiveti_premium_yearly';

  /// Compra única vitalícia - R$ 299,90
  /// Features: todas as features premium para sempre
  static const String lifetime = 'petiveti_lifetime';

  // MARK: - Add-on Products (Opcional - futuro)

  /// Integração com clínicas veterinárias
  static const String vetIntegration = 'petiveti_addon_vet_integration';

  /// Relatórios avançados de saúde
  static const String advancedReports = 'petiveti_addon_advanced_reports';

  // MARK: - Product Lists

  /// Lista de todos os produtos de assinatura
  static const List<String> allSubscriptions = [
    monthlyPremium,
    yearlyPremium,
    lifetime,
  ];

  /// Lista de produtos principais (exibir na tela de subscription)
  static const List<String> mainProducts = [monthlyPremium, yearlyPremium];

  /// Lista de add-ons
  static const List<String> addons = [vetIntegration, advancedReports];
}
