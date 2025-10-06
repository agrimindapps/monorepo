import 'package:flutter/material.dart';
import '../domain/premium_service.dart';

/// Central settings state following SOLID principles
class SettingsState {
  final bool isDarkTheme;
  final bool isLoading;
  final PremiumStatus premiumStatus;
  final bool isDevelopmentMode;
  final String? error;
  final SettingsSection? activeSection;
  
  const SettingsState({
    this.isDarkTheme = false,
    this.isLoading = false,
    this.premiumStatus = const PremiumStatus(isActive: false),
    this.isDevelopmentMode = false,
    this.error,
    this.activeSection,
  });
  
  SettingsState copyWith({
    bool? isDarkTheme,
    bool? isLoading,
    PremiumStatus? premiumStatus,
    bool? isDevelopmentMode,
    String? error,
    SettingsSection? activeSection,
  }) {
    return SettingsState(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      isLoading: isLoading ?? this.isLoading,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      isDevelopmentMode: isDevelopmentMode ?? this.isDevelopmentMode,
      error: error,
      activeSection: activeSection ?? this.activeSection,
    );
  }
  
  bool get isPremium => premiumStatus.isActive;
  bool get isTestSubscription => premiumStatus.isTestSubscription;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.isDarkTheme == isDarkTheme &&
        other.isLoading == isLoading &&
        other.premiumStatus == premiumStatus &&
        other.isDevelopmentMode == isDevelopmentMode &&
        other.error == error &&
        other.activeSection == activeSection;
  }
  
  @override
  int get hashCode {
    return isDarkTheme.hashCode ^
        isLoading.hashCode ^
        premiumStatus.hashCode ^
        isDevelopmentMode.hashCode ^
        error.hashCode ^
        activeSection.hashCode;
  }
  
  @override
  String toString() {
    return 'SettingsState(isDark: $isDarkTheme, isPremium: $isPremium, isDev: $isDevelopmentMode)';
  }
}

/// Available settings sections
enum SettingsSection {
  premium,
  siteAccess,
  speechToText,
  development,
  about,
}

/// Settings section configuration
class SettingsSectionConfig {
  final SettingsSection section;
  final String title;
  final IconData icon;
  final bool showOnWeb;
  final bool showOnMobile;
  final bool requiresDevelopmentMode;
  
  const SettingsSectionConfig({
    required this.section,
    required this.title,
    required this.icon,
    this.showOnWeb = true,
    this.showOnMobile = true,
    this.requiresDevelopmentMode = false,
  });
  
  static const List<SettingsSectionConfig> allSections = [
    SettingsSectionConfig(
      section: SettingsSection.premium,
      title: 'Publicidade & Assinaturas',
      icon: Icons.monetization_on,
      showOnWeb: false, // Only show on mobile
    ),
    SettingsSectionConfig(
      section: SettingsSection.siteAccess,
      title: 'Acessar Site',
      icon: Icons.public,
      showOnWeb: false, // Only show on mobile
    ),
    SettingsSectionConfig(
      section: SettingsSection.speechToText,
      title: 'Transcrição para Voz',
      icon: Icons.mic,
    ),
    SettingsSectionConfig(
      section: SettingsSection.development,
      title: 'Ferramentas de Desenvolvimento',
      icon: Icons.code,
      requiresDevelopmentMode: true,
    ),
    SettingsSectionConfig(
      section: SettingsSection.about,
      title: 'Mais informações',
      icon: Icons.info,
    ),
  ];
  
  static List<SettingsSectionConfig> getVisibleSections({
    required bool isWeb,
    required bool isDevelopmentMode,
  }) {
    return allSections.where((section) {
      if (isWeb && !section.showOnWeb) return false;
      if (!isWeb && !section.showOnMobile) return false;
      if (section.requiresDevelopmentMode && !isDevelopmentMode) return false;
      
      return true;
    }).toList();
  }
}
