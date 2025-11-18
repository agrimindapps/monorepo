/// Constants for reminder feature
///
/// Centralizes configuration values for reminders
class ReminderConstants {
  // Private constructor to prevent instantiation
  ReminderConstants._();

  // ========================================================================
  // REMINDER TIMING
  // ========================================================================

  /// Default hours before reminder to send notification
  static const int defaultHoursBeforeReminder = 1;

  /// Default preferred time for reminders
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;

  /// Snooze duration in minutes
  static const int snoozeDurationMinutes = 15;

  /// Maximum snooze count
  static const int maxSnoozeCount = 3;

  // ========================================================================
  // REMINDER TYPES
  // ========================================================================

  static const String typeVaccination = 'vaccination';
  static const String typeMedication = 'medication';
  static const String typeAppointment = 'appointment';
  static const String typeGrooming = 'grooming';
  static const String typeFeeding = 'feeding';
  static const String typeExercise = 'exercise';
  static const String typeCustom = 'custom';

  // ========================================================================
  // FREQUENCY OPTIONS
  // ========================================================================

  static const String frequencyOnce = 'once';
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyBiweekly = 'biweekly';
  static const String frequencyMonthly = 'monthly';
  static const String frequencyYearly = 'yearly';

  // ========================================================================
  // PRIORITY LEVELS
  // ========================================================================

  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
  static const String priorityCritical = 'critical';

  // ========================================================================
  // VALIDATION
  // ========================================================================

  /// Minimum title length
  static const int minTitleLength = 3;

  /// Maximum title length
  static const int maxTitleLength = 100;

  /// Maximum description length
  static const int maxDescriptionLength = 500;

  /// Maximum advance notice days
  static const int maxAdvanceNoticeDays = 365;

  // ========================================================================
  // UI CONFIGURATION
  // ========================================================================

  /// Number of upcoming reminders to show
  static const int upcomingRemindersLimit = 10;

  /// Number of overdue reminders to show
  static const int overdueRemindersLimit = 5;

  /// Animation duration in milliseconds
  static const int animationDurationMs = 250;

  // ========================================================================
  // NOTIFICATION SETTINGS
  // ========================================================================

  /// Enable persistent notifications
  static const bool defaultPersistentNotifications = false;

  /// Enable sound
  static const bool defaultEnableSound = true;

  /// Enable vibration
  static const bool defaultEnableVibration = true;

  /// Default notification channel ID
  static const String notificationChannelId = 'petiveti_reminders';

  /// Default notification channel name
  static const String notificationChannelName = 'PetiVeti Reminders';

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Get frequency display name
  static String getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case frequencyOnce:
        return 'Uma vez';
      case frequencyDaily:
        return 'Diário';
      case frequencyWeekly:
        return 'Semanal';
      case frequencyBiweekly:
        return 'Quinzenal';
      case frequencyMonthly:
        return 'Mensal';
      case frequencyYearly:
        return 'Anual';
      default:
        return 'Desconhecido';
    }
  }

  /// Get priority display name
  static String getPriorityDisplayName(String priority) {
    switch (priority) {
      case priorityLow:
        return 'Baixa';
      case priorityMedium:
        return 'Média';
      case priorityHigh:
        return 'Alta';
      case priorityCritical:
        return 'Crítica';
      default:
        return 'Média';
    }
  }

  /// Get type display name
  static String getTypeDisplayName(String type) {
    switch (type) {
      case typeVaccination:
        return 'Vacinação';
      case typeMedication:
        return 'Medicação';
      case typeAppointment:
        return 'Consulta';
      case typeGrooming:
        return 'Banho e Tosa';
      case typeFeeding:
        return 'Alimentação';
      case typeExercise:
        return 'Exercício';
      case typeCustom:
        return 'Personalizado';
      default:
        return 'Outros';
    }
  }

  /// Calculate next occurrence based on frequency
  static DateTime? calculateNextOccurrence(DateTime current, String frequency) {
    switch (frequency) {
      case frequencyDaily:
        return current.add(const Duration(days: 1));
      case frequencyWeekly:
        return current.add(const Duration(days: 7));
      case frequencyBiweekly:
        return current.add(const Duration(days: 14));
      case frequencyMonthly:
        return DateTime(current.year, current.month + 1, current.day);
      case frequencyYearly:
        return DateTime(current.year + 1, current.month, current.day);
      case frequencyOnce:
      default:
        return null; // No next occurrence
    }
  }
}
