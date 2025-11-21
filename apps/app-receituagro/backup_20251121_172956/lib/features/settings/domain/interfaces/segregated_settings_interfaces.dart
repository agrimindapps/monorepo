import '../entities/device_settings_entity.dart';
import '../entities/notification_settings_entity.dart';
import '../entities/premium_settings_entity.dart';
import '../entities/theme_settings_entity.dart';

/// Interface Segregation: Segregate settings by concern
/// Cada interface expõe apenas o que é necessário para seu domínio específico
///
/// Benefício: Clients que precisam de um tipo de setting específico
/// recebem apenas aquela interface, não a classe monolítica completa.

/// Interface for theme-related settings only
/// Clients interessados apenas em tema recebem apenas essa interface
abstract interface class IThemeSettings {
  bool get isDarkTheme;
  String get language;
  String get languageDisplayName;
  bool get isRtlLanguage;

  factory IThemeSettings.from(ThemeSettingsEntity entity) =>
      _ThemeSettingsImpl(entity);
}

class _ThemeSettingsImpl implements IThemeSettings {
  final ThemeSettingsEntity _entity;

  _ThemeSettingsImpl(this._entity);

  @override
  bool get isDarkTheme => _entity.isDarkTheme;

  @override
  String get language => _entity.language;

  @override
  String get languageDisplayName => _entity.languageDisplayName;

  @override
  bool get isRtlLanguage => _entity.isRtlLanguage;
}

/// Interface for notification-related settings only
/// Expõe apenas os getters relevantes de notificação
abstract interface class INotificationSettings {
  bool get notificationsEnabled;
  bool get soundEnabled;
  bool get promotionalNotificationsEnabled;

  factory INotificationSettings.from(NotificationSettingsEntity entity) =>
      _NotificationSettingsImpl(entity);
}

class _NotificationSettingsImpl implements INotificationSettings {
  final NotificationSettingsEntity _entity;

  _NotificationSettingsImpl(this._entity);

  @override
  bool get notificationsEnabled => _entity.notificationsEnabled;

  @override
  bool get soundEnabled => _entity.soundEnabled;

  @override
  bool get promotionalNotificationsEnabled =>
      _entity.promotionalNotificationsEnabled;
}

/// Interface for device-related settings only
/// Expõe apenas os getters relevantes de device
abstract interface class IDeviceSettings {
  String get currentDeviceId;
  bool get syncEnabled;
  List<String> get connectedDevices;
  DateTime? get lastSyncTime;

  factory IDeviceSettings.from(DeviceSettingsEntity entity) =>
      _DeviceSettingsImpl(entity);
}

class _DeviceSettingsImpl implements IDeviceSettings {
  final DeviceSettingsEntity _entity;

  _DeviceSettingsImpl(this._entity);

  @override
  String get currentDeviceId => _entity.currentDeviceId;

  @override
  bool get syncEnabled => _entity.syncEnabled;

  @override
  List<String> get connectedDevices => _entity.connectedDevices;

  @override
  DateTime? get lastSyncTime => _entity.lastSyncTime;
}

/// Interface for premium-related settings only
/// Expõe apenas os getters relevantes de premium
abstract interface class IPremiumSettings {
  bool get hasPremiumFeatures;
  bool get isDevelopmentMode;
  bool get analyticsEnabled;

  factory IPremiumSettings.from(PremiumSettingsEntity entity) =>
      _PremiumSettingsImpl(entity);
}

class _PremiumSettingsImpl implements IPremiumSettings {
  final PremiumSettingsEntity _entity;

  _PremiumSettingsImpl(this._entity);

  @override
  bool get hasPremiumFeatures => _entity.hasPremiumFeatures;

  @override
  bool get isDevelopmentMode => _entity.isDevelopmentMode;

  @override
  bool get analyticsEnabled => _entity.analyticsEnabled;
}
