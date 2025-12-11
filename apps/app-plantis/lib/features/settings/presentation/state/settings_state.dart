import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/settings_entity.dart';

part 'settings_state.freezed.dart';

/// View states for settings feature
enum SettingsViewState { initial, loading, loaded, error }

/// State imutável para gerenciamento de configurações
///
/// Usa @freezed para type-safety, imutabilidade e código gerado
@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState({
    /// Configurações do usuário (composto por sub-entities)
    SettingsEntity? settings,

    /// Estado de loading
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// Última sincronização
    DateTime? lastSync,

    /// Sincronização em progresso
    @Default(false) bool isSyncing,

    /// Versão do app
    String? appVersion,

    /// Build number
    String? buildNumber,
  }) = _SettingsState;
}

/// Extension para computed properties e métodos de transformação do state
extension SettingsStateX on SettingsState {
  /// Factory para estado inicial
  static SettingsState initial() => const SettingsState();

  // ========== Computed Properties ==========

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se usuário está logado
  bool get isUserLoggedIn => settings?.account.isAnonymous == false;

  /// Verifica se backup está habilitado
  bool get isBackupEnabled =>
      settings?.backup.autoBackupEnabled == true && isUserLoggedIn;

  /// Verifica se notificações estão disponíveis
  bool get areNotificationsAvailable =>
      settings?.notifications.permissionsGranted == true &&
      settings?.notifications.taskRemindersEnabled == true;

  /// Estado da view baseado nos dados
  SettingsViewState get viewState {
    if (isLoading) return SettingsViewState.loading;
    if (hasError) return SettingsViewState.error;
    if (settings != null) return SettingsViewState.loaded;
    return SettingsViewState.initial;
  }

  /// Verifica se última sincronização foi recente (últimas 24h)
  bool get isLastSyncRecent {
    if (lastSync == null) return false;
    final difference = DateTime.now().difference(lastSync!);
    return difference.inHours < 24;
  }

  /// Tempo desde última sincronização
  String get lastSyncLabel {
    if (lastSync == null) return 'Nunca';

    final difference = DateTime.now().difference(lastSync!);

    if (difference.inMinutes < 1) return 'Agora mesmo';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m atrás';
    if (difference.inHours < 24) return '${difference.inHours}h atrás';
    if (difference.inDays < 7) return '${difference.inDays}d atrás';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem atrás';
    }

    return '${(difference.inDays / 30).floor()}m atrás';
  }

  /// Nome de exibição do idioma
  String get languageDisplayName {
    final language = settings?.app.language ?? 'pt_BR';
    switch (language) {
      case 'pt_BR':
        return 'Português (Brasil)';
      case 'en_US':
        return 'English (US)';
      case 'es_ES':
        return 'Español';
      default:
        return language;
    }
  }

  /// Versão completa do app
  String get fullVersion {
    if (appVersion == null) return 'Desconhecida';
    if (buildNumber == null) return appVersion!;
    return '$appVersion ($buildNumber)';
  }

  /// Verifica se configurações foram carregadas
  bool get hasSettings => settings != null;

  /// Tema escuro ativado
  bool get isDarkTheme => settings?.theme.isDarkMode ?? false;

  /// Tema claro ativado
  bool get isLightTheme => settings?.theme.isLightMode ?? false;

  /// Seguir tema do sistema
  bool get followSystemTheme => settings?.theme.followSystemTheme ?? true;

  /// Notificações ativadas
  bool get notificationsEnabled =>
      settings?.notifications.taskRemindersEnabled ?? true;

  /// Analytics ativado
  bool get analyticsEnabled => settings?.app.analyticsEnabled ?? true;

  /// Crash reports ativados
  bool get crashReportsEnabled => settings?.app.crashReportsEnabled ?? true;

  /// Email do usuário
  String? get userEmail => settings?.account.email;

  /// Nome do usuário
  String? get userName => settings?.account.displayName;

  /// URL da foto do usuário
  String? get userPhotoUrl => settings?.account.photoUrl;

  /// É conta anônima
  bool get isAnonymousAccount => settings?.account.isAnonymous ?? true;

  /// Tempo em minutos antes de lembrete
  int get reminderMinutesBefore =>
      settings?.notifications.reminderMinutesBefore ?? 60;

  /// Notificações diárias ativadas
  bool get dailySummaryEnabled =>
      settings?.notifications.dailySummaryEnabled ?? true;

  /// Horário do resumo diário
  String get dailySummaryTimeLabel {
    final time = settings?.notifications.dailySummaryTime;
    if (time == null) return '08:00';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Auto backup ativado
  bool get autoBackupEnabled => settings?.backup.autoBackupEnabled ?? true;

  /// Frequência de backup
  String get backupFrequencyLabel =>
      settings?.backup.frequency.displayName ?? 'Diário';

  /// Último backup
  String get lastBackupLabel {
    final lastBackup = settings?.backup.lastBackupTime;
    if (lastBackup == null) return 'Nunca';

    final difference = DateTime.now().difference(lastBackup);

    if (difference.inMinutes < 1) return 'Agora mesmo';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m atrás';
    if (difference.inHours < 24) return '${difference.inHours}h atrás';
    if (difference.inDays < 7) return '${difference.inDays}d atrás';

    return '${(difference.inDays / 7).floor()}sem atrás';
  }

  /// Limpa mensagem de erro
  SettingsState clearError() => copyWith(error: null);

  /// Reseta ao padrão
  SettingsState resetToDefaults() => SettingsStateX.initial().copyWith(
    settings: SettingsEntity.defaults(),
    appVersion: appVersion,
    buildNumber: buildNumber,
  );

  /// Atualiza configurações
  SettingsState updateSettings(SettingsEntity newSettings) =>
      copyWith(settings: newSettings);

  /// Atualiza tema
  SettingsState updateTheme(ThemeSettingsEntity newTheme) {
    if (settings == null) return this;
    return copyWith(settings: settings!.copyWith(theme: newTheme));
  }

  /// Atualiza notificações
  SettingsState updateNotifications(
    NotificationSettingsEntity newNotifications,
  ) {
    if (settings == null) return this;
    return copyWith(
      settings: settings!.copyWith(notifications: newNotifications),
    );
  }

  /// Atualiza backup
  SettingsState updateBackup(BackupSettingsEntity newBackup) {
    if (settings == null) return this;
    return copyWith(settings: settings!.copyWith(backup: newBackup));
  }

  /// Atualiza app settings
  SettingsState updateAppSettings(AppSettingsEntity newAppSettings) {
    if (settings == null) return this;
    return copyWith(settings: settings!.copyWith(app: newAppSettings));
  }

  /// Atualiza conta
  SettingsState updateAccount(AccountSettingsEntity newAccount) {
    if (settings == null) return this;
    return copyWith(settings: settings!.copyWith(account: newAccount));
  }
}
