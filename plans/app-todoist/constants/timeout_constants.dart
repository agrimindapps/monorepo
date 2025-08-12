/// Constantes de timeout e duração para o módulo app-todoist
/// Centraliza todos os valores de Duration para facilitar manutenção e consistência
class TimeoutConstants {
  // === Date/Time Calculations ===
  static const Duration oneDay = Duration(days: 1);
  static const Duration oneWeek = Duration(days: 7);
  static const Duration oneYear = Duration(days: 365);
  static const Duration oneHour = Duration(hours: 1);

  // === UI Animations ===
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration fadeAnimation = Duration(milliseconds: 800);
  static const Duration slideAnimation = Duration(milliseconds: 1000);

  // === User Input Debouncing ===
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // === API/Network Timeouts ===
  static const Duration shortDelay = Duration(seconds: 1);
  static const Duration mediumDelay = Duration(seconds: 2);
  static const Duration longDelay = Duration(seconds: 3);
  static const Duration extraLongDelay = Duration(seconds: 4);

  // === Notification Settings ===
  static const Duration defaultReminderAdvance = Duration(hours: 1);

  // === Memory Management ===
  static const Duration memoryCheckInterval = Duration(minutes: 30);

  // === Development/Placeholder ===
  static const Duration placeholderDelay = Duration(seconds: 1);
}