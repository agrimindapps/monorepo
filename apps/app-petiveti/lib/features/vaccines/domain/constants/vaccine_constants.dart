/// Constants for vaccine feature
///
/// Centralizes magic numbers and configuration values
/// to improve maintainability and avoid duplication
class VaccineConstants {
  // Private constructor to prevent instantiation
  VaccineConstants._();

  // ========================================================================
  // REMINDER CONFIGURATION
  // ========================================================================

  /// Default number of days before vaccine due date to send reminder
  static const int defaultDaysBeforeReminder = 7;

  /// Number of days before due date considered urgent
  static const int urgentReminderDays = 3;

  /// Critical alert - send reminder this many days before
  static const int criticalReminderDays = 1;

  /// Default preferred time for reminders
  static const int defaultReminderHour = 9;
  static const int defaultReminderMinute = 0;

  // ========================================================================
  // NOTIFICATION SETTINGS
  // ========================================================================

  /// Default reminder frequency options
  static const String frequencyDaily = 'daily';
  static const String frequencyWeekly = 'weekly';
  static const String frequencyMonthly = 'monthly';

  /// Reminder channels
  static const bool defaultEnableSmartReminders = true;
  static const bool defaultEnablePushNotifications = true;
  static const bool defaultEnableEmailReminders = false;
  static const bool defaultEnableSmsReminders = false;
  static const bool defaultWeekendReminders = true;

  // ========================================================================
  // VACCINE SCHEDULING
  // ========================================================================

  /// Minimum interval between doses (in days)
  static const int minIntervalBetweenDoses = 1;

  /// Maximum interval between doses (in days) - 1 year
  static const int maxIntervalBetweenDoses = 365;

  /// Default interval for annual vaccines
  static const int defaultAnnualInterval = 365;

  /// Default interval for semi-annual vaccines
  static const int defaultSemiAnnualInterval = 182;

  /// Default interval for quarterly vaccines
  static const int defaultQuarterlyInterval = 91;

  // ========================================================================
  // VALIDATION
  // ========================================================================

  /// Minimum vaccine name length
  static const int minVaccineNameLength = 2;

  /// Maximum vaccine name length
  static const int maxVaccineNameLength = 100;

  /// Maximum notes length
  static const int maxNotesLength = 500;

  /// Maximum manufacturer name length
  static const int maxManufacturerLength = 100;

  /// Maximum batch number length
  static const int maxBatchNumberLength = 50;

  // ========================================================================
  // UI CONFIGURATION
  // ========================================================================

  /// Number of upcoming vaccines to show in dashboard
  static const int upcomingVaccinesLimit = 5;

  /// Number of overdue vaccines to highlight
  static const int overdueVaccinesLimit = 3;

  /// Calendar months to show ahead
  static const int calendarMonthsAhead = 12;

  /// Animation duration in milliseconds
  static const int animationDurationMs = 300;

  // ========================================================================
  // BUSINESS RULES
  // ========================================================================

  /// Number of days after which vaccine is considered overdue
  static const int overdueDays = 0; // Overdue on due date

  /// Number of days to show "due soon" warning
  static const int dueSoonDays = 14;

  /// Maximum number of reminder attempts
  static const int maxReminderAttempts = 3;

  /// Hours between reminder retry attempts
  static const int reminderRetryHours = 24;

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  /// Get reminder frequency display name
  static String getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case frequencyDaily:
        return 'Diário';
      case frequencyWeekly:
        return 'Semanal';
      case frequencyMonthly:
        return 'Mensal';
      default:
        return 'Desconhecido';
    }
  }

  /// Check if vaccine is overdue based on due date
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Check if vaccine is due soon
  static bool isDueSoon(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference >= 0 && difference <= dueSoonDays;
  }

  /// Check if reminder should be sent (within reminder window)
  static bool shouldSendReminder(DateTime dueDate, int daysBeforeReminder) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    return difference <= daysBeforeReminder && difference >= 0;
  }
}
