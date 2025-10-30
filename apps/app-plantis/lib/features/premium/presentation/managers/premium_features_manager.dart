import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages premium feature access and limitations
class PremiumFeaturesManager {
  final Ref ref;

  PremiumFeaturesManager(this.ref);

  /// Check if unlimited plants feature is available
  bool canCreateUnlimitedPlants(List<String> enabledFeatures) {
    return enabledFeatures.contains('unlimited_plants');
  }

  /// Check if custom reminders are available
  bool canUseCustomReminders(List<String> enabledFeatures) {
    return enabledFeatures.contains('custom_reminders');
  }

  /// Check if data export is available
  bool canExportData(List<String> enabledFeatures) {
    return enabledFeatures.contains('export_data');
  }

  /// Check if premium themes are available
  bool canAccessPremiumThemes(List<String> enabledFeatures) {
    return enabledFeatures.contains('premium_themes');
  }

  /// Check if cloud backup is available
  bool canBackupToCloud(List<String> enabledFeatures) {
    return enabledFeatures.contains('cloud_backup');
  }

  /// Check if plant identification is available
  bool canIdentifyPlants(List<String> enabledFeatures) {
    return enabledFeatures.contains('plant_identification');
  }

  /// Check if disease diagnosis is available
  bool canDiagnoseDiseases(List<String> enabledFeatures) {
    return enabledFeatures.contains('disease_diagnosis');
  }

  /// Check if weather notifications are available
  bool canUseWeatherNotifications(List<String> enabledFeatures) {
    return enabledFeatures.contains('weather_notifications');
  }

  /// Check if care calendar is available
  bool canUseCareCalendar(List<String> enabledFeatures) {
    return enabledFeatures.contains('care_calendar');
  }

  /// Get current plant limit
  int getCurrentPlantLimit(Map<String, int>? plantLimits) {
    return plantLimits?['default'] ?? 5;
  }

  /// Get all available features for current subscription
  List<String> getAvailableFeatures(bool isPremium) {
    if (!isPremium) {
      return const []; // No premium features for free users
    }
    return const [
      'unlimited_plants',
      'custom_reminders',
      'export_data',
      'premium_themes',
      'cloud_backup',
      'plant_identification',
      'disease_diagnosis',
      'weather_notifications',
      'care_calendar',
    ];
  }

  /// Check if user should upgrade
  bool shouldDisplayUpgradePrompt(bool isPremium) => !isPremium;

  /// Get upgrade message for specific feature
  String getUpgradeMessageForFeature(String featureName) {
    switch (featureName) {
      case 'unlimited_plants':
        return 'Desbloqueie plantas ilimitadas com Premium';
      case 'custom_reminders':
        return 'Lembretes personalizados disponíveis em Premium';
      case 'plant_identification':
        return 'Identifique plantas com IA em Premium';
      case 'disease_diagnosis':
        return 'Diagnóstico de doenças disponível em Premium';
      case 'export_data':
        return 'Exporte seus dados em Premium';
      default:
        return 'Recurso disponível em Premium';
    }
  }
}
