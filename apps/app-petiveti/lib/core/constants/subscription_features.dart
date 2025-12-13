/// Features premium do Petiveti
/// Define quais funcionalidades requerem assinatura premium
class PetivetiFeatures {
  PetivetiFeatures._();

  // MARK: - Premium Features

  /// Número ilimitado de animais cadastrados (Free: max 3)
  static const String unlimitedAnimals = 'unlimited_animals';

  /// Sincronização na nuvem (Firebase + Drift)
  static const String cloudSync = 'cloud_sync';

  /// Relatórios avançados de saúde e despesas
  static const String advancedReports = 'advanced_reports';

  /// Lembretes de medicamentos e vacinas com notificações
  static const String medicationReminders = 'medication_reminders';

  /// Integração com clínicas veterinárias
  static const String vetIntegration = 'vet_integration';

  /// Exportação de dados (PDF, Excel, CSV)
  static const String exportData = 'export_data';

  /// Sem anúncios
  static const String noAds = 'no_ads';

  /// Backup automático
  static const String autoBackup = 'auto_backup';

  /// Suporte prioritário
  static const String prioritySupport = 'priority_support';

  /// Histórico completo sem limite de tempo
  static const String unlimitedHistory = 'unlimited_history';

  // MARK: - Free Features

  /// Cadastro básico de até 3 animais
  static const String basicAnimalRegistry = 'basic_animal_registry';

  /// Registro de vacinas e medicamentos
  static const String basicHealthRecords = 'basic_health_records';

  /// Cálculos veterinários básicos
  static const String basicCalculators = 'basic_calculators';

  /// Lembretes simples (sem notificações push)
  static const String basicReminders = 'basic_reminders';

  // MARK: - Feature Sets

  /// Conjunto de features premium
  static const Set<String> premiumFeatures = {
    unlimitedAnimals,
    cloudSync,
    advancedReports,
    medicationReminders,
    vetIntegration,
    exportData,
    noAds,
    autoBackup,
    prioritySupport,
    unlimitedHistory,
  };

  /// Conjunto de features gratuitas (sempre disponíveis)
  static const Set<String> freeFeatures = {
    basicAnimalRegistry,
    basicHealthRecords,
    basicCalculators,
    basicReminders,
  };

  /// Verifica se uma feature é premium
  static bool isPremiumFeature(String featureKey) {
    return premiumFeatures.contains(featureKey);
  }

  /// Verifica se uma feature é gratuita
  static bool isFreeFeature(String featureKey) {
    return freeFeatures.contains(featureKey);
  }
}
