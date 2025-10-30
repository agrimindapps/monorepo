import '../../domain/entities/device_settings_entity.dart';
import '../../domain/entities/notification_settings_entity.dart';
import '../../domain/entities/premium_settings_entity.dart';
import '../../domain/entities/theme_settings_entity.dart';
import '../../domain/interfaces/segregated_settings_interfaces.dart';

/// ✅ REFACTORED: Segregated Settings Provider - Follows ISP
///
/// OLD APPROACH (UserSettingsModel - violated ISP):
/// - Agrupava 4 tipos de setting diferentes
/// - Expunha 20+ getters misturados
/// - Cliente precisava de tema recebia toda a interface
///
/// NEW APPROACH (Segregated Interfaces):
/// - Interface IThemeSettings - apenas tema
/// - Interface INotificationSettings - apenas notificações
/// - Interface IDeviceSettings - apenas device
/// - Interface IPremiumSettings - apenas premium
///
/// BENEFITS:
/// ✅ Interface Segregation Principle: Cada client recebe apenas o que precisa
/// ✅ Single Responsibility: Cada interface tem uma responsabilidade
/// ✅ Better Testability: Fácil mockar interfaces específicas
/// ✅ Extensibility: Adicionar novo setting não afeta interfaces existentes

/// Composite model que AINDA expõe todas as interfaces segregadas
/// Use este apenas quando realmente precisar de TUDO
/// Para a maioria dos casos, use as interfaces específicas
class UserSettingsComposite {
  /// Segregated interface para tema
  final IThemeSettings themeSettings;

  /// Segregated interface para notificações
  final INotificationSettings notificationSettings;

  /// Segregated interface para device
  final IDeviceSettings deviceSettings;

  /// Segregated interface para premium
  final IPremiumSettings premiumSettings;

  /// Estado de loading/error compartilhado
  final bool isLoading;
  final String? error;

  const UserSettingsComposite({
    required this.themeSettings,
    required this.notificationSettings,
    required this.deviceSettings,
    required this.premiumSettings,
    required this.isLoading,
    this.error,
  });

  /// Factory para criar a partir de entidades
  factory UserSettingsComposite.fromEntities({
    required ThemeSettingsEntity themeEntity,
    required NotificationSettingsEntity notificationEntity,
    required DeviceSettingsEntity deviceEntity,
    required PremiumSettingsEntity premiumEntity,
    bool isLoading = false,
    String? error,
  }) {
    return UserSettingsComposite(
      themeSettings: IThemeSettings.from(themeEntity),
      notificationSettings: INotificationSettings.from(notificationEntity),
      deviceSettings: IDeviceSettings.from(deviceEntity),
      premiumSettings: IPremiumSettings.from(premiumEntity),
      isLoading: isLoading,
      error: error,
    );
  }

  /// Copy with para atualizar parcialmente
  UserSettingsComposite copyWith({
    IThemeSettings? themeSettings,
    INotificationSettings? notificationSettings,
    IDeviceSettings? deviceSettings,
    IPremiumSettings? premiumSettings,
    bool? isLoading,
    String? error,
  }) {
    return UserSettingsComposite(
      themeSettings: themeSettings ?? this.themeSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      deviceSettings: deviceSettings ?? this.deviceSettings,
      premiumSettings: premiumSettings ?? this.premiumSettings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Clear error
  UserSettingsComposite clearError() {
    return copyWith(error: null);
  }
}

/// Helper providers para casos específicos
/// Use esses quando precisar de apenas um tipo de setting específico

extension UserSettingsCompositeExt on UserSettingsComposite {
  /// Get only theme settings - use esse em vez de acessar tudo
  IThemeSettings getThemeSettings() => themeSettings;

  /// Get only notification settings - use esse em vez de acessar tudo
  INotificationSettings getNotificationSettings() => notificationSettings;

  /// Get only device settings - use esse em vez de acessar tudo
  IDeviceSettings getDeviceSettings() => deviceSettings;

  /// Get only premium settings - use esse em vez de acessar tudo
  IPremiumSettings getPremiumSettings() => premiumSettings;
}
