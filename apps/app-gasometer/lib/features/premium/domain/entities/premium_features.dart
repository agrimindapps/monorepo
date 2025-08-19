import 'package:equatable/equatable.dart';

/// Entidade que representa as features premium disponíveis no GasOMeter
class PremiumFeatures extends Equatable {
  const PremiumFeatures({
    required this.unlimitedVehicles,
    required this.advancedReports,
    required this.exportData,
    required this.customCategories,
    required this.premiumThemes,
    required this.cloudBackup,
    required this.locationHistory,
    required this.advancedAnalytics,
    required this.costPredictions,
    required this.maintenanceAlerts,
    required this.fuelPriceAlerts,
    required this.detailedCharts,
    required this.premiumSupport,
    required this.offlineMode,
  });

  /// Permite veículos ilimitados (vs limite de 2 no free)
  final bool unlimitedVehicles;

  /// Acesso a relatórios avançados com insights detalhados
  final bool advancedReports;

  /// Exportação de dados em múltiplos formatos
  final bool exportData;

  /// Criação de categorias personalizadas
  final bool customCategories;

  /// Acesso a temas premium
  final bool premiumThemes;

  /// Backup automático na nuvem
  final bool cloudBackup;

  /// Histórico de localização de abastecimentos
  final bool locationHistory;

  /// Analytics avançados de consumo e performance
  final bool advancedAnalytics;

  /// Predições de custos baseadas em AI
  final bool costPredictions;

  /// Alertas inteligentes de manutenção
  final bool maintenanceAlerts;

  /// Alertas de variação de preços de combustível
  final bool fuelPriceAlerts;

  /// Gráficos detalhados e comparativos
  final bool detailedCharts;

  /// Suporte premium com prioridade
  final bool premiumSupport;

  /// Modo offline avançado com sincronização
  final bool offlineMode;

  /// Features premium completas (todas habilitadas)
  static const PremiumFeatures all = PremiumFeatures(
    unlimitedVehicles: true,
    advancedReports: true,
    exportData: true,
    customCategories: true,
    premiumThemes: true,
    cloudBackup: true,
    locationHistory: true,
    advancedAnalytics: true,
    costPredictions: true,
    maintenanceAlerts: true,
    fuelPriceAlerts: true,
    detailedCharts: true,
    premiumSupport: true,
    offlineMode: true,
  );

  /// Features gratuitas (todas desabilitadas)
  static const PremiumFeatures none = PremiumFeatures(
    unlimitedVehicles: false,
    advancedReports: false,
    exportData: false,
    customCategories: false,
    premiumThemes: false,
    cloudBackup: false,
    locationHistory: false,
    advancedAnalytics: false,
    costPredictions: false,
    maintenanceAlerts: false,
    fuelPriceAlerts: false,
    detailedCharts: false,
    premiumSupport: false,
    offlineMode: false,
  );

  /// Lista de IDs de features para verificação
  static const List<String> featureIds = [
    'unlimited_vehicles',
    'advanced_reports',
    'export_data',
    'custom_categories',
    'premium_themes',
    'cloud_backup',
    'location_history',
    'advanced_analytics',
    'cost_predictions',
    'maintenance_alerts',
    'fuel_price_alerts',
    'detailed_charts',
    'premium_support',
    'offline_mode',
  ];

  /// Verifica se uma feature específica está habilitada
  bool hasFeature(String featureId) {
    switch (featureId) {
      case 'unlimited_vehicles':
        return unlimitedVehicles;
      case 'advanced_reports':
        return advancedReports;
      case 'export_data':
        return exportData;
      case 'custom_categories':
        return customCategories;
      case 'premium_themes':
        return premiumThemes;
      case 'cloud_backup':
        return cloudBackup;
      case 'location_history':
        return locationHistory;
      case 'advanced_analytics':
        return advancedAnalytics;
      case 'cost_predictions':
        return costPredictions;
      case 'maintenance_alerts':
        return maintenanceAlerts;
      case 'fuel_price_alerts':
        return fuelPriceAlerts;
      case 'detailed_charts':
        return detailedCharts;
      case 'premium_support':
        return premiumSupport;
      case 'offline_mode':
        return offlineMode;
      default:
        return false;
    }
  }

  /// Retorna quantas features estão habilitadas
  int get enabledFeaturesCount {
    return [
      unlimitedVehicles,
      advancedReports,
      exportData,
      customCategories,
      premiumThemes,
      cloudBackup,
      locationHistory,
      advancedAnalytics,
      costPredictions,
      maintenanceAlerts,
      fuelPriceAlerts,
      detailedCharts,
      premiumSupport,
      offlineMode,
    ].where((feature) => feature).length;
  }

  /// Se tem todas as features premium
  bool get isPremium => enabledFeaturesCount == featureIds.length;

  /// Se não tem nenhuma feature premium
  bool get isFree => enabledFeaturesCount == 0;

  @override
  List<Object?> get props => [
        unlimitedVehicles,
        advancedReports,
        exportData,
        customCategories,
        premiumThemes,
        cloudBackup,
        locationHistory,
        advancedAnalytics,
        costPredictions,
        maintenanceAlerts,
        fuelPriceAlerts,
        detailedCharts,
        premiumSupport,
        offlineMode,
      ];

  @override
  String toString() {
    return 'PremiumFeatures(enabledFeatures: $enabledFeaturesCount/${featureIds.length})';
  }
}

/// Limites para usuários free vs premium
class UsageLimits extends Equatable {
  const UsageLimits({
    required this.maxVehicles,
    required this.maxFuelRecords,
    required this.maxMaintenanceRecords,
    required this.maxExportSize,
    required this.maxBackupSize,
    required this.maxCategories,
  });

  final int maxVehicles;
  final int maxFuelRecords;
  final int maxMaintenanceRecords;
  final int maxExportSize; // MB
  final int maxBackupSize; // MB
  final int maxCategories;

  /// Limites para usuários gratuitos
  static const UsageLimits free = UsageLimits(
    maxVehicles: 2,
    maxFuelRecords: 50,
    maxMaintenanceRecords: 20,
    maxExportSize: 0, // Não pode exportar
    maxBackupSize: 0, // Não tem backup
    maxCategories: 5, // Categorias básicas
  );

  /// Limites para usuários premium (ilimitados)
  static const UsageLimits premium = UsageLimits(
    maxVehicles: -1, // Ilimitado
    maxFuelRecords: -1, // Ilimitado
    maxMaintenanceRecords: -1, // Ilimitado
    maxExportSize: 100, // 100MB
    maxBackupSize: 500, // 500MB
    maxCategories: -1, // Ilimitado
  );

  /// Se um valor é ilimitado
  bool isUnlimited(int value) => value == -1;

  /// Se pode adicionar mais veículos
  bool canAddVehicle(int currentCount) {
    return isUnlimited(maxVehicles) || currentCount < maxVehicles;
  }

  /// Se pode adicionar mais registros de combustível
  bool canAddFuelRecord(int currentCount) {
    return isUnlimited(maxFuelRecords) || currentCount < maxFuelRecords;
  }

  /// Se pode adicionar mais registros de manutenção
  bool canAddMaintenanceRecord(int currentCount) {
    return isUnlimited(maxMaintenanceRecords) || currentCount < maxMaintenanceRecords;
  }

  /// Se pode exportar dados
  bool canExport() => maxExportSize > 0;

  /// Se pode fazer backup
  bool canBackup() => maxBackupSize > 0;

  @override
  List<Object?> get props => [
        maxVehicles,
        maxFuelRecords,
        maxMaintenanceRecords,
        maxExportSize,
        maxBackupSize,
        maxCategories,
      ];
}