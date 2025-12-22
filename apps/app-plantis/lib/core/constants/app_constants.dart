/// Application-wide constants for CantinhoVerde
/// Centralizes hardcoded values to improve maintainability
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation
  static const String appId = 'cantinhoverde';
  static const String appName = 'CantinhoVerde';
  static const String packageName = 'br.com.agrimsolution.plantis';

  /// App Store ID - Update this before production release
  static const String appStoreId = '123456789';

  /// Google Play Store ID
  static const String googlePlayId = packageName;
  static const String analyticsAppParam = 'app';
  static const String errorPrefix = '❌';
  static const String successPrefix = '✅';
  static const String warningPrefix = '⚠️';
  static const String infoPrefix = '📋';
  static const String errorGeneric = 'Erro ao processar operação';
  static const String errorNetwork = 'Erro de conexão. Verifique sua internet.';
  static const String errorAuth = 'Erro de autenticação. Faça login novamente.';
  static const String errorNotFound = 'Dados não encontrados';
  static const String errorInvalidData = 'Dados inválidos fornecidos';
  static const String errorRegisteringScreen = 'Erro ao registrar tela';
  static const String errorRegisteringEvent = 'Erro ao registrar evento';
  static const String errorSettingUser = 'Erro ao definir usuário';
  static const String errorSettingProperty = 'Erro ao definir propriedade';
  static const String errorRegisteringError = 'Erro ao registrar erro';
  static const String errorRegisteringPlantCreation =
      'Erro ao registrar criação de planta';
  static const String errorRegisteringPlantDeletion =
      'Erro ao registrar exclusão de planta';
  static const String errorRegisteringPlantUpdate =
      'Erro ao registrar atualização de planta';
  static const String errorProcessingNotificationData =
      'Error processing plant care notification data';
  static const String errorHandlingAction = 'Error handling plant care action';
  static const String errorSchedulingReminder =
      'Error scheduling plant care reminder';
  static const String errorSchedulingRecurring =
      'Error scheduling recurring plant care';
  static const String errorCancellingNotifications =
      'Error cancelling plant notifications';
  static const String errorGettingNotifications =
      'Error getting plant notifications';
  static const String errorUpdatingSchedule =
      'Error updating plant notification schedule';
  static const String errorSnoozingReminder = 'Error snoozing reminder';
  static const String errorInitializingSyncService =
      'Error initializing CantinhoVerde sync service';
  static const String errorDuringInitialSync = 'Error during initial sync';
  static const String errorClearingSyncData = 'Error clearing sync data';
  static const String exceptionNotificationNotFound = 'Notification not found';
  static const String successGeneric = 'Operação realizada com sucesso';
  static const String successPlantCreated = 'Planta criada com sucesso';
  static const String successPlantUpdated = 'Planta atualizada com sucesso';
  static const String successPlantDeleted = 'Planta excluída com sucesso';
  static const String defaultVersion = '1.0.0';
  static const String defaultCurrency = 'USD';
  static const int appRatingMinDays = 3;
  static const int appRatingMinLaunches = 5;
  static const int appRatingRemindDays = 7;
  static const int appRatingRemindLaunches = 10;
  static const int maxRetries = 3;
  static const int retryDelayMs = 500;
  static const String emojiError = '❌';
  static const String emojiSuccess = '✅';
  static const String emojiWarning = '⚠️';
  static const String emojiInfo = '📋';
  static const String emojiPlant = '🌱';
  static const String emojiWater = '💧';
  static const String emojiSync = '🔄';
  static const String emojiLock = '🔒';
  static const String emojiStats = '📊';
}
