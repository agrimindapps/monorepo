enum Language {
  portuguese('pt_BR', 'Português (Brasil)'),
  english('en', 'English'),
  spanish('es', 'Español');

  const Language(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum WeightUnit {
  kilogram('kg', 'Quilogramas'),
  gram('g', 'Gramas'),
  pound('lb', 'Libras');

  const WeightUnit(this.code, this.displayName);
  final String code;
  final String displayName;
}

enum ThemeType {
  blue('blue', 'Azul Padrão'),
  green('green', 'Verde Natureza'),
  purple('purple', 'Roxo Moderno'),
  orange('orange', 'Laranja Vibrante'),
  teal('teal', 'Teal Profissional');

  const ThemeType(this.code, this.displayName);
  final String code;
  final String displayName;
}

class SettingsData {
  final bool notificationsEnabled;
  final bool darkMode;
  final Language selectedLanguage;
  final WeightUnit selectedWeightUnit;
  final ThemeType selectedTheme;
  final String notificationTime;
  final DateTime? lastBackupDate;

  const SettingsData({
    this.notificationsEnabled = true,
    this.darkMode = false,
    this.selectedLanguage = Language.portuguese,
    this.selectedWeightUnit = WeightUnit.kilogram,
    this.selectedTheme = ThemeType.purple,
    this.notificationTime = '09:00',
    this.lastBackupDate,
  });

  SettingsData copyWith({
    bool? notificationsEnabled,
    bool? darkMode,
    Language? selectedLanguage,
    WeightUnit? selectedWeightUnit,
    ThemeType? selectedTheme,
    String? notificationTime,
    DateTime? lastBackupDate,
  }) {
    return SettingsData(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedWeightUnit: selectedWeightUnit ?? this.selectedWeightUnit,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      notificationTime: notificationTime ?? this.notificationTime,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'darkMode': darkMode,
      'selectedLanguage': selectedLanguage.code,
      'selectedWeightUnit': selectedWeightUnit.code,
      'selectedTheme': selectedTheme.code,
      'notificationTime': notificationTime,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
    };
  }

  static SettingsData fromJson(Map<String, dynamic> json) {
    return SettingsData(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      darkMode: json['darkMode'] ?? false,
      selectedLanguage: _getLanguageByCode(json['selectedLanguage'] ?? 'pt_BR'),
      selectedWeightUnit: _getWeightUnitByCode(json['selectedWeightUnit'] ?? 'kg'),
      selectedTheme: _getThemeByCode(json['selectedTheme'] ?? 'purple'),
      notificationTime: json['notificationTime'] ?? '09:00',
      lastBackupDate: json['lastBackupDate'] != null 
          ? DateTime.parse(json['lastBackupDate'])
          : null,
    );
  }

  static Language _getLanguageByCode(String code) {
    return Language.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => Language.portuguese,
    );
  }

  static WeightUnit _getWeightUnitByCode(String code) {
    return WeightUnit.values.firstWhere(
      (unit) => unit.code == code,
      orElse: () => WeightUnit.kilogram,
    );
  }

  static ThemeType _getThemeByCode(String code) {
    return ThemeType.values.firstWhere(
      (theme) => theme.code == code,
      orElse: () => ThemeType.purple,
    );
  }

  @override
  String toString() {
    return 'SettingsData(notifications: $notificationsEnabled, darkMode: $darkMode, language: ${selectedLanguage.displayName}, weightUnit: ${selectedWeightUnit.displayName}, theme: ${selectedTheme.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsData &&
        other.notificationsEnabled == notificationsEnabled &&
        other.darkMode == darkMode &&
        other.selectedLanguage == selectedLanguage &&
        other.selectedWeightUnit == selectedWeightUnit &&
        other.selectedTheme == selectedTheme &&
        other.notificationTime == notificationTime &&
        other.lastBackupDate == lastBackupDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      notificationsEnabled,
      darkMode,
      selectedLanguage,
      selectedWeightUnit,
      selectedTheme,
      notificationTime,
      lastBackupDate,
    );
  }
}

class SettingsRepository {
  static SettingsData getDefaultSettings() {
    return const SettingsData();
  }

  static List<Language> getAvailableLanguages() {
    return Language.values;
  }

  static List<WeightUnit> getAvailableWeightUnits() {
    return WeightUnit.values;
  }

  static List<ThemeType> getAvailableThemes() {
    return ThemeType.values;
  }

  static String formatNotificationTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return '09:00';
      }
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '09:00';
    }
  }

  static bool isValidNotificationTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return false;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
    } catch (e) {
      return false;
    }
  }

  static String getLanguageDisplayName(String code) {
    final language = Language.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => Language.portuguese,
    );
    return language.displayName;
  }

  static String getWeightUnitDisplayName(String code) {
    final unit = WeightUnit.values.firstWhere(
      (unit) => unit.code == code,
      orElse: () => WeightUnit.kilogram,
    );
    return unit.displayName;
  }

  static String getThemeDisplayName(String code) {
    final theme = ThemeType.values.firstWhere(
      (theme) => theme.code == code,
      orElse: () => ThemeType.purple,
    );
    return theme.displayName;
  }

  static Map<String, dynamic> getSettingsStatistics(SettingsData settings) {
    return {
      'hasNotifications': settings.notificationsEnabled,
      'isDarkMode': settings.darkMode,
      'language': settings.selectedLanguage.code,
      'weightUnit': settings.selectedWeightUnit.code,
      'theme': settings.selectedTheme.code,
      'notificationTime': settings.notificationTime,
      'hasBackup': settings.lastBackupDate != null,
      'daysSinceLastBackup': settings.lastBackupDate != null
          ? DateTime.now().difference(settings.lastBackupDate!).inDays
          : null,
    };
  }

  static bool needsBackupReminder(SettingsData settings, {int daysThreshold = 30}) {
    if (settings.lastBackupDate == null) return true;
    
    final daysSinceBackup = DateTime.now().difference(settings.lastBackupDate!).inDays;
    return daysSinceBackup >= daysThreshold;
  }

  static String getBackupStatusText(SettingsData settings) {
    if (settings.lastBackupDate == null) {
      return 'Nunca';
    }
    
    final now = DateTime.now();
    final difference = now.difference(settings.lastBackupDate!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}