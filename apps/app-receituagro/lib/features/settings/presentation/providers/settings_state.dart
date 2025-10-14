import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

import '../../../../core/services/device_identity_service.dart';
import '../../domain/entities/user_settings_entity.dart';

part 'settings_state.freezed.dart';

/// Settings view states
enum SettingsViewState {
  initial,
  loading,
  loaded,
  error,
}

/// State imutável para gerenciamento de configurações
///
/// Migrado para @freezed para type-safety, imutabilidade e código gerado
@freezed
class SettingsState with _$SettingsState {
  const SettingsState._();

  const factory SettingsState({
    /// Configurações do usuário
    UserSettingsEntity? settings,

    /// Loading state
    @Default(false) bool isLoading,

    /// Mensagem de erro
    String? error,

    /// ID do usuário atual
    @Default('') String currentUserId,

    /// Se o usuário é premium
    @Default(false) bool isPremiumUser,

    /// Dispositivo atual
    DeviceEntity? currentDevice,

    /// Dispositivos conectados
    @Default([]) List<DeviceEntity> connectedDevices,
  }) = _SettingsState;

  /// Factory para estado inicial
  factory SettingsState.initial() => const SettingsState();

  // ========== Computed Properties ==========

  /// Tema escuro ativado (delega para settings)
  bool get isDarkTheme => settings?.isDarkTheme ?? false;

  /// Notificações ativadas (delega para settings)
  bool get notificationsEnabled => settings?.notificationsEnabled ?? true;

  /// Som ativado (delega para settings)
  bool get soundEnabled => settings?.soundEnabled ?? true;

  /// Idioma atual (delega para settings)
  String get language => settings?.language ?? 'pt-BR';

  /// Modo de desenvolvimento ativado (delega para settings)
  bool get isDevelopmentMode => settings?.isDevelopmentMode ?? false;

  /// Speech to text ativado (delega para settings)
  bool get speechToTextEnabled => settings?.speechToTextEnabled ?? false;

  /// Analytics ativado (delega para settings)
  bool get analyticsEnabled => settings?.analyticsEnabled ?? true;

  /// Se há configurações carregadas
  bool get hasSettings => settings != null;

  /// Verifica se há erro
  bool get hasError => error != null;

  /// Verifica se está carregando
  bool get isLoadingData => isLoading;

  /// Estado da view baseado nos dados
  SettingsViewState get viewState {
    if (isLoading) return SettingsViewState.loading;
    if (hasError) return SettingsViewState.error;
    if (hasSettings) return SettingsViewState.loaded;
    return SettingsViewState.initial;
  }

  /// Current device as DeviceInfo for UI compatibility
  DeviceInfo? get currentDeviceInfo =>
      currentDevice != null ? _convertToDeviceInfo(currentDevice!) : null;

  /// Connected devices as DeviceInfo list for UI compatibility
  List<DeviceInfo> get connectedDevicesInfo =>
      connectedDevices.map(_convertToDeviceInfo).toList();

  /// Converts DeviceEntity to DeviceInfo for UI compatibility
  DeviceInfo _convertToDeviceInfo(DeviceEntity entity) {
    return DeviceInfo(
      uuid: entity.uuid,
      name: entity.name,
      model: entity.model,
      platform: entity.platform,
      systemVersion: entity.systemVersion,
      appVersion: entity.appVersion,
      buildNumber: entity.buildNumber,
      identifier: entity.id,
      isPhysicalDevice: entity.isPhysicalDevice,
      manufacturer: entity.manufacturer,
      firstLoginAt: entity.firstLoginAt,
      lastActiveAt: entity.lastActiveAt,
      isActive: entity.isActive,
    );
  }
}

/// Extension para métodos de transformação do state
extension SettingsStateX on SettingsState {
  /// Limpa mensagem de erro
  SettingsState clearError() => copyWith(error: null);
}
